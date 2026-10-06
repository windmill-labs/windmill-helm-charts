# Security profiles for nsjail without a privileged container

[nsjail sandboxing](https://www.windmill.dev/docs/advanced/security_isolation#nsjail-sandboxing) builds each job its own PID and mount namespaces. A container runtime's default seccomp and AppArmor profiles block the system calls and mounts this takes, so a worker group that sets [`isolationSecurity`](../README.md#running-nsjail-without-privileged-workers) runs with both `Unconfined` unless it names profiles installed on the nodes.

The two profiles here are the runtime defaults with only what nsjail needs added, so the worker keeps a seccomp filter and an AppArmor profile.

| File | Purpose |
| --- | --- |
| `windmill-nsjail.seccomp.json` | Docker's default seccomp profile plus `clone` with namespace flags, `mount`, `umount2`, `pivot_root` and `sethostname` |
| `windmill-nsjail.apparmor` | The [runtime default AppArmor profile](https://github.com/moby/profiles/blob/main/apparmor/template.go) with `deny mount` replaced by `mount`, `umount` and `pivot_root` rules; every other rule, including the denied socket families, is kept |
| `generate-seccomp.py` | Rebuilds the seccomp profile from a newer Docker default |

## Installing the profiles on Kubernetes nodes

Both profiles are read from the node, so they have to be present on every node that runs workers.

```bash
# seccomp: relative to the kubelet's seccomp directory
sudo install -D -m 0644 windmill-nsjail.seccomp.json /var/lib/kubelet/seccomp/profiles/windmill-nsjail.json

# AppArmor: only on nodes where AppArmor is enabled
sudo install -m 0644 windmill-nsjail.apparmor /etc/apparmor.d/windmill-nsjail
sudo apparmor_parser -r /etc/apparmor.d/windmill-nsjail
```

Then name them in the worker group:

```yaml
windmill:
  workerGroups:
    - name: "default"
      isolationSecurity: userNamespaces
      localhostProfiles:
        seccomp: profiles/windmill-nsjail.json
        appArmor: windmill-nsjail
```

A pod that references a profile missing from its node fails to start, so node groups that autoscale need these steps in their bootstrap or in a DaemonSet. On nodes without AppArmor, leave `appArmor` out.

## Using the profiles with Docker

```bash
sudo install -m 0644 windmill-nsjail.apparmor /etc/apparmor.d/windmill-nsjail
sudo apparmor_parser -r /etc/apparmor.d/windmill-nsjail

docker run \
  --user 1000:1000 --cap-drop ALL \
  --security-opt no-new-privileges \
  --security-opt systempaths=unconfined \
  --security-opt seccomp=windmill-nsjail.seccomp.json \
  --security-opt apparmor=windmill-nsjail \
  -e DISABLE_NSJAIL=false \
  ...
```

## What the profiles give up

Jobs inherit the seccomp filter, so job code can also call `clone` with namespace flags and `mount`, which the runtime default denies to a container without `SYS_ADMIN`. Where the kernel allows unprivileged user namespaces, a job can therefore create a nested user and mount namespace and mount filesystems inside it. This grants nothing outside that namespace, but it exposes more of the kernel to job code than the runtime default does.

The AppArmor profile no longer denies mounts, so its path rules on `/proc` and `/sys` do not hold against a process that can mount those filesystems elsewhere. Both profiles remain far narrower than `Unconfined` or `privileged: true`.

## Regenerating the seccomp profile

`windmill-nsjail.seccomp.json` is derived from the [default profile of the Moby project](https://github.com/moby/profiles/blob/main/seccomp/default.json) (Apache License 2.0). To rebase it on a newer default:

```bash
curl -fsSLO https://raw.githubusercontent.com/moby/profiles/main/seccomp/default.json
python3 generate-seccomp.py default.json windmill-nsjail.seccomp.json
```
