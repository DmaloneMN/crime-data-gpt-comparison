FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY notebooks ./notebooks
COPY scripts ./scripts
CMD ["python", "scripts/validate_results.py"]  # Or run a notebook
