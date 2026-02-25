docker exec vllm curl http://localhost:8000/v1/chat/completions \
  -H "Authorization: Bearer local" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Nanbeige4.1-3B-EXL2-8.0bpw",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 50
  }'