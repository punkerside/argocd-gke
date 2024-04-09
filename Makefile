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

build:
	echo "${dockerhubPass}" | docker login --username "${dockerhubUser}" --password-stdin
	docker build -t ${dockerhubUser}/${project}:${version} .
	docker push ${dockerhubUser}/${project}:${version}