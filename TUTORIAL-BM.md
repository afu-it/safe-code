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

Pemasangan global duduk dalam `~/.agents/skills/safe-code/`. Pemasangan projek masuk ke folder skills projek agent anda, contohnya `.agents/skills/safe-code/`. Skrip yang dibekalkan ada dalam folder `scripts/` di dalamnya.

### Apa yang anda perlukan

- Agent yang boleh load skills. Tak perlu API key atau akaun untuk safe-code.
- **bash** untuk skrip yang dibekalkan dan session hook: macOS dan Linux terus boleh, Windows melalui Git Bash atau WSL.
- **git** tak wajib. Tanpa git tiada rollback, jadi safe-code tetap sediakan brain tapi jalan plan-only: dapatan dan draf je, tiada cleanup kecuali anda luluskan, dan tiada commit.
- Boleh guna apa-apa bahasa dalam chat.
- **codegraph** pilihan je (bahagian 10b); nak pasang perlukan Node (`npm`) atau installer rasminya.

### Privasi

safe-code tak buat panggilan rangkaian dan tak hantar apa-apa ke mana-mana. Skripnya jalan offline. Satu-satunya tool pilihan, codegraph (bahagian 10b), hantar statistik penggunaan tanpa nama; matikan dengan `codegraph telemetry off` atau `DO_NOT_TRACK=1`. Kalau codegraph atau GitHub CLI dipasang, safe-code mungkin jalankan semakan read-only mereka (`codegraph upgrade --check`, `gh auth status`), yang akan hubungi servis tersebut.

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
  CHANGELOG.md          (dicipta bila ada perubahan pertama yang patut masuk release)
  .last-save            (cop masa save untuk session hook; gitignored)
  backups/              (salinan sebelum fail ditulis semula; gitignored)
  context/
    project-overview.md
    architecture.md
    user-preferences.md
    code-standards.md
    ai-workflow-rules.md
    ui-context.md       (dicipta bila kerja UI bermula)
    progress-tracker.md
    current-issues.md
    feature-specs/00-template.md
```

Setup juga tambah tiga baris dalam `.gitignore`: `/.safe-code/context/current-issues.md`, `/.safe-code/backups/`, dan `/.safe-code/.last-save`.

Run pertama ialah run **setup**: ia isi context dengan apa yang boleh dibuktikan dari repo, self-test context tu, dan buat audit dapatan sahaja (tiada apa-apa dibuang masa run pertama). Projek baru atau yang hampir kosong dapat setup **fresh**; projek sedia ada yang dah ada sejarah sebenar dapat setup **adopt** (bahagian 6).

Baris pertama balasan agent bagitahu keadaan brain: `[safe-code: no project brain — initializing now]` masa run pertama, dan `[safe-code: brain loaded @ <commit>]` dalam session seterusnya. Kalau nampak baris ni, maknanya agent kerja berdasarkan brain, bukan main teka.

`AGENTS.md` ialah pintu masuk kanonik dan `.safe-code/` simpan semua kesinambungan (agent-agnostic, dikongsi merentas Codex, Claude, Cursor, Windsurf, dan lain-lain). Kebanyakan host baca `AGENTS.md` sendiri; bawah Claude Code, safe-code tambah satu fail pointer nipis ("bridge") yang arahkan ia ke brain yang sama — tengok "Jalan dalam mana-mana host" di bawah.

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

safe-code tulis `AGENTS.md`, dan secara default tak tulis apa-apa lagi kat root. Cuma dua host perlukan sikit tambahan, dan hanya bila anda run safe-code dalam host itu:

- **Claude Code** dapat `CLAUDE.md` kecil dengan import `@AGENTS.md` (ditambah ke `CLAUDE.md` sedia ada kalau anda dah ada). Versi baru boleh baca `AGENTS.md` sendiri, tapi hanya bila tiada `CLAUDE.md` dalam folder itu atau mana-mana folder di atasnya, jadi bawah Claude Code bridge ni sentiasa ditulis.
- **Gemini CLI** secara default baca `GEMINI.md` je. safe-code tak tulis apa-apa fail untuknya; ia cetak satu snippet untuk anda tambah sendiri dalam `.gemini/settings.json`: `{"context":{"fileName":["AGENTS.md","GEMINI.md"]}}`.

Buka chat baru dalam host yang boleh nampak brain itu dan ia auto-load `.safe-code/context/` yang sama, tanpa anda run apa-apa. Setiap run safe-code pun semak sama ada context dah basi (deps, folder, atau scripts berubah sejak sync terakhir) dan refresh, jadi chat baru tak pernah baca brain lapuk. Lepas tulis context, ia pun self-test — semakan context-only yang ia boleh jawab asas projek — dan isi mana-mana lubang yang dijumpai.

`AGENTS.md` yang dihasilkan juga bawa **Grounding Rules**: dalam setiap session, agent mesti jawab berdasarkan fail context atau kod anda (bukan ingatan am), verify sesuatu fail atau function wujud sebelum merujuknya, dan rekod perkara tak pasti sebagai Open Questions, bukan meneka.

Bahagian `## Commands` dalam fail tu senaraikan command yang agent patut jalankan, setiap satu dengan buktinya: `verified: <commit> · <tarikh>` bila ia dah pernah jalan hijau (test juga rekod `known total: N`, jumlah test yang dilaporkan run tu), atau `unverified` kalau cuma dijumpai dalam config. Kalau run test lepas tu jumlahnya jauh berkurang, ia dikira amaran, bukan lulus.

Host lain semua (Codex, Cursor, GitHub Copilot, Windsurf, Cline, Warp, Zed, Amp, RooCode, Kilo, dan lain-lain) baca `AGENTS.md` secara native, jadi tak perlukan fail pointer langsung; Copilot dalam VS Code baca melalui setting `chat.useAgentsMdFile`. Untuk Aider, safe-code cetak satu baris cadangan config yang anda boleh apply sendiri. Fail bridge daripada safe-code versi lama (`GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc`, `.clinerules/safe-code.md`) dibiarkan, tak pernah dipadam.

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

### Tambah safe-code ke projek sedia ada

Projek yang ada 20 commit ke atas, atau 30 fail source ke atas, dan belum pernah run safe-code akan dapat setup **adopt**. Projek baru pula mula dengan setup **fresh**. Selain setup biasa, adopt akan:

- **Baca nota agent yang dah ada:** `CLAUDE.md`, `.cursorrules`, `.cursor/rules/`, `.windsurfrules`, `.github/copilot-instructions.md`, `GEMINI.md`, `memory-bank/`, ADR dan doc seni bina bawah `docs/`, `CONTRIBUTING.md`, dan `README.md`. Fakta yang boleh disahkan dalam kod masuk ke brain bersama tag sumbernya (`[extracted: CLAUDE.md:12]`); yang selebihnya jadi Open Questions. Dokumen panjang diberi link sahaja, tak disalin.
- **Baca 200 commit terakhir, baca sahaja:** fail yang paling kerap berubah, commit yang nampak macam keputusan (revert, migrate, replace, deprecate), branch yang aktif dalam 30 hari lepas, dan berapa orang yang menyumbang. 10 komen `TODO` / `FIXME` / `HACK` teratas jadi calon BACKLOG, bukan janji.
- **Tak ubah fail-fail tu langsung.** Tiada apa diubah, dipindah, atau dipadam. Bawah Claude Code, satu-satunya tambahan ialah blok bridge bertanda di hujung `CLAUDE.md`. `CLAUDE.local.md` dan fail `.env` tak pernah dibaca.
- **Mula kecil untuk repo besar.** Kalau lebih ~300 fail source (atau ~50k baris), run pertama baca manifest, config, entry point, fail yang paling kerap berubah, dan susun atur peringkat atas sahaja; yang lain disenaraikan bawah "Not Yet Specified" dan dibaca bila kerja anda sampai ke situ. Banner tunjuk berapa banyak yang dibaca: `Run: setup (adopt) · Coverage: ~40%`.
- **Cadangkan branch.** Dalam repo team, atau atas default branch repo yang ada remote, ia cadangkan `git switch -c safe-code/adopt` sebelum commit pertama, supaya anda boleh buka PR sendiri. Ia tak pernah push. Kalau tiada jawapan, ia tak cipta branch, dan dalam team mode ia tak commit apa-apa atas default branch.
- **Tanya pasal kerja anda yang belum commit, sekali sahaja:** "Are these uncommitted changes your work in progress?" Jawab ya, dan ia jadi task aktif (tetap tak di-commit untuk anda). Jawab tak, dan ia dibiarkan.

## 7. Projek safe-code Lama

Jika projek pernah guna layout lama, setiap command safe-code (`/safe-code`, `--continue`, `--save`) akan migrate dengan selamat:

- auto-detect layout lama: pre-v3 `.codex/agents/`, `.claude/agents/`, `.cursor/agents/`, `.windsurf/agents/`, dan v3 `.agents/` + `context/` di root + `CHANGELOG.md` di root — tapi cuma bila folder tu ada fail session safe-code sendiri
- pindahkan fail safe-code sahaja ke dalam `.safe-code/` — subagent sebenar anda (`.claude/agents/*.md`) dan skills (`.agents/skills/`) kekal di tempatnya
- patch config lama ke version baru (entry `.gitignore`, rujukan path dalam `AGENTS.md`)
- buang folder legacy yang sudah kosong
- tidak akan overwrite fail destination sedia ada — conflict akan dilapor untuk merge manual

Boleh juga jalankan migration yang sama secara deterministik guna skrip yang dibekalkan dalam skill. Jalankan dari dalam projek anda (contoh untuk pemasangan global; untuk pemasangan projek guna folder skills projek agent anda, contohnya `.agents/skills/safe-code/scripts/`):

```bash
bash ~/.agents/skills/safe-code/scripts/migrate.sh           # dry-run: tunjuk apa yang akan dipindah
bash ~/.agents/skills/safe-code/scripts/migrate.sh --apply   # pindahkan fail
bash ~/.agents/skills/safe-code/scripts/check.sh             # semak hasilnya (amaran nasihat sahaja)
```

Selepas migrate, `.safe-code/context/` jadi project brain utama.

## 8. Sambung Kerja

Guna:

```text
/safe-code --continue
```

Jika lupa dan taip `/safe-code`, safe-code auto-detect saved unfinished work dan resume juga.

Kalau session lepas habis tanpa `--save`, kerjanya masih dalam `SESSION.md`. `--continue` akan beritahu (`Unsaved work from the last session found in SESSION.md — merged into this run`) dan gabungkan task dan draf tu ke dalam senarai baru — tak pernah tulis ganti. Jalankan `/safe-code --save` bila nak simpan terus.

## 8b. Run Ringan dan `--audit`

Bila projek dah ada brain, `/safe-code` biasa ialah **run ringan** (light): ia load brain, semak dengan commit terkini, sambung kerja yang disave atau buat apa yang anda minta, dan berhenti di situ. Ia tak cari dead code, tak audit config agent, dan tak buat sapuan refactor. Banner akhir tulis `hygiene pass skipped (light run; /safe-code --audit runs it)`.

Nak hygiene pass penuh? Minta:

```text
/safe-code --audit
```

Minta guna ayat sendiri pun jadi, dalam apa-apa bahasa ("kemas repo ni", "cari dead code", "audit projek ni"). Run audit buat semua yang run ringan buat, tambah audit dead code, audit kepercayaan config agent, dan sapuan refactor. Apa yang betul-betul berubah masih ikut mod pelaksanaan: **A** jalankan pelan yang selamat, **B** tunjuk pelan dan tunggu anda, **C** lapor dapatan sahaja. Pembuangan dibuat satu slice demi satu, setiap satu disahkan dan ada restore pointer. Permintaan khusus ("fix bug ni", "rename X") ialah kerja anda, bukan sapuan, jadi ia kekal run ringan.

Baris pertama banner akhir sebut jenis run: `Run: setup (fresh)`, `Run: setup (adopt) · Coverage: ~N%`, `Run: light`, atau `Run: audit`.

## 9. Save Kerja

Tutup session dengan:

```text
/safe-code --save
```

Save akan apply draft context/docs yang dibuat sepanjang session (disimpan bawah `SESSION.md ## Drafts`), tulis resume state, append safe logs, wipe temporary session memory, dan pecahkan session jadi beberapa atomic conventional commit — local sahaja. Ia tidak push.

Six-File Save Rule: setiap `/safe-code --save` update semua enam fail session dalam `.safe-code/`; fail yang tiada content baru tetap dapat date stamp terkini.

Save juga jaga brain supaya tak membengkak. Fail context ada bajet lebih kurang 300 baris semuanya (`AGENTS.md` lebih kurang 120): fakta yang dah basi atau diganti dengan entry lebih baru dipindah ke sejarah `LOG.md`, satu baris setiap satu, tak pernah dipadam senyap. Banner tunjuk `Brain: N lines (budget 300)`. Command yang jalan hijau dalam session ni dapat cop `verified:` baru dalam `AGENTS.md`.

Setiap commit yang safe-code buat diakhiri dengan trailer `Safe-Code: <version>`. Itu cara run seterusnya bezakan commit safe-code sendiri daripada kerja baru bila ia semak sama ada brain dah lari.

Save cuma commit fail yang disentuh oleh session ni. Kalau ada benda lain berubah dalam working tree anda (agent lain, terminal lain, atau anda sendiri), safe-code senaraikan ia sebagai `foreign` dan biarkan — ia tak pernah revert atau commit perubahan yang bukan dia buat.

### Simpan brain di luar git (local-only)

Tak nak commit `.safe-code/`? Masukkan `.safe-code/` (atau `.safe-code/context/`) dalam `.gitignore`. safe-code akan kesan mana-mana satu sendiri: `--save` tetap update enam fail tu dalam disk (buat backup dulu dan semak tiada fail yang terpotong tanpa sengaja), commit perubahan kod dan setup anda sahaja, dan baris `Brain:` dalam banner tambah `local-only (gitignored)`. Kalau anda ignore fail session je (contohnya `SESSION.md`), itu bukan brain local-only; itu team mode (bahagian 9b). Harganya: brain tu cuma wujud dalam mesin ni. Dah pernah commit sebelum ni? Git masih track fail-fail tu sampai anda run `git rm -r --cached .safe-code` — safe-code akan paparkan arahan tu untuk anda, tapi takkan run sendiri.

Save juga buat **retro** ringkas — apa-apa yang buat agent lambat atau tersilap dalam run ni (fail yang susah dijumpai, check yang boleh tangkap kesilapan, baris arahan yang tak beri kesan) masuk `BACKLOG.md` sebagai item `retro:`. Tiada dapatan, tiada tulisan.

Ada jurnal peribadi di luar repo? Letak path penuhnya dalam `.safe-code/context/user-preferences.md` di bawah `## Save Bridge` → `diary_path:` dan setiap save akan append satu blok bertarikh ke situ (ringkasan mudah, commit, langkah seterusnya). Append sahaja; safe-code tak pernah cipta atau commit fail itu. Tak nak path tu ada dalam fail yang dikongsi? Letak dalam `.safe-code/context/user-preferences.local.md`: ia mengatasi `user-preferences.md`, tak pernah di-commit, dan di-gitignore bila dicipta (tempatnya dalam team mode, bahagian 9b).

### Brief session dan peringatan save (Claude Code)

Lupa `--save` ialah satu-satunya kegagalan sebenar, dan chat baru tak patut mula macam orang buta. safe-code bekalkan satu hook pilihan untuk Claude Code yang jalan bila session bermula:

- **Brief:** ia bagi agent satu brief pendek (paling banyak 15 baris): projek ni apa, langkah seterusnya dari session lepas, soalan terbuka, dan amaran kalau brain dah lapuk. Agent terus faham keadaan sebelum baca apa-apa. Brief ni baca beberapa baris tu je, tak pernah baca `current-issues.md` atau isi draf.
- **Peringatan save:** bila session sebelum ni tinggalkan kerja `.safe-code/` yang belum disave, anda nampak satu baris mesej suruh run `/safe-code --save`. Kalau tak ada apa-apa, tiada mesej.

Tak pernah commit, tak pernah sekat, dan tak buat panggilan rangkaian. `/safe-code` akan tawar untuk pasang hook ni setiap kali run bawah Claude Code sampai anda kata ya atau tak. Kalau ya, ia ditulis dalam `.claude/settings.local.json` untuk projek ni (tak di-commit). Kalau anda dah guna hook global, bagitahu je dan safe-code berhenti tawar. Kalau skill tu duduk di tempat lain selain folder biasa, tawaran tu guna path tempat skill itu di-load. Nak guna untuk semua projek? Pasang sendiri sekali (pemasangan global):

```jsonc
// ~/.claude/settings.json
{"hooks":{"SessionStart":[{"matcher":"startup|resume","hooks":[{"type":"command","command":"f=\"$HOME/.agents/skills/safe-code/scripts/save-reminder.sh\"; [ -f \"$f\" ] && bash \"$f\" || true"}]}]}}
```

Kalau skrip tu dah tiada, arahan tu senyap je. Pemasangan projek: guna `f="$CLAUDE_PROJECT_DIR/.claude/skills/safe-code/scripts/save-reminder.sh"; [ -f "$f" ] && bash "$f" || true` dalam `.claude/settings.local.json` (escape tanda petik macam contoh di atas). Nak peringatan je, tanpa brief: tambah `--no-brief` lepas skrip (`bash "$f" --no-brief`). Untuk host yang tiada hook JSON, `--plain` cetak teks biasa. Dulu pasang bawah `Stop` dengan versi lama? Sekarang dia senyap kat situ; safe-code akan perasan entry tu setiap kali run dan tawar untuk pindahkan ke `SessionStart`.

### Identiti commit

Sebelum commit pertama dalam satu run, safe-code semak `git config user.name` / `user.email`. Rekod identiti yang anda mahu di bawah `## Git Identity` dalam `.safe-code/context/user-preferences.local.md` (peribadi, tak pernah di-commit, mengatasi fail yang dikongsi; tempat yang betul dalam team mode) atau dalam `user-preferences.md`; kalau tak sepadan, commit dihentikan dan cara betulkan dicetak. Kalau kosong, safe-code tetap beri amaran untuk email bentuk `anda@MesinAnda.local` (git ambil dari akaun OS) dan, di GitHub, bila akaun `gh` aktif bukan pemilik repo. Ia tak pernah edit config git global dan tak pernah push.

## 9b. Kerja Dalam Team

Bila lebih dari seorang commit ke repo dalam 90 hari lepas (bot tak dikira), safe-code tukar ke **team mode** sendiri. Anda juga boleh tetapkan dalam `.safe-code/context/user-preferences.md` di bawah `## Team Mode` dengan `team: on` atau `team: off`. Banner tunjuk `Team: on (N authors, 90d)`.

Dalam team mode, brain yang dikongsi di-commit supaya semua orang dapat: `AGENTS.md`, `.safe-code/context/`, feature specs, dan `BACKLOG.md`. Fail session setiap developer (`ACTIVE.md`, `SESSION.md`, `LOG.md`, `MEMORY.md`, `safe-refactor-code.md`) kekal dalam mesin masing-masing. Nilai peribadi macam identiti git atau path jurnal masuk dalam `.safe-code/context/user-preferences.local.md`, yang tak pernah di-commit dan mengatasi fail yang dikongsi. Suis `team:` tu sendiri dibaca dari `user-preferences.md` yang dikongsi sahaja.

Masa run team pertama, safe-code cetak baris `.gitignore` untuk fail per-developer tu dan tanya dulu sebelum tambah. Kalau fail-fail tu pernah di-commit, ia cetak arahan `git rm --cached` untuk anda, tapi takkan run sendiri. Context ditulis satu fakta satu baris, dengan entry baru ditambah di hujung bahagian, jadi dua branch jarang bertembung.

## 9c. Monorepo

Monorepo dapat **satu brain di root**. safe-code jumpa brain tu dari mana-mana dalam repo (folder terdekat yang ada `.safe-code/`, kalau tiada, root git), jadi run dari `packages/api/src/` guna brain yang sama.

Package yang ada command atau perangkap sendiri boleh dapat `AGENTS.md` pendek sendiri (paling banyak lebih kurang 40 baris: command dan perangkap package tu je, tiada salinan rule root). `AGENTS.md` di root pautkan setiap satu di bawah `## Packages`. Agent yang baca `AGENTS.md` akan ambil yang paling dekat bila kerja dalam folder tu; bawah Claude Code, safe-code tambah bridge `CLAUDE.md` nipis di sebelahnya.

## 10. Explain Projek Anda (read-only)

Lupa projek sendiri buat apa? Minta penerangan bahasa mudah:

```text
/safe-code --explain
```

Ayat biasa macam "explain my project" atau "apa projek aku" pun jadi. safe-code baca otak projek dan beritahu anda, dalam bahasa mudah, app ni buat apa, stack-nya, status sekarang, apa yang tengah dibuat, dan soalan terbuka. Ia tidak ubah apa-apa dan tidak commit.

## 10b. Knowledge Graph (pilihan)

Petakan seluruh projek anda jadi code graph yang boleh ditanya (dikuasakan oleh tool luaran [codegraph](https://github.com/colbymchenry/codegraph), jika dipasang):

```text
/safe-code --codegraph                         # bina graph + segarkan peta navigasi otak projek
/safe-code --codegraph "macam mana auth jalan?"  # tanya graph soalan (read-only)
```

Kalau codegraph tak dipasang, safe-code tanya sekali dan ingat jawapan anda. Kalau anda kata ya (dalam Claude Code ini juga benarkan tool read-only codegraph tanpa prompt), ia jalankan ikut turutan: `npm i -g @colbymchenry/codegraph` (tiada Node -> ia cetak installer rasmi untuk anda), `codegraph install --target <agent ini> --location global --yes` (sambung MCP server ke agent yang anda guna je — tulisan di luar projek, dibuat hanya dengan ya anda; agent yang tak dikenali dapat arahan dicetak je), dan `codegraph init`. Kalau anda kata tak nak, atau run headless, ia cetak arahan-arahan tu dan teruskan tanpa graph — ia pemecut pilihan, bukan keperluan. Index duduk dalam `.codegraph/` dan tidak pernah di-commit. codegraph hantar statistik penggunaan tanpa nama; matikan dengan `codegraph telemetry off` atau `DO_NOT_TRACK=1`. Flag lama `--graphify` masih jalan sebagai alias.

Bina sekali sahaja — lepas tu ia sentiasa terkini: kalau MCP server dah disambung, graph sync semula setiap kali fail berubah; kalau tak, setiap run `/safe-code` mula dengan `codegraph sync` (bawah satu saat). Tak payah rebuild manual. Graph yang sama juga dipakai untuk audit dead code, semak impak, dan pilih test mana nak dijalankan.

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

Helper skills analyze dahulu. Sapuan cleanup dan refactor hanya jalan dalam run audit (`--audit` atau bila anda minta kemas), dengan scope jelas dan ada bukti; refactor yang anda minta terus boleh jalan dalam mana-mana run.

## 12. Macam mana safe-code tahu ia dah siap

Setiap task dalam satu run bawa check penutupnya sebelum kerja bermula (`check: <command> · expect: <token>`) dan hanya ditutup atas kesan yang diperhati — bukan "exit code 0" atau tool kata "success". Kalau anda minta beberapa perkara, safe-code senaraikan setiap satu dalam `SESSION.md ## Requested` dan semak senarai itu di hujung; item yang tak diperhati menghalang dakwaan "siap". Task yang rupanya mustahil ditanda `[!] abandoned` dengan sebab dan muncul dalam banner akhir — tak pernah digugurkan senyap. Task yang tunggu kelulusan yang session tak boleh dapat (contohnya pelan cleanup dalam run headless) ditanda `[p] parked: needs approval`: masih terbuka, dikira berasingan dalam banner (`session ended · … parked …`), dan dibawa ke session seterusnya. Setiap nombor dalam banner itu diukur semula masa lapor, bukan disalin dari nota tengah run.

Banner dibuka dengan baris run (`Run: light · …`) dan baris `Brain:` yang tunjuk saiz context berbanding bajetnya (tambah `Team: on …` dalam team mode). Ia juga bagitahu dua perkara pasal git: `unpushed: N` bila ada commit local yang belum ada di remote (tak ditunjuk kalau kosong; `no upstream` kalau branch tu tiada remote), dan apa-apa perubahan `foreign` — fail yang berubah masa run tapi tiada task yang boleh terangkan. safe-code lapor dan biarkan saja; ia tak pernah revert. Kalau ada session agent lain tengah kerja dalam folder yang sama, safe-code beritahu di awal run dan cadangkan worktree berasingan untuk kerja yang panjang.

## 13. Uninstall

1. Buang skill: `npx skills remove safe-code` (tambah `-g` untuk pemasangan global). Helper skills yang anda pasang sekali boleh dibuang dengan cara sama, contohnya `npx skills remove senior-dev build-graph explore-codebase codebase-pruner safe-refactor-code review-changes debug-issue`.
2. Buang session hook, kalau anda pasang: padam entry `SessionStart` yang command-nya sebut `save-reminder.sh` (dan apa-apa entry `Stop` lama yang sebut skrip tu) dalam `.claude/settings.local.json` (projek) atau `~/.claude/settings.json` (global). Kalau dibiarkan pun tak apa; ia senyap bila skrip dah tiada.
3. Dalam setiap projek, buang brain: `git rm -r .safe-code` kalau ia di-commit (masih ada dalam history git), kalau tidak alihkan `.safe-code/` ke trash.
4. Kemas fail root: padam `AGENTS.md` (dan `AGENTS.md` dalam package, kalau ada) kalau safe-code yang cipta (kalau anda memang ada sendiri, buang bahagian yang safe-code tambah je); dalam `CLAUDE.md`, padam blok antara `<!-- safe-code:bridge … -->` dan `<!-- /safe-code:bridge -->`, atau seluruh fail kalau safe-code yang cipta. Bridge daripada versi lama (`GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc`, `.clinerules/safe-code.md`) pun boleh dibuang.
5. Buang baris `.gitignore` `/.safe-code/context/current-issues.md`, `/.safe-code/backups/`, dan `/.safe-code/.last-save`, apa-apa baris team mode bawah `/.safe-code/`, dan `.safe-code/` kalau anda tambah sendiri. Kalau anda pernah bina code graph, jalankan `codegraph uninit` dalam projek; `codegraph uninstall` buang sambungan MCP dan `npm uninstall -g @colbymchenry/codegraph` buang CLI-nya.
