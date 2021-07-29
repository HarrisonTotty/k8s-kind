# Local Kubernetes Configuration

The following reository contains [kind](https://kind.sigs.k8s.io/)
configurations for creating a local development cluster.

## Cluster Features

* Runs locally entirely within docker containers.
* Contains 1 control plane "node" and 2 worker "nodes".
* Multiple clusters can pull from a shared, private docker registry also run in
  a local docker container.
* Provides a NGINX ingress controller bound to port 80 and 443.
