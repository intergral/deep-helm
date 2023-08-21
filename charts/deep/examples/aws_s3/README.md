# AWS S3

This example uses AWS S3 as the primary storage.

## Prerequisites

- S3 bucket
- IAM User with access to the bucket (see [AWS IAM Role](https://intergral.github.io/deep/deploy/aws/permissions/))

## Deployment

The first thing todo is to create the namespace you want to use:

```bash
kubectl create namespace deep
```

### Secret
For Deep to use the S3 bucket it needs to use the IAM role to access the bucket. To do this you need to create a secret
with the Access and Secret keys. This can be done with the file [00-config](./00-config.yaml) or with the command line (
ensure you replace the access key and secret).

```bash
AWS_ACCESS_KEY_ID=youtaccesskey
AWS_SECRET_ACCESS_KEY=yoursecretkey
NAMESPACE=deep
kubectl create secret generic aws-s3-cred --from-literal=AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} --from-literal=AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} -o yaml --dry-run=client --namespace ${NAMESPACE} | kubectl apply -f-
```

The command above will create the secret called 'aws-s3-cred' in the namespace 'deep'.

### Helm Chart
Once the config is in place you can install deep to use the S3 bucket using the provided values file.

```bash
helm repo add deep https://intergral.github.io/deep-helm/
helm install deep deep/deep -n deep -f values.yaml
```

# Files

 - [00-config.yaml](./00-config.yaml) - Example on how to set up kubernetes secret with aws credentials
 - [values.yuaml](./values.yaml) - Example values file to configure deep to use S3 as storage
