.PHONY: helm-docs
helm-docs:
	helm-docs --values-file values.yaml --output-file README.md --chart-search-root . --template-files README.md.gotmpl
