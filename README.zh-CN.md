# abu-deploy

[English](./README.md) | 简体中文

Abu API 官方自托管部署模板。

- 镜像公开可拉取，**无需授权码即可部署**（内置免费个人版）
- 需要更高额度或企业能力时，再申请授权升级
- 本仓库开源部署配置与脚本；应用能力边界见 [FEATURES.md](./FEATURES.md)

授权门户：[https://www.abuai.chat/](https://www.abuai.chat/)

## 在线演示与正式站点

| | 地址 | 说明 |
|--|------|------|
| 演示站 | [http://129.213.115.171:8003/](http://129.213.115.171:8003/) | 账号 `admin` / 密码 `abuai@111111` |
| 正式站 | [https://api.abusz.com/](https://api.abusz.com/) | 生产环境 |

演示站仅供体验，数据可能被重置；请勿存放真实密钥或生产业务数据。

## 目录

```
abu-deploy/
├── standalone/          # 单机 + SQLite（推荐起步）
├── cluster/             # 小集群（1 master + N slaves + HAProxy）
├── examples/
│   ├── mysql/           # 单机 + MySQL 8
│   └── postgres/        # 单机 + PostgreSQL 16
├── scripts/             # 一键启动脚本
├── FEATURES.md          # 功能与授权对照
├── README.md            # English
└── README.zh-CN.md      # 简体中文
```

## 要求

- Docker Engine 24+ 与 Docker Compose v2
- 单机：约 2 CPU / 4 GB RAM（SQLite + Redis）
- 小集群：外部 MySQL，建议 4 CPU / 8 GB+ RAM；多实例容量受授权约束

## 镜像说明

| 镜像 | 内容 | 适用 |
|------|------|------|
| `abu116/abu-api-team:latest` | **最新版**（含团队版能力） | **默认**：单机与小集群均用此镜像 |
| `abu116/abu-api:latest` | 个人/核心版，**不含团队版能力** | 仅在明确只要非团队镜像线时使用 |

`standalone/` 与 `cluster/` 默认均为 `abu-api-team`。个人版仍可 `LICENSE_CODE` 留空免费使用；升级团队授权后解锁更高额度。可用 `ABU_API_IMAGE` 覆盖。

## 单机免费部署

```bash
git clone https://github.com/BeyondYang117/abu-deploy.git
cd abu-deploy/standalone
cp .env.example .env
# 至少修改 REDIS_PASSWORD / SESSION_SECRET / CRYPTO_SECRET / CARD_ENCRYPTION_KEY
docker compose up -d
curl http://127.0.0.1:3004/ready
```

或：

```bash
./scripts/deploy-standalone.sh
```

默认使用 SQLite（`SQL_DSN=local`）。`LICENSE_CODE` 可留空。

访问入口：`http://127.0.0.1:3004`（仅本机；生产请加反向代理）。

## 数据库样例（MySQL / PostgreSQL）

SQLite 不够用时，可用以下样例（应用 + Redis 不变，仅数据库不同）。

### MySQL 8

```bash
cd examples/mysql
cp .env.example .env
# 修改 MYSQL_* 密码，并保持 SQL_DSN 一致
docker compose up -d
curl http://127.0.0.1:3004/ready
```

DSN 格式：`user:pass@tcp(mysql:3306)/abu_api?parseTime=true&interpolateParams=true`

### PostgreSQL 16

```bash
cd examples/postgres
cp .env.example .env
# 修改 POSTGRES_PASSWORD，并保持 SQL_DSN 一致
docker compose up -d
curl http://127.0.0.1:3004/ready
```

DSN **必须以** `postgres://` 或 `postgresql://` 开头，应用才会走 PostgreSQL：

`postgres://abu:pass@postgres:5432/abu_api?sslmode=disable`

注意：`standalone/`、`examples/mysql/`、`examples/postgres/` 默认都占用本机 `3004`，同一台机器不要同时用默认端口启动多套。

## 小集群部署

适合团队版 / 需要多实例的场景。模板在单机拉起 master + slaves + Redis + HAProxy；**MySQL 需自备**。

```bash
cd abu-deploy/cluster
cp .env.example .env
# 配置 SQL_DSN、密钥；按需填写 LICENSE_CODE（团队/企业）
# 首次可先迁移：
#   RUN_MIGRATE=1 ../scripts/deploy-cluster.sh
docker compose up -d
curl http://127.0.0.1:8004/ready
```

或：

```bash
RUN_MIGRATE=1 ./scripts/deploy-cluster.sh
```

默认固定 2 个 slave（`abu-api-slave-1/2`），与 `haproxy.cfg` 对齐。若增减节点，请同时改 compose 服务与 HAProxy 后端。

> 个人版面向单实例；小集群模板公开可部署，实际可运行实例数以授权为准。

## 功能与授权

试运行友情价，方便先用起来；正式定价可能调整，以 [授权门户](https://www.abuai.chat/) 为准。

| 版本 | 定位 | 镜像 | 部署模板 |
|------|------|------|----------|
| 个人版 | 永久免费；3 用户 / 5 渠道 / 10 令牌 / 1 实例 | `abu-api-team`（默认）或 `abu-api` | `standalone/` |
| 基础团队 | ¥9.9/月；10 用户 / 20 渠道 / 3 实例 | `abu-api-team` | `standalone/` + `cluster/` |
| 标准团队 | ¥29.9/月；20 用户 / 50 渠道 / 5 实例 | `abu-api-team` | `standalone/` + `cluster/` |
| 高级团队 | ¥59.9/月；50 用户 / 100 渠道 / 10 实例 | `abu-api-team` | `standalone/` + `cluster/` |
| 企业版 | 无限额度、SLA、定制与私有化 | `abu-api-team` | 联系销售 |

需要我们帮忙部署上线：**代部署服务费 ¥100 / 次**（一次性）。详见 [FEATURES.md](./FEATURES.md)。

## 常用命令

```bash
# 单机
cd standalone && docker compose ps && docker compose logs -f abu-api

# 小集群
cd cluster && docker compose ps && docker compose logs -f master

# 指定镜像版本（个人版与团队版是两条镜像线）
ABU_API_IMAGE=abu116/abu-api:vX.Y.Z docker compose up -d
ABU_API_IMAGE=abu116/abu-api-team:vX.Y.Z docker compose up -d
```

## 安全建议

- 首次启动前务必替换 `.env` 中所有 `CHANGE_ME_*`
- 不要将 `.env` 提交到 Git
- 生产环境用 Nginx / Caddy 终止 TLS，再反代到本机端口
- 升级前备份数据卷与数据库

## 与私有主仓的关系

- `abu-api`：产品源码（私有）
- `abu-deploy`：公开部署入口（本仓库）
- 镜像由官方构建并推送到公共 Registry；本仓库只消费镜像 tag

## License

部署模板与脚本以 [Apache License 2.0](./LICENSE) 开源。  
Abu API 应用镜像的使用受产品授权条款约束；免费个人版可直接部署，高级能力需另行授权。
