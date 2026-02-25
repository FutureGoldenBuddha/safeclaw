It may ask for a api key, use the one tabbyAPI gives you by checking in:

`docker logs tabbyapi` <- your container name

save them in .env

TABBY_API_KEY=...
TABBY_ADMIN_KEY=...

then restart the container with:

`docker restart tabbyapi`


then you can test the model by using

docker exec ubuntu-tabbyapi-1 curl -H "Authorization: Bearer <tabby_api_key>" http://localhost:5000/v1/completions   -H "Content-Type: application/json"   -d '{
    "model": "nanbeige",
    "prompt": "hello",
    "max_tokens": 50
  }'


docker exec ubuntu-tabbyapi-1 curl http://localhost:5000/v1/chat/completions \
  -H "Authorization: Bearer <tabby_api_key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Nanbeige4.1-3B-EXL2-8.0bpw",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 50
  }'

---


# CRITICAL - it is not automatically loading tool calling (?), but one can try this explicitly...

TabbyAPI automatically reads the `chat_template` from the model's `tokenizer_config.json` when no `prompt_template` is specified. This is the recommended path when the model already ships a proper template — which yours clearly does.

In your `config.yml`:

```yaml
# Option 1 — let TabbyAPI use the model's built-in template (recommended)
prompt_template: null
```

---
---
---
| |
\ /

## If you do want to save it as an explicit template file

Save the `chat_template` string as a `.jinja` file inside TabbyAPI's `templates/` directory, then reference it by name:

```yaml
# config.yml
prompt_template: boss-zhipin-qwen   # matches templates/boss-zhipin-qwen.jinja
```

The `.jinja` file is just the raw template string from the JSON, unescaped — so you'd strip the surrounding quotes and unescape the `\"` → `"` throughout.

---

## What your template actually does

Looking at it, this is a **ChatML + tool calling** template (the `<|im_start|>` / `<|im_end|>` markers confirm it's Qwen-based). It handles the full tool calling cycle:

```
tools present?
    ↓ yes
Injects tool signatures inside <tools>...</tools>
    ↓
Agent responds with <tool_call>{"name": ..., "arguments": ...}</tool_call>
    ↓
Tool result comes back wrapped in <tool_response>...</tool_response>
    ↓
Agent summarizes in natural language
```

It also has **reasoning/thinking support** — notice the `<think>...</think>` block handling, which means this model supports chain-of-thought. That reasoning content is stripped from intermediate turns but preserved on the final reply.

---

## One thing to watch for

The default system prompt in the template is in Chinese (it's from BOSS直聘's internal model). When OpenClaw injects its own system prompt via `AGENTS.md`, it will override that correctly — but double-check by looking at your session `.jsonl` files to confirm the system block is being set by OpenClaw and not falling back to the Chinese default.