#!/bin/bash
echo "Building filters..."
echo "["
mkdir -p out
for filter in lib/*.jq; do
  echo "  ${filter}" >&2
  echo "## ${filter}"
  echo
  cat "${filter}"
  echo
  echo
done > out/jqtui.jq
echo "] > out/jqtui.jq"
echo "Done!"