#!/usr/bin/env bash
#
set -eu

lockfile_tmpl='
{
	"name": "%s",
	"version": "1.0.0",
	"lockfileVersion": 1
}
'

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

deps_json="$(printf '%s\n' ${deps[@]} | jq -R '. | {(.[indices("/")[0]+1:]): {"from": "git+https://\(.)", "version": "git+https://\(.)#main"}}' | jq -s 'reduce .[] as $item ({}; . * $item)')"
printf "$lockfile_tmpl" "$modname" | jq --argjson deps "$deps_json" '. | .dependencies = $deps' > package-lock.json

printf "Your dependencies have been updated in package-lock.json\n" >&2
