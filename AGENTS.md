# agent-article-kit

Claude Code / Codex CLI 対応の日本語の記事作成ツールキット。
採用広報・社内広報記事を、対話型ワークフローで効率的に作成する。

## ディレクトリ構成

```
.claude/
├── skills/              # スキル（スラッシュコマンドとして呼べる）
│   ├── write-article/   # 書きたいことドリブン記事作成
│   ├── interview/       # インタビュー記事作成
│   ├── review-article/  # 記事レビュー
│   ├── publish-article/ # 公開用の書き出しと告知文
│   └── yomiyasu/        # AI文の推敲スキル（nanaism/yomiyasu を同梱）
├── shared/              # 全スキル共通の定義
│   ├── writing-rules.md     # 文章ルール、タイトル指針、行動経済学テクニック
│   └── workflow-common.md   # プロフィール、引数、作業ファイル、仕上げの手順
├── agents/              # サブエージェント定義
│   ├── write-article-drafter.md
│   └── article-writer.md
├── hooks/session-start.sh   # textlint の自動インストール
└── settings.json        # フックの設定
.agents/skills/          # Codex 用（.claude/skills/ へのシンボリックリンク）
.article-kit/
├── profile.example.md   # 書き手プロフィールのひな形
└── profile.md           # 書き手プロフィール（個人用、git 管理外）
.yomiyasu-words/         # yomiyasu の語の一覧（allow.txt / flag.txt）
prh.yml                  # 社名・技術用語の表記辞書（textlint-rule-prh）
articles/                # 記事の出力先（記事本体は git 管理外）
├── .work/{slug}/material.md  # 素材と回答の作業ファイル（途中から再開できる）
└── exports/{slug}/           # 公開先ごとの書き出しと告知文
```

## 共通の仕組み

- **プロフィール**: 書き手の会社名・所属・名前・役職を `.article-kit/profile.md` に1回登録すれば、毎回聞かれない。ファイルがなければ初回に聞いて保存する
- **引数**: `/write-article notes.md` のようにファイルや本文を渡すと、答えの分かる質問を飛ばす
- **作業ファイル**: 素材と回答を `articles/.work/{slug}/material.md` に保存する。会話が切れても途中から再開でき、yomiyasu の推敲やファクトチェックの資料にも使う
- **共通ルール**: 文章ルールとタイトル指針は `.claude/shared/writing-rules.md` の1か所で管理する。テンプレート（`article-template.md`）には構成だけを書く

## ワークフロー

### 1. 書きたいことドリブン記事作成（write-article）

テーマや断片メモから対話で素材を深掘りし、記事を生成する。

**フロー:** 準備 → 素材入力と記事の設定（質問1回） → 6視点で深掘り対話 → 構成提案 → ドラフト生成 → yomiyasu で推敲・textlint → 確認。

6つの深掘り視点。
- 具体性（固有名詞・数字）
- エピソード（体験・出来事）
- 背景・動機（なぜ）
- 成果・変化（Before/After）
- 感情・気づき（温度感）
- メッセージ（読者への伝言）

### 2. インタビュー記事作成（interview）

社員へのインタビューから記事を生成する。エンジニア以外の職種（PM、デザイナー、セールス、コーポレートなど）にも対応する。

**進め方:** その場で対話型インタビューをするか、取材の文字起こしを読み込んで足りない点だけ追加で聞く。

**フロー:** 準備 → 目的・読者・進め方の設定（質問1回） → インタビュー or 文字起こしの整理 → ドラフト生成 → yomiyasu で推敲・textlint → 確認。

5つの質問カテゴリ。
- 仕事・専門性（技術・プロダクト）
- チーム・カルチャー
- キャリア・成長
- 日常・働き方
- 未来・ビジョン

### 3. 記事レビュー（review-article）

生成済み記事を9つの観点でレビューし、改善を適用する。

**レビュー観点:** 構成 / 文章ルール / 視点の一貫性 / 具体性 / 訴求力 / 行動経済学 / ファクトチェック / AI文体（yomiyasu）/ textlint。

**評価:** A（公開可）/ B（改善推奨）/ C（書き直し）

### 4. 公開用の書き出し（publish-article）

完成した記事を公開先の形式に変換し、`articles/exports/{slug}/` に書き出す。記事の文章は変えない。

- 公開先: note / Zenn / Qiita / はてなブログ / 社内Wiki
- 告知: X の告知文（3案）/ LinkedIn・Facebook / Slack の社内告知 / アイキャッチ画像の案

### 5. AI文の推敲（yomiyasu）

[yomiyasu](https://github.com/nanaism/yomiyasu)（ALGO ARTIS、MIT ライセンス）を `.claude/skills/yomiyasu/` に同梱している。
AI が書いた日本語の不自然な比喩、擬人化、曖昧な主述関係、過剰な装飾を、意味を変えずに直す。

`articles/` の記事を書いたり直したりするときは、常に yomiyasu スキル（Codex では `yomiyasu:yomiyasu`）で推敲すること。コードや設定を直したあとの作業の報告には使わなくてよい。

- 文書の種類: 採用広報・社内広報・インタビュー記事は `promo`、テックブログは `article`
- 作業ファイルを資料として渡し、資料にない事実を足さない
- 推敲後は textlint を再実行し、エラー0を保つ
- 自社で直させたくない語は `.yomiyasu-words/allow.txt`、必ず見直す語は `.yomiyasu-words/flag.txt` に書く

## 品質ゲート

すべての記事は textlint エラー0が必須。textlint は Claude Code のセッション開始時に自動でインストールされる（Codex などでは `npm install` を実行する）。

```bash
# 1記事をチェック
npx textlint articles/対象ファイル.md

# 1記事を自動修正
npx textlint --fix articles/対象ファイル.md

# articles/ の全記事をチェック
npm run lint

# AI特有の表現の見直し候補を出す（yomiyasu、Python 3 が必要。合否判定ではない）
npm run lint:yomiyasu -- articles/対象ファイル.md --doc-type promo
```

### textlint ルール

| ルール | 内容 |
|--------|------|
| preset-ja-technical-writing | 日本語の技術文書の総合ルール（1文100文字以内） |
| no-doubled-joshi | 助詞の連続使用を検出 |
| ja-no-redundant-expression | 冗長な表現を検出 |
| ja-unnatural-alphabet | 不自然なアルファベット使用を検出 |
| prh | `prh.yml` の表記辞書と違う社名・技術用語を検出 |

### 記事の文章規約

詳細は `.claude/shared/writing-rules.md` を参照。

- 1文100文字以内
- です・ます調で統一
- 助詞の連続使用禁止
- 冗長表現の排除
- 全角・半角の適切な使い分け
- 冒頭は挨拶文 →「この記事のポイント」（インタビュー記事は冒頭の引用 → プロフィール → リード）
- 素材に引用可能な発言があれば「」引用を活用
- 1セクション150〜300文字目安

## 出力

記事は `articles/{YYYY-MM-DD}-{slug}.md` に出力される。
