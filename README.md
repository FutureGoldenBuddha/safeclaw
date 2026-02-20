# Safeclaw: security tips for openclaw! 🦞 🫧

### Safeclaw — security best practices for OpenClaw 🦞✨

![Banner](./.devcontainer/assets/banner_1280x320.png)

Build a safer, more private OpenClaw setup with **rootless Docker**, a controlled outbound proxy, and sensible defaults so your personal AI behaves like a well-trained lobster — useful, contained, and not wandering off into the wild web. 🚀🔒

---

### Why Safeclaw

**What you get**
- **Privacy first** — run Llama-compatible models locally and keep **sensitive data** off third-party clouds. 🧠🔐  
- **Defense in depth** — Docker rootless plus a forward proxy (Squid) to control and audit outbound traffic. 🛡️📡  
- **Portable and practical** — works on any OS that supports rootless Docker and VS Code DevContainers. 💻🌍  
- **Developer-friendly** — DevContainer scripts, onboarding helpers, and maintenance toggles so you spend less time configuring and more time asking clever questions. ⚙️✨  
- **GPU-ready** — prepared for NVIDIA and Intel GPUs with Ubuntu 24.04 instructions included. ⚡🖥️

**Tone check**: this repo is for people who want a powerful local assistant without accidentally turning it into a data-leaking gremlin. 🦖➡️🦞

---

### Quick Start

#### Prerequisites
**Install and configure** GPU drivers for your hardware, Git, Docker with rootless mode enabled, Visual Studio Code with Dev Containers, Node.js, and pnpm. Place optional local Llama-compatible model files in `.devcontainer/models/` for best privacy. 📦🔧

#### Clone the repo

```bash
git clone https://github.com/FutureGoldenBuddha/safe-openclaw.git
cd safe-openclaw
```

Ensure your local model name matches in the root `docker-compose.yml` and `.devcontainer/containers/openclaw/debian/openclaw.json`. 🗂️✅

#### Start the environment

**Option A — VS Code DevContainer (recommended)**  
Open the project in VS Code and choose Reopen in Container or run Dev Containers: Reopen in Container from the command palette. 🧩

**Option B — Docker Compose (CLI)**

```bash
docker compose up -d
docker exec -it openclaw sh
```

Continue from inside the container shell if needed. 🐚

#### Maintenance mode for temporary internet access

Containers start with strict network restrictions. To temporarily allow internet access via a controlled Squid proxy, run from the host inside the `.devcontainer` folder:

```bash
bash maintenance-on.sh
```

When finished, lock it back down:

```bash
bash maintenance-off.sh
```

Think of maintenance-on as opening the hatch for a quick supply run and maintenance-off as closing it again so nothing sneaks out. 🚪🔐

#### Post-start setup

Run the OpenClaw post-start script from the host:

```bash
bash .devcontainer/containers/openclaw/debian/post-start.sh
```

Wait for it to finish. ⏳

#### Configure OpenClaw

From the `openclaw_install` directory inside the container:

```bash
pnpm openclaw onboard
pnpm openclaw models set llama/Ministral-3-3B-Instruct-2512-Q8_0
pnpm openclaw models list
pnpm openclaw gateway --bind loopback --port 18789 --allow-unconfigured --token gateway-token
```

**Note**: final config is at `openclaw_data/.openclaw/openclaw.json`. If `models.providers` is missing after onboarding, add it manually. 📝🔎

---

### Security Operational Tips

- **Keep Docker rootless** to reduce blast radius. 🧯  
- **Use local models** for sensitive data and avoid sending PII to external providers. 🗝️  
- **Enable the proxy only when needed** and log traffic for audits. 📋🔍  
- **Secrets** must never be committed to the repo. Use environment variables or a secrets manager. 🔑  
- **Patch often** and update OS, drivers, and container images regularly. 🔄  
- **User groups** add your user to `render` and `video` for GPU access. 🧑‍💻

---

### GPU Setup on Ubuntu 24.04

Check your GPU:

```bash
lspci | grep -E 'VGA|3D|Display'
```

#### Common preparation

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential
lspci -k | grep -EA3 'VGA|3D|Display'
```

#### Intel GPU

```bash
sudo apt install intel-media-va-driver-non-free vainfo
vainfo
sudo apt install intel-opencl-icd clinfo
clinfo | grep "Device Name"
```

If the `-non-free` package is unavailable, use `intel-media-va-driver`. 🧩

#### NVIDIA GPU

```bash
ubuntu-drivers devices
sudo ubuntu-drivers autoinstall
# or
sudo apt install nvidia-driver-550
sudo reboot
nvidia-smi
sudo apt install nvidia-cuda-toolkit
nvcc --version
sudo apt install libva-utils vdpauinfo
vdpauinfo
```

Add your user to GPU groups:

```bash
sudo usermod -a -G render,video $USER
```

Log out and back in for group changes to take effect. 🔁

---

### Contribute and Support

- **Test** with local models and open issues for bugs or UX pain points. 🧪  
- **Star** the repo if Safeclaw saved you from a late-night data leak panic. ⭐  
- **PRs welcome** for better automation, extra GPU support, or clearer onboarding. 🤝

Open an issue on GitHub for help and we’ll get back to you faster than a lobster can pinch. 🦞⚡

---

**Ready to be useful?** Clone the repo, follow the Quick Start, and enjoy a local OpenClaw that’s powerful, private, and delightfully well-behaved. 🎯🦞