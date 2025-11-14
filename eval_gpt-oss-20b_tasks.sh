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

# flexevalコンテナが稼働中で既存タスクが動いていれば通知して終了
RUNNING_CONTAINER=$(docker compose ps -q flexeval 2>/dev/null || true)
if [[ -n "$RUNNING_CONTAINER" ]]; then
  if docker compose exec -T flexeval pgrep -f flexeval_lm >/dev/null 2>&1; then
    echo "flexevalコンテナでflexeval_lmが稼働中のため、新規実行を中止します。"
    exit 1
  fi
fi

# gpt-oss-20bを使用したモデル設定
MODEL_CONFIG="/app/configs/gpt-oss-20b.jsonnet"

# タスクリスト
TASKS=("aio" "jcomqa" "jemhopqa" "jsquad" "niilcqa")

# デバッグ用途で処理件数を制限したい場合は MAX_INSTANCES を外部から与える
MAX_INSTANCE_ARGS=()
if [[ -n "${MAX_INSTANCES}" ]]; then
  echo "max_instances override: ${MAX_INSTANCES}"
  MAX_INSTANCE_ARGS=(--eval_setup.init_args.max_instances "${MAX_INSTANCES}")
fi

echo "====================================="
echo "gpt-oss-20bでの評価を開始します"
echo "実行タスク: ${TASKS[@]}"
echo "====================================="

# ログディレクトリを作成
LOG_DIR="logs"
mkdir -p "${LOG_DIR}"

# 各タスクを順次実行
for TASK in "${TASKS[@]}"; do
  echo ""
  echo "-------------------------------------"
  echo "タスク: ${TASK} の評価を開始"
  echo "-------------------------------------"
  
  # eval_setupのパスを設定（aioはプリセット、それ以外はexamplesから）
  if [[ " aio jcomqa jemhopqa jsquad niilcqa " =~ " ${TASK} " ]]; then
    EVAL_SETUP="examples/gpt-oss-evaluation/eval_setups_chat/${TASK}.jsonnet"
  else
    EVAL_SETUP="examples/sarashina_evaluation/eval_setups_chat/${TASK}.jsonnet"
  fi
  
  SAVE_DIR="data/results/${TASK}_chat/gpt-oss-20b"
  #LOG_FILE="${LOG_DIR}/${TASK}_gpt-oss-20b.log"
  
  #echo "ログファイル: ${LOG_FILE}"
  
  docker compose exec -T flexeval flexeval_lm \
    --language_model "${MODEL_CONFIG}" \
    --eval_setup "${EVAL_SETUP}" \
    --save_dir "${SAVE_DIR}" \
    --force true \
    "${MAX_INSTANCE_ARGS[@]}"
  
  if [ $? -eq 0 ]; then
    echo "タスク: ${TASK} が正常に完了しました"
    echo "結果保存先: ${SAVE_DIR}"
  else
    echo "エラー: タスク: ${TASK} の実行中に問題が発生しました"
    exit 1
  fi
done

echo ""
echo "====================================="
echo "全てのタスクが正常に完了しました"
echo "====================================="
