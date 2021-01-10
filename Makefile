VERSION?="v0.1.0"
CIVO_CMD?=civo
CIVO_TEST_CLUSTER_NAME?=app-test
CIVO_KUBECONFIG?=kubeconfig.$(CIVO_TEST_CLUSTER_NAME)
KUBECTL?=kubectl --kubeconfig=$(CIVO_KUBECONFIG)
DOCKER_REPO=quay.io/ssmiller25
currentepoch := $(shell date +%s)

.PHONY: build
build: app.yaml

app.yaml:
# Whatever commands are needed to build the app.yaml.  Kustomize example below
	@kustomize build https://gitlab.com/ssmiller25/r15cookieblog.git//?ref=main > app.yaml

	# Test final app.yaml for validity
	@echo "Testing validity of app.yaml"
	@$(KUBECTL) apply -f app.yaml --dry-run=client > /dev/null
	@echo "Clean app.yaml generated"

.PHONY: clean
clean:
	@rm app.yaml

.PHONY: test
test: $(CIVO_KUBECONFIG) test-noclean cluster-clean

.PHONY: test-keep
test-keep: $(CIVO_KUBECONFIG) test-noclean

.PHONY: test-noclean
test-noclean:
	@echo "Applying manifest and test run"
	@$(KUBECTL) apply -f app.yaml
	@$(KUBECTL) create -f test-manifests/testjob.yaml  
	@sleep 10
	@echo "Checking status of test run"
	@$(KUBECTL) get job testjob -n r15cookieblog -ojson | jq -r .status.conditions[0].type | grep -q Complete
	@echo "Success!"

.PHONY: cluster-clean
cluster-clean:
	@echo "Tearing down test cluster!"
	@$(CIVO_CMD) k3s remove -y $(CIVO_TEST_CLUSTER_NAME) || true
	@rm $(CIVO_KUBECONFIG) 

$(CIVO_KUBECONFIG):
	@echo "Creating $(CIVO_TEST_CLUSTER_NAME)"
	@$(CIVO_CMD) k3s create $(CIVO_TEST_CLUSTER_NAME) -n 3 --size g2.small --wait
	@$(CIVO_CMD) k3s config $(CIVO_TEST_CLUSTER_NAME) > $(CIVO_KUBECONFIG)

# For JUST building the docker runtime
build-docker:
	docker build . -t $(DOCKER_REPO)/civo-marketplace-builder:${currentepoch}; 
	docker tag $(DOCKER_REPO)/civo-marketplace-builder:${currentepoch} $(DOCKER_REPO)/civo-marketplace-builder:latest