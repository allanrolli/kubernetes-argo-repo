# Kubernetes GitOps Repo

This is an example on how I would structure a 1:1 (repo-to-single cluster)
git repo for a Kubernetes cluster.

This example assumes single repo for a single cluster. However, this can be modified (quite
easily) for poly/mono repos or for multiple clusters. This is meant as
a good starting point and not what your final repo will look like.

# ArgoCD Concepts

## Application
Representa uma aplicação declarada no Git que será sincronizada e gerenciada pelo ArgoCD.

## ApplicationSet
Automatiza a criação de múltiplas Applications com base em um template, útil para múltiplos clusters, ambientes ou projetos.

## Project
Define um escopo lógico para agrupar Applications, controlando permissões, destinos e repositórios.

# Structure

Below is an explanation on how this repo is laid out. You'll notice
that I use [Kustomize](https://kustomize.io/) heavily. I do this since I
follow the [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)
principal when it comes to YAML files.

```shell
cluster-k8s-local
    ├── applications
    │   ├── echo
    │   │   ├── echo-deployment.yaml
    │   │   ├── echo-ns.yaml
    │   │   ├── echo-service.yaml
    │   │   └── kustomization.yaml
    │   └── echo2
    │       ├── echo-deployment.yaml
    │       ├── echo-ns.yaml
    │       ├── echo-service.yaml
    │       └── kustomization.yaml
    ├── bootstrap
    │   ├── base
    │   │   ├── argo-ns.yaml
    │   │   ├── kustomization.yaml
    │   │   └── values
    │   │       └── argocd-values.yaml
    │   └── overlays
    │       └── default
    │           └── kustomization.yaml
    ├── components
    │   ├── applicationsets
    │   │   ├── applications-appset.yaml
    │   │   ├── core-components-appset.yaml
    │   │   └── kustomization.yaml
    │   └── argocdproj
    │       ├── application-project.yaml
    │       ├── core-project.yaml
    │       └── kustomization.yaml
    └── core
        └── gitops-controller
            └── kustomization.yaml
```

# Testing

To see this in action, first get yourself a cluster (using [kind](kind.sigs.k8s.io/) as an example)

```shell
kind create cluster
```

Then, just apply this repo.

```shell
until k apply -k https://github.com/allanrolli/kubernetes-argo-repo/cluster-k8s-local/bootstrap/overlays/default; do sleep 3; done
```

This should give you 3 applications

```shell
$ kubectl get applications -n argocd
NAME                SYNC STATUS   HEALTH STATUS
echo                Synced        Healthy
echo2               Synced        Healthy
gitops-controller   Synced        Healthy
```

Backed by 2 applicationsets

```shell
$ kubectl get appsets -n argocd
NAME           AGE
applications   31m
cluster        31m
```

And with 2 app projects
```shell
$ kubectl get appprojects -n argocd
NAME                  AGE
application-project   31m
core-project          31m
default               31m
```



To see the Argo CD UI, you'll first need the password

```shell
kubectl get secret/argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d ; echo
```

Then port-forward to see it in your browser (using `admin` as the username).

```shell
kubectl -n argocd port-forward service/argocd-server 8080:443
```

---
## Author

👤 **Allan Rolli**

- Github: [@AllanRolli](https://github.com/allanrolli)
- LinkedIn: [@AllanRolli](https://www.linkedin.com/in/allan-rolli/)