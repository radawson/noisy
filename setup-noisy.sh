#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
git clone https://github.com/1tayH/noisy.git && cd noisy
readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
curl -sSL "http://s3.amazonaws.com/alexa-static/top-1m.csv.zip" | tar xvfz - -C ${__dir}
python - <<EOF
import json
import csv
import os

config_file = 'config.json'
top_1m = "top-1m.csv"

with open(config_file) as f:
    config = json.load(f)

with open(top_1m) as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    for row in csv_reader:
        config["root_urls"].append("https://{}".format(row[-1]))
try:
    os.remove(top_1m)
except OSError:
    pass
config["max_depth"] = 15
config["min_sleep"] = 1
config["max_sleep"] = 3

with open(config_file, 'w') as json_file:
    json.dump(config, json_file)
EOF
echo "[*] updated max_depth -> 15 | min_sleep -> 1 | max_sleep -> 3"
echo "[*] Alexa top 1 million site added to noisy root urls"
echo "python noisy.py --help"
echo "[*] example: python noisy.py --config config.json"
