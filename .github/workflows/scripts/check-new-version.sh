#!/bin/bash

set -e

diff_output=$(git diff charts/bindplane/Chart.yaml)

if echo "$diff_output" | grep "^+version:" > /dev/null; then
    echo "Version bump detected. Proceeding with release"
else
    echo "ERROR: The version of the chart has not been incremented. Release cancelled."
    exit 1
fi
