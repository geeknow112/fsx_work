#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import sys

def extract_failed_files(log_file):
    """ログファイルから未同期ファイルを抽出"""
    failed_files = []
    
    try:
        # 複数のエンコーディングを試行
        encodings = ['utf-8', 'shift_jis', 'cp932', 'utf-16']
        content = None
        
        for encoding in encodings:
            try:
                with open(log_file, 'r', encoding=encoding, errors='ignore') as f:
                    content = f.read()
                break
            except:
                continue
        
        if not content:
            print("ファイルを読み込めませんでした")
            return []
        
        # エラー112の直前行からファイルパスを抽出
        lines = content.split('\n')
        for i, line in enumerate(lines):
            if 'エラー 112' in line and i > 0:
                prev_line = lines[i-1].strip()
                if '<IP_ADDRESS>' in prev_line:
                    # ファイルパスを抽出
                    match = re.search(r'\\\\172\.16\.5\.245\\share\\.*', prev_line)
                    if match:
                        failed_files.append(match.group(0))
        
        return failed_files
        
    except Exception as e:
        print(f"エラー: {e}")
        return []

if __name__ == "__main__":
    log_file = "logs/logs_prod/robocopy_20250830_020000.txt"
    failed_files = extract_failed_files(log_file)
    
    print(f"未同期ファイル数: {len(failed_files)}")
    print("\n=== 未同期ファイル一覧（最初の20件） ===")
    for i, file_path in enumerate(failed_files[:20]):
        print(f"{i+1:3d}: {file_path}")
    
    if len(failed_files) > 20:
        print(f"\n... 他 {len(failed_files) - 20} 件")
    
    # ファイルサイズ別の統計
    print(f"\n=== 統計 ===")
    print(f"総未同期ファイル数: {len(failed_files)}")
