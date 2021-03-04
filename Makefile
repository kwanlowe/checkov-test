VENV=python_venv
ROLES_PATH=roles
TF_BINARY_URL=https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip
SCRATCH=tmp
BINPATH=bin
TFDIR=tf/gcp
PRIVKEY=/home/kwan/.ssh/google_compute_engine

install-ansible:
	virtualenv -p $$(which python3) $(VENV)
	$(VENV)/bin/pip install -r requirements.txt
	mkdir -p $(ROLES_PATH)
	# $(VENV)/bin/ansible-galaxy install --roles-path $(ROLES_PATH) geerlingguy.docker

install-terraform:
	mkdir -p $(SCRATCH) $(BINPATH)
	wget -P tmp/ $(TF_BINARY_URL)
	@$(eval TF_BASENAME=$(shell sh -c "basename $(TF_BINARY_URL)"))
	echo $(TF_BASENAME)
	unzip -p $(SCRATCH)/$(TF_BASENAME) terraform >./$(BINPATH)/terraform
	chmod +x bin/terraform
	pwd

generate-inventory:
	@gcloud compute instances list|awk 'BEGIN{print"[workers]\n"} NR>1 && /worker/{printf "%s ansible_ssh_private_key_file=$(PRIVKEY)\n", $$5}'
	@gcloud compute instances list|awk 'BEGIN{print"[jumpoff]\n"} NR>1 && /bastion/{printf "%s ansible_ssh_private_key_file=$(PRIVKEY)\n", $$5}'

setup: install-ansible install-terraform
	@echo Enable the python virtual environment with:
	@echo "    source $(VENV)/bin/activate"
	@echo Add the binary directory to your path with:
	@echo "    export PATH=$$(pwd)/bin:\$$PATH"

run-test:
	checkov -d $(TFDIR)

deploy-gcp-single-node:
	@ $(eval CLIENT_EXTERNAL_IP=$(shell sh -c "curl ifconfig.me 2>/dev/null"))
	@echo $(CLIENT_EXTERNAL_IP)/32
	cd tf/gcp && terraform init && terraform apply -var="client_external_ip=$(CLIENT_EXTERNAL_IP)/32"

destroy-gcp-single-node:
	cd tf/gcp && terraform destroy

deploy-gcp-kubespray:
	@ $(eval CLIENT_EXTERNAL_IP=$(shell sh -c "curl ifconfig.me 2>/dev/null"))
	@echo $(CLIENT_EXTERNAL_IP)/32
	cd tf/workers && terraform init && terraform apply -var="client_external_ip=$(CLIENT_EXTERNAL_IP)/32"

generate-private-key:
	mkdir -p keys
	test ! -f playbooks/keys/jumpoff && ssh-keygen -b 4096 -t rsa -f playbooks/keys/jumpoff 

setup-jumpoff-host:
	@ $(eval GCLOUD_REMOTE_USER=$(shell sh -c 'gcloud compute ssh vm-bastion-001 --command "whoami"' )) 
	@echo $(GCLOUD_REMOTE_USER)
	ansible-playbook playbooks/setup-hosts.yml -C -i inventory/hosts -e "gcloud_remote_user=$(GCLOUD_REMOTE_USER)"
