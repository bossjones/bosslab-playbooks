#!/usr/bin/env bash
set -e
set -o pipefail

# SOURCE: https://github.com/Uninett/helm-charts/blob/febce64a71f03af7f3b010f38b8d7fb7c32f59a3/lint-chart.sh

echo "Linting $1..."
# echo "Running Helm lint..."
# helm lint --strict $1 | grep -vE "linted|Lint"
helm template $1 > deployment.yaml
echo "Running kubeval lint..."
kubeval --strict <deployment.yaml | (grep -v " valid" || true)
echo "Running kubetest lint..."
kubetest --verbose <deployment.yaml | (grep -v "info" || true)
echo "Yay, no errors when linting $1"
