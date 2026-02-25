Your api key is NOT set on docker-compose.
Go to http://localhost:8000/docs for an extra help
put some string "<authorization_string>" on both fields on the Authorize button area, to avoid unauthorized errors...
If you want to avoid stress induced authentication problems leave the tag DISABLE_AUTHENTICATION in docker-compose...

After install first create a new user with:
(Note: if the token expires just repeat the steps from here)

```
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@local.com", "password": "admin123"}'
```

for login (with help of http://localhost:8000/docs...):

```
curl -X 'POST' \
  'http://localhost:8000/api/v1/auth/login' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer <authorization_string>' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Cookie: auth_token=authorized' \
  -d 'grant_type=password&username=admin%40local.com&password=admin123&scope=&client_id=string&client_secret=********'
```

obtained the access token, and use it:

```
curl -X POST http://localhost:8000/api/v1/datasets \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "test"}'
```

in the docs it says to use it as the api key (?):

```
export COGNEE_API_KEY="your-key-here"
```

add some data to the dataset:

```
echo "the slow fox grabbed some coffee with the quick turtle" > /tmp/test.txt
```

```
url http://localhost:8000/api/v1/add   -H "Authorization: Bearer <user_access_token>"    -F "datasetName=test"  -F "data=@/tmp/test.txt"
```


after that use the dataset_id obtained above when creating the dataset:

```
curl http://localhost:8000/v1/datasets/{dataset_id}/graph/visualization > graph.html
```
  
  
  