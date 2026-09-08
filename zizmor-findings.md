# Zizmor-funn

Arbeidsoversikt for zizmor-scannen i fikse-branchen. Funnene er gruppert etter
regel og fil slik at gjentakende problemer kan løses som mønstre.

## Scan

- Dato: 2026-09-07
- Miljø: WSL
- zizmor: 1.30.0
- Konfigurasjon: [`zizmor.yml`](zizmor.yml)
- Policy for `unpinned-uses`:
  - `3lvia/*`: `ref-pin`
  - øvrige actions: `hash-pin`
- Omfang: 16 workflows og 15 composite actions (`*/action.yml`)
- Resultat: 135 workflow-funn og 27 composite-action-funn, totalt 162

## Sammendrag

| Område            | Funn | Status |
| ----------------- | ---: | ------ |
| Workflows         |  135 | Åpen   |
| Composite actions |   27 | Åpen   |
| Totalt            |  162 | Åpen   |

Dette er en arbeidsliste fra én scan. Den bør oppdateres etter hver
fix-gruppe og en ny scan bør brukes som fasit før branchen merges.

## Workflows

### Funn per regel

| Regel                   | Antall | Første prioritet |
| ----------------------- | -----: | ---------------- |
| `artipacked`            |     62 | Høy              |
| `github-app`            |     49 | Høy              |
| `self-repository`       |     10 | Medium           |
| `excessive-permissions` |      5 | Høy              |
| `adhoc-packages`        |      1 | Medium           |
| `obfuscation`           |      3 | Medium           |
| `template-injection`    |      5 | Høy              |

### Funn per fil

| Fil                                                             | Funn | Status |
| --------------------------------------------------------------- | ---: | ------ |
| `.github/workflows/test-actions.yaml`                           |   34 | Åpen   |
| `.github/workflows/update-starter-workflows.yaml`               |   12 | Åpen   |
| `.github/workflows/example-build-deploy-dotnet-google.yaml`     |   14 | Åpen   |
| `.github/workflows/example-build-deploy-dotnet.yaml`            |   14 | Åpen   |
| `.github/workflows/example-build-deploy-go-google.yaml`         |   10 | Åpen   |
| `.github/workflows/example-build-deploy-go.yaml`                |   10 | Åpen   |
| `.github/workflows/example-build-deploy-python-google.yaml`     |   10 | Åpen   |
| `.github/workflows/example-build-deploy-python.yaml`            |   10 | Åpen   |
| `.github/workflows/example-build-deploy-dockerfile-google.yaml` |    8 | Åpen   |
| `.github/workflows/example-build-deploy-dockerfile.yaml`        |    8 | Åpen   |
| `.github/workflows/check-format.yaml`                           |    3 | Åpen   |
| `.github/workflows/build-arc-image.yaml`                        |    1 | Åpen   |
| `.github/workflows/zizmor.yaml`                                 |    1 | Åpen   |

Tre workflows hadde ingen funn i denne scannen.

## Composite actions

### Funn per regel

| Regel                | Antall | Første prioritet |
| -------------------- | -----: | ---------------- |
| `template-injection` |     14 | Høy              |
| `artipacked`         |     11 | Høy              |
| `github-env`         |      1 | Høy              |
| `unsound-ternary`    |      1 | Medium           |

### Funn per action

| Action                          | Funn | Status |
| ------------------------------- | ---: | ------ |
| `trivy-iac-scan/action.yml`     |    8 | Åpen   |
| `slack-message/action.yml`      |    4 | Åpen   |
| `playwright/action.yml`         |    3 | Åpen   |
| `build/action.yml`              |    2 | Åpen   |
| `terraform-format/action.yml`   |    2 | Åpen   |
| `analyze/action.yml`            |    1 | Åpen   |
| `deploy/action.yml`             |    1 | Åpen   |
| `integrationtest/action.yml`    |    1 | Åpen   |
| `sonarcloud/action.yml`         |    1 | Åpen   |
| `unittest/action.yml`           |    1 | Åpen   |
| `validate-metrics/action.yml`   |    1 | Åpen   |
| `vault/action.yml`              |    1 | Åpen   |
| `verify-edna-deploy/action.yml` |    1 | Åpen   |

To composite actions hadde ingen funn i denne scannen.

Alle 19 `template-injection`-funn i workflows og composite actions er nå
fjernet. Den opprinnelige scannen telte flere forekomster i samme scriptblokk
separat.

Alle 73 `artipacked`-funn er også fjernet ved å sette
`persist-credentials: false` på checkout-stegene.

## Anbefalt rekkefølge

1. `template-injection` i composite actions og workflows. Dette kan gi
   kodeeksekvering dersom bruker- eller eventdata brukes direkte i expressions.
2. `artipacked` og `github-env`. Sikre checkout-credentialer og vurder all
   dataflyt til `GITHUB_ENV`.
3. `excessive-permissions`. Reduser standard- og jobbpermissions til minste
   nødvendige tilgang.
4. `github-app` og `self-repository`. Vurder tillitsnivået og om workflowene
   kjører med tilstrekkelig eksplisitte begrensninger.
5. `adhoc-packages`, `obfuscation` og `unsound-ternary`. Behandle disse etter
   at de mer direkte sikkerhetsfunnene er ryddet opp.

## Arbeidsstatus

- [x] Composite actions: `template-injection` (14 funn løst)
- [x] Workflows: `template-injection` (5 funn løst)
- [x] `artipacked` og credential-persistens (73 funn løst)
- [x] `github-env` (1 funn løst)
- [x] `unsound-ternary` (1 funn løst)
- [x] `excessive-permissions` (5 funn løst)
- [x] `github-app` (49 funn løst)
- [x] `obfuscation` (3 funn løst)
- [x] `adhoc-packages` (1 funn løst)
- [x] `self-repository` (10 funn løst)
- [ ] Resterende medium-funn
- [ ] Kjør full zizmor-scan på nytt med samme `zizmor.yml`
- [ ] Oppdater denne filen med sluttresultatet
