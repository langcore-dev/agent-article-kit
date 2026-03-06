# agent-article-kit

Claude Code / Codex CLI 対応の日本語の記事作成ツールキット。
採用広報・社内広報記事を、対話型ワークフローで効率的に作成する。

## ディレクトリ構成

```
.claude/
├── commands/        # スラッシュコマンド定義
│   ├── write-article.md
│   └── interview.md
├── skills/          # ワークフロー定義（SKILL.md）
│   ├── write-article/
│   ├── interview/
│   └── review-article/
└── agents/          # サブエージェント定義
    ├── write-article-drafter.md
    └── article-writer.md
articles/            # 生成記事の出力先
```

## ワークフロー

### 1. 書きたいことドリブン記事作成（write-article）

テーマや断片メモから対話で素材を深掘りし、記事を生成する。

**フロー:** 素材入力 → 6視点で深掘り対話 → 構成提案 → ドラフト生成 → レビュー。

6つの深掘り視点。
- 具体性（固有名詞・数字）
- エピソード（体験・出来事）
- 背景・動機（なぜ）
- 成果・変化（Before/After）
- 感情・気づき（温度感）
- メッセージ（読者への伝言）

### 2. インタビュー記事作成（interview）

エンジニアへの対話型インタビューを実施し、記事を生成する。

**フロー:** 目的・対象設定 → 5カテゴリでインタビュー → ドラフト生成 → レビュー。

5つの質問カテゴリ。
- 技術・プロダクト
- チーム・カルチャー
- キャリア・成長
- 日常・働き方
- 未来・ビジョン

### 3. 記事レビュー（review-article）

生成済み記事を6次元でレビューし、改善を適用する。

**レビュー観点:** 構成 / 文章ルール / 視点の一貫性 / 具体性 / 訴求力 / textlint。

**評価:** A（公開可）/ B（改善推奨）/ C（書き直し）

## 品質ゲート

すべての記事は textlint エラー0が必須。

```bash
# リント実行
npm run lint -- articles/対象ファイル.md

# 自動修正
npm run lint:fix -- articles/対象ファイル.md
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
