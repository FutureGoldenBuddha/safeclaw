# Tutorial: Cognee + OpenClaw + pgvector + BAML — Do Zero ao Funcionando

> **Abordagem first-principles:** antes de cada passo de instalação, explicamos *por que* ele existe e *o que acontece* por baixo dos panos.

---

## 0. O Mapa Mental: O Que Você Está Montando e Por Quê

Antes de instalar qualquer coisa, entenda o problema que esse stack resolve.

**O problema central:** agentes de IA (como o OpenClaw) têm memória efêmera. Cada sessão começa do zero. Quando o agente "aprende" algo — preferências do usuário, decisões de arquitetura, contextos de projetos — esse conhecimento se perde. O OpenClaw resolve isso parcialmente com arquivos Markdown, mas arquivos Markdown são texto plano: não modelam *relações* entre conceitos, não fazem busca semântica, e não escalam para projetos complexos.

**A solução em camadas:**

```
┌─────────────────────────────────────────────────────────┐
│                   OpenClaw (o agente)                   │
│  — executa tarefas, escreve código, conversa           │
│  — tem memória nativa em Markdown (~/.openclaw/)        │
└───────────────────────┬─────────────────────────────────┘
                        │ plugin @cognee/cognee-openclaw
                        ▼
┌─────────────────────────────────────────────────────────┐
│                   Cognee (camada de memória)             │
│  — consome os arquivos .md e constrói um grafo          │
│  — busca contexto relevante antes de cada prompt        │
│  — usa BAML para extração tipada de entidades/relações  │
└───────────────────────┬─────────────────────────────────┘
                        │ usa como storage
                        ▼
┌─────────────────────────────────────────────────────────┐
│          PostgreSQL + pgvector (o armazém)               │
│  — guarda embeddings (vetores) e o grafo de relações    │
│  — viabiliza busca por similaridade semântica           │
└─────────────────────────────────────────────────────────┘
```

**BAML** entra como a "cola de tipos" entre o LLM e o Cognee: em vez de pedir ao modelo uma resposta em JSON livre (frágil), o BAML define *contratos* — schemas declarativos que o modelo é obrigado a respeitar, com validação e retry automáticos.

---

## 1. Conceitos Fundamentais (Leia Antes de Instalar)

### 1.1 OpenClaw — O Agente

OpenClaw é um assistente de IA open-source (MIT) que roda localmente e se conecta a WhatsApp, Telegram, Slack, Discord e terminais. Começou como "Clawdbot" em novembro de 2025, foi renomeado após reclamação de trademark da Anthropic (fonética próxima demais ao mascote deles), e hoje tem mais de 200k estrelas no GitHub.

A memória nativa do OpenClaw funciona assim:

```
~/.openclaw/workspace/
├── MEMORY.md         # fatos duráveis: preferências, decisões
└── memory/
    ├── 2026-02-04.md # log diário da sessão
    └── 2026-02-05.md
```

No início de cada sessão, o `MEMORY.md` é injetado no system prompt automaticamente. Simples, auditável, versionável com Git. O problema: sem relações, sem grafo, sem busca semântica.

### 1.2 Cognee — A Camada de Memória

Cognee é um *memory engine* para agentes de IA. Ele processa documentos/textos, extrai entidades e relações, constrói um knowledge graph, e armazena embeddings vetoriais. Quando o agente vai responder algo, o Cognee busca no grafo o contexto mais relevante e o injeta no prompt — sem inflar o contexto com texto desnecessário.

Fluxo interno do Cognee:
1. **Ingest:** recebe texto (markdown, PDFs, código)
2. **Chunk:** divide em pedaços (~400 tokens, 80 de overlap)
3. **Embed:** gera vetores para cada chunk (via OpenAI, Anthropic, etc.)
4. **Extract:** usa LLM (com BAML ou Instructor) para extrair entidades e relações
5. **Graph:** persiste nós e arestas no banco de grafos
6. **Search:** dado um query, encontra o subgrafo mais relevante

### 1.3 pgvector — Busca Vetorial no PostgreSQL

Vetores (embeddings) são arrays de floats — representações numéricas do *significado* de um texto. Para encontrar memórias relevantes, você precisa de "busca por vizinhos mais próximos" (nearest-neighbor search). O pgvector adiciona esse tipo de índice diretamente ao PostgreSQL.

Por que PostgreSQL + pgvector em vez de Pinecone/Qdrant/Weaviate?

- **Sem nova infraestrutura:** você já tem (ou vai ter) Postgres
- **SQL nativo:** joins entre dados relacionais e vetoriais na mesma query
- **Transações ACID:** consistência garantida ao atualizar memórias
- **Para o Cognee:** pgvector cobre tanto o armazenamento vetorial *quanto* o de grafo relacional

### 1.4 BAML — Outputs Tipados do LLM

BAML (BoundaryML) é uma DSL (linguagem específica de domínio) para construir contratos de chamada LLM. Em vez de:

```python
# Frágil: e se o modelo não retornar JSON válido?
response = llm.complete("Extraia entidades. Retorne JSON.")
data = json.loads(response)  # 💥 pode falhar silenciosamente
```

Você faz:

```baml
function ExtractEntities(text: string) -> KnowledgeGraph {
  client OpenAI
  prompt #"
    Extraia entidades e relações do texto abaixo.
    {{ ctx.output_format }}
    {{ _.role('user') }}
    {{ text }}
  "#
}
```

O BAML garante validação de schema, retry automático com json-repair, geração de clientes tipados (Python, TypeScript), e versionamento de prompts como código.

**No Cognee:** seus modelos Pydantic são *automaticamente* convertidos em tipos BAML em runtime — zero duplicação de schema.

---

## 2. Pré-requisitos

| Ferramenta | Versão mínima | Verificação |
|---|---|---|
| Node.js | 18+ | `node --version` |
| Python | 3.11+ | `python --version` |
| Docker + Docker Compose | qualquer recente | `docker --version` |
| OpenClaw | 2026.2.3-1+ | `openclaw --version` |
| git | qualquer | `git --version` |

Você vai precisar de uma API key de um provedor LLM. O Cognee usa OpenAI como padrão para embeddings, mas suporta Anthropic, AWS Bedrock, Azure e outros.

---

## 3. Instalação: PostgreSQL + pgvector via Docker

### Por que Docker aqui?

pgvector precisa ser compilado como extensão do PostgreSQL. Usar a imagem oficial `pgvector/pgvector` elimina esse trabalho — ela já vem com a extensão pré-compilada.

### 3.1 Criar o arquivo Docker Compose

Crie uma pasta de projeto e o arquivo de configuração:

```bash
mkdir ~/cognee-stack && cd ~/cognee-stack
```

Crie o arquivo `docker-compose.yml`:

```yaml
version: "3.9"

services:
  # ─── Banco de dados: PostgreSQL + pgvector ───────────────────────
  postgres:
    image: pgvector/pgvector:pg16
    container_name: cognee_postgres
    environment:
      POSTGRES_USER: cognee
      POSTGRES_PASSWORD: cognee_secret
      POSTGRES_DB: cognee_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U cognee -d cognee_db"]
      interval: 5s
      timeout: 5s
      retries: 10

  # ─── Cognee: servidor de memória ─────────────────────────────────
  cognee:
    image: ghcr.io/topoteretes/cognee-server:latest
    container_name: cognee_server
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      # Banco
      DB_PROVIDER: postgres
      DB_HOST: postgres
      DB_PORT: 5432
      DB_USER: cognee
      DB_PASSWORD: cognee_secret
      DB_NAME: cognee_db

      # Storage vetorial (pgvector no mesmo postgres)
      VECTOR_DB_PROVIDER: pgvector
      VECTOR_DB_URL: postgresql://cognee:cognee_secret@postgres:5432/cognee_db

      # LLM (troque pela sua chave)
      LLM_PROVIDER: openai                   # ou: anthropic, bedrock, azure
      LLM_MODEL: gpt-4o-mini
      OPENAI_API_KEY: ${OPENAI_API_KEY}

      # Embeddings
      EMBEDDING_PROVIDER: openai
      EMBEDDING_MODEL: text-embedding-3-small
      EMBEDDING_API_KEY: ${OPENAI_API_KEY}

      # BAML como framework de output estruturado
      STRUCTURED_OUTPUT_FRAMEWORK: BAML
      BAML_LLM_PROVIDER: openai
      BAML_LLM_MODEL: gpt-4o-mini
      BAML_LLM_API_KEY: ${OPENAI_API_KEY}

    ports:
      - "8000:8000"
    volumes:
      - cognee_data:/app/data

volumes:
  postgres_data:
  cognee_data:
```

### 3.2 Criar o arquivo de variáveis de ambiente

```bash
# Crie o .env com suas chaves
cat > .env << 'EOF'
OPENAI_API_KEY=sk-sua-chave-aqui

# Se usar Anthropic em vez de OpenAI:
# ANTHROPIC_API_KEY=sk-ant-sua-chave-aqui
# LLM_PROVIDER=anthropic
# LLM_MODEL=claude-3-5-haiku-20241022
# BAML_LLM_PROVIDER=anthropic
# BAML_LLM_MODEL=claude-3-5-haiku-20241022
# BAML_LLM_API_KEY=${ANTHROPIC_API_KEY}
EOF
```

### 3.3 Subir o stack

```bash
docker compose up -d

# Acompanhe os logs para garantir que tudo subiu
docker compose logs -f cognee
```

Aguarde a mensagem `Application startup complete` nos logs do Cognee. Normalmente leva 30–60 segundos na primeira execução (download das imagens + inicialização do banco).

### 3.4 Verificar que o pgvector está ativo

```bash
docker exec cognee_postgres psql -U cognee -d cognee_db -c "SELECT * FROM pg_extension WHERE extname = 'vector';"
```

Você deve ver uma linha com `vector` na coluna `extname`. Se não aparecer, o Cognee vai criá-la automaticamente no primeiro uso (ele roda `CREATE EXTENSION IF NOT EXISTS vector` durante o setup).

### 3.5 Verificar a API do Cognee

```bash
curl http://localhost:8000/api/v1/health
# Resposta esperada: {"status": "healthy"}

# Abra também o Swagger UI para explorar a API interativamente:
# http://localhost:8000/docs
```

---

## 4. Autenticação: Criar Usuário e Obter Token

O Cognee usa autenticação Bearer token. Você precisa criar um usuário e fazer login para obter o token que o plugin do OpenClaw vai usar.

```bash
# 1. Registrar usuário
curl -X POST "http://localhost:8000/api/v1/users/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "seu@email.com",
    "password": "sua-senha-segura"
  }'

# 2. Login e captura do token
TOKEN=$(curl -s -X POST "http://localhost:8000/api/v1/users/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "seu@email.com",
    "password": "sua-senha-segura"
  }' | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

echo "Seu token: $TOKEN"
```

Guarde esse token — você vai precisar dele no próximo passo.

```bash
# Salve no seu .env para não perder
echo "COGNEE_API_KEY=$TOKEN" >> .env
```

---

## 5. Instalação do OpenClaw

Se você ainda não tem o OpenClaw instalado:

```bash
# Via npm (global)
npm install -g openclaw

# Verificar instalação
openclaw --version
```

O OpenClaw cria sua estrutura de diretórios na primeira execução:

```
~/.openclaw/
├── config.yaml          # configuração global
└── workspace/
    ├── MEMORY.md        # memória durável (criado na primeira sessão)
    └── memory/          # logs diários
```

---

## 6. Instalação do Plugin Cognee para OpenClaw

### 6.1 Por que o plugin existe?

O OpenClaw tem um sistema de plugins que permite estender seu comportamento em pontos específicos do ciclo de vida: startup, pré-execução, pós-execução. O plugin Cognee se registra nesses hooks para sincronizar memórias automaticamente — você não precisa fazer nada manualmente.

### 6.2 Instalar via npm

```bash
# Instalação direta (recomendado para produção)
openclaw plugins install @cognee/cognee-openclaw

# Verificar instalação
openclaw plugins list
```

### 6.3 Instalar em modo desenvolvimento (opcional)

Se quiser customizar o plugin ou entender seu funcionamento:

```bash
git clone https://github.com/topoteretes/cognee-integrations.git
cd cognee-integrations/integrations/openclaw
npm install
npm run build
openclaw plugins install -l .
```

---

## 7. Configuração do Plugin

### 7.1 Editar o config do OpenClaw

Abra `~/.openclaw/config.yaml` e adicione a seção de plugins:

```yaml
# ~/.openclaw/config.yaml

plugins:
  entries:
    memory-cognee:
      enabled: true
      config:
        # URL do servidor Cognee (rodando via Docker)
        baseUrl: "http://localhost:8000"

        # Token de autenticação — use variável de ambiente (mais seguro)
        apiKey: "${COGNEE_API_KEY}"

        # Nome do dataset: separa memórias por projeto
        # Use nomes diferentes para projetos diferentes
        datasetName: "meu-projeto"

        # Tipo de busca no grafo:
        # GRAPH_COMPLETION — mais rico, traversa relações (recomendado)
        # CHUNKS           — retorna chunks de texto diretamente
        # SUMMARIES        — retorna resumos de cada documento
        searchType: "GRAPH_COMPLETION"

        # Injetar contexto relevante antes de cada prompt
        autoRecall: true

        # Sincronizar arquivos de memória após cada sessão
        autoIndex: true

        # Número de resultados de memória a injetar (default: 5)
        recallLimit: 5
```

### 7.2 Exportar a variável de ambiente

```bash
# Adicione ao seu ~/.bashrc, ~/.zshrc, ou equivalente
export COGNEE_API_KEY="seu-token-aqui"

# Para a sessão atual
source ~/.bashrc
```

---

## 8. Entendendo o Fluxo de Dados (First Principles)

Agora que tudo está instalado, vamos entender o que acontece em cada etapa de uma sessão do OpenClaw.

### 8.1 Ciclo de vida de uma sessão

```
Usuário executa: openclaw
        │
        ▼
[Plugin: ON_STARTUP]
  1. Lê ~/.openclaw/workspace/MEMORY.md e memory/*.md
  2. Calcula hash MD5 de cada arquivo
  3. Compara com ~/.openclaw/memory/cognee/sync-index.json
  4. Para arquivos novos/modificados:
     POST /api/v1/datasets/{datasetName}/data  (upload do markdown)
     POST /api/v1/cognify                       (processa: chunk → embed → extract → graph)
  5. Atualiza sync-index.json
        │
        ▼
Usuário digita um prompt: "qual era a decisão sobre o banco de dados?"
        │
        ▼
[Plugin: BEFORE_AGENT_RUN]
  1. GET /api/v1/search?query="{prompt}"&searchType=GRAPH_COMPLETION
  2. Cognee busca no pgvector (busca semântica) + grafo (traversal)
  3. Retorna fragmentos de memória relevantes
  4. Plugin injeta no system prompt:
     "Contexto relevante da memória:\n- [memórias encontradas]"
        │
        ▼
[Agente executa com contexto enriquecido]
  → LLM recebe o prompt + contexto de memória
  → Responde com base no histórico real do projeto
        │
        ▼
[Plugin: AFTER_AGENT_RUN]
  1. O agente pode ter escrito novos fatos no MEMORY.md
  2. Re-escaneia os arquivos
  3. Sincroniza mudanças com o Cognee
```

### 8.2 O que o BAML faz nesse fluxo?

Durante o passo de **cognify** (processamento), o Cognee precisa extrair entidades e relações do texto para construir o grafo. Sem BAML, isso seria um prompt livre sujeito a erros de parsing. Com BAML:

```
Texto Markdown
     │
     ▼ BAML function: AcreateStructuredOutput(text, system_prompt) -> KnowledgeGraph
     │
     ▼ LLM retorna JSON validado contra o schema
     │
     ▼ Nós e arestas tipados persistidos no pgvector/grafo
```

Se o LLM retornar JSON malformado, o BAML usa um algoritmo de json-repair antes de falhar — reduzindo drasticamente os erros silenciosos.

---

## 9. Uso na Prática

### 9.1 Iniciar o OpenClaw com memória Cognee

```bash
# Certifique-se que o Docker stack está rodando
docker compose -f ~/cognee-stack/docker-compose.yml ps

# Inicie o OpenClaw (o plugin vai sincronizar automaticamente)
openclaw
```

Na inicialização, você verá logs como:
```
[cognee-plugin] Scanning memory files...
[cognee-plugin] Found 3 files to sync
[cognee-plugin] Syncing MEMORY.md... ✓
[cognee-plugin] Syncing memory/2026-02-26.md... ✓
[cognee-plugin] Memory sync complete (2 new, 1 unchanged)
```

### 9.2 Verificar o status de sincronização

```bash
# Ver arquivos indexados e pendentes
openclaw cognee status

# Forçar re-sincronização manual
openclaw cognee index
```

### 9.3 Diferentes tipos de busca

O parâmetro `searchType` na configuração controla como o Cognee recupera contexto:

**GRAPH_COMPLETION** (recomendado para memória de projetos):
Traversa o grafo de relações. Se você mencionou "usar PostgreSQL porque o Redis não aguentaria o volume", o GRAPH_COMPLETION consegue conectar "decisão de banco" → "PostgreSQL" → "motivo: volume" mesmo que sejam documentos diferentes.

**CHUNKS** (bom para recuperação literal):
Retorna os chunks de texto mais próximos semanticamente. Útil quando você quer encontrar trechos específicos, como snippets de código ou configurações.

**SUMMARIES** (bom para visão geral):
Retorna resumos de documentos completos. Útil quando o contexto precisa de uma visão de alto nível.

### 9.4 Usar múltiplos datasets por projeto

Uma das features mais úteis é isolar memórias por projeto:

```yaml
# Projeto A
datasetName: "projeto-ecommerce"

# Projeto B (em outro config.yaml ou via --dataset flag)
datasetName: "projeto-analytics"
```

Isso garante que o contexto de um projeto não vaze para outro.

---

## 10. Configuração Avançada: BAML com Python

Se você quer usar o Cognee diretamente em Python com BAML (fora do OpenClaw), aqui está o setup completo.

### 10.1 Instalar dependências

```bash
pip install cognee baml-py

# Inicializar BAML no projeto
cd seu-projeto
baml init
```

### 10.2 Configurar variáveis de ambiente

```bash
# .env do seu projeto Python
STRUCTURED_OUTPUT_FRAMEWORK=BAML
BAML_LLM_PROVIDER=openai
BAML_LLM_MODEL=gpt-4o-mini
BAML_LLM_API_KEY=sk-sua-chave

EMBEDDING_API_KEY=sk-sua-chave

# Conexão com o pgvector
VECTOR_DB_PROVIDER=pgvector
VECTOR_DB_URL=postgresql://cognee:cognee_secret@localhost:5432/cognee_db
```

### 10.3 Exemplo: Extraindo Knowledge Graph com BAML

```python
import asyncio
import os
from pydantic import BaseModel, Field
from typing import List, Optional
from cognee.infrastructure.llm import LLMGateway

# 1. Definir o schema — seus modelos Pydantic viram tipos BAML automaticamente
class Entity(BaseModel):
    id: str = Field(description="Identificador único da entidade")
    type: str = Field(description="Categoria: Person, Organization, Concept, etc.")
    properties: dict = Field(default_factory=dict)

class Relation(BaseModel):
    source: str = Field(description="ID da entidade de origem")
    target: str = Field(description="ID da entidade de destino")
    type: str = Field(description="Tipo da relação: WORKS_AT, DECIDED, USES, etc.")

class KnowledgeGraph(BaseModel):
    entities: List[Entity] = Field(default_factory=list)
    relations: List[Relation] = Field(default_factory=list)
    summary: str = Field(description="Resumo de uma frase do conteúdo")

# 2. Extrair conhecimento estruturado
async def extract_knowledge(text: str) -> KnowledgeGraph:
    system_prompt = """Você é um especialista em extração de conhecimento.
    Extraia todas as entidades (pessoas, organizações, conceitos, tecnologias)
    e as relações entre elas do texto fornecido.
    Seja específico nos tipos de relação."""

    # BAML garante que o retorno respeita o schema KnowledgeGraph
    result = await LLMGateway.acreate_structured_output(
        text_input=text,
        system_prompt=system_prompt,
        response_model=KnowledgeGraph
    )
    return result

# 3. Usar com Cognee para persistir no pgvector
async def main():
    import cognee

    # Configurar conexão com pgvector
    await cognee.config.set_vector_db_config({
        "provider": "pgvector",
        "url": os.getenv("VECTOR_DB_URL")
    })

    # Texto de exemplo
    texto = """
    Em 26 de fevereiro de 2026, a equipe de engenharia da Acme Corp decidiu
    migrar de Redis para PostgreSQL com pgvector para o sistema de memória
    do agente. A decisão foi tomada por Ana Silva (engenheira-chefe) após
    testes de carga mostrarem que o Redis não suportaria mais de 10M vetores.
    O sistema usa o modelo text-embedding-3-small da OpenAI para embeddings.
    """

    # Adicionar ao Cognee (vai usar BAML internamente para extração)
    await cognee.add(texto, dataset_name="decisoes-arquitetura")
    await cognee.cognify()

    # Buscar contexto relevante
    resultados = await cognee.search(
        "decisão sobre banco de dados",
        query_type="GRAPH_COMPLETION"
    )

    for resultado in resultados:
        print(resultado)

    # Extrair diretamente com BAML (sem persistir)
    kg = await extract_knowledge(texto)
    print(f"\nEntidades encontradas: {len(kg.entities)}")
    for entidade in kg.entities:
        print(f"  • {entidade.id} [{entidade.type}]")
    print(f"\nRelações encontradas: {len(kg.relations)}")
    for relacao in kg.relations:
        print(f"  • {relacao.source} -[{relacao.type}]-> {relacao.target}")

asyncio.run(main())
```

### 10.4 Verificar que o BAML está sendo usado

```python
import cognee

# Ver configuração atual de output framework
config = await cognee.config.get_llm_config()
print(config)
# {"structured_output_framework": "BAML", "provider": "openai", ...}
```

---

## 11. Consultas Diretas no pgvector (SQL)

Uma das vantagens de usar pgvector é poder fazer queries SQL diretamente para inspecionar e depurar a memória.

```bash
# Conectar no banco
docker exec -it cognee_postgres psql -U cognee -d cognee_db
```

```sql
-- Ver tabelas criadas pelo Cognee
\dt

-- Ver os chunks indexados
SELECT
    id,
    LEFT(content, 100) AS conteudo_resumido,
    created_at,
    dataset_name
FROM vector_store
ORDER BY created_at DESC
LIMIT 10;

-- Busca por similaridade vetorial (cosine distance)
-- Substitua '[0.1, 0.2, ...]' pelo embedding real do seu query
SELECT
    id,
    LEFT(content, 200) AS conteudo,
    1 - (embedding <=> '[0.1, 0.2, 0.3]'::vector) AS similaridade
FROM vector_store
ORDER BY embedding <=> '[0.1, 0.2, 0.3]'::vector
LIMIT 5;

-- Ver nós do grafo de conhecimento
SELECT * FROM graph_nodes LIMIT 20;

-- Ver arestas (relações)
SELECT
    n1.name AS origem,
    e.relation_type AS relacao,
    n2.name AS destino
FROM graph_edges e
JOIN graph_nodes n1 ON e.source_id = n1.id
JOIN graph_nodes n2 ON e.target_id = n2.id
LIMIT 20;
```

---

## 12. Troubleshooting

### O plugin não está sincronizando

```bash
# 1. Verificar se o servidor está acessível
curl http://localhost:8000/api/v1/health

# 2. Verificar se o token ainda é válido (tokens expiram)
curl -H "Authorization: Bearer $COGNEE_API_KEY" \
     http://localhost:8000/api/v1/users/me

# 3. Se expirou, gere um novo token
curl -X POST "http://localhost:8000/api/v1/users/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "seu@email.com", "password": "sua-senha"}'

# 4. Verificar logs do plugin
openclaw --log-level debug
```

### O BAML não está sendo usado / erros de parsing

```bash
# Verificar variável de ambiente
echo $STRUCTURED_OUTPUT_FRAMEWORK  # deve ser "BAML"

# Ver logs do servidor Cognee
docker compose logs cognee | grep -i baml

# Se houver erros de tipo, verifique se seus modelos Pydantic
# têm tipos específicos — BAML não consegue mapear `Any` ou `dict` sem annotation
```

### pgvector: extensão não encontrada

```sql
-- Conecte no postgres e crie manualmente se necessário
CREATE EXTENSION IF NOT EXISTS vector;

-- Verificar versão
SELECT extversion FROM pg_extension WHERE extname = 'vector';
-- Deve retornar >= 0.5.0
```

### Cognee não conecta no PostgreSQL

```bash
# Testar conexão manualmente
docker exec cognee_server python3 -c "
import psycopg2
conn = psycopg2.connect('postgresql://cognee:cognee_secret@postgres:5432/cognee_db')
print('Conexão OK:', conn.get_dsn_parameters())
"
```

---

## 13. Referência Rápida de Comandos

```bash
# ── Docker ──────────────────────────────────────────────
docker compose up -d              # Sobe o stack (postgres + cognee)
docker compose down               # Para tudo
docker compose logs -f cognee     # Acompanha logs do servidor
docker compose restart cognee     # Reinicia apenas o Cognee

# ── OpenClaw ────────────────────────────────────────────
openclaw                          # Inicia o agente (com sync automático)
openclaw cognee status            # Ver status de sincronização
openclaw cognee index             # Forçar re-sync manual
openclaw plugins list             # Ver plugins instalados

# ── Cognee API ──────────────────────────────────────────
# Health check
curl http://localhost:8000/api/v1/health

# Listar datasets
curl -H "Authorization: Bearer $COGNEE_API_KEY" \
     http://localhost:8000/api/v1/datasets

# Busca manual
curl -G "http://localhost:8000/api/v1/search" \
     -H "Authorization: Bearer $COGNEE_API_KEY" \
     --data-urlencode "query=decisão sobre banco de dados" \
     --data-urlencode "searchType=GRAPH_COMPLETION"

# ── PostgreSQL ───────────────────────────────────────────
docker exec -it cognee_postgres psql -U cognee -d cognee_db
```

---

## 14. Próximos Passos

Com o stack rodando, você pode:

1. **Mudar o provider de LLM para Anthropic:** altere `LLM_PROVIDER=anthropic`, `LLM_MODEL=claude-3-5-haiku-20241022`, e `BAML_LLM_PROVIDER=anthropic` no `docker-compose.yml`.

2. **Adicionar Neo4j para grafos complexos:** o Cognee suporta Neo4j como graph backend além do pgvector. Útil para projetos com muitas relações entre entidades.

3. **Integrar com CI/CD:** use `openclaw cognee index` como passo de pre-commit para manter a memória do projeto sempre atualizada.

4. **Criar datasets por branch Git:** automatize a criação de datasets diferentes por branch para isolar contextos de features em desenvolvimento.

5. **Explorar o Cognee Cloud:** para times, o [platform.cognee.ai](https://platform.cognee.ai) oferece memória compartilhada entre múltiplos agentes sem precisar gerenciar infraestrutura.

---

*Baseado na documentação oficial do Cognee, OpenClaw e BAML — fevereiro de 2026.*