.PHONY: helm-docs
helm-docs:
	helm-docs --chart-search-root . --skip-version-footer
