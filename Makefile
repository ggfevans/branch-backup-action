# Makefile for Branch Backup Action Testing

# Variables
SHELL := /bin/bash
REPO_ROOT := $(shell pwd)
TEST_RESULTS_DIR := test-results
COVERAGE_DIR := coverage

# Default target
.PHONY: help
help: ## Show this help message
	@echo "Branch Backup Action - Test & Build Commands"
	@echo "============================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Test targets
.PHONY: test
test: lint test-unit test-integration ## Run all tests (lint + unit + integration)

.PHONY: test-unit
test-unit: ## Run unit tests only
	@echo "Running unit tests..."
	@scripts/run-bats.sh test/unit

.PHONY: test-integration
test-integration: ## Run integration tests only
	@echo "Running integration tests..."
	@scripts/run-bats.sh test/integration

.PHONY: test-quick
test-quick: test-unit ## Run quick tests (unit only)

# Linting targets
.PHONY: lint
lint: lint-shell lint-action lint-workflows ## Run all linting

.PHONY: lint-shell
lint-shell: ## Lint shell scripts with shellcheck
	@echo "Linting shell scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		find src -name "*.sh" -exec shellcheck {} +; \
		find test -name "*.bash" -not -path "test/vendor/*" -exec shellcheck {} +; \
	else \
		echo "Warning: shellcheck not installed. Install with: brew install shellcheck"; \
	fi

.PHONY: lint-action
lint-action: ## Validate action.yml schema
	@echo "Validating action.yml..."
	@scripts/validate-action-yml.sh

.PHONY: lint-workflows
lint-workflows: ## Lint GitHub Actions workflows
	@echo "Linting workflows..."
	@if command -v actionlint >/dev/null 2>&1; then \
		actionlint; \
	else \
		echo "Warning: actionlint not installed. Install with: brew install actionlint"; \
	fi

# Coverage targets
.PHONY: coverage
coverage: ## Generate test coverage report (requires kcov on Linux)
	@echo "Generating coverage report..."
	@if [[ "$(shell uname)" == "Linux" ]] && command -v kcov >/dev/null 2>&1; then \
		mkdir -p $(COVERAGE_DIR); \
		scripts/run-coverage.sh; \
	else \
		echo "Coverage requires kcov on Linux. Skipping..."; \
	fi

# Setup targets
.PHONY: setup
setup: ## Setup development environment
	@echo "Setting up development environment..."
	@scripts/setup-env.sh
	@echo "Initializing git submodules..."
	@git submodule update --init --recursive

# Format targets
.PHONY: format
format: ## Format shell scripts with shfmt
	@echo "Formatting shell scripts..."
	@if command -v shfmt >/dev/null 2>&1; then \
		find src test -name "*.sh" -o -name "*.bash" | grep -v test/vendor | xargs shfmt -w -i 4; \
	else \
		echo "shfmt not installed. Install with: brew install shfmt"; \
	fi

# Clean targets
.PHONY: clean
clean: ## Remove test artifacts and temporary files
	@echo "Cleaning up..."
	@rm -rf $(TEST_RESULTS_DIR) $(COVERAGE_DIR)
	@find . -name "*.tmp" -delete
	@find . -name ".test_tmp*" -delete

.PHONY: clean-all
clean-all: clean ## Remove all generated files including submodules
	@echo "Deep cleaning (including submodules)..."
	@git submodule deinit --all --force || true
	@rm -rf test/vendor

# Development targets
.PHONY: watch
watch: ## Watch for changes and run tests (requires entr)
	@echo "Watching for changes... (requires: brew install entr)"
	@find src test -name "*.sh" -o -name "*.bash" | grep -v test/vendor | entr -c make test-unit

# CI targets
.PHONY: ci-setup
ci-setup: ## Setup CI environment
	@scripts/setup-env.sh ci

.PHONY: validate
validate: lint ## Validate code without running tests

# Documentation
.PHONY: docs
docs: ## Generate/validate documentation
	@echo "Validating documentation examples..."
	@if [[ -f docs/test_examples.sh ]]; then \
		bash docs/test_examples.sh; \
	else \
		echo "No documentation tests found"; \
	fi

# Make directories
$(TEST_RESULTS_DIR) $(COVERAGE_DIR):
	@mkdir -p $@