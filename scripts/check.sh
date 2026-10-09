#!/usr/bin/env bash
# Checks of the onicost-agent chart, run by the ci and release workflows: lint, rendering and schema refusals.
set -euo pipefail

chart=charts/onicost-agent
endpoint=(--set endpoint=https://ingest.example.test)

helm lint "$chart" --strict
helm template onicost-agent "$chart" "${endpoint[@]}" > /dev/null

if helm template onicost-agent "$chart" "${endpoint[@]}" --set unknown=1 > /dev/null; then
  echo 'schema did not refuse an unknown key' >&2
  exit 1
fi
if helm template onicost-agent "$chart" --set endpoint=ingest.example.test > /dev/null; then
  echo 'schema did not refuse an endpoint without an http(s) scheme' >&2
  exit 1
fi
if helm template onicost-agent "$chart" "${endpoint[@]}" --set proxy.url=socks5://proxy:1080 > /dev/null; then
  echo 'schema did not refuse a proxy URL without an http(s) scheme' >&2
  exit 1
fi
