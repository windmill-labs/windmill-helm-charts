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

## One-time registry setup (already done for `windmillmarketplace`)

Microsoft's marketplace application (`32597670-3e15-4def-8851-614ff48c1efa`) has `AcrPull` on
the registry, and the `Microsoft.PartnerCenterIngestion` provider is registered on the
subscription. The registry must stay in the Entra tenant linked to the Partner Center account.
