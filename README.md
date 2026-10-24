# agent-article-kit

AI コーディングエージェント（Claude Code / Codex CLI）を使った日本語の記事作成ツールキットです。採用広報・社内広報記事の作成、インタビュー、レビュー、公開用の書き出しを対話形式で実行できます。

## 特徴

- `/write-article` - 書きたいこと（テーマや断片メモ）から対話で素材を深掘りし、記事を自動生成
- `/interview` - 社員への対話型インタビュー、または取材の文字起こしから記事を自動生成（エンジニア以外の職種にも対応）
- `/review-article` - 記事ドラフトを構成・文章・訴求力・AI文体・ファクトの観点でレビューし、改善案を提示
- `/publish-article` - note・Zenn・Qiita・はてなブログ向けの形式と、X や Slack の告知文を書き出し
- 書き手のプロフィールを1回登録すれば、毎回聞かれません
- 素材を作業ファイルに保存するので、会話が切れても途中から再開できます
- 日本語の技術文章向け textlint 設定と、社名・技術用語の表記辞書を同梱
- AI が書いた日本語を推敲するスキル [yomiyasu](https://github.com/nanaism/yomiyasu) を同梱し、記事生成とレビューの流れに組み込み済み

## セットアップ

```bash
git clone https://github.com/langcore-dev/agent-article-kit.git
cd agent-article-kit
npm install
```

Claude Code では、セッション開始時に textlint が入っていなければ自動で `npm install` が走ります（`.claude/hooks/session-start.sh`）。

### 書き手のプロフィール（任意）

ひな形をコピーして、会社名・所属・名前・役職を書いておくと、記事を作るたびに聞かれなくなります。書かなくても、初回に聞かれた内容で自動的に作られます。

```bash
cp .article-kit/profile.example.md .article-kit/profile.md
```

`profile.md` は個人の情報なので git には入りません。

### 前提

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) または Codex CLI
- Node.js（textlint 用）
- Python 3（yomiyasu の検査ツール用。なくても記事は作れます）

## 使い方

このリポジトリのディレクトリで Claude Code を起動し、スラッシュコマンドを実行します。どのコマンドも、引数にファイルパスや本文を渡すと、答えの分かる質問を飛ばします。

### 書きたいことから記事を作る

```text
/write-article
/write-article notes/ci-migration.md
/write-article 新しいCI/CDを入れて開発速度が2倍になった話
```

素材を受け取ったあと、記事の種類・書き手・登場人物・読者を1回の質問でまとめて確認します。その後、6つの観点（具体性・エピソード・背景/動機・成果/変化・感情/実感・メッセージ性）で素材を深掘りし、構成案の確認を経て記事ドラフトを生成します。

### インタビューから記事を作る

```text
/interview
/interview transcripts/2026-10-20-yamada.txt
```

進め方を2つから選べます。

- **その場でインタビュー**: 対象者が画面の前で質問に答えます。5つのカテゴリ（仕事・専門性 / チーム・文化 / キャリア・成長 / 日常・働き方 / 未来・ビジョン）から質問を動的に生成します
- **文字起こしから作る**: 会議ツールの録音などの文字起こしを読み込み、Q&A に整理します。足りない点だけを追加で質問します

エンジニア、PM、デザイナー、セールス、コーポレートなど、職種に合わせた質問を使います。

### 記事をレビューする

```text
/review-article
/review-article articles/2026-10-24-ci-migration.md
```

構成・文章ルール・視点の一貫性・具体性・訴求力・行動経済学・ファクトチェック・AI文体（yomiyasu）・textlint の9つの観点でレビューし、A / B / C で評価します。

### 公開用に書き出す

```text
/publish-article articles/2026-10-24-ci-migration.md
```

選んだ公開先の形式で `articles/exports/{slug}/` に書き出します。記事の文章は変えません。

| 公開先・告知 | 書き出す内容 |
|---|---|
| note | タイトルと本文（表は箇条書きに変換） |
| Zenn | front matter（title, emoji, type, topics）つきの記事 |
| Qiita | Qiita CLI の形式の記事 |
| はてなブログ | Markdown モードの本文 |
| 社内Wiki | 一般的な Markdown |
| 告知文・画像 | X の告知文（3案）、LinkedIn・Facebook、Slack の社内告知、アイキャッチ画像の案 |

### 途中から再開する

素材や回答は `articles/.work/{slug}/material.md` に保存されます。会話が切れたら、同じコマンドを実行すると再開するかを聞かれます。作業ファイルを引数に渡しても再開できます。

```text
/write-article articles/.work/2026-10-24-ci-migration/material.md
```

### yomiyasu で推敲する

記事の生成（`/write-article`・`/interview`）では、ドラフトを書いたあとに自動で yomiyasu の推敲を通します。単体で使う場合は次のように依頼します。

```text
articles/2026-10-24-example.md を yomiyasu で推敲して。採用広報の記事です。
```

付属の検査ツールで、AI 特有の表現の見直し候補を出すこともできます。`--doc-type` は採用広報・社内広報なら `promo`、テックブログなら `article` を指定します。

```bash
npm run lint:yomiyasu -- articles/対象ファイル.md --doc-type promo
```

### textlint を手動で実行する

```bash
npx textlint articles/対象ファイル.md        # 1記事をチェック
npx textlint --fix articles/対象ファイル.md  # 1記事を自動修正
npm run lint                                 # 全記事をチェック
npm run lint:fix                             # 全記事を自動修正
```

### Codex CLI での実行例

`.agents/skills/` にスキルへのリンクがあるため、追加設定なしで `$skill-name` で呼び出せます。`/skills` コマンドから選ぶこともできます。

```text
$write-article
$interview
$review-article
$publish-article
```

Codex には SessionStart フックがないため、最初に `npm install` を実行してください。

## textlint 設定

日本語の技術文章向けに以下のルールを設定しています（`.textlintrc.json`）。

| ルール | 説明 |
|---|---|
| `preset-ja-technical-writing` | 日本語の技術文章プリセット（一文100文字以内など） |
| `no-doubled-joshi` | 助詞の連続使用を検出 |
| `ja-no-redundant-expression` | 冗長な表現を検出（「することができる」→「できる」） |
| `ja-unnatural-alphabet` | 不自然なアルファベット使用を検出 |
| `prh` | `prh.yml` の辞書と違う社名・技術用語の表記を検出（例: Github → GitHub） |

## 記事の管理

| パス | 内容 | git |
|---|---|---|
| `articles/{YYYY-MM-DD}-{slug}.md` | 記事 | 管理外 |
| `articles/.work/{slug}/material.md` | 素材と回答の作業ファイル | 管理外 |
| `articles/exports/{slug}/` | 公開先ごとの書き出しと告知文 | 管理外 |

## カスタマイズ

| 変えたいもの | 編集するファイル |
|---|---|
| 文章ルール・タイトル指針・行動経済学テクニック（全スキル共通） | `.claude/shared/writing-rules.md` |
| プロフィール・作業ファイル・仕上げの手順（全スキル共通） | `.claude/shared/workflow-common.md` |
| 書きたいことドリブン記事の構成 | `.claude/skills/write-article/article-template.md` |
| インタビュー記事の構成 | `.claude/skills/interview/article-template.md` |
| 深掘り対話の質問 | `.claude/skills/write-article/writing-guide.md` |
| インタビューの質問・職種別の質問 | `.claude/skills/interview/interview-guide.md` |
| レビュー観点 | `.claude/skills/review-article/review-checklist.md` |
| 公開先の形式 | `.claude/skills/publish-article/platforms.md` |
| 社名・プロダクト名・技術用語の表記 | `prh.yml` |
| yomiyasu に直させない語 / 必ず見直させる語 | `.yomiyasu-words/allow.txt` / `.yomiyasu-words/flag.txt` |
| textlint のルール | `.textlintrc.json` |

### yomiyasu の更新

`.claude/skills/yomiyasu/` は [nanaism/yomiyasu](https://github.com/nanaism/yomiyasu) の `skills/yomiyasu/` をそのままコピーしたものです（v2.3.0 を同梱）。最新版にするには次を実行します。

```bash
rm -rf /tmp/yomiyasu .claude/skills/yomiyasu
git clone --depth 1 https://github.com/nanaism/yomiyasu /tmp/yomiyasu
cp -R /tmp/yomiyasu/skills/yomiyasu .claude/skills/yomiyasu
```

スキルを入れられない環境（ChatGPT のカスタム指示、Microsoft 365 Copilot など）では、短縮版の [yomiyasu-mini](https://github.com/nanaism/yomiyasu-mini)（SKILL.md 18,000字以下）や [yomiyasu-pocket](https://github.com/nanaism/yomiyasu-pocket)（指示欄に貼る400〜500字）を使えます。

## ディレクトリ構成

```
.agents/skills/        # Codex CLI 用（.claude/skills/ へのシンボリックリンク）
.article-kit/          # 書き手プロフィール（profile.md は git 管理外）
.claude/
├── agents/            # 記事生成サブエージェント
├── hooks/             # SessionStart フック（textlint の自動インストール）
├── shared/            # 全スキル共通の文章ルールと手順
├── skills/            # スキル（スラッシュコマンドとして呼べる）
└── settings.json      # フックの設定
.yomiyasu-words/       # yomiyasu の語の一覧
articles/              # 記事の出力先
.textlintrc.json       # textlint 設定
prh.yml                # 表記辞書
package.json           # 依存パッケージ
```

## ライセンス

MIT

同梱の `.claude/skills/yomiyasu/` は [ALGO ARTIS](https://www.algo-artis.com/) による yomiyasu で、MIT ライセンスです（同ディレクトリの `LICENSE` と `UNICODE-LICENSE.txt` を参照）。
