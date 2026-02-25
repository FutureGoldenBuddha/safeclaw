# Usa a imagem oficial com suporte Vulkan
FROM ghcr.io/ggml-org/llama.cpp:server-vulkan

# reforço para quando o llama está como container no conjunto todo
# entrypoint corre como root, gosu faz a troca
USER root 

# Evita prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalação de dependências básicas e repositório oficial da Intel
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    wget \
    sudo \
    software-properties-common \
    && wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble unified" > /etc/apt/sources.list.d/intel-gpu.list \
    && apt-get update

# 2. Instalação dos drivers de Mídia (VA-API) e Computação (OpenCL/Level Zero)
# Equivalente ao seu processo no Arch, mas usando pacotes modernos (Broadwell+)
RUN apt-get install -y --no-install-recommends \
    build-essential \
    intel-media-va-driver-non-free vainfo \
    intel-opencl-icd clinfo \
    mesa-vulkan-drivers libgl1 libglx-mesa0 \
    sudo gosu \
    && rm -rf /var/lib/apt/lists/*

# Verificar se o grupo 1000 já existe e usar nome apropriado: é ubuntu..

# Cria o grupo render com o GID 992 (mesmo do host) para poder mapear senao /dev/dri é mapeado como nogroup
RUN groupadd -g 992 render && \
    # useradd -m -G render ubuntu && \
    # ou se o usuário já existe, apenas adiciona ao grupo:
    usermod -a -G render ubuntu
# adiciona user aos recursos de renderizacao da GPU no compose

# Expõe a porta que o OpenClaw vai usar
EXPOSE 8080

# usuario nao root
# USER 1000:1000

# (Opcional) Comando para verificar se a GPU é detectada ao iniciar
CMD ["sh", "-c", "vainfo && clinfo"]

# Comando padrão (sem ENTRYPOINT, deixa o CMD fazer tudo) - esta no compose
# CMD ["llama-server", "--host", "0.0.0.0", "--port", "8080", "-ngl", "99", "--ctx-size", "8192"]
