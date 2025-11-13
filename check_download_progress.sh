#!/bin/bash
# gpt-oss-120bのダウンロード進捗を確認するスクリプト

echo "=========================================="
echo "gpt-oss-120b ダウンロード進捗"
echo "=========================================="

# ダウンロード済みサイズ
SIZE=$(du -sh ~/work/hf_cache/hub/models--openai--gpt-oss-120b 2>/dev/null | cut -f1 || echo "N/A")
echo "現在のサイズ: $SIZE"

# safetensorsファイルの数
SAFETENSORS=$(find ~/work/hf_cache/hub/models--openai--gpt-oss-120b -name "*.safetensors" 2>/dev/null | wc -l)
INCOMPLETE=$(find ~/work/hf_cache/hub/models--openai--gpt-oss-120b -name "*.incomplete" 2>/dev/null | wc -l)
echo "完了ファイル数: $SAFETENSORS"
echo "ダウンロード中: $INCOMPLETE"

# プロセス確認
docker compose exec -T flexeval ps aux | grep -E "download_model|snapshot_download" | grep -v grep > /dev/null
if [ $? -eq 0 ]; then
  echo "ステータス: ダウンロード実行中 ✅"
else
  echo "ステータス: プロセスなし ❌"
fi

# 最新ログ
echo ""
echo "最新ログ:"
docker compose exec -T flexeval tail -5 /tmp/download_120b.log 2>/dev/null

echo "=========================================="

