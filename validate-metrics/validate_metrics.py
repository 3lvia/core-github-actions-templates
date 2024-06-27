"""
This script checks if a promql query returns data. If the query returns no data, this script returns an error code. 

python3 ./validate_metrics.py --query 'kafka_consumergroup_lag_sum{origin_prometheus="runtimeaksclusterdev", consumergroup="private.dp.edna.examples-core.democonsumer-0"}==0'
"""
import argparse
import base64
from urllib import parse
import requests
from elvia_vault import VaultClient
import json
import os


class ValidationError(Exception):
    pass

def grafana_info():
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
    return (api_url, api_headers)


def handle_response_status(response, query):
    """Log errors to proceed checking dashboards. Collect errors."""
    # message = f"HTTP Status Code: {str(response.status_code)}, Response: {response.text}"
    # print(message)

    y = json.loads(response.text)

    if not response.ok:
        error_message = f"ERROR: HTTP Status Code: {str(response.status_code)}, Response: {response.text}, PromQL: {query}"
        print(error_message)
        raise ValidationError("ERROR. Check the logs.")


def run_prometheus_query(promql: str, step: str) -> bool:
    (api_url, api_headers) = grafana_info()
    url = parse.urljoin(api_url, "query")
    params = {"query": promql, "step": step}
    response = requests.get(url=url, headers=api_headers, params=params)

    handle_response_status(response, promql)

    response_json = json.loads(response.text)

    # print("response: ", response_json)

    result = response_json["data"]["result"]
    if result:
        return True
    return False


def main(args):
    print(f"Executing PromQL query to check for alerts. Args: {args}")
    promql = args.query
    print("promql: ", promql)
    success = run_prometheus_query(promql, args.step)
    if success:
        print("Query result exist.")
    else:
        error_message = f"Query result empty. Query: {promql}"
        print(error_message)
        raise ValidationError("Query result empty. Check the logs.")


def get_args_parser():
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--query", help="Promql query. Will raise error if the query returns emtpy result.")
    parser.add_argument("--step", help="maximum time interval to look for the last alert state in the past")
    return parser


def get_args():
    return get_args_parser().parse_known_args()[0]

if __name__ == "__main__":
    print("Starting validate_metrics.py")
    main(get_args_parser().parse_args())
