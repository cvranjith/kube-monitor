#!/bin/bash

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found. Please make sure it is installed and in your PATH."
    exit
fi

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please make sure it is installed and in your PATH."
    exit
fi

# Check if argument is provided
if [[ $# -eq 0 ]]; then
  echo "Please provide namespace(s) as argument(s) or use 'all' to print all namespaces."
  exit
elif [[ "$1" == "all" ]]; then
  all_namespaces=$(kubectl get namespaces -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null)
  namespaces="$all_namespaces"
elif [[ "$1" == "odt" ]]; then
  namespaces="fcubs obpm elcm obtr obtf obcl"
elif [[ "$1" == "obma" ]]; then
  namespaces="config plato apshell saml cmc obbrn oflo mocore obpy javaic obtfpm obx"
else
  namespaces="$@"
fi

l_tmp=$(mktemp)

namespace_regex=$(echo $namespaces | sed 's/ /|^/g; s/^/^/')
kubectl get pods -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase,RESTARTS:.status.containerStatuses[].restartCount 2>/dev/null |grep -E $namespace_regex > $l_tmp
kubectl get svc -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name 2>/dev/null |grep -E $namespace_regex > $l_tmp.svc
#cat $l_tmp

# Loop through each namespace argument
printf "\033[0;36m%-20s\033[0m\t\033[0;36m%-10s\033[0m\t\033[0;36m%-10s\033[0m\t\033[0;36m%-10s\033[0m\t\033[0;36m%-10s\033[0m\t\033[0;36m%-10s\033[0m\n" "Namespace" "Services" "Pods" "Restarts" "Unhealthy" "Pending"


for namespace in $namespaces
do
  num_pods=$(cat $l_tmp | grep '^'$namespace | wc -l)
  unhealthy=$(cat $l_tmp | grep '^'$namespace | grep -v 'Running\|Completed\|Pending' | wc -l)
  pending=$(cat $l_tmp | grep '^'$namespace | grep 'Pending' | wc -l)
  num_services=$(cat $l_tmp.svc | grep '^'$namespace | wc -l)
  restarts=$(cat $l_tmp |grep '^'$namespace | grep -v 'Pending' | awk '$4 >0' | wc -l)

  if [[ $unhealthy -eq 0 ]] && [[ $restarts -eq 0 ]] && [[ $pending -eq 0 ]] ; then
    printf "\033[0;42m\033[1;37m%-20s\033[0m\t%-10d\t%-10d\t%-10d\t%-10d\t%-10d\n" "$namespace" "$num_services" "$num_pods" "$restarts" "$unhealthy" "$pending"
  else
    printf "\033[0;41m\033[1;37m%-20s\033[0m\t%-10d\t%-10d\t" "$namespace" "$num_services" "$num_pods"
    if [[ $restarts -gt 0 ]]; then
      printf "\033[0;31m%-10d\033[0m\t" "$restarts"
    else
      printf "%-10d\t" "$restarts"
    fi
    if [[ $unhealthy -gt 0 ]]; then
      printf "\033[0;31m%-10d\033[0m\t" "$unhealthy"
    else
      printf "%-10d\t" "$unhealthy"
    fi
    if [[ $pending -gt 0 ]]; then
      printf "\033[0;31m%-10d\033[0m\n" "$pending"
    else
      printf "%-10d\n" "$pending"
    fi
  fi

done

rm -f $l_tmp $l_tmp.svc

