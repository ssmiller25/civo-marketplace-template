VERSION="v0.0.1"
# For cli directly installed
CIVO_CMD="civo"
# For Docker
#CIVO_CMD=docker run -it --rm -v $HOME/.civo.json:/.civo.json civo/cli:latest
CIVO_TEST_CLUSTER_NAME=app-test
CIVO_KUBECONFIG=kubeconfig.$(CIVO_TEST_CLUSTER_NAME)
KUBECTL=kubectl --kubeconfig=$(CIVO_KUBECONFIG)

.PHONY: build
build: app.yaml

app.yaml:
	@curl https://myapp.lan/release.yaml > app.yaml

	# Test final app.yaml for validity
	@echo "Testing validity of app.yaml"
	@kubectl apply -f app.yaml --dry-run=client > /dev/null
	@echo "Clean app.yaml generated"

.PHONY: clean
clean:
	@rm app.yaml

.PHONY: test
test:
	@echo "Creating $(CIVO_TEST_CLUSTER_NAME)"
	@$(CIVO_CMD) k3s create $(CIVO_TEST_CLUSTER_NAME) -n 3 --size g2.small --wait
	@$(CIVO_CMD) k3s config $(CIVO_TEST_CLUSTER_NAME) > $(CIVO_KUBECONFIG)
	@echo "Applying manifest and test run"
	@$(KUBECTL) apply -f app.yaml
	@$(KUBECTL) create -f test-manifests/testjob.yaml 
	@sleep 10
	@echo "Checking status of test run"
	@$(KUBECTL) get job testjob -ojson | jq -r .status.conditions[0].type | grep -q Completed
	@echo "Success!  Tearing down test cluster"
	@$(CIVO_CMD) k3s remove -y $(CIVO_TEST_CLUSTER_NAME)
	@rm $(CIVO_KUBECONFIG)
