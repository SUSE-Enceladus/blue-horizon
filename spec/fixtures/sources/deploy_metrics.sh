#! /bin/sh
export KUBECONFIG=./aksk8scfg
APISRV="$(kubectl cluster-info| head -n 1|grep -o ' at .*$'| cut -f3 -d' '| cut -f3 -d'/'|cut -f1 -d':')"
cat $METRICS_FILE $SCF_FILE > ./capConfigurationFile.yaml
sed -i "s/MASTER_URL/https:\/\/$APISRV/g"  ./capConfigurationFile.yaml
helm install suse/metrics     --name susecf-metrics     --namespace metrics    --values ./capConfigurationFile.yaml
