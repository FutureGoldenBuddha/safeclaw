## Cognee + OpenClaw Parallel Usage

The issue isn't cognee itself — it's **contention for the llama.cpp instance**:

```
OpenClaw  ──→ llama:8080  ←──  Cognee
```

llama.cpp processes **one request at a time** by default. If cognee is running cognify (multiple chained LLM calls), OpenClaw will have to wait — and vice versa.

## When it's a problem

- **Cognify running in background** while using OpenClaw → slow responses or timeouts
- **Indexing many files at once** → blocks the chat for minutes

## When it's NOT a problem

- Cognee only **storing data** (`/add`) — no LLM involved, just writes files
- Cognee **searching/querying** — uses the embeddings model (separate CPU container), doesn't interfere with chat at all
- **Cognify scheduled** for when you're not actively using OpenClaw (e.g. end of day)

## Recommended Workflow

Keep the two phases separate — run cognify manually at the end of your work session:

```bash
#!/bin/bash
# run-cognify.sh — execute when done working for the day
export COGNEE_TOKEN=$(...)

curl -X POST http://localhost:8000/api/v1/cognify \
  -H "Authorization: Bearer $COGNEE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"datasets": ["work"]}'

echo "Cognify complete — knowledge graph updated"
```

```
During the day  → OpenClaw chat + cognee /add (no LLM usage)
End of day      → run cognify to process everything
Next day        → OpenClaw has updated memory available
```

This way cognee never competes with your active chat sessions.