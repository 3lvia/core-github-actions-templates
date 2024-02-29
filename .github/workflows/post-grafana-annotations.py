"""
This script posts annotations to Grafana

python3 ./post-grafana-annotations.py --json_params '{ tag1: "value1" }'
"""

import argparse
import yaml
import json
import urllib
import requests

from elvia_vault import VaultClient

def post_annotations(event):
    vault = VaultClient()
    base_url = vault.get_value("monitoring/kv/shared/grafana_api_url")
    grafana_secret = vault.get_value("monitoring/kv/shared/grafana_editor_api_key")
    headers = {"Accept": "application/json", "Content-Type": "application/json; charset=utf-8", "Authorization": "Bearer " + grafana_secret}
    path = "annotations/graphite"
    json_data = json.dumps(event)
    url = urllib.parse.urljoin(base_url, path)
    response = requests.post(url=url, headers=headers, data=json_data, timeout=10, verify=True)
    response.raise_for_status()  # Break on error


def main(args):
    print(f"Executing script to post Grafana annotations. Args: {args}")
    if not args.tags:
        raise ValueError("tags parameter missing")
    if not args.what:
        raise ValueError("what parameter missing")
    if not args.data:
        raise ValueError("data parameter missing")

    # this json lacks double quotes, but yaml parsing handles it.
    tags_dict = yaml.safe_load(args.tags.strip()) 

    # transform tags to "key:value" pairs
    tags = []
    for key in tags_dict:
        tags.append(f"{key}:{tags_dict[key].lower().strip()}")
    
    event = {
        "what": args.what.strip(),
        "data": args.data.strip(),
        "tags": tags
    }

    post_annotations(event)


def get_args_parser():
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--tags", help="Json formatted key-value object: { myVar1: system/kv/path1, myVar2: system/kv/path2 }")
    parser.add_argument("--what", help="Text describing the annotation header.")
    parser.add_argument("--data", help="Text describing the annotation value.")
    return parser

if __name__ == "__main__":
    main(get_args_parser().parse_args())