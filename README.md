# GitOps - Creating deployment pipelines with ArgoCD for Google GKE

[![GitHub Tag](https://img.shields.io/github/tag-date/punkerside/argocd-gke.svg?style=plastic)](https://github.com/punkerside/argocd-gke/tags/)

## **Prerequisites**

* [Install Terraform](https://www.terraform.io/downloads.html)
* [Install gcloud CLI](https://cloud.google.com/sdk/docs/install?hl=es-419)
* [Install Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

## **Uso**

1. Crear cluster y nodes

```bash
make init
make apply
```

2. Instalar ArgoCD

```bash
make argocd
```

3. Inscribir aplicaciones en ArgoCD

```bash
make gitops
```

4. Liberar nueva version de imagen en DockerHub

```bash
export dockerhubPass=myPass
export dockerhubUser=myUser
make release
```

## **Pruebas**

1. Pruebas contra la API:

```bash
curl -XPOST http://${ipLoadBalancer}/music/post?name=oasis
curl -XGET http://${ipLoadBalancer}/music/get
```

## **Author**

The demo is maintained by [Ivan Echegaray](https://github.com/punkerside)