---
name: publish-article
description: 完成した記事を note・Zenn・Qiita・はてなブログ・社内Wiki の投稿形式に書き出し、X や Slack の告知文とアイキャッチ画像の案を作る。
argument-hint: "[記事のファイルパス]"
---

# 公開用書き出しスキル

`articles/` の完成した記事を、公開先の形式に変換して書き出すスキル。あわせて SNS の告知文とアイキャッチ画像の案を作る。記事の本文の内容は変えない。

呼び出し例:

```text
/publish-article
/publish-article articles/2026-10-24-ci-migration.md
```

## 前提ファイル

- `.claude/skills/publish-article/platforms.md` - 公開先ごとの形式と注意点
- `.article-kit/profile.md` - 会社名と、よく使う公開先（あれば）

## ワークフロー

### Phase 1: 対象と公開先の決定

1. 対象記事を決める
   - 引数に記事のファイルパスがあれば、それを使う
   - なければ `articles/*.md` を更新日の新しい順に最大4件、AskUserQuestion の選択肢にして選んでもらう
2. 記事を Read で読み込み、`npx textlint {記事パス}` でエラーが0か確かめる。エラーがあれば先に直すか、ユーザーに伝えて止める
3. AskUserQuestion を1回呼び、次の2問をまとめて聞く（どちらも複数選択）。プロフィールに公開先があれば、それを1つ目の選択肢にする

```
questions:
  - header: "公開先"
    question: "どこに公開しますか？（複数選択可。社内Wiki などは Other に入力）"
    multiSelect: true
    options:
      - label: "note"
        description: "採用広報でよく使うブログサービス"
      - label: "Zenn"
        description: "技術記事向け。front matter つきで書き出す"
      - label: "Qiita"
        description: "技術記事向け。Qiita CLI の形式で書き出す"
      - label: "はてなブログ"
        description: "Markdown モードの本文として書き出す"
  - header: "告知・画像"
    question: "一緒に作るものを選んでください（複数選択可）"
    multiSelect: true
    options:
      - label: "X の告知文"
        description: "140字以内で3案"
      - label: "LinkedIn・Facebook の告知文"
        description: "300字程度で1案"
      - label: "Slack の社内告知"
        description: "社内チャンネルに貼る短い告知文"
      - label: "アイキャッチ画像の案"
        description: "画像に入れる文字の案と、画像生成 AI 向けの指示文"
```

### Phase 2: 書き出し

`.claude/skills/publish-article/platforms.md` を読み、選ばれた公開先ごとに `articles/exports/{記事のslug}/` へ書き出す。

| 公開先 | ファイル名 |
|---|---|
| note | `note.md` |
| Zenn | `zenn.md` |
| Qiita | `qiita.md` |
| はてなブログ | `hatena.md` |
| 社内Wiki など（Other） | `wiki.md` |
| 告知文・アイキャッチ | `promotion.md` |

- タイトル、本文の文章、「」引用は変えない。変えてよいのは、公開先が対応していない書式（表など）の置き換えと、front matter の追加だけ
- タグ（Zenn の topics、Qiita の tags）は記事の内容から選び、公開先の上限を守る
- 告知文は記事に書いてある事実だけを使う。記事にない数値や誇張を足さない
- 告知文の URL は `{記事のURL}` のままにする（公開後に差し替える）

### Phase 3: 確認

1. 書き出したファイルの一覧と、`promotion.md` の内容を提示する
2. 各公開先で手作業が必要な点（タイトル欄への貼り付け、見出し画像の設定など）を箇条書きで添える
