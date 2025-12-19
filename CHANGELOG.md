# Changelog

## 4.x

> **⚠️ Breaking Change:**
> Workers now run with privileged security context by default and use `UNSHARE_PID` by default for [PID namespace isolation](https://www.windmill.dev/docs/advanced/security_isolation#pid-namespace-isolation-recommended-for-production).

The privileged security context allows overriding cgroup v2 behavior to disable `oom.group`, so that jobs can be killed without killing the entire container.

By default, cgroup v2 on Kubernetes 1.32+ uses `oom.group=1`, which results in killing the whole worker instead of just the job whenever a job exceeds memory limits. In most cases, this would be the proper behavior, but not for Windmill which has proper `oom_adj_score` priority and handles OOM kills on jobs gracefully.

To disable privileged mode for a worker group, set `privileged: false` in the worker group configuration.

## 3.x

> **⚠️ Breaking Change:**
> The 3.x release introduces a breaking change due to the migration of the demo PostgreSQL and demo MinIO from Bitnami subcharts to the vanilla MinIO subchart and vanilla non-persistent PostgreSQL pods.

These demo services are intended **only for testing or demo purposes** and should **not** be used in production environments under any circumstances. They are not configured for persistence.
