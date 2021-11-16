TOP_DIR   := $(shell git rev-parse --show-toplevel)
PROJECT   ?= dat-home-infra
ENV       ?= dev
REGION    ?= us-central1
INFRA_ENV := $(TOP_DIR)/infra/environments/$(ENV)

infra/init: hack/import-key-ring hack/import-key
	cd $(INFRA_ENV) && terraform init -upgrade

infra/plan: infra/init
	cd $(INFRA_ENV) && terraform plan

# TODO add validation step
infra/apply: hack/import-key-ring hack/import-key infra/refresh
	cd $(INFRA_ENV) && terraform apply

infra/destroy: hack/remove-key
	cd $(INFRA_ENV) && terraform destroy

infra/refresh:
	cd $(INFRA_ENV) && terraform refresh

infra/list:
	cd $(INFRA_ENV) && terraform state list

infra/show-state:
	cd $(INFRA_ENV) && \
	terraform state show -state=./terraform.tfstate google_kms_key_ring.sops-vault

hack/import-key-ring: # Check if key-ring is imported
	cd $(INFRA_ENV) && \
	(terraform state list | grep google_kms_key_ring.sops-vault) || \
	terraform import google_kms_key_ring.sops-vault "${PROJECT}/${REGION}/sops-vault"

hack/import-key: # Check if key is imported
	cd $(INFRA_ENV) && \
	(terraform state list | grep google_kms_crypto_key.sops) || \
	terraform import google_kms_crypto_key.sops "${PROJECT}/${REGION}/sops-vault/sops"

hack/remove-key:
	cd $(INFRA_ENV) && \
	(terraform state list | grep google_kms_crypto_key.sops) || false; \
	terraform state rm google_kms_crypto_key.sops

kube-ctl/switch-context:
	gcloud container clusters get-credentials testbed --region=us-central1-c
