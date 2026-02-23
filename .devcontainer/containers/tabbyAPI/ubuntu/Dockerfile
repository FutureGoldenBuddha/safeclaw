# Stage 1: build/install
FROM nvidia/cuda:12.8.1-runtime-ubuntu24.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY pyproject.toml .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir .[cu12] requests

RUN rm pyproject.toml

# Stage 2: runtime limpo
FROM nvidia/cuda:12.8.1-runtime-ubuntu24.04 AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 ca-certificates curl git \
    && rm -rf /var/lib/apt/lists/*

# Copia apenas o venv instalado, sem build-essential
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

RUN git clone https://github.com/theroyallab/tabbyAPI.git

# 2. MUDA O WORKDIR PARA DENTRO DO REPOSITÓRIO CLONADO
WORKDIR /app/tabbyAPI

# ✅ Copia o código da app/tabbyAPI diretamente do host 
COPY . .

# Cria o grupo render com o GID 992 (mesmo do host) para poder mapear senao /dev/dri é mapeado como nogroup
RUN groupadd -g 992 render && \
    # useradd -m -G render ubuntu && \
    # ou se o usuário já existe, apenas adiciona ao grupo:
    usermod -a -G render ubuntu

EXPOSE 5000
ENTRYPOINT ["python3"]
CMD ["main.py"]