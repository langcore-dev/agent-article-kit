---
name: write-article
description: 書きたいことドリブンで採用広報・社内広報記事を作成する。断片メモやテーマ・キーワードから対話で素材を深掘りし、記事ドラフトを自動生成する。
argument-hint: "[メモのファイルパス、テーマ、または作業ファイル]"
---

# 書きたいことドリブン記事作成スキル

「書きたいこと」を起点に、対話で素材を深掘りしながら採用広報・社内広報記事のドラフトを生成するスキル。インタビュー形式ではなく、ユーザー自身が持つアイデアや断片的なメモから記事を組み立てる。

呼び出し例:

```text
/write-article
/write-article notes/ci-migration.md
/write-article 新しいCI/CDを入れて開発速度が2倍になった話
```

## 前提ファイル

すべてプロジェクトルートからの相対パスで参照する。

- `.claude/shared/workflow-common.md` - プロフィール、引数、作業ファイル、仕上げの共通手順
- `.claude/shared/writing-rules.md` - 文章ルール、タイトル指針、行動経済学テクニック
- `.claude/skills/write-article/writing-guide.md` - 深掘り対話ガイドと質問パターン
- `.claude/skills/write-article/article-template.md` - 記事の構成テンプレート
- `.claude/agents/write-article-drafter.md` - 記事生成サブエージェント

## ワークフロー

### Phase 0: 準備

`.claude/shared/workflow-common.md` の「1. 準備」を行う（プロフィールの読み込み、引数の確認、途中の作業の確認）。

### Phase 1: 素材投入

#### 1-1. 素材の受け取り

引数で素材が渡されていなければ、通常のメッセージで次のように聞く（AskUserQuestion は使わない）。

> 書きたいテーマやキーワード、メモを貼り付けてください。箇条書き、走り書き、どんな形式でも構いません。

素材がテーマだけか、メモを含むかは内容から判断する。ユーザーに入力の種類を選ばせない。

#### 1-2. 記事の設定

AskUserQuestion を1回だけ呼び、次の質問をまとめて聞く。プロフィールや素材から明らかな項目は質問から外す。

```
questions:
  - header: "記事の種類"
    question: "どんな記事にしますか？"
    options:
      - label: "採用広報（エンジニア向け）"
        description: "エンジニア候補者に自社の魅力を伝える記事"
      - label: "採用広報（非エンジニア向け）"
        description: "非エンジニア候補者に向けた組織・文化紹介の記事"
      - label: "社内広報"
        description: "社内メンバーに向けた取り組み紹介・ナレッジ共有の記事"
      - label: "テックブログ（採用広報兼）"
        description: "技術発信しつつ採用ブランディングも兼ねる記事"
  - header: "書き手"
    question: "誰の視点で書きますか？"
    options:
      - label: "{プロフィールの名前}（一人称）"
        description: "プロフィールの書き手の一人称視点で書く"
      - label: "別の人（一人称）"
        description: "記事の主役となる人物の視点で書く（Other で名前・役職を入力）"
      - label: "著者なし（三人称）"
        description: "特定の著者を置かず、組織やチーム視点で書く"
  - header: "登場人物"
    question: "書き手以外に登場する人物はいますか？"
    options:
      - label: "いない"
        description: "書き手と組織だけで構成する"
      - label: "いる"
        description: "Other で名前・役職・チームを入力"
  - header: "読者"
    question: "主な読者は誰ですか？"
    options:
      - label: "{プロフィールの主な読者}"
        description: "プロフィールに登録した読者"
      - label: "中途の候補者"
        description: "経験者採用の候補者"
      - label: "新卒の候補者"
        description: "新卒採用の候補者"
      - label: "社内メンバー"
        description: "社内広報として読む同僚"
```

回答を受けたら、`.claude/shared/workflow-common.md` の「2. 作業ファイル」の形式で `articles/.work/{slug}/material.md` を作り、コンテキストと素材を書き込む（`status: collecting`）。

### Phase 2: 素材の深掘り対話

`.claude/skills/write-article/writing-guide.md` を読み込み、深掘りパターンを把握する。

#### 対話の進め方

1. 素材を6観点（具体性・エピソード・背景/動機・成果/変化・感情/実感・メッセージ性）で分析し、不足している要素を洗い出す
2. 不足要素に対して AskUserQuestion で1問ずつ質問する
   - 回答の参考になる選択肢を2〜3個用意しつつ、「Other」からの自由入力を基本とする
   - 素材から推測できる答えを選択肢にし、ユーザーが選ぶだけで済む形を優先する
3. 回答を受け取ったら、writing-guide.md の深掘りルールに照らして判定する（深掘りは同じ質問で最大2回）
4. 次の質問を前の回答の内容を踏まえて動的に生成する
5. 合計3〜6問を目安に素材を充実させる。素材が十分なら少なくてよい
6. 回答を受け取るたびに作業ファイルの「素材」に追記する

```
- 観点: {観点}
  質問: {質問文}
  回答: {回答文}
  深掘り:
    - 質問: {深掘り質問}
      回答: {深掘り回答}
```

### Phase 3: 構成提案

作業ファイルを `status: outlining` にし、素材全体を俯瞰して構成案を作る。逆三角形（結論先出し）の原則に従う。

1. **仮タイトル**: `.claude/shared/writing-rules.md` の「タイトルのガイドライン」に従い、30文字以内で2案出す
2. **「この記事のポイント」**: 3〜4項目の箇条書き。結論や核心を先に示す
3. **セクション構成**: 3〜4セクションの見出しと、各セクションに割り当てる素材
4. **山場と締め**: どのセクションが山場（ピーク）で、どう締めるか（エンド）

構成案をテキストで提示し、AskUserQuestion で確認する。

```
question: "この構成で記事を作成してよいですか？"
options:
  - label: "この構成でOK"
    description: "このまま記事を生成する"
  - label: "構成を修正したい"
    description: "セクションの順番や内容を変更する"
  - label: "素材を追加したい"
    description: "Phase 2 に戻って追加の深掘りを行う"
```

- 「この構成でOK」→ 構成案を作業ファイルに書き込み、Phase 4 へ進む
- 「構成を修正したい」→ 修正内容を聞いて構成を更新し、再度確認する
- 「素材を追加したい」→ Phase 2 に戻る

### Phase 4: ドラフト生成

作業ファイルを `status: drafting` にし、Agent ツールで `write-article-drafter` サブエージェントを起動する。素材は作業ファイルに入っているので、プロンプトにはパスと設定だけを渡す。

```
以下の作業ファイルの素材と構成案から記事を作成してください。

## 作業ファイル
articles/.work/{slug}/material.md

## 出力先
articles/{slug}.md

## 記事の種類
{記事の種類}（パターン{A / B}）

## 読者
{読者}

## 書き手
- 名前: {名前}
- 所属: {所属}
- 役職: {役職}
- 視点: {一人称 / 三人称}

## 登場人物
{登場人物（いなければ「なし」）}
```

### Phase 5: 仕上げ

作業ファイルを `status: finishing` にし、`.claude/shared/workflow-common.md` の「3. ドラフト後の仕上げ」を行う（yomiyasu で推敲 → textlint → 提示と確認）。
