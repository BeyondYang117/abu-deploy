# 升级指南

自托管升级请：

1. 阅读本仓库 [`releases/`](./releases/) 中对应版本说明（破坏性变更 / 迁移 / 回滚）
2. 将 `ABU_API_IMAGE` **钉在明确 tag**（推荐 `abu116/abu-api-team:vX.Y.Z`），避免盲目跟 `latest`
3. 备份 `.env` 与数据后再 `docker compose pull && docker compose up -d`
4. 核对 `/api/status` 返回的 `version`

## 当前正式版本

- **[v1.0.0](./releases/v1.0.0.md)** — SemVer 重开，主线 `abu-api-team`

## 版本策略（摘要）

| 项 | 说明 |
|----|------|
| 格式 | `vMAJOR.MINOR.PATCH`（可带预发布后缀） |
| 主线镜像 | `abu116/abu-api-team` |
| 非主推 | `abu116/abu-api` |
| 历史四段号 | 如 `v0.4.0.2`，仅作归档，不再发正式版 |

应用内「更新日志」与官方更新检查 feed 与发版说明同源；本仓库同步运维向摘要，方便只使用部署模板的用户。
