#!/bin/bash
# Author: Daniel Bowder
# Date: March 23, 2020 01:31 PST


# Variables
HOSTNAME="myspecial.service.example.com";                           # CRITICAL
ACME_EMAIL="admin@example.com";                                     # CRITICAL
CLOUDFLARE_EMAIL="cloudflare@example.com";                          # CRITICAL
CLOUDFLARE_API_TOKEN_VALUE="token-value-goes-here";                 # CRITICAL
NAMESPACE="nextcloud";                                              # CRITICAL
SERVICE_SELECTOR_APP="nextcloud-app";                               # CRITICAL

CLOUDFLARE_API_TOKEN_SECRET_NAME="cloudflare-api-token-secret";     # arbitrary
SERVICE_NAME="nextcloud-ports";                                     # arbitrary
INGRESS_NAME="nextcloud-http-ingress";                              # arbitrary
ISSUER_NAME="nextcloud-letsencrypt-issuer";                         # arbitrary
CERTIFICATE_NAME="nextcloud-cert";                                  # arbitrary
CERTIFICATE_SECRET_NAME="nextcloud-letsencrypt-tls-secret";         # arbitrary
ACME_ACCOUNT_SECRET_NAME="acme-account-secret";                     # arbitrary


# 1. Install cert-manager using helm
# helm repo add jetstack https://charts.jetstack.io;
# helm repo update;
#
# helm install \
#  cert-manager jetstack/cert-manager \
#  --namespace cert-manager \
#  --version v1.2.0 \
#  --create-namespace \
#  --set installCRDs=true


# 2. Create service pointing to container
echo "\
kind: Service
apiVersion: v1
metadata:
  name: ${SERVICE_NAME}
  namespace: ${NAMESPACE}
spec:
  selector:
    app: ${SERVICE_SELECTOR_APP}
  ports:
    - name: http
      port: 80
      targetPort: 80
" > service.yaml

# 3. Create an opaque secret containing the cloudflare api token
echo "\
apiVersion: v1
kind: Secret
metadata:
  name: ${CLOUDFLARE_API_TOKEN_SECRET_NAME}
  namespace: ${NAMESPACE}
type: Opaque
stringData:
  api-token: ${CLOUDFLARE_API_TOKEN_VALUE}
" > secret.yaml



# 4. Create a cert-manager issuer that can talk to letsencrypt
echo "\
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ${ISSUER_NAME}
  namespace: ${NAMESPACE}
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    # server: https://acme-v02.api.letsencrypt.org/directory
    email: ${ACME_EMAIL}
    privateKeySecretRef:
      name: ${ACME_ACCOUNT_SECRET_NAME}
    solvers:
    - dns01:
    # Note this pesky additional indent for cloudflare here,
    # this additional indent is necessary
        cloudflare:
          email: ${CLOUDFLARE_EMAIL}
          # Note this is an api TOKEN not an api KEY
          # The KEY is the global cloudflare api key,
          # The TOKEN is a manually created api token.
          # https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/
          # apiTokenSecretRef vs apiKeySecretRef
          apiTokenSecretRef:
            name: ${CLOUDFLARE_API_TOKEN_SECRET_NAME}
            key: api-token
" > issuer.yaml


# 5. Create a cert-manager certificate for your hostname
echo "\
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${CERTIFICATE_NAME}
  namespace: ${NAMESPACE}
spec:
  dnsNames:
    - ${HOSTNAME}
  secretName: ${CERTIFICATE_SECRET_NAME}
  issuerRef:
    name: ${ISSUER_NAME}
" > certificate.yaml


# 6. Create Ingress pointing to service
echo "\
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${INGRESS_NAME}
  namespace: ${NAMESPACE}
  annotations:
    kubernetes.io/ingress.class: traefik
    # redirect-entry-point and redirect-permanent help redirect to https
    traefik.ingress.kubernetes.io/redirect-entry-point: https
    traefik.ingress.kubernetes.io/redirect-permanent: \"true\"
    cert-manager.io/cluster-issuer: ${ISSUER_NAME}
spec:
  rules:
  - host: ${HOSTNAME}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ${SERVICE_NAME}
            port:
              name: http
  tls:
  - hosts:
      - ${HOSTNAME}
    secretName: ${CERTIFICATE_SECRET_NAME}
" > ingress.yaml


# 7. Apply the yaml files
# kubectl apply -f secret.yaml -f service.yaml -f issuer.yaml -f certificate.yaml -f ingress.yaml
