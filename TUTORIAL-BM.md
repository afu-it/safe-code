# Tutorial safe-code

safe-code bagi setiap projek satu pintu masuk agent, fail context jangka panjang, feature specs, dan session memory yang selamat.

## 1. Install

```bash
npx skills add afu-it/safe-code
```

Install global jika mahu:

```bash
npx skills add afu-it/safe-code -g

# kemas kini kemudian (kekalkan -g untuk pemasangan global)
npx skills update -g
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

`AGENTS.md` ialah pintu masuk kanonik dan `.safe-code/` simpan semua kesinambungan (agent-agnostic, dikongsi merentas Codex, Claude, Cursor, dan Windsurf). Sebab bukan semua host auto-baca `AGENTS.md`, safe-code juga tulis fail pointer nipis — `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc` — yang redirect setiap host ke brain yang sama.

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

Agent tidak baca `.safe-code/context/current-issues.md` masa kerja biasa — cuma bila ada isu (anda kata "fix this", "failed", "got error", atau paste stack trace) atau bila anda rujuk fail tu.

Preference capture:

- Jika anda kata `aku taknak`, `aku nak`, `aku prefer`, `jangan`, `please remove`, `always`, atau `never`, safe-code anggap ia preference candidate.
- Durable preferences akan draft dalam `SESSION.md` dan disimpan ke `.safe-code/context/user-preferences.md` masa `/safe-code --save`.

### Jalan dalam mana-mana host

safe-code tulis `AGENTS.md` plus satu fail pointer nipis untuk host yang anda tengah guna — `CLAUDE.md` (Claude), `GEMINI.md` (Gemini), `.github/copilot-instructions.md` (Copilot), atau `.cursor/rules/safe-code.mdc` (Cursor). Pointer host lain ditambah secara lazy kali pertama anda run safe-code dalam host itu, jadi anda cuma simpan bridge untuk tool yang betul-betul diguna. Buka chat baru dalam host yang dah ada bridge-nya dan ia auto-load brain `.safe-code/context/` yang sama, tanpa anda run apa-apa. Setiap run safe-code pun semak sama ada context dah basi (deps, folder, atau scripts berubah sejak sync terakhir) dan refresh, jadi chat baru tak pernah baca brain lapuk. Lepas tulis context, ia pun self-test — semakan context-only yang ia boleh jawab asas projek — dan isi mana-mana lubang yang dijumpai.

`AGENTS.md` yang dihasilkan juga bawa **Grounding Rules**: dalam setiap session, agent mesti jawab berdasarkan fail context atau kod anda (bukan ingatan am), verify sesuatu fail atau function wujud sebelum merujuknya, dan rekod perkara tak pasti sebagai Open Questions, bukan meneka.

Kebanyakan host moden (Codex, Windsurf, Warp, Zed, RooCode, Kilo, dan lain-lain) baca `AGENTS.md` secara native, jadi tak perlukan fail pointer langsung; Cline dapat `.clinerules/safe-code.md`, dan untuk Gemini CLI atau Aider safe-code cetak satu baris config yang anda boleh apply sendiri.

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

Setiap spec ada field `status:` (`suggested` / `approved` / `in-progress` / `done` / `rejected`). Idea feature baru disimpan sebagai `status: suggested` walaupun anda belum build — jadi ia kekal sebagai history boleh rujuk balik. Approve untuk build; reject dan spec tu disimpan supaya idea sama tak dicadang semula.

## 5. Current Issues

`.safe-code/context/current-issues.md` ialah issue tracker dikongsi. Fail ini gitignored (`/.safe-code/context/current-issues.md`) dan local sahaja — tak pernah di-commit.

Anda boleh paste error, steps reproduce, logs, atau nota screenshot. Agent pun tulis di sini: bila anda report masalah ("fix this", "failed", "got error", atau paste stack trace) ia append satu entry, kemudian tukar ke resolved (dengan root cause + fix) bila dah selesai. Sebab fail ni mungkin ada secret, agent tak pernah salin isi mentahnya ke fail yang di-commit — ringkasan selamat setiap fix masuk `LOG.md` sebagai gantinya.

Untuk pass yang berhati-hati (plan dulu), minta:

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

Save akan apply draft context/docs, tulis resume state, append safe logs, wipe temporary session memory, dan pecahkan session jadi beberapa atomic conventional commit — local sahaja. Ia tidak push.

Six-File Save Rule: setiap `/safe-code --save` update semua enam fail session dalam `.safe-code/`; fail yang tiada content baru tetap dapat date stamp terkini.

Save juga buat **retro** ringkas — apa-apa yang buat agent lambat atau tersilap dalam run ni (fail yang susah dijumpai, check yang boleh tangkap kesilapan, baris arahan yang tak beri kesan) masuk `BACKLOG.md` sebagai item `retro:`. Tiada dapatan, tiada tulisan.

Ada jurnal peribadi di luar repo? Letak path penuhnya dalam `.safe-code/context/user-preferences.md` di bawah `## Save Bridge` → `diary_path:` dan setiap save akan append satu blok bertarikh ke situ (ringkasan mudah, commit, langkah seterusnya). Append sahaja; safe-code tak pernah cipta atau commit fail itu.

### Jangan hilang session

Lupa `--save` ialah satu-satunya kegagalan sebenar. Pasang peringatan sekali (Claude Code, pemasangan global):

```jsonc
// ~/.claude/settings.json
{ "hooks": { "Stop": [ { "hooks": [ { "type": "command",
  "command": "bash \"$HOME/.agents/skills/safe-code/scripts/save-reminder.sh\"" } ] } ] } }
```

Ia cetak satu baris peringatan bila session tamat dengan kerja `.safe-code/` belum disave. Tak pernah commit, tak pernah sekat. Pemasangan projek: guna `bash "$CLAUDE_PROJECT_DIR/.claude/skills/safe-code/scripts/save-reminder.sh"` dalam `.claude/settings.json`.

### Identiti commit

Sebelum commit pertama dalam satu run, safe-code semak `git config user.name` / `user.email`. Rekod identiti yang anda mahu dalam `.safe-code/context/user-preferences.md` di bawah `## Git Identity`; kalau tak sepadan, commit dihentikan dan cara betulkan dicetak. Kalau kosong, safe-code tetap beri amaran untuk email bentuk `anda@MesinAnda.local` (git ambil dari akaun OS) dan, di GitHub, bila akaun `gh` aktif bukan pemilik repo. Ia tak pernah edit config git global dan tak pernah push.

## 10. Explain Projek Anda (read-only)

Lupa projek sendiri buat apa? Minta penerangan bahasa mudah:

```text
/safe-code --explain
```

Ayat biasa macam "explain my project" atau "apa projek aku" pun jadi. safe-code baca otak projek dan beritahu anda, dalam bahasa mudah, app ni buat apa, stack-nya, status sekarang, apa yang tengah dibuat, dan soalan terbuka. Ia tidak ubah apa-apa dan tidak commit.

## 10b. Knowledge Graph (pilihan)

Petakan seluruh projek anda jadi knowledge graph yang boleh ditanya (dikuasakan oleh tool luaran [graphify](https://github.com/Graphify-Labs/graphify), jika dipasang):

```text
/safe-code --graphify                        # bina graph + segarkan peta navigasi otak projek
/safe-code --graphify "macam mana auth jalan?"  # tanya graph soalan (read-only)
```

Kalau graphify tak dipasang, safe-code beritahu caranya (`uv tool install graphifyy`) dan teruskan tanpanya — ia pemecut pilihan, bukan keperluan. Output graph duduk dalam `graphify-out/` dan tidak pernah di-commit.

Bina sekali sahaja — selepas itu, setiap run `/safe-code` akan refresh graph secara automatik bila kod anda berubah. Tak payah rebuild manual.

## 11. Helper Skills

Biasanya anda hanya panggil `/safe-code`.

safe-code guna helper skills secara internal bila perlu:

- `senior-dev`
- `build-graph`
- `explore-codebase`
- `codebase-pruner`
- `safe-refactor-code`
- `review-changes` — review atas dua paksi, Standards (`code-standards.md` anda + senarai code smell asas) dan Spec (adakah ia buat apa yang spec aktif minta: tertinggal, scope creep, salah), dilapor berasingan
- `debug-issue` — bina command yang boleh reproduce bug *sebelum* buat teori, kecilkan repro, susun 3–5 hipotesis yang boleh diuji, probe satu pembolehubah pada satu masa, tulis regression test di seam yang betul, dan bersihkan log bertag

Helper skills analyze dahulu. Cleanup/refactor hanya jalan bila scope jelas dan ada bukti.

## 12. Macam mana safe-code tahu ia dah siap

Setiap task dalam satu run bawa check penutupnya sebelum kerja bermula (`check: <command> · expect: <token>`) dan hanya ditutup atas kesan yang diperhati — bukan "exit code 0" atau tool kata "success". Kalau anda minta beberapa perkara, safe-code senaraikan setiap satu dalam `SESSION.md ## Requested` dan semak senarai itu di hujung; item yang tak diperhati menghalang dakwaan "siap". Task yang rupanya mustahil ditanda `[!] abandoned` dengan sebab dan muncul dalam banner akhir — tak pernah digugurkan senyap. Setiap nombor dalam banner itu diukur semula masa lapor, bukan disalin dari nota tengah run.
