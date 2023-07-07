#!/usr/bin/env bash

# set -euo pipefail

# Get the script's directory after resolving a possible symlink.
# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

SCRIPT_DIR=$DIR

echo "SCRIPT_DIR: $SCRIPT_DIR"

# Run npm script to get coverage.
if [ $USE_YARN = true ]
then
    echo "Using yarn"
    npm run $COVERAGE_NPM_SCRIPT
else
    echo "Using npm"
    yarn run $COVERAGE_NPM_SCRIPT
fi

# Extract total coverage: the decimal number from the last line of the function report.
COVERAGE=$(jq $JSON_COVERAGE_VAR $JSON_COVERAGE_FILE)

echo "coverage: $COVERAGE% of statements"

date "+%s,$COVERAGE" >> "$SCRIPT_DIR/coverage.log"

# Pick a color for the badge.
if awk "BEGIN {exit !($COVERAGE >= 90)}"; then
	COLOR=brightgreen
elif awk "BEGIN {exit !($COVERAGE >= 80)}"; then
	COLOR=green
elif awk "BEGIN {exit !($COVERAGE >= 70)}"; then
	COLOR=yellowgreen
elif awk "BEGIN {exit !($COVERAGE >= 60)}"; then
	COLOR=yellow
elif awk "BEGIN {exit !($COVERAGE >= 50)}"; then
	COLOR=orange
else
	COLOR=red
fi

# Download the badge; store next to script.
curl -s "https://img.shields.io/badge/coverage-$COVERAGE%25-$COLOR" > "$SCRIPT_DIR/coverage.svg"