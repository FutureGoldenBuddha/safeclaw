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