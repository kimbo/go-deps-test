#!/usr/bin/env bash
#
set -eu

printf "Running 'npm init -y' " >&2
npm init -y > /dev/null
printf "done\n" >&2

modname=$(go list -m)
deps=()

printf "Running 'go list -deps ./...' " >&2
for dep in $(go list -deps ./...); do
	if [[ "$dep" =~ ^github.com/.* ]] && [[ ! "$dep" = "$modname" ]]; then
		deps+=("$dep")
	fi
done
printf "done\n" >&2

deps_json="$(printf '%s\n' ${deps[@]} | jq -R '. | {(.[indices("/")[0]+1:]): "git+https://\(.)"}' | jq -s 'reduce .[] as $item ({}; . * $item)')"
jq --argjson deps "$deps_json" '. | .dependencies = $deps' package.json > package.tmp.json
mv package.tmp.json package.json

printf "Your dependencies have been updated in package.json\n" >&2
