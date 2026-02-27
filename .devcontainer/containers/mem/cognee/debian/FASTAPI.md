Go to http://localhost:8000/docs for an extra help

If you want to avoid stress induced authentication problems leave the tag REQUIRE_AUTHENTICATION=false in docker-compose...

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

see the docs to use the api... this ingests the data
```
curl -X 'POST' \
  'http://localhost:8000/api/v1/add' \
  -H 'accept: application/json' \
  -H 'Content-Type: multipart/form-data' \
  -F 'data=@test.txt;type=text/plain' \
  -F 'datasetName=test' \
  -F 'datasetId=' \
  -F 'node_set=nomde_do_node'  # this field is critical, or else it does not generate a node!!!
```

Now before viewing the graph use the cognify section... this builds the graph
using baml mode because instructor requires parallelism and llama.cpp is not keen on it...

```
curl -X 'POST' \
  'http://localhost:8000/api/v1/cognify' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "datasets": [
    "test"
  ],
  "datasetIds": [],
  "runInBackground": false,
  "customPrompt": "",
  "ontologyKey": [],
  "chunksPerBatch": 10
}'
```


after that use the dataset_id obtained above when creating the dataset:

```
curl http://localhost:8000/v1/datasets/{dataset_id}/graph/visualization > graph.html
```

if you go to visualize section on http://localhost:8000/docs you get the corresponding code, like this for example:
      
curl -X 'GET' \
  'http://localhost:8000/api/v1/visualize?dataset_id=40dbcd5b-8196-595f-a325-bd3f81c8ae38'
