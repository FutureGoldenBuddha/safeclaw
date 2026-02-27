#### Configure OpenClaw

From the `openclaw_install` directory inside the container:

```bash
pnpm openclaw onboard
pnpm openclaw models set llama/Ministral-3-3B-Instruct-2512-Q8_0.gguf
pnpm openclaw models list
cd .openclaw_install && pnpm openclaw gateway --bind loopback --port 18789 --allow-unconfigured --token gateway-token
```

**Note**: final config is at `openclaw_data/.openclaw/openclaw.json`. If `models.providers` is missing after onboarding, add it manually. 📝🔎

#### Configure cognee

##### install

Inside .openclaw_install folder, install cognee with

`pnpm openclaw plugins install @cognee/cognee-openclaw`

##### configure

Create a .openclaw/config.yaml like the one inside this repo cognee/.../config folder

Go to `localhost:8000/docs` and create the dataset equivalent to the config.yaml

##### enable cognee plugin

run `pnpm openclaw plugins list` to see cognee's id to see its status

it should be memory-cognee, now run

`cd .openclaw_install && pnpm openclaw plugins enable memory-cognee`

now try

 `pnpm openclaw cognee index` 


note: I faced a fetch memory files problem

so in $OPENCLAW_HOME/.openclaw/extensions/memory-cognee/dist/index.js

I changed both the default environment variables, and ...
