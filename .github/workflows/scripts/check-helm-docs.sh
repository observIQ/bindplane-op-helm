#!/bin/bash

set -e

if ! git diff --exit-code --quiet '../../charts/bindplane/README.md'; then
    echo "ERROR: Uncommitted helm doc changes detected. Please commit your changes before running this script."
    exit 1
fi
