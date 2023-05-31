# Makefile

define there-is-a-cookie
	@if [ ! -f cookie ]; then \
		echo "'cookie' not found. Please run \e[1;33m'make get_cookie'\e[0m"; \
		exit 1; \
	fi
endef

define there-is-create_errors
	@if [ ! -f create_errors.test.csv ]; then \
		echo "'create_errors.test.csv' not found. Please run \e[1;33m'make test'\e[0m"; \
		exit 1; \
	fi
endef

define there-is-update_errors
	@if [ ! -f update_errors.test.csv ]; then \
		echo "'update_errors.test.csv' not found. Please run \e[1;33m'make test'\e[0m"; \
		exit 1; \
	fi
endef

there-is-a-cookie:
	$(there-is-a-cookie)
there-is-create_errors:
	$(there-is-create_errors)
there-is-update_errors:
	$(there-is-update_errors)

cookie:
	@bash scripts/get_cookie.sh
.PHONY: cookie


test: there-is-a-cookie
	@bash scripts/run_test.sh
.PHONY: test

check_errors_create: there-is-create_errors
	@bash scripts/check_create_errors.sh
.PHONY: check_errors_create

check_errors_update: there-is-update_errors
	@bash scripts/check_update_errors.sh
.PHONY: check_errors_update

results:
	@bash scripts/results.sh
.PHONY: results

get_results:
	@bash scripts/get_results.sh
.PHONY: get_results

delete_db:
	@bash scripts/delete_db.sh
.PHONY: delete_db


clean:
	@rm -f *.test.csv
.PHONY: clean
