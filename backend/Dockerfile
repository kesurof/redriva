FROM python:3.10-slim
WORKDIR /app
COPY backend/app.py ./app.py
COPY backend/requirements.txt ./requirements.txt
COPY src ./src
ENV PYTHONPATH=/app/src
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]