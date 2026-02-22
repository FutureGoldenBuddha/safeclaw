It may ask for a api key, use the one tabbyAPI gives you by checking in:

`docker logs tabbyapi` <- your container name

save them in .env

TABBY_API_KEY=...
TABBY_ADMIN_KEY=...

then restart the container with:

`docker restart tabbyapi`


then you can test the model by using

docker exec ubuntu-tabbyapi-1 curl -H "Authorization: Bearer <atabby_pi_key>" http://localhost:8080/v1/completions   -H "Content-Type: application/json"   -d '{
    "model": "nanbeige",
    "prompt": "hello",
    "max_tokens": 50
  }'