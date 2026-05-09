# Tutorial: Cara Guna safe-code

> **Untuk sesiapa yang baru je mula coding** — kita explain dari mula, step by step, dengan gambar.

---

## 🤔 Apa Tu Skill?

Bayangkan kau ada **tukang masak AI**. Skill ni macam **resipi** yang kau bagi kat dia:

```
  Kau         Skill (Resipi)      AI Agent
  ───         ──────────────      ────────
  "tolong      safe-code         "Okay, aku
   kemas        SKILL.md    →     faham nak
   kod aku"     (arahan)          buat apa"
```

Tanpa skill, AI agent tak tahu cara selamat nak kemas kod kau. Dengan skill, dia ikut prosedur yang betul — audit dulu, plan, verify, baru buang.

---

## ✅ Sebelum Mula — Semak 3 Benda Ni

### 1. Ada Node.js ke?

Buka **Terminal** (atau Command Prompt) dan taip:

```bash
node --version
```

Kalau keluar nombor macam `v20.11.0` → ✅ ada.
Kalau keluar error → install dulu dari [nodejs.org](https://nodejs.org) (pilih LTS).

> **Apa tu Terminal?**
> Terminal = kotak hitam untuk bagi arahan kat komputer pakai taip.
> Windows: cari "Command Prompt" atau "PowerShell"
> Mac: cari "Terminal" dalam Applications → Utilities

### 2. Ada Git ke?

```bash
git --version
```

Kalau keluar nombor → ✅ ada.
Kalau error → install dari [git-scm.com](https://git-scm.com).

### 3. Projek kau ada dalam folder dengan git?

```bash
cd nama-projek-kau
git status
```

Kalau keluar sesuatu (walaupun "nothing to commit") → ✅ okay.
Kalau keluar `not a git repository` → jalankan `git init` dulu.

---

## 📦 Step 1 — Install Skill

Buka terminal, pergi ke folder projek kau, lepas tu taip:

```bash
npx skills add afu-it/safe-code
```

Tekan Enter. Tunggu. Dia akan:

```
⠋ Detecting your agent...
✔ Found: Codex
⠋ Installing safe-code...
✔ Installed → ~/.codex/skills/safe-code
⠋ Installing codebase-pruner...
✔ Installed → ~/.codex/skills/codebase-pruner
⠋ Installing safe-refactor-code...
✔ Installed → ~/.codex/skills/safe-refactor-code
⠋ Installing build-graph...
✔ Installed → ~/.codex/skills/build-graph
⠋ Installing explore-codebase...
✔ Installed → ~/.codex/skills/explore-codebase
⠋ Installing review-changes...
✔ Installed → ~/.codex/skills/review-changes
⠋ Installing debug-issue...
✔ Installed → ~/.codex/skills/debug-issue
✔ Done!
```

Skill terus masuk dalam folder agent kau secara automatic. **Kau tak perlu tahu folder mana** — dia cari sendiri.

> **Nak install untuk semua projek sekaligus?**
> ```bash
> npx skills add afu-it/safe-code -g
> ```
> `-g` = global (semua projek)

> **Nak tengok dulu apa yang akan diinstall?**
> ```bash
> npx skills add afu-it/safe-code --list
> ```

---

## 🚀 Step 2 — Guna Skill

Buka projek kau dalam **AI agent** kau (Codex, Claude Code, Cursor, atau Windsurf).

Lepas tu taip dalam chat:

```
/safe-code
```

Tekan Enter. Agent akan buat semua ni secara automatic:

```
  /safe-code
      │
      ▼
  ┌─────────────────────────────────────────────────────────┐
  │  Step 0  Detect agent kau                               │
  │  Step 1  Buat 8 fail rekod + isi AGENTS.md sebenar      │
  │  Step 2  Load context                                   │
  │  Step 3  Semak git & backup                             │
  │  Step 4  Scan kod mati dalam projek                     │
  │  Step 5  Plan kerja (tanya kau dulu)                    │
  │  Step 6  Buang kod mati satu-satu                       │
  │  Step 7  Refactor + update semua docs                   │
  │  Step 8  Print laporan                                  │
  └─────────────────────────────────────────────────────────┘
```

**Kau tak perlu buat apa-apa** — tengok je sambil dia kerja. Kalau dia ragu-ragu tentang sesuatu, dia akan tanya kau dulu sebelum proceed.

### Apa yang jadi dengan AGENTS.md?

Pada setup, safe-code **scan repo kau dulu** sebelum decide nak buat apa dengan `AGENTS.md`:

- Dia baca `README`, config files, CI workflows, package manager files, dan instruction files lain yang sedia ada
- Dia extract fakta sebenar yang boleh disahkan — command tepat, stack kau, struktur folder, quirks
- Kalau `AGENTS.md` dah ada tapi kosong atau cuma auto-generated boilerplate, dia isi dengan betul
- Kalau `AGENTS.md` pendek atau generic, dia kira sebagai thin dan upgrade jadi handoff file yang berguna
- Kalau `AGENTS.md` dah ada content berguna, dia audit dan reconcile file itu in place tanpa overwrite benda yang masih betul

---

## 💾 Nak Tutup Session?

Kalau kau nak stop kerja dan sambung esok, atau nak beralih projek lain:

```
/safe-code --save
```

Dia akan buat **11 benda automatik** dalam masa beberapa saat:

```
  ✔  Simpan progress → ACTIVE.md
  ✔  Catat dalam diari → LOG.md
  ✔  Update architecture → MEMORY.md
  ✔  Bersihkan working notes → SESSION.md
  ✔  git init (kalau perlu)
  ✔  git add -A
  ✔  git commit (dengan message auto)
  ✔  Print: commit hash + local-only status
  ✔  Tutup safe-code session ini
```

Lain kali kau jalankan `/safe-code` balik, dia **auto-detect** session yang ditutup dan sambung dari `ACTIVE.md`.

---

## 📁 Fail Apa Yang Dibuat?

Lepas first run, projek kau akan ada struktur macam ni:

```
your-project/
├── AGENTS.md                    ← rules, stack & command sebenar projek kau
├── CHANGELOG.md                 ← sejarah perubahan
└── .codex/                      ← (atau .claude/ .cursor/ .windsurf/)
    └── agents/
        ├── ACTIVE.md            ← status semasa  (macam hard disk 💾)
        ├── SESSION.md           ← working notes  (macam RAM 🧠)
        ├── LOG.md               ← diari semua keputusan
        ├── BACKLOG.md           ← senarai kerja tunggu
        ├── MEMORY.md            ← gambar besar projek
        └── safe-refactor-code.md ← rules refactor
```

> 💡 **ACTIVE.md** = macam hard disk — kekal even lepas kau tutup
> 💡 **SESSION.md** = macam RAM — kosong balik setiap kali `/safe-code --save`
> 💡 **AGENTS.md** = diisi dengan context projek sebenar, bukan placeholder generic

---

## 🎛️ Tiga Command Je

Kau cuma perlu tiga ni:

| Apa yang kau nak | Command |
|---|---|
| First-time setup atau fresh hygiene pass | `/safe-code` |
| Sambung dari saved docs tanpa hallucinate context | `/safe-code --continue` |
| Save docs, commit local, dan tutup session | `/safe-code --save` |

safe-code pilih mode paling selamat secara automatic: orientation, audit, atau cleanup. Dia juga auto-run helper skills untuk graph build, repo exploration, dead-code pruning, refactor checks, review, dan debugging bila perlu. Kalau `uvx` ada, safe-code boleh create `.mcp.json` project-local untuk graph mode secara automatic.

Setiap run juga simpan task checklist dalam `SESSION.md`, jadi agent track progress dan tak main agak apa yang dah siap.

---

## 🔄 Update Skill

Bila ada versi baru:

```bash
# Update semua skills
npx skills update

# Semak ada update tak (tanpa install)
npx skills check

# Update satu skill je
npx skills update --skill safe-code
```

---

## 🗑️ Nak Buang Skill?

```bash
# Buang semua tujuh
npx skills remove safe-code codebase-pruner safe-refactor-code build-graph explore-codebase review-changes debug-issue

# Buang satu je
npx skills remove safe-code
```

> **Nota:** Buang skill tak delete docs yang dah dibuat dalam projek kau (`AGENTS.md`, `.codex/` etc.). Kau kena delete sendiri kalau nak.

---

## ❓ Soalan Biasa Orang Baru Tanya

**"AI dia delete terus ke tanpa tanya?"**
Tidak. Dia akan tunjuk plan dulu dan tanya kau kalau ada benda yang dia tak sure. Kod yang dia confident je dia buang — dan setiap slice dia verify dulu sebelum teruskan.

**"Kalau agent silap buang, macam mana?"**
Dia rollback automatik kalau ada slice yang fail verification. Plus, sebab kau ada git, kau boleh `git checkout -- filename` bila-bila masa untuk restore fail.

**"Kena ada internet ke?"**
Hanya semasa install (`npx skills add ...`). Lepas tu, skill dah ada dalam komputer kau — tak perlu internet.

**"Skill ni buang source code kita ke?"**
Dia buang **dead code** je — kod yang dah takde siapa guna dalam projek. Kod yang masih active, dia tak sentuh.

**"Kenapa AGENTS.md nampak detail lepas first run?"**
Kerana safe-code scan repo kau dulu sebelum tulis. Tujuannya supaya mana-mana AI agent baca file tu terus faham projek kau — stack kau, command kau, cara kerja kau — tanpa perlu tanya lagi.

**"Macam mana nak tahu skill dah installed?"**
```bash
npx skills list
```

---

## 💡 Tips Untuk Orang Baru

**Mulakan dengan `/safe-code`.**
Kalau repo baru, dirty, atau risky, dia akan kekal dalam mode audit/documentation secara natural.

**Pastikan git clean sebelum start.**
Jalankan `git status` dulu. Kalau ada perubahan belum commit, buat `git commit` dulu. Ni supaya kau ada backup sebelum agent buat kerja.

**Jangan takut.**
Skill ni direka untuk selamat. Agent akan tanya kau bila ada keraguan. Kau sentiasa in control.
