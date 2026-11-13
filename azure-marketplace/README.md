# Azure Marketplace bundle (AKS Kubernetes application)

Packaging of the Windmill chart as a Microsoft Marketplace "Azure Container" offer for AKS.
The offer is bring-your-own-licence: the customer installs Windmill Enterprise Edition from
the Azure portal and enters a licence key in Instance settings afterwards.

## What is here

| File | Purpose |
| --- | --- |
| `manifest.yaml` | Bundle manifest read by Microsoft's packaging tool (`cpa`). |
| `windmill-aks/` | Wrapper chart. Declares every image under `global.azure.images` (a marketplace requirement) and pulls in `charts/windmill` unpacked. |
| `mainTemplate.json` | ARM template that installs the bundle as a cluster extension on an existing AKS cluster. |
| `createUiDefinition.json` | The Azure portal form. |
| `build.sh` | Assembles `dist/` and pins the linux/amd64 image digests from the registry. |

The main chart only gained the `windmill.imageRef` helper: when `global.azure.images.<name>`
is unset, image references render exactly as before.

## Releasing a new bundle version

Marketplace customers only receive a new Windmill version when a new bundle is submitted.

1. Import the images for the chart's `appVersion` into the registry (marketplace accepts
   linux/amd64 only; the build script picks that digest out of the multi-arch manifest):

   ```bash
   V=$(awk '/^appVersion:/{print $2}' ../charts/windmill/Chart.yaml)
   az acr import -n windmillmarketplace --source ghcr.io/windmill-labs/windmill-ee:$V --image windmill-ee:$V
   az acr import -n windmillmarketplace --source ghcr.io/windmill-labs/windmill-extra:$V --image windmill-extra:$V
   az acr import -n windmillmarketplace --source docker.io/library/postgres:18 --image postgres:18 --force
   ```

2. Assemble the bundle sources with a new `#.#.#` bundle version: `./build.sh 1.0.1`

3. On a Linux AMD64 host with Docker (the packaging tool does not run on macOS/ARM), with
   `dist/` copied to `~/wm-azmp` and `docker login windmillmarketplace.azurecr.io` done:

   ```bash
   docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
     -v $HOME/.docker/config.json:/root/.docker/config.json:ro -v $HOME/wm-azmp:/data \
     --entrypoint /bin/bash mcr.microsoft.com/container-package-app:latest \
     -c "cd /data && cpa verify && cpa buildbundle"
   ```

   When copying from macOS, use `COPYFILE_DISABLE=1 tar --no-xattrs` so no `._*` files end up
   in the chart (the validator rejects them).

4. In Partner Center, select the new bundle tag on the offer's technical configuration and
   submit.

## Bundle versions

| Bundle | Windmill | Status |
| --- | --- | --- |
| 1.0.0 | 1.866.0 | Submitted 10 November 2026. |
| 1.0.1 | 1.873.0 (chart 4.0.320) | Built 13 November 2026 as `windmillmarketplace.azurecr.io/dev.windmill.enterprise:1.0.1` (`sha256:4242d41c33a1b2e0e75057f57f98bbe8586b4db688767e70008de9770484a616`) and submitted to Microsoft Partner Center the same day; in certification, not yet live. Changes vs 1.0.0: PostgreSQL persistence (50Gi on the cluster's default storage class); cluster-size warning and licence note in `createUiDefinition.json` (details below). |

Changes in 1.0.1, from the preview install test of 1.0.0 on 12 November 2026:

- The bundled PostgreSQL gets a persistent volume (`windmill.postgresql.persistence.enabled: true`
  in `windmill-aks/values.yaml`): a StatefulSet with a 50Gi PVC on the cluster's default storage
  class. In 1.0.0 it was a Deployment without a volume, so its data was lost on every pod restart.
  Upgrading an install from 1.0.0 replaces that Deployment, so the 1.0.0 evaluation data is not
  carried over. Uninstalling does not delete the PVC (StatefulSet claims are retained); delete it
  to release the disk.
- The portal form states the minimum cluster size and that jobs do not run until a licence key is
  entered. With the default settings the pods request 17 GiB of memory in total (the chart sets
  memory limits only, which Kubernetes also uses as requests): app 2 x 2Gi, default workers
  3 x 2Gi, native worker 2Gi, indexer 2Gi, bundled PostgreSQL 2Gi, windmill-extra 1Gi. On
  2 x Standard_D2as_v5 (8 GiB each) five pods stayed Pending and the extension never left
  "Creating"; on 2 x Standard_D4as_v5 (16 GiB each) it installed in 6m26s with 9/9 pods Running.
  The requests are unchanged: the chart gives no guidance that would justify lower values.
- The licence InfoBox at the top of the Windmill step (added after 1.0.0) ships for the first time.

`cpa verify` passed on these changes when 1.0.1 was built on 13 November 2026.

## One-time registry setup (already done for `windmillmarketplace`)

Microsoft's marketplace application (`32597670-3e15-4def-8851-614ff48c1efa`) has `AcrPull` on
the registry, and the `Microsoft.PartnerCenterIngestion` provider is registered on the
subscription. The registry must stay in the Entra tenant linked to the Partner Center account.
