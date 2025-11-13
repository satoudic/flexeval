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

# モデル設定
MODEL="sbintuitions/sarashina2.2-3b"
MODEL_NAME="sarashina2.2-3b"

# 全タスクを実行
TASKS=("aio" "jcomqa" "jemhopqa" "jsquad" "niilcqa")

echo "=========================================="
echo "${MODEL_NAME} での評価を開始します"
echo "実行タスク: ${TASKS[@]}"
echo "=========================================="

for TASK in "${TASKS[@]}"; do
  echo ""
  echo "----------------------------------------"
  echo "タスク: ${TASK} の評価を開始"
  echo "----------------------------------------"
  
  # eval_setupのパスを設定（aioはプリセット、それ以外はexamplesから）
  if [ "${TASK}" = "aio" ]; then
    EVAL_SETUP="${TASK}"
  else
    EVAL_SETUP="examples/sarashina_evaluation/eval_setups/${TASK}.jsonnet"
  fi
  
  SAVE_DIR="data/results/${TASK}/${MODEL_NAME}"
  
  docker compose exec -T flexeval flexeval_lm \
    --language_model HuggingFaceLM \
    --language_model.model "${MODEL}" \
    --eval_setup "${EVAL_SETUP}" \
    --save_dir "${SAVE_DIR}" \
    --force true
  
  if [ $? -eq 0 ]; then
    echo "タスク: ${TASK} が正常に完了しました"
    echo "結果保存先: ${SAVE_DIR}"
  else
    echo "エラー: タスク: ${TASK} の実行中に問題が発生しました"
    exit 1
  fi
  echo ""
done

echo "=========================================="
echo "全てのタスクが正常に完了しました！"
echo "=========================================="


# gpt-oss-20Bトライ
#docker compose exec -T flexeval flexeval_lm \
#  --language_model HuggingFaceLM \
#  --language_model.model "openai/gpt-oss-20b" \
#  --eval_setup "aio" \
#  --save_dir "data/results/aio/gpt-oss-20b"