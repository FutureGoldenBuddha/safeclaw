O problema é de rede: dentro de um devcontainer, `localhost` aponta para o próprio container, não para os outros serviços do compose. Há duas abordagens — qual você precisa depende de *de onde* quer acessar o `/docs`:

---

## Opção A — Acessar no browser do host (mais comum)

Configure o `devcontainer.json` para fazer port forward da porta do Cognee:

```json
// .devcontainer/devcontainer.json
{
  "forwardPorts": [8000],
  "portsAttributes": {
    "8000": {
      "label": "Cognee API",
      "onAutoForward": "openPreview"   // abre automaticamente no VS Code
    }
  }
}
```

Depois de rebuild do container, o VS Code cria um túnel e você acessa normalmente no browser do host:

```
http://localhost:8000/docs
```

O VS Code também faz isso automaticamente quando detecta um processo escutando numa porta — aparece a notificação "Port 8000 forwarded". Você pode clicar em "Open in Browser" direto.

---

## Opção B — Acessar de dentro do container (curl, scripts, etc.)

De dentro do devcontainer, use o **nome do serviço** definido no docker-compose como hostname:

```bash
# Se o serviço se chama "cognee" no docker-compose.yml:
curl http://cognee:8000/api/v1/health

# Abrir docs no browser integrado do VS Code:
# Ctrl+Shift+P → "Simple Browser: Show"  → http://cognee:8000/docs
```

Isso funciona porque todos os serviços do mesmo docker-compose estão na mesma rede bridge e se resolvem pelo nome do serviço via DNS interno do Docker.

---

## Verificar em qual rede estão os serviços

Se não souber o nome do serviço ou da rede:

```bash
# De dentro do devcontainer
docker network ls

# Ver os containers e IPs da rede do compose
docker network inspect <nome-da-rede> --format '{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}'

# Ou simplesmente
getent hosts cognee   # resolve o hostname do serviço
```

---

**Resumo prático:** para o `/docs` no browser, use `forwardPorts` no `devcontainer.json` (Opção A). Para scripts e código rodando dentro do container, troque `localhost` pelo nome do serviço no compose (Opção B).