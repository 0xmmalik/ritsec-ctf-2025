FROM python:3.9-slim
RUN apt-get update && apt-get install -y socat && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir pycryptodome
EXPOSE 12345
CMD ["socat", "TCP-LISTEN:12345,reuseaddr,fork", "EXEC:'python server.py'"]