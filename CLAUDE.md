# Claude Code 固有設定

共通のプロジェクト情報は @AGENTS.md を参照。

## スラッシュコマンド

`.claude/skills/` のスキルは、そのままスラッシュコマンドとして呼べる。引数にファイルパスや本文を渡すと、答えの分かる質問を飛ばす。

| コマンド | 説明 |
|---------|------|
| `/write-article [メモ]` | テーマ・メモから対話で記事を作成 |
| `/interview [文字起こし]` | 社員へのインタビュー、または取材の文字起こしから記事を作成 |
| `/review-article [記事]` | 記事ドラフトをレビューし改善案を提示 |
| `/publish-article [記事]` | note・Zenn・Qiita などの形式と SNS 告知文を書き出す |
| `/yomiyasu` | AI が書いた日本語を推敲（外部スキル yomiyasu） |

## サブエージェント

| エージェント | トリガー | 役割 |
|------------|---------|------|
| `write-article-drafter` | `/write-article` Phase 4 | 作業ファイルの素材と構成案からドラフトを生成 |
| `article-writer` | `/interview` Phase 3 | 作業ファイルのインタビュー記録からドラフトを生成 |

両エージェントとも、生成後に textlint を実行しエラー0を確認してから完了する。

## フック

`.claude/settings.json` の SessionStart フック（`.claude/hooks/session-start.sh`）が、textlint が入っていなければ `npm install` を実行する。

## 記事作成時の注意

- 記事の出力先は `articles/` ディレクトリ
- ファイル名は `{YYYY-MM-DD}-{slug}.md` 形式
- textlint エラーが残っている場合は修正してから完了すること
- `articles/` の記事を書いたり直したりするときは、常に yomiyasu スキルで推敲してください。コードや設定を直したあとの作業の報告には使わなくてかまいません。
