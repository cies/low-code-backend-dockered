# This file should gather/document commonly used commands and make remembering them easier.
# It also serves to clean up the README.

# Some default parameters
c=frontend

# The .PHONY rule should come before all tasks that do not have "file targets", which is all of 'm :)

# Borrowed from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## Display this help section
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help


.PHONY: jumpin
jumpin: ## Get a bash shell in an already started container ('frontend' by default, pick another one with c=<name>)
	docker-compose exec $(c) bash

.PHONY: ps
ps: ## List all containers that are part of this project
	docker-compose ps

.PHONY: hasura-migrations-init
hasura-migrations-init: ##  Initialize Hasura migrations
	@docker-compose exec hasura bash -c "cd /tmp; hasura-cli init hasura --endpoint http://localhost:8080; cp -r /tmp/hasura/* /hasura/"
	@echo "When using the Makefile start conosle with: make hasura-console"

.PHONY: hasura-migrations-status
hasura-migrations-status: ## Check Hasura's migration status
	@docker-compose exec hasura bash -c "cd /hasura; hasura-cli migrate status --database-name=postgres"

.PHONY: hasura-migrations-squash
hasura-migrations-squash: ## Squash multiple migrations into one (currently broken)
	@echo "Go run it yourself (fill in the gaps and use the resulting migration version with 'make hasura-migration-apply'):"
	@echo 'docker-compose exec hasura bash -c "cd /hasura; hasura-cli migrate squash --name \"<feature name>\" --from <start migration version> --database-name=postgres"'

.PHONY: hasura-migrations-apply
hasura-migrations-apply: ## Make Hasura apply it's migrations
	@echo "Go run it yourself (fill in the squased migration version):"
	@echo 'docker-compose exec hasura bash -c "cd /hasura; hasura-cli migrate apply --version \"<squash migration version>\" --skip-execution --database-name=postgres"'

.PHONY: hasura-export-metadata
hasura-export-metadata: ## Export the metadata from Hasura
	@docker-compose exec hasura bash -c "cd /hasura; hasura-cli metadata export"

.PHONY: hasura-console
hasura-console: ## Start the Hasura console (on http://localhost:9695)
	@docker-compose exec hasura bash -c "apt-get install -y socat; cd /hasura; \
		socat TCP-LISTEN:8080,fork TCP:hasura:8080 & \
		socat TCP-LISTEN:9695,fork,reuseaddr,bind=hasura TCP:127.0.0.1:9695 & \
		socat TCP-LISTEN:9693,fork,reuseaddr,bind=hasura TCP:127.0.0.1:9693 & \
		hasura-cli console --log-level DEBUG --address "127.0.0.1" --no-browser || exit 1 "

.PHONY: generate-elm-graphql-client
generate-elm-graphql-client: ## Generate GraphQL client library
	@docker-compose run elm-graphql-generator \
		/usr/local/bin/npx --yes --package=@dillonkearns/elm-graphql@4.2.0 \
		-- elm-graphql http://hasura:8080/v1/graphql --base HasuraClient \
		--header "x-hasura-admin-secret:adminsecret" \
		--output /output --skip-elm-format

.PHONY: frontend-prod-build
frontend-prod-build: ## Create a production build
	@docker-compose run frontend \
		npm run prod
