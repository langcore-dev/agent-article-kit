# 記事作成ワークフローの共通手順

`write-article` と `interview` が共通で使う手順。各スキルの SKILL.md から参照する。

## 1. 準備（ワークフローの最初に必ず行う）

### 1-1. プロフィールの読み込み

`.article-kit/profile.md` を Read で読み込む。会社名・所属・書き手の名前・役職・よく使う読者層が書かれている。

- ある場合: 書いてある項目は質問しない。挨拶文の「{所属}」「{名前}」はここから取る
- ない場合: 次の1問を通常のメッセージで聞く（AskUserQuestion は使わない）

  > はじめに、記事の書き手について教えてください。会社名、所属（部署・チーム）、お名前、役職の4つです。次回から聞かずに済むよう `.article-kit/profile.md` に保存します。

  回答を `.article-kit/profile.example.md` の形式で `.article-kit/profile.md` に保存する。保存したことをユーザーに一言伝える
- 今回だけ別の人が書き手になる場合は、その人の情報を Phase 1 で聞き、プロフィールのファイルは書き換えない

### 1-2. 呼び出し時の引数

スキルを呼び出したときに引数（`/write-article notes.md` のようなファイルパスや、貼り付けた本文）が渡されていれば、それを素材として使う。

- ファイルパスなら Read で読み込む
- 本文ならそのまま素材とする
- 引数から答えが分かる質問は飛ばす（例: メモが渡されていれば「素材を貼ってください」と聞かない）
- `articles/.work/{slug}/material.md` が渡された場合は、下の「4. 再開」の手順に進む

### 1-3. 途中の作業の確認

引数がなく、`articles/.work/` に `status: drafting` 以前の作業ファイルがある場合は、AskUserQuestion で再開するかを聞く。

```
question: "途中の記事があります。続きから再開しますか？"
options:
  - label: "{slug}（{最終更新日}）を再開"
    description: "{テーマや対象者の要約}"
  - label: "新しく始める"
    description: "途中の作業はそのまま残し、新しい記事を作る"
```

## 2. 作業ファイル（素材の保存）

素材や回答は会話の中だけに置かず、`articles/.work/{slug}/material.md` に書き出す。会話が切れても再開でき、yomiyasu の推敲やファクトチェックの資料にも使える。

- slug は記事ファイル名と同じ `{YYYY-MM-DD}-{英小文字とハイフンのslug}` にする
- Phase 1 が終わった時点で作成し、質問に1つ答えてもらうごとに追記する
- 形式は次のとおり

```markdown
---
skill: write-article | interview
status: collecting | outlining | drafting | finishing | done
article: articles/{slug}.md
updated: {YYYY-MM-DD}
---

# コンテキスト

{Phase 1 で決めた内容（記事の種類、読者、書き手、登場人物 / 対象者プロフィール など）}

# 素材

{元のメモ、文字起こし、質問と回答のログ}

# 構成案

{確定した構成案（確定前は空）}
```

- `status` は各 Phase の開始時に更新する
- 記事を確定したら `status: done` にする（作業ファイルは消さない）

## 3. ドラフト後の仕上げ

サブエージェントがドラフトを書き終えたら、次の順に仕上げる。

### 3-1. yomiyasu で推敲する

AI が書いたドラフトに残る不自然な比喩や曖昧な主述関係を、yomiyasu スキル（`.claude/skills/yomiyasu/`）で直す。

- 文書の種類: 採用広報・社内広報・インタビュー記事は `promo`、テックブログは `article` として依頼する
- 読者: Phase 1 で決めた読者を伝える（例: 「中途のエンジニア候補者向け」）
- 資料: 作業ファイル `articles/.work/{slug}/material.md` を渡し、資料にない事実を足さないようにする
- 「」引用の発言内容は変えない
- 推敲した最終稿で元の記事ファイルを上書きする

### 3-2. textlint を通す

`npx textlint {記事パス}` を実行し、エラーが0になるまで直す。機械的に直せるものは `npx textlint --fix {記事パス}` で直す。

### 3-3. ユーザーに提示する

1. 記事ファイルを Read で読み込み、全文を提示する
2. yomiyasu の完了報告に「書き手に確かめたい点」があれば、記事の後に箇条書きで添える
3. AskUserQuestion で修正の要否を確認する

```
question: "記事のドラフトが完成しました。どうしますか？"
options:
  - label: "このままでOK"
    description: "記事を確定する"
  - label: "部分的に修正したい"
    description: "特定のセクションや表現を修正する"
  - label: "全体的に書き直したい"
    description: "トーンや構成を含めて大幅に修正する"
  - label: "公開用に書き出す"
    description: "記事を確定し、note・Zenn などの形式と SNS 告知文を作る（publish-article）"
```

- 「このままでOK」→ 作業ファイルを `status: done` にし、記事のパスを伝える
- 「部分的に修正したい」→ 修正箇所を聞いて Edit で直し、textlint を再実行する
- 「全体的に書き直したい」→ フィードバックを作業ファイルに追記し、サブエージェントを再起動する
- 「公開用に書き出す」→ 作業ファイルを `status: done` にし、`publish-article` スキルの手順に進む

## 4. 再開

作業ファイルを Read し、`status` に応じて途中から再開する。

| status | 再開する場所 |
|---|---|
| collecting | 素材集め（深掘り / インタビュー）の続き。記録済みの質問は繰り返さない |
| outlining | 構成提案 |
| drafting | ドラフト生成（サブエージェントを起動し直す） |
| finishing | 「3. ドラフト後の仕上げ」 |
