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
	bundle exec rails db:create
	bundle exec rails db:migrate

db.create:
	bundle exec rails db:create

db.drop:
	bundle exec rails db:drop

db.migrate:
	bundle exec rails db:migrate

lint:
	bundle exec rubocop

test:
	bundle exec rspec
