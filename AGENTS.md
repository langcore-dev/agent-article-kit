# agent-article-kit

Claude Code / Codex CLI 対応の日本語の記事作成ツールキット。
採用広報・社内広報記事を、対話型ワークフローで効率的に作成する。

## ディレクトリ構成

```
.claude/
├── commands/        # スラッシュコマンド定義
│   ├── write-article.md
│   ├── interview.md
│   └── review-article.md
├── skills/          # ワークフロー定義（SKILL.md）
│   ├── write-article/
│   ├── interview/
│   ├── review-article/
│   └── yomiyasu/    # AI文の推敲スキル（nanaism/yomiyasu を同梱）
└── agents/          # サブエージェント定義
    ├── write-article-drafter.md
    └── article-writer.md
.agents/skills/      # Codex 用（.claude/skills/ へのシンボリックリンク）
articles/            # 生成記事の出力先
```

## ワークフロー

### 1. 書きたいことドリブン記事作成（write-article）

テーマや断片メモから対話で素材を深掘りし、記事を生成する。

**フロー:** 素材入力 → 6視点で深掘り対話 → 構成提案 → ドラフト生成 → yomiyasu で推敲 → レビュー。

6つの深掘り視点。
- 具体性（固有名詞・数字）
- エピソード（体験・出来事）
- 背景・動機（なぜ）
- 成果・変化（Before/After）
- 感情・気づき（温度感）
- メッセージ（読者への伝言）

### 2. インタビュー記事作成（interview）

エンジニアへの対話型インタビューを実施し、記事を生成する。

**フロー:** 目的・対象設定 → 5カテゴリでインタビュー → ドラフト生成 → yomiyasu で推敲 → レビュー。

5つの質問カテゴリ。
- 技術・プロダクト
- チーム・カルチャー
- キャリア・成長
- 日常・働き方
- 未来・ビジョン

### 3. 記事レビュー（review-article）

生成済み記事を6次元でレビューし、改善を適用する。

**レビュー観点:** 構成 / 文章ルール / 視点の一貫性 / 具体性 / 訴求力 / AI文体（yomiyasu）/ textlint。

**評価:** A（公開可）/ B（改善推奨）/ C（書き直し）

### 4. AI文の推敲（yomiyasu）

[yomiyasu](https://github.com/nanaism/yomiyasu)（ALGO ARTIS、MIT ライセンス）を `.claude/skills/yomiyasu/` に同梱している。
AI が書いた日本語の不自然な比喩、擬人化、曖昧な主述関係、過剰な装飾を、意味を変えずに直す。

`articles/` の記事を書いたり直したりするときは、常に yomiyasu スキル（Codex では `yomiyasu:yomiyasu`）で推敲すること。コードや設定を直したあとの作業の報告には使わなくてよい。

- 文書の種類: 採用広報・社内広報は `promo`、テックブログは `article`
- 素材やインタビュー記録を資料として渡し、資料にない事実を足さない
- 推敲後は textlint を再実行し、エラー0を保つ

## 品質ゲート

すべての記事は textlint エラー0が必須。

```bash
# リント実行
npm run lint -- articles/対象ファイル.md

# 自動修正
npm run lint:fix -- articles/対象ファイル.md

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

### 記事の文章規約

- 1文100文字以内
- です・ます調で統一
- 助詞の連続使用禁止
- 冗長表現の排除
- 全角・半角の適切な使い分け
- 素材に引用可能な発言があれば「」引用を活用
- 1セクション150〜300文字目安

## 出力

記事は `articles/{YYYY-MM-DD}-{slug}.md` に出力される。
