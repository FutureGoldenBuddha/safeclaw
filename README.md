# Safeclaw: security tips for openclaw! 🦞 🫧

### Safeclaw — security best practices for OpenClaw 🦞✨

![Banner](./.devcontainer/assets/banner_1280x320.png)

Build a safer, more private OpenClaw setup with **rootless Docker**, a controlled outbound proxy, and sensible defaults so your personal AI behaves like a well-trained lobster — useful, contained, and not wandering off into the wild web. 🚀🔒

---

### Why Safeclaw

**What you get**
- **Privacy first** — run Llama-compatible models locally and keep **sensitive data** off third-party clouds. 🧠🔐  
<br>
- **Defense in depth** — Docker rootless plus a forward proxy (Squid) to control outbound traffic. 🛡️📡  
<br>
- **Portable and practical** — works on any OS that supports rootless Docker and VS Code DevContainers. 💻🌍  
<br>
- **Developer-friendly** — DevContainer scripts, onboarding helpers, and maintenance toggles so you spend less time configuring and more time asking clever questions. ⚙️✨  
<br>
- **GPU-ready** — prepared for NVIDIA and Intel GPUs, with Ubuntu 24.04 instructions included. ⚡🖥️
<br>

**Tone check**: this repo is for people who want a local assistant without accidentally turning it into a data-leaking gremlin. 🦖➡️🦞

<details>
<summary>**Possible constraints** GPU card(s) and local LLMs</summary>

---

I have a NVIDIA 4060 RTX with 8GB RAM, so if you have a different GPU and/or use a different model please adjust the context size and maximum tokens accordingly. I can make a list with different models configurations to make it easier, but I am currently using ministral 3B and happy with the results 😊.

A trick to make your agent smarter is to write meaningful skills with bigger models on the web, asking them to make a SKIlL.md, MEMORY_snippet.md (a small section that you add in your main MEMORY.md file) and a README.md (for future reference). Then you place the skill folder with the files in the skills folder (try to say this fast twice in a row 🥴) and proceed to ask your local AI to "load the skill <skill folder name> and confirm it's loaded". This way your local ai agent gets smarter without overloading its memory files. I think we are going to need skills focusing in security measures also...

token speed comparison between local LLM providers with my specs:

ollama -- xx t/s

llamacpp vulkan << t/s

llamacpp cuda 60 t/s IT'S MY CHOICE, FOR NOW

tabbyApi cuda 68 t/s, but no automatic function call support (?, at least for nanbeige4.1-3B...), and need for a different API key at every setup

vLLM not fully tested, 8GB RAM is not enough because it pre-allocates a lot of VRAM for KV cache.

---

</details>

---

### Quick Start

#### Prerequisites
**Install and configure** GPU drivers in your host, and Docker with rootless mode enabled, Visual Studio Code with Dev Containers extension.  📦🔧

#### Clone the repo

```bash
git clone https://github.com/FutureGoldenBuddha/safeclaw.git
cd safeclaw
```

Place local Llama-compatible model files in `.devcontainer/models/` for best privacy.

Ensure your local model name matches in the root `docker-compose.yml` and `.devcontainer/containers/openclaw/debian/openclaw.json`. 🗂️✅

#### Start the environment

**Option A — VS Code DevContainer (recommended)**  
Open the project in VS Code and choose Reopen in Container or run Dev Containers: Reopen in Container from the command palette. 🧩

**Option B — Docker Compose (CLI)**

```bash
docker compose up -d
```

Continue from inside the container shell. 🐚

```bash
docker exec -it openclaw sh
```

#### Maintenance mode for temporary internet access

These containers start with strict network restrictions. To temporarily allow internet access via a controlled Squid proxy (or else you cannot install openclaw), run from the host and inside the `.devcontainer` folder:

```bash
bash maintenance-on.sh
```

When finished installing openclaw, lock it back down:

```bash
bash maintenance-off.sh
```

Think of maintenance-on as opening the hatch for a quick supply run and maintenance-off as closing it again so nothing sneaks out. 🚪🔐

#### Run post-start setup (if you don't see de openclaw_install folder and its contents)

Run the OpenClaw post-start script from inside the devcontainer in vscode:

```bash
bash .devcontainer/containers/openclaw/debian/post-start.sh
```

Wait for it to finish. ⏳

#### Configure OpenClaw

From the `openclaw_install` directory inside the container:

```bash
pnpm openclaw onboard
pnpm openclaw models set tabbyapi/Nanbeige4.1-3B-EXL2-8.0bpw
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