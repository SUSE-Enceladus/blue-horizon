#! /bin/sh
export KUBECONFIG=./aksk8scfg
kubectl annotate svc susecf-console-ui-ext -n stratos  "external-dns.alpha.kubernetes.io/hostname=stratos.${DOMAIN}"
