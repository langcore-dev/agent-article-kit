#!/bin/bash
# セッション開始時に、記事の品質チェックに使うツールをそろえる。
# - textlint（npm の devDependencies）が入っていなければ npm install する
# - yomiyasu の検査ツールに使う python3 がなければ知らせる
set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" || exit 0

if [ ! -x node_modules/.bin/textlint ]; then
  if command -v npm >/dev/null 2>&1; then
    if npm install --no-audit --no-fund --loglevel=error >/dev/null 2>&1; then
      echo "agent-article-kit: textlint をインストールしました（npm install）。"
    else
      echo "agent-article-kit: npm install に失敗しました。記事の textlint チェックの前に npm install を実行してください。"
    fi
  else
    echo "agent-article-kit: npm が見つかりません。textlint を使うには Node.js をインストールしてください。"
  fi
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "agent-article-kit: python3 が見つかりません。yomiyasu の検査ツール（yomiyasu_lint.py）は使えません。"
fi

exit 0
