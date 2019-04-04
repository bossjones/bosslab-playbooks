IMAGE = bossjones/event-generator

build-event-generator-image:
	@docker build -t $(IMAGE):latest docker/event-generator

run-event-generator: ## Run the falco event generator
	@docker-compose -f event-generator.yml up --remove-orphans
