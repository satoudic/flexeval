#!/bin/bash
set -e

# コンテナの状態を確認（-aオプションで停止中のコンテナも含める）
CONTAINER_STATUS=$(docker compose ps -aq flexeval | xargs docker inspect -f '{{.State.Status}}' 2>/dev/null || echo "not_exist")

if [ "$CONTAINER_STATUS" = "not_exist" ]; then
  echo "コンテナが存在しないため、作成して起動します..."
  docker compose up -d
elif [ "$CONTAINER_STATUS" != "running" ]; then
  echo "コンテナが停止しているため、起動します..."
  docker compose start
else
  echo "コンテナは既に起動しています"
fi

# ダウンロードスクリプトを実行
echo "モデルのダウンロードを開始します..."
docker compose exec -T flexeval python scripts/download_model_from_huggingface.py

