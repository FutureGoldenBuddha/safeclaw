# Safe Openclaw Project

![Banner](./.devcontainer/assets/banner_1280x320.png)

Just like a paella 👨‍🍳 🥘: mixed with docker rootless, llamacpp, squidproxy and love. 🦞

Your own personal AI assistant. Any OS. Any Platform.

# How to Install OpenClaw (Rootless Docker) Inside a DevContainer

This tutorial walks you through setting up **OpenClaw** — a personal AI assistant — using a rootless Docker environment inside a VS Code DevContainer.

---

## Prerequisites

Before you start, make sure you have the following installed and configured on your machine:

- **GPU drivers** - install your nvidia / amd / intel / <insert other provider here> in your host system
- **Git** — to clone the repository
- **Docker** ([Docker Engine with rootless mode enabled](https://docs.docker.com/engine/security/rootless/))
- **Visual Studio Code** with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed
- **Node.js** and **pnpm** — required to run OpenClaw CLI commands inside the container
- *(Optional)* Any **llama-compatible model files** you want to use locally

---

## Step 1 — Clone the Repository

Open a terminal and run:

```bash
git clone https://github.com/FutureGoldenBuddha/safe-openclaw.git
cd safe-openclaw
```

If you plan to use local llama models (you better if you gonna have personal data), place your model files inside the `.devcontainer/models/` folder before proceeding.

Also, make sure the local model name is consistent across these two places:
- The `llama` service definition in the root `docker-compose.yml`
- The `openclaw.json` file located at `.devcontainer/containers/openclaw/debian/openclaw.json`

Also x 2, the docker-compose and corresponding dockerfiles are prepared for Nvidia / Intel GPU, please refer to original documentation for installing other GPU providers. Below, in the section [GPU Setup on Ubuntu 24.04](#gpu-setup-on-ubuntu-2404), there are the installation steps for ubuntu as an example.

---

## Step 2 — Start the Containers

You have two options to bring up the environment:

**Option A — via VS Code DevContainers (you can see your workspace in your vscode and make github commits all in the same place):**

Open the project folder in VS Code, then either:
- Click the prompt **"Reopen in Container"** when it appears, or
- Press `Ctrl + Shift + P` and select **"Dev Containers: Reopen in Container"**

**Option B — via Docker Compose (CLI) (you can see your workspace in your pc and make github commits in the host terminal):**

Navigate to the folder containing `docker-compose.yml` and run:

```bash
docker compose up -d
```

Then, for the commands to execute inside the conainer, access the openclaw container via the terminal:

```bash
docker exec -it openclaw sh
```

and go to point 3.

---

## Step 3 — Enable Maintenance Mode

The container starts with strict network restrictions by default, which prevents it from accessing the internet. You need to temporarily lift those restrictions by running a secondary squid proxy in another container which allows internet access.

Run the following script from the host inside the .devcontainer folder, not from the container:

```bash
bash maintenance-on.sh
```

---

## Step 4 — Run the OpenClaw Post-Start Script

This script handles the initial setup and download of OpenClaw:

```bash
bash .devcontainer/containers/openclaw/debian/post-start.sh
```

Wait for the script to complete before moving on.

---

## Step 5 — Configure and Start OpenClaw

Navigate to the `openclaw_install` directory and run the following commands in order:

**1. Run the onboarding wizard** (required if you're using OpenRouter — it lets you manually select your provider):

```bash
pnpm openclaw onboard
```

**2. Set your local model:**

```bash
pnpm openclaw models set llama/Ministral-3-3B-Instruct-2512-Q8_0
```

Replace the model name with whichever model you placed in the `.devcontainer/models/` folder.

**3. List available models** to confirm your model is detected:

```bash
pnpm openclaw models list
```

**4. Start the gateway in production mode** with a loopback binding and an authentication token:

```bash
pnpm openclaw gateway --bind loopback --port 18789 --allow-unconfigured --token gateway-token
```

> **Note:** The final configuration file is stored at `openclaw_data/.openclaw/openclaw.json`. If you notice that model providers are missing after onboarding, you may need to manually add the `models.providers` section to that file.

---

## You're All Set! 🦞

OpenClaw should now be running inside your DevContainer on port `18789`. You can connect to it via `localhost:18789` using your gateway token.

And... whenever you feel that you want to lock the container from any internet access just run this inside the .devcontainer folder:

```bash
bash maintenance-off.sh
```

---

---

---

---


## GPU Setup on Ubuntu 24.04

Ubuntu 24.04 comes with Mesa drivers pre-installed. The guide below covers setup for both **Intel** and **NVIDIA** GPUs. Follow only the section that matches your hardware.

> To check which GPU you have, run:
> ```bash
> lspci | grep -E 'VGA|3D|Display'
> ```

---

### 1. Preparation and Verification

This step applies to **both** Intel and NVIDIA setups.

```bash
# Update repositories
sudo apt update && sudo apt upgrade -y

# Install essential build tools
sudo apt install build-essential

# Check your GPU and the driver in use
lspci -k | grep -EA3 'VGA|3D|Display'
```

---

## Intel GPU

### 2a. Hardware Acceleration (VA-API)

The modern VA-API driver for Intel GPUs (Broadwell and later) is available directly from Ubuntu's repositories.

```bash
# Install the media driver and diagnostic tools
sudo apt install intel-media-va-driver-non-free vainfo

# Verify that hardware acceleration is active
vainfo
```

> **Note:** If the `-non-free` variant is unavailable, use `intel-media-va-driver` as a fallback.

### 3a. OpenCL and Compute

For OpenCL support — used by apps like Darktable or Blender:

```bash
# Install the compute runtime and clinfo for verification
sudo apt install intel-opencl-icd clinfo

# Verify the OpenCL installation
clinfo | grep "Device Name"
```

---

## NVIDIA GPU

### 2b. Install NVIDIA Drivers

Ubuntu 24.04 includes NVIDIA drivers in its repositories. The recommended approach is to let Ubuntu detect the best driver for your card:

```bash
# Check which driver is recommended for your GPU
ubuntu-drivers devices

# Automatically install the recommended driver
sudo ubuntu-drivers autoinstall

# Or install a specific version manually (e.g. 550)
sudo apt install nvidia-driver-550
```

After installation, **reboot your system**:

```bash
sudo reboot
```

Then verify the driver is loaded correctly:

```bash
nvidia-smi
```

### 3b. CUDA and Compute

For CUDA support — used by apps like Blender, DaVinci Resolve, or machine learning frameworks:

```bash
# Install CUDA toolkit
sudo apt install nvidia-cuda-toolkit

# Verify the CUDA installation
nvcc --version
```

### 4b. Hardware Acceleration (VA-API via NVDEC)

```bash
# Install VA-API bridge for NVIDIA and diagnostic tools
sudo apt install libva-utils vdpauinfo

# Verify hardware decode support
vdpauinfo
```

---

### 5. User Permissions

Applies to **both** Intel and NVIDIA setups. Add your user to the `render` and `video` groups to ensure full access to GPU resources:

```bash
sudo usermod -a -G render,video $USER
# A session restart (logout/login) is required for this to take effect
```