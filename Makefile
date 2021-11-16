include ./infra/Makefile
include .env
export

setup:     infra/init infra/apply kubectl/switch-context flux/bootstrap
uninstall: infra/destroy

flux/bootstrap:
	flux bootstrap github \
	--owner=${GITHUB_USER} \
	--repository=${GITHUB_REPO} \
	--path=clusters/testbed \
	--personal --watch-all-namespaces

flux/uninstall:
	flux uninstall

kubectl/switch-context:
	gcloud container clusters get-credentials testbed --region=us-central1
