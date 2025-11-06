PYTHON=python
ENV_NAME=ocr
ENV_FILE=environment.yml
APP=app.py

run:
	$(PYTHON) -B $(APP)

dev:
	uvicorn $(basename $(APP)):app --reload --host 0.0.0.0 --port 8000

envcreate:
	@conda env create -f $(ENV_FILE)

envupdate:
	conda env update -f $(ENV_FILE)

envexport:
	@echo "Exporting clean environment..."
	conda env export --from-history | grep -v "^prefix:" > $(ENV_FILE)
	@echo "  - pip:" >> $(ENV_FILE)
	pip list --format=freeze --not-required | grep -v "file://" | sed 's/^/      - /' >> $(ENV_FILE)

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	rm -rf build dist *.egg-info

lint:
	black .
	isort .
	flake8 .
	mypy .

help:
	@echo "Available commands:"
	@echo "  make run        - Run app without __pycache__"
	@echo "  make dev      - Start FastAPI with uvicorn"
	@echo "  make envcreate     - Create environment from environment.yml"
	@echo "  make envupdate     - Update environment from environment.yml"
	@echo "  make envexport  - Export clean environment.yml"
	@echo "  make lint       - Check code formatting"
	@echo "  make clean      - Remove __pycache__"