# Stage 1: build/install
FROM nvidia/cuda:12.8.1-runtime-ubuntu24.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential python3.12 python3-pip python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY pyproject.toml .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir .[cu12,extras] requests

RUN rm pyproject.toml

# Stage 2: runtime limpo
FROM nvidia/cuda:12.8.1-runtime-ubuntu24.04 AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# Copia apenas o venv instalado, sem build-essential
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# ✅ Copia o código da app diretamente do host (não precisa passar pelo builder)
COPY . .

EXPOSE 5000
ENTRYPOINT ["python3"]
CMD ["main.py"]