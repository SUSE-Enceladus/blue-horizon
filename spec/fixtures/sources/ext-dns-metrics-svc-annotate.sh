#! /bin/sh
export KUBECONFIG=./aksk8scfg
kubectl annotate svc susecf-metrics-metrics-nginx -n metrics  "external-dns.alpha.kubernetes.io/hostname=metrics.${DOMAIN}"
