VENV=python_venv
ROLES_PATH=roles
TF_BINARY_URL=https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip
SCRATCH=tmp
BINPATH=bin

install-checkov:
	virtualenv -p $$(which python3) $(VENV)
	$(VENV)/bin/pip install -r requirements.txt
	mkdir -p $(ROLES_PATH)

install-terraform:
	mkdir -p $(SCRATCH) $(BINPATH)
	wget -P tmp/ $(TF_BINARY_URL)
	@$(eval TF_BASENAME=$(shell sh -c "basename $(TF_BINARY_URL)"))
	echo $(TF_BASENAME)
	unzip -p $(SCRATCH)/$(TF_BASENAME) terraform >./$(BINPATH)/terraform
	chmod +x bin/terraform

setup: install-checkov install-terraform
	@echo Enable the python virtual environment with:
	@echo "    source $(VENV)/bin/activate"
	@echo Add the binary directory to your path with:
	@echo "    export PATH=$$(pwd)/bin:\$$PATH"
