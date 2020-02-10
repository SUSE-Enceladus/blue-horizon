#!/bin/sh
export KUBECONFIG=./aksk8scfg

# Create the namespace for cert-manager
kubectl create namespace cert-manager

# Label the cert-manager namespace to disable resource validation
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# Install the CustomResourceDefinition resources separately
kubectl apply -f ./jetstack-cert-manager-0.8-deploy-manifest-00-crds.yaml
