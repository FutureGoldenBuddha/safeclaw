FROM ollama/ollama:latest

# primeiro faz update do sistema
RUN apt-get update
# necessario para fazer update no github
RUN apt-get install -y git openssh-client

# Instalar dependências de sistema segundo instrucoes da Intel client GPU, ubuntu 24
RUN apt-get update && apt-get install -y software-properties-common 
RUN add-apt-repository -y ppa:kobuk-team/intel-graphics
RUN apt-get install -y libze-intel-gpu1 libze1 intel-metrics-discovery intel-opencl-icd clinfo intel-gsc
RUN apt-get install -y intel-media-va-driver-non-free libmfx-gen1 libvpl2 libvpl-tools libva-glx2 va-driver-all vainfo \
    && rm -rf /var/lib/apt/lists/*

# necessario para instalar nividia tollkit
RUN apt-get update && apt-get install -y curl gpg
# instalar nvidia drivers
RUN curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
RUN apt-get update && apt-get install -y nvidia-container-toolkit
RUN nvidia-ctk runtime configure --runtime=docker

# This tells the 'ollama' binary to start the server and stay open
CMD ["serve"]
