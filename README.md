# chengzhou

Local workspace for content assets, scripts, and skill drafts.

## What is in this repo

- `detail-page-draft/`: generated product-detail draft images
- `logo/`: generated logo assets (64/128/512)
- `jiang-hushuo/`: local skill draft (`SKILL.md` + agent metadata)
- `make-detail-images.ps1`: generate detail-page draft images
- `make-chengzhou-logo.ps1`: generate logo images

## Quick start (PowerShell)

Run image detail generator:

```powershell
$code = Get-Content -LiteralPath ".\make-detail-images.ps1" -Raw -Encoding UTF8
Invoke-Expression $code
```

Run logo generator:

```powershell
$code = Get-Content -LiteralPath ".\make-chengzhou-logo.ps1" -Raw -Encoding UTF8
Invoke-Expression $code
```

## Git workflow

```powershell
git status
git add .
git commit -m "update assets"
git push
```
