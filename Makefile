APP_NAME ?= loveletter
RAILS_ENV ?= development

GREEN := $(shell tput -Txterm setaf 2 2>/dev/null || printf "")
RESET := $(shell tput -Txterm sgr0 2>/dev/null || printf "")

.DEFAULT_GOAL := help

run:
	@echo "$(GREEN)==> Running $(APP_NAME) in $(RAILS_ENV)...$(RESET)"
	bin/dev

setup:
	@echo "$(GREEN)==> Setting up $(APP_NAME)...$(RESET)"
	bundle install
	bin/rails db:create
	bin/rails db:migrate

db.create:
	bin/rails db:create

db.drop:
	bin/rails db:drop

db.migrate:
	bin/rails db:migrate

lint:
	bundle exec rubocop

test:
	bin/rspec
