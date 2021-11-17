TOP_DIR   := $(shell git rev-parse --show-toplevel)
PROJECT   ?= dat-home-infra
ENV       ?= dev
REGION    ?= us-central1
INFRA_ENV := $(TOP_DIR)/infra/environments/$(ENV)

KEYRING   ?= sops-vault
SOPS_KEY  ?= sops-key

KEYRING_IN_TFSTATE = `terraform state list | grep google_kms_key_ring.${KEYRING}`
KEY_IN_TFSTATE     = `terraform state list | grep google_kms_crypto_key.${SOPS_KEY}`

KEYRING_EXISTS     = `gcloud kms keyrings list --location=${REGION} | grep ${KEYRING}`
KEY_EXISTS         = `gcloud kms keys list --location=${REGION} --keyring ${KEYRING} | grep ${SOPS_KEY}`

infra/init: hack/import-keyring hack/import-key
	cd $(INFRA_ENV) && terraform init -upgrade

infra/plan: infra/validate infra/init infra/refresh
	cd $(INFRA_ENV) && terraform plan

# Known issue in terraform. It doesn't destroy GCP KMS so we have to manually import
# keyring if previously created.
infra/apply: infra/validate hack/import-keyring hack/import-key infra/refresh
	cd $(INFRA_ENV) && terraform apply

infra/validate:
	cd $(INFRA_ENV) && terraform validate

infra/destroy: hack/remove-key-from-tfstate hack/remove-keyring-from-tfstate
	cd $(INFRA_ENV) && terraform destroy

infra/refresh:
	cd $(INFRA_ENV) && terraform refresh

infra/list:
	cd $(INFRA_ENV) && terraform state list

# -z : is empty
# -n : is not empty
hack/import-keyring: # Check if key-ring if needed
	cd $(INFRA_ENV) && if [[ -z $(KEYRING_IN_TFSTATE) ]] && [[ -n $(KEYRING_EXISTS) ]]; then \
		terraform import google_kms_key_ring.${KEYRING} "${PROJECT}/${REGION}/${KEYRING}"; \
	fi

hack/import-key: # Check if key is imported
	cd $(INFRA_ENV) && if [[ -z $(KEY_IN_TFSTATE) ]] && [[ -n $(KEY_EXISTS) ]]; then \
		terraform import google_kms_crypto_key.${SOPS_KEY} ${REGION}/${KEYRING}/${SOPS_KEY}; \
	fi

hack/remove-key-from-tfstate:
	cd $(INFRA_ENV) && if [[ -n $(KEY_IN_TFSTATE) ]]; then \
		terraform state rm google_kms_crypto_key.${SOPS_KEY} ; \
	fi

hack/remove-keyring-from-tfstate:
	cd $(INFRA_ENV) && if [[ -n $(KEYRING_IN_TFSTATE) ]]; then \
		terraform state rm google_kms_key_ring.${KEYRING} ; \
	fi

kube-ctl/switch-context:
	gcloud container clusters get-credentials testbed --region=${REGION}

# print-%: ; @echo $*=$($*)
