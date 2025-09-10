# Storage configuration
APP_NAME=microleaffunc
RESOURCE_GROUP=microleaf-test-hai
ZIP_FILE=functionapp.zip
DEPLOY_DIR=deploy

# build: compile TS -> JS
build:
	npm install
	npm run build

# prepare: copy files to deploy
prepare: clean build
	mkdir -p $(DEPLOY_DIR)
	cp host.json package.json $(DEPLOY_DIR)/
	cp -r dist/* $(DEPLOY_DIR)/
	cp -r node_modules $(DEPLOY_DIR)/

# zip: create zip file from deploy dir
zip: prepare
	cd $(DEPLOY_DIR) && zip -r ../$(ZIP_FILE) .

# deploy: upload zip to Azure Function
deploy: zip
	az functionapp deployment source config-zip -g $(RESOURCE_GROUP) -n $(APP_NAME) --src $(ZIP_FILE)

# clean: remove deploy directory and old zip file
clean:
	rm -rf $(DEPLOY_DIR) $(ZIP_FILE)
