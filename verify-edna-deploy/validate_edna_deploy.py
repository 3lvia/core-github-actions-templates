"""
This script checks if a deploy is successful by checking if a certain metric has been updated
after the deployment happened

python3 ./validate_deploy.py --topic "dp.examples" --env "dev"
"""
import argparse
import base64
from urllib import parse
import requests
from elvia_vault import VaultClient
import json
import time


class ValidationError(Exception):
    pass


vault = VaultClient()
api_base_url = vault.get_value(
    "monitoring/kv/shared/grafana_prometheus_api_url")
api_username = vault.get_value(
    "monitoring/kv/shared/grafana_prometheus_api_username")
api_token = vault.get_value("monitoring/kv/shared/grafana_prometheus_api_key")
api_url = parse.urljoin(api_base_url, "/api/prom/api/v1/")


BASIC_AUTH_HEADER = base64.encodebytes(
    f"{api_username}:{api_token}".encode("utf-8")).decode("utf-8").replace("\n", "")
api_headers = {"Accept": "application/json", "Content-Type": "application/json",
               "Authorization": "Basic " + BASIC_AUTH_HEADER}


def handle_response_status(response, query):
    """Log errors to proceed checking dashboards. Collect errors."""
    # message = f"HTTP Status Code: {str(response.status_code)}, Response: {response.text}"
    # print(message)

    y = json.loads(response.text)

    if not response.ok:
        error_message = f"ERROR: HTTP Status Code: {str(response.status_code)}, Response: {response.text}, PromQL: {query}"
        print(error_message)
        raise ValidationError("ERROR. Check the logs.")


def run_prometheus_query(promql: str, secondsSinceDeploy: float) -> bool:
    url = parse.urljoin(api_url, "query")
    params = {"query": promql}
    response = requests.get(url=url, headers=api_headers, params=params)

    handle_response_status(response, promql)

    y = json.loads(response.text)

    # print(y["data"])

    # print("value: " + str(y["data"]["result"][0]["value"][1]))
    # print("time(): " + str(time.time()))

    if not y["data"] or not y["data"]["result"]:
        return False

    lastMetricTimestamp = float(y["data"]["result"][0]["value"][1])
    secondsSinceLastMetric = time.time() - lastMetricTimestamp
    print(str(secondsSinceLastMetric) + " seconds since last metric")
    if secondsSinceLastMetric < secondsSinceDeploy:
        # print("Metric seen after deploy. Success.")
        return True
    else:
        # print("Metric not yet seen after deploy. Not success.")
        return False


def main(args):
    print(f"Executing PromQL query to check if metric exists. Args: {args}")
    if not args.env:
        raise ValueError("env missing")
    if not args.topic:
        raise ValueError("topic missing")

    cluster = "runtimeakscluster" + args.env 
    if args.type == "publisher":
        promql = "max_over_time(timestamp(sum(edna_published_messages_total{topic=\"" + args.topic + "\", origin_prometheus=\"" + cluster + "\", success=\"true\"}>0) by (topic))[1h:]) >= max_over_time(timestamp(sum(edna_published_fake_messages_total{topic=\"" + args.topic + "\", origin_prometheus=\"" + cluster + "\", success=\"true\"}>0) by (topic))[1h:]) or max_over_time(timestamp(sum(edna_published_fake_messages_total{topic=\"" + args.topic + "\", origin_prometheus=\"" + cluster + "\", success=\"true\"}>0) by (topic))[1h:])"
    elif args.type == "consumer":
        if not args.system:
            raise ValueError("system missing")
        if not args.application:
            raise ValueError("application missing")
        consumer_group_id = args.topic + "-" + args.system + "." + args.application
        promql = "max_over_time(timestamp(sum(edna_consumed_messages_total{consumerGroupId=\"" + consumer_group_id + "\", origin_prometheus=\"" + cluster + "\", success=\"true\"}>0) by (consumerGroupId))[1h:]) >= max_over_time(timestamp(sum(edna_consumed_fake_messages_total{consumerGroupId=\"" + consumer_group_id + "\", origin_prometheus=\"" + cluster + "\", success=\"true\"}>0) by (consumerGroupId))[1h:]) or max_over_time(timestamp(sum(edna_consumed_fake_messages_total{consumerGroupId=\"" + consumer_group_id + "\", origin_prometheus=\"" + cluster + "\", success=\"true\"}>0) by (consumerGroupId))[1h:])"
    else:
        raise ValueError("type must be publisher or consumer")

    print(promql)

    success = False
    deployTime = time.time()
    secondsSinceDeploy = 10
    time.sleep(secondsSinceDeploy)
    for i in range(30):
        secondsSinceDeploy = time.time() - deployTime
        success = run_prometheus_query(promql, secondsSinceDeploy)
        if success:
            break
        sleepInterval = 10
        print(f"Metric not yet found. Sleeping {sleepInterval} seconds.")
        time.sleep(sleepInterval)

    if success:
        print("Metric exists. Deploy successful!")
    else:
        error_message = f"METRIC_NOT_FOUND: The metric has not been seen in prometheus since deployment. Query: {promql}"
        print(error_message)
        raise ValidationError("METRIC_NOT_FOUND. Check the logs.")


def get_args_parser():
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--env", help="environment")
    parser.add_argument("--topic", help="topic name")
    parser.add_argument("--system", help="system")
    parser.add_argument("--application", help="application name")
    parser.add_argument("--type", help="publisher or consumer")
    return parser


def get_args():
    return get_args_parser().parse_known_args()[0]


if __name__ == "__main__":
    main(get_args_parser().parse_args())