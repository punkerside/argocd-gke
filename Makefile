export project=cloudfly-01
export name=argocd-demo
export region=us-central1
export version=$(shell cat app/app.go | grep version | cut -d'"' -f8)

export DOCKER_BUILDKIT=0
export dockerhubUser=punkerside

init:
	@cd terraform/ && terraform init

apply:
	@cd terraform/ && terraform apply -var="project=${project}" -var="name=${name}" -var="region=${region}"
	@gcloud container clusters get-credentials ${name} --region ${region} --project ${project}

destroy:
	@cd terraform/ && terraform destroy -var="project=${project}" -var="name=${name}" -var="region=${region}"

argocd:
	@kubectl create namespace argocd
	@kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
	@echo "\n esperando creacion del balanceador" && sleep 20s
	@make initial

# getting argocd startup credentials
initial:
	@echo "\n username: admin \n password: $(shell kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) \n dns_name: $(shell kubectl get service argocd-server -n argocd --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')\n"

gitops:
	kubectl apply -f gitops.yaml

release:
	@echo "${dockerhubPass}" | docker login --username "${dockerhubUser}" --password-stdin
	docker build -t ${dockerhubUser}/${project}:${version} .
	docker push ${dockerhubUser}/${project}:${version}