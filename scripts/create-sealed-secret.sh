#!/usr/bin/env bash

if ! kubectl config current-context &>/dev/null; then
	echo -e "\e[31mNo context found. Please run: \e[32mkubectl config use-context <context-name>\e[0m"
	exit
else
	context=$(kubectl config current-context)
	echo -e "\e[32mContext: $context\e[0m"
fi

cmd=$(kubectl -n kube-system get pod -l app.kubernetes.io/instance=sealed-secrets --field-selector=status.phase=Running -o=jsonpath='{range .items[*]}{.status.phase}{"\n"}{end}')

if [ -z "$cmd" ]; then
	echo -e "\e[31mSealed Secrets controller is not running.e[0m"
	exit
fi

if ! command -v kubeseal &>/dev/null; then
	echo -e "\e[31mCommand kubeseal could not be found. Please install it with: \e[32mbrew install kubeseal\e[0m"
	exit
fi

if [ $# -lt 2 ]; then
	echo -e "\e[31mAt least 2 arguments must be passed\e[0m"
	echo -e "\e[1;32mUsage: bash $0 secret_name key1=value1 key2=value2 ...\e[0m"
	exit
fi

secret_name=$1
literals=("${@:2}")
prefix="--from-literal="
from_literals=""

function validate_literal {
	if [[ $1 != *"="* ]]; then
		echo -e "\e[31mLiteral $1 must have the format: key=value\e[0m"
		exit
	fi
}

for literal in "${literals[@]}"; do
	validate_literal "$literal"
	from_literals="$from_literals $prefix$literal"
done

# don't double quote $from_literals, otherwise it will be considered as a single string
kubectl create secret generic "$secret_name" --dry-run=client $from_literals -o yaml |
	kubeseal \
		--format yaml >"$secret_name".yaml

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "\e[32m$DIR/$secret_name.yaml created\e[0m"
