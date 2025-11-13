#!/usr/bin/env python3
"""任意のモデルを事前にダウンロードするスクリプト"""

from huggingface_hub import snapshot_download
import os

model_id = "sbintuitions/sarashina2.2-3b"
cache_dir = os.path.expanduser("/workspace/.cache/huggingface")

print(f"モデル {model_id} のダウンロードを開始します...")
print(f"キャッシュディレクトリ: {cache_dir}")
print("=" * 60)

try:
    # モデル全体をダウンロード
    local_path = snapshot_download(
        repo_id=model_id,
        cache_dir=cache_dir,
        resume_download=True,  # 中断した場合は再開
        local_files_only=False,
    )
    print("=" * 60)
    print(f"✅ ダウンロード完了！")
    print(f"保存先: {local_path}")
except Exception as e:
    print(f"❌ エラーが発生しました: {e}")
    raise


