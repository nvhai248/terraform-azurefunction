# Storage configuration
STORAGE_ACCOUNT = microleaffuncsa
CONTAINER       = microleaffunccontainer
EXPIRY_DATE     = 2030-01-01
FUNCTION_APP    = microleaffunc
RESOURCE_GROUP  = microleaffunc-rg

# Full path list (can be overridden when running make)
FUNCTION_PATHS ?= function_app/func1 function_app/func2

# Extract basename (func1, func2, ...)
FUNCTIONS = $(notdir $(FUNCTION_PATHS))

# Default target
.PHONY: deploy
deploy: $(addprefix deploy-,$(FUNCTIONS))

# Build zip from function_app/<name> directory
.PHONY: build-%
build-%:
	# This line MUST start with a TAB
	cd function_app/$* && zip -r ../../$*.zip .

# Upload zip to Azure Blob Storage
.PHONY: upload-%
upload-%: build-%
	# This line MUST start with a TAB
	az storage blob upload \
	  --account-name $(STORAGE_ACCOUNT) \
	  --container-name $(CONTAINER) \
	  --name $*.zip \
	  --file $*.zip \
	  --overwrite

# Generate SAS URL and update appsettings
.PHONY: sas-url-%
sas-url-%: upload-%
	# This line and the following lines in this recipe MUST start with a TAB
	@SAS=$$(az storage blob generate-sas \
	  --account-name $(STORAGE_ACCOUNT) \
	  --container-name $(CONTAINER) \
	  --name $*.zip \
	  --permissions r \
	  --expiry $(EXPIRY_DATE) \
	  --https-only \
	  --output tsv); \
	URL="https://$(STORAGE_ACCOUNT).blob.core.windows.net/$(CONTAINER)/$*.zip?$${SAS}"; \
	echo "Function '$*' SAS URL:"; \
	az functionapp config appsettings set \
	  --name $(FUNCTION_APP) \
	  --resource-group $(RESOURCE_GROUP) \
	  --settings "WEBSITE_RUN_FROM_PACKAGE=$${URL}"

# Deploy function
.PHONY: deploy-%
deploy-%: sas-url-%
