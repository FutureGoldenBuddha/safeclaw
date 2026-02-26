#### Configure OpenClaw

From the `openclaw_install` directory inside the container:

```bash
pnpm openclaw onboard
pnpm openclaw models set llama/gemma-3-4b-it-q4_0
pnpm openclaw models list
pnpm openclaw gateway --bind loopback --port 18789 --allow-unconfigured --token gateway-token
```

**Note**: final config is at `openclaw_data/.openclaw/openclaw.json`. If `models.providers` is missing after onboarding, add it manually. 📝🔎
