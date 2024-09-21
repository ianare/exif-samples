# If exifread is installed locally (e.g. pip install -e .), use it, else fallback to uv
EXIF_PY := $(if $(shell which EXIF.py),EXIF.py,uvx --from exifread EXIF.py)

.PHONY: help
all: help

uv: ## Install/update uv (simplifies fetching and running EXIF.py in a venv)
	pip3 install -q -U --user uv

test: ## Run exifread on all sample images
	find . -name *.tiff -o -name *.jpg -o -name *.heif | sort -f | xargs $(EXIF_PY) -dc

update: ## Update dump file with tags from sample images
	find . -name *.tiff -o -name *.jpg -o -name *.heif | sort -f | xargs $(EXIF_PY) > dump
	@# Edit dump to match CI of exifread and remove trailing whitespace
	sed -i -e 's/Opening: ./Opening: exif-samples-master/g' -e 's/[ \t]*$$//' dump
	@git diff --quiet dump || echo "\033[1;31mChanges detected, commit updates to 'dump'."

help: Makefile
	@echo
	@echo "Choose a command to run:"
	@echo
	@grep --no-filename -E '^[a-zA-Z_%-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf " \033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo
