![Deep Release](https://img.shields.io/github/v/release/intergral/deep-helm?filter=deep-1*)
![Deep Distributed](https://img.shields.io/github/v/release/intergral/deep-helm?filter=deep-d*)

# Deep Kubernetes Helm Charts

This project contains a collection of helm charts related to the running of Deep on a kubernetes cluster.

# Usage
Prerequisites:
 - [Helm](https://helm.sh/)
 - Kubernetes

Once helm is installed and configured, add the repo as follows:
```bash
helm repo add deep https://intergral.github.io/deep-helm/
```

You can then run `helm search repo deep` to see the charts.

# Docs
There are multiple charts in this repo, each is documented below:

 - [deep](https://intergral.github.io/deep-helm/deep/) - A Helm chart for running deep as a monolith
 - [deep-distributed](https://intergral.github.io/deep-helm/deep-distributed/) - A helm chart for deploying Deep in distributed mode.

# License

[Apache 2.0 License](./LICENSE)
