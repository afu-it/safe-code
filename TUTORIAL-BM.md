# Tutorial safe-code

safe-code bagi setiap projek satu pintu masuk agent, fail context jangka panjang, feature specs, dan session memory yang selamat.

## 1. Install

```bash
npx skills add afu-it/safe-code
```

Install global jika mahu:

```bash
npx skills add afu-it/safe-code -g
```

## 2. Run Pertama

Dalam projek, minta agent:

```text
/safe-code
```

safe-code akan create atau reconcile dua artifact sahaja di root repo:

```text
AGENTS.md
.safe-code/
  ACTIVE.md
  SESSION.md
  LOG.md
  BACKLOG.md
  MEMORY.md
  safe-refactor-code.md
  CHANGELOG.md
  context/
    project-overview.md
    architecture.md
    user-preferences.md
    code-standards.md
    ai-workflow-rules.md
    ui-context.md
    progress-tracker.md
    current-issues.md
    feature-specs/00-template.md
```

`AGENTS.md` kekal di root sebagai pintu masuk universal yang setiap AI host auto-baca. `.safe-code/` ialah satu-satunya folder yang safe-code create. Ia agent-agnostic dan dikongsi merentas Codex, Claude, Cursor, dan Windsurf, jadi kesinambungan session kekal dengan projek.

## 3. Urutan Baca

Agent baca `AGENTS.md` dahulu. `AGENTS.md` arahkan agent baca:

1. `.safe-code/context/project-overview.md`
2. `.safe-code/context/architecture.md`
3. `.safe-code/context/user-preferences.md`
4. `.safe-code/context/code-standards.md`
5. `.safe-code/context/ai-workflow-rules.md`
6. `.safe-code/context/ui-context.md` untuk kerja UI
7. `.safe-code/context/progress-tracker.md`
8. spec aktif dalam `.safe-code/context/feature-specs/`

Agent tidak baca `.safe-code/context/current-issues.md` kecuali anda minta debug/issue analysis secara jelas.

Preference capture:

- Jika anda kata `aku taknak`, `aku nak`, `aku prefer`, `jangan`, `please remove`, `always`, atau `never`, safe-code anggap ia preference candidate.
- Durable preferences akan draft dalam `SESSION.md` dan disimpan ke `.safe-code/context/user-preferences.md` masa `/safe-code --save`.

## 4. Feature Work

Minta feature:

```text
/safe-code build email login with verification
```

safe-code patut tulis active spec dahulu:

```text
.safe-code/context/feature-specs/01-email-login.md
```

Lepas itu baru implement ikut spec sahaja, verify, dan draft progress update dalam `SESSION.md`.

## 5. Current Issues

`.safe-code/context/current-issues.md` ialah fail manual untuk anda tulis sendiri. Fail ini gitignored (`/.safe-code/context/current-issues.md`) dan local sahaja.

Guna untuk error, steps reproduce, logs, atau nota screenshot.

Bila bersedia, minta:

```text
Explore the current-issues.md file and deeply analyze the problem. Only when you have the analysis, give it back to me with the idea of how you're planning to solve it, and then wait for me to give you the green light to execute it.
```

Agent akan analyze dahulu dan tunggu lampu hijau sebelum fix.

## 6. Projek Sedia Ada

Untuk projek in-progress atau sudah siap, safe-code tidak anggap projek kosong.

Ia inspect evidence repo dahulu:

- README
- package manifest dan lockfile
- routes dan entrypoints
- schemas dan migrations
- tests dan configs
- instruction files sedia ada

Lepas itu baru backfill context dari fakta yang terbukti. Fakta yang tidak pasti masuk `.safe-code/context/progress-tracker.md` Open Questions.

## 7. Projek safe-code Lama

Jika projek pernah guna layout lama, setiap command safe-code (`/safe-code`, `--continue`, `--save`) akan migrate dengan selamat:

- auto-detect layout lama: pre-v3 `.codex/agents/`, `.claude/agents/`, `.cursor/agents/`, `.windsurf/agents/`, dan v3 `.agents/` + `context/` di root + `CHANGELOG.md` di root
- pindahkan fail ke dalam `.safe-code/`
- patch config lama ke version baru (entry `.gitignore`, rujukan path dalam `AGENTS.md`)
- buang folder legacy yang sudah kosong
- tidak akan overwrite fail destination sedia ada — conflict akan dilapor untuk merge manual

Boleh juga jalankan migration yang sama secara deterministik dengan `bash scripts/migrate.sh --apply` (tanpa `--apply` ia dry-run sahaja).

Selepas migrate, `.safe-code/context/` jadi project brain utama.

## 8. Sambung Kerja

Guna:

```text
/safe-code --continue
```

Jika lupa dan taip `/safe-code`, safe-code auto-detect saved unfinished work dan resume juga.

## 9. Save Kerja

Tutup session dengan:

```text
/safe-code --save
```

Save akan apply draft context/docs, tulis resume state, append safe logs, wipe temporary session memory, dan buat local commit sahaja. Ia tidak push.

Six-File Save Rule: setiap `/safe-code --save` update semua enam fail session dalam `.safe-code/`; fail yang tiada content baru tetap dapat date stamp terkini.

## 10. Helper Skills

Biasanya anda hanya panggil `/safe-code`.

safe-code guna helper skills secara internal bila perlu:

- `senior-dev`
- `build-graph`
- `explore-codebase`
- `codebase-pruner`
- `safe-refactor-code`
- `review-changes`
- `debug-issue`

Helper skills analyze dahulu. Cleanup/refactor hanya jalan bila scope jelas dan ada bukti.
