# LetsEncrypt some Traefik
Helper scripts for the setup of LetsEncrypt https certificates for a Traefik reverse proxy on Kubernetes.


## Description:

To get letsencrypt certificates for services hosted in Kubernetes using cert-manager and traefik, the following Kubernetes objects are needed:

*  **Service**, **Secret**, **Issuer**, **Certificate**, **Ingress**

This script will generate a yaml file for each one of these objects.

The variables at the beginning of this script are labeled as CRITICAL or as arbitrary.

* **CRITICAL**
  * Unique values to a specific account or configuration. eg: My account with cloudflare has a different email than yours, therefore the variable holding my email is CRITICAL.
* **arbitrary**
  * Unique values that have no major consequences as to what value they hold. These arbitrary values only need to be unique.

**NOTE**: In step 1, the helm installation of cert-manager is commented out, If you wish to install cert-manager, uncomment the helm commands.

## Variables:

**HOSTNAME** is the FQDN of the service to issue a certificate.

**ACME_EMAIL** is the email that lets encrypt will keep on file for this issuance.

**CLOUDFLARE_EMAIL** contains your email address for cloudflare

**CLOUDFLARE_API_TOKEN_VALUE** contains your api token obtained from cloudflare.

> **NOTE**: The API TOKEN is NOT the API KEY (See notes in issuer.yaml)

**CLOUDFLARE_API_TOKEN_SECRET_NAME** is an arbitrary name of the k8s secret.

**NAMESPACE** is the namespace of all of these k8s objects.

**SERVICE_SELECTOR_APP** is the application name that triggers your service.

> **NOTE**: If you modify the Service k8s object, you may not need SERVICE_SELECTOR_APP.

**SERVICE_NAME** is the arbitrary name of your k8s service.

**INGRESS_NAME** is the arbitrary name of your k8s ingress.

**ISSUER_NAME** is the arbitrary name of your k8s cert-manager issuer.

**CERTIFICATE_NAME** is the arbitrary name of your k8s cert-manager certificate.

**CERTIFICATE_SECRET_NAME** is the arbitrary name of your k8s tls secret.

**ACME_ACCOUNT_SECRET_NAME** is the arbitrary name of your k8s cert-manager acme secret.
