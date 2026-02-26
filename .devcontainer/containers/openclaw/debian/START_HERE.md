#### Configure OpenClaw

From the `openclaw_install` directory inside the container:

```bash
pnpm openclaw onboard
pnpm openclaw models set tabbyapi/Nanbeige4.1-3B-EXL2-8.0bpw
pnpm openclaw models list
pnpm openclaw gateway --bind loopback --port 18789 --allow-unconfigured --token gateway-token
```

**Note**: final config is at `openclaw_data/.openclaw/openclaw.json`. If `models.providers` is missing after onboarding, add it manually. 📝🔎
