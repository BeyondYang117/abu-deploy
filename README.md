# abu-deploy

English | [简体中文](./README.zh-CN.md)

Official self-host deploy templates for **Abu API**.

- Public images — **deploy without a license code** (built-in free Personal plan)
- Upgrade when you need higher limits or enterprise capabilities
- This repo opens the Compose stacks and scripts; limits are documented in [FEATURES.md](./FEATURES.md) (Chinese detail table)

License portal: [https://www.abuai.chat/](https://www.abuai.chat/)

## Demo & production

| | URL | Notes |
|--|-----|--------|
| Demo | [http://129.213.115.171:8003/](http://129.213.115.171:8003/) | `admin` / `abuai@111111` |
| Production | [https://api.abusz.com/](https://api.abusz.com/) | Live site |

Demo is for evaluation only — data may be reset. Do not store real secrets or production workloads there.

## Layout

```
abu-deploy/
├── standalone/          # single-host free deploy (start here)
├── cluster/             # small cluster (1 master + 2 slaves + HAProxy)
├── scripts/             # one-shot helpers
├── FEATURES.md          # plans & assisted-deploy fee (zh)
├── README.md            # English
└── README.zh-CN.md      # Simplified Chinese
```

## Requirements

- Docker Engine 24+ and Docker Compose v2
- Standalone: ~2 CPU / 4 GB RAM (SQLite + Redis)
- Small cluster: external MySQL; ~4 CPU / 8 GB+ RAM recommended; multi-instance capacity follows your license

## Images

| Image | Contains | Use when |
|-------|----------|----------|
| `abu116/abu-api-team:latest` | **Latest** (includes Team edition) | **Default** for standalone & cluster |
| `abu116/abu-api:latest` | Personal / core — **no Team edition** | Only if you explicitly want the non-Team channel |

Both templates default to `abu-api-team`. Free Personal still works with `LICENSE_CODE` empty; Team limits unlock after you set a Team license. Override with `ABU_API_IMAGE` if needed.

## Standalone (free)

```bash
git clone https://github.com/BeyondYang117/abu-deploy.git
cd abu-deploy/standalone
cp .env.example .env
# set REDIS_PASSWORD / SESSION_SECRET / CRYPTO_SECRET / CARD_ENCRYPTION_KEY
docker compose up -d
curl http://127.0.0.1:3004/ready
```

Or:

```bash
./scripts/deploy-standalone.sh
```

Defaults to SQLite (`SQL_DSN=local`). `LICENSE_CODE` may be left empty.

Entrypoint: `http://127.0.0.1:3004` (loopback only — put a reverse proxy in front for production).

## Small cluster

For Team plans / multi-instance. One host runs master + slaves + Redis + HAProxy; **bring your own MySQL**.

```bash
cd abu-deploy/cluster
cp .env.example .env
# set SQL_DSN, secrets; set LICENSE_CODE for Team / Enterprise as needed
# first-time migrate (optional):
#   RUN_MIGRATE=1 ../scripts/deploy-cluster.sh
docker compose up -d
curl http://127.0.0.1:8004/ready
```

Or:

```bash
RUN_MIGRATE=1 ./scripts/deploy-cluster.sh
```

Two fixed slaves (`abu-api-slave-1/2`) match `haproxy.cfg`. If you add/remove nodes, update both Compose and HAProxy.

> Personal is single-instance oriented. Cluster templates are public; runnable instance count follows your license.

## Plans & licensing

Soft-launch / trial pricing — subject to change; see the [license portal](https://www.abuai.chat/).

| Plan | Limits | Image | Templates |
|------|--------|-------|-----------|
| Personal | Free forever; 3 users / 5 channels / 10 tokens / 1 instance | `abu-api-team` (default) or `abu-api` | `standalone/` |
| Team Basic | ¥9.9/mo; 10 users / 20 channels / 3 instances | `abu-api-team` | `standalone/` + `cluster/` |
| Team Standard | ¥29.9/mo; 20 users / 50 channels / 5 instances | `abu-api-team` | `standalone/` + `cluster/` |
| Team Pro | ¥59.9/mo; 50 users / 100 channels / 10 instances | `abu-api-team` | `standalone/` + `cluster/` |
| Enterprise | Unlimited limits, SLA, custom & private deploy | `abu-api-team` | Contact sales |

Need help standing it up? **Assisted deploy: ¥100 one-time.** Details in [FEATURES.md](./FEATURES.md).

## Common commands

```bash
# standalone
cd standalone && docker compose ps && docker compose logs -f abu-api

# cluster
cd cluster && docker compose ps && docker compose logs -f master

# pin an image tag (Personal vs Team channels are different)
ABU_API_IMAGE=abu116/abu-api:vX.Y.Z docker compose up -d
ABU_API_IMAGE=abu116/abu-api-team:vX.Y.Z docker compose up -d
```

## Security

- Replace every `CHANGE_ME_*` in `.env` before first use
- Never commit `.env`
- Terminate TLS with Nginx / Caddy and reverse-proxy to the local port
- Back up volumes and the database before upgrades

## Relation to the private app repo

- `abu-api`: product source (private)
- `abu-deploy`: public deploy entry (this repo)
- Images are built and published by the project; this repo only consumes image tags

## License

Deploy templates and scripts are [Apache License 2.0](./LICENSE).  
Use of the Abu API application image is subject to product licensing — free Personal deploy is allowed; higher tiers require a license upgrade.
