# 1. Usamos a imagem oficial do llama.cpp já compilada para CUDA
# Essa imagem é baseada em Ubuntu e já vem com as bibliotecas necessárias
FROM ghcr.io/ggml-org/llama.cpp:server-cuda

# Voltamos para root apenas para instalar utilitários administrativos
USER root

# Evita prompts interativos
ENV DEBIAN_FRONTEND=noninteractive

# 2. Instalamos apenas o essencial: git para seus hooks e gosu para gestão de usuários
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    sudo \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# No CUDA, não precisamos mapear o grupo 'render' (992) manualmente 
# como fazíamos para o Intel/Vulkan. O driver NVIDIA cuida disso.

# Criamos o usuário ubuntu se ele não existir (na imagem oficial geralmente já existe)
# mas garantimos que ele tenha permissões para o que precisamos
RUN id -u ubuntu >/dev/null 2>&1 || useradd -m -u 1000 ubuntu

# Expõe a porta do servidor
EXPOSE 8080

# (Opcional) Verificação de saúde: nvidia-smi para ver se as GPUs estão lá
CMD ["nvidia-smi"]