APP_NAME ?= loveletter
RAILS_ENV ?= development

GREEN := $(shell tput -Txterm setaf 2 2>/dev/null || printf "")
YELLOW := $(shell tput -Txterm setaf 3 2>/dev/null || printf "")
RESET := $(shell tput -Txterm sgr0 2>/dev/null || printf "")

.DEFAULT_GOAL := help

# 🧩 Local Development

run: ## Start the dev server (bin/dev)
	@echo "$(GREEN)==> Running $(APP_NAME) in $(RAILS_ENV)...$(RESET)"
	bin/dev

setup: ## Install gems and set up the database
	@echo "$(GREEN)==> Setting up $(APP_NAME)...$(RESET)"
	bundle install
	bundle exec rails db:create
	bundle exec rails db:migrate

install: ## Install gem dependencies only
	bundle install

console: ## Open a Rails console
	bin/rails c

# 🗄️ Database

db.create: ## Create the database
	bundle exec rails db:create

db.drop: ## Drop the database
	bundle exec rails db:drop

db.migrate: ## Run pending migrations
	bundle exec rails db:migrate

db.reset: ## Drop, recreate and migrate the database
	bundle exec rails db:reset

# 🧪 Testing

test: ## Run the RSpec suite
	bundle exec rspec

# 🔍 Linting & Security

lint: ## Run RuboCop
	bundle exec rubocop

lint.fix: ## Auto-correct RuboCop offenses
	bundle exec rubocop -A

security: ## Run Brakeman security scan
	bundle exec brakeman -q --no-pager

check: lint security test ## Run lint, security scan and tests

# 🧰 Utilities

cleanup: ## Delete stale/finished games
	bin/rails games:cleanup

# 📖 Help

help: ## Show all available make targets
	@echo "$(GREEN)$(APP_NAME) - Available targets:$(RESET)"
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(RESET) %s\n", $$1, $$2}'

.PHONY: run setup install console db.create db.drop db.migrate db.reset test lint lint.fix security check cleanup help
