#! /bin/sh
export KUBECONFIG=./aksk8scfg
kubectl create secret generic -n cert-manager azuredns-config --from-literal=CLIENT_SECRET=${AZ_CERT_MGR_SP_PWD}
kubectl apply -f le-cert-issuer.yaml
