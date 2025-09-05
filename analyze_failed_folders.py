#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
from collections import defaultdict

def analyze_failed_folders(log_file):
    """失敗ファイルをフォルダ別に分析"""
    failed_files = []
    
    try:
        with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # エラー5の直前行からファイルパスを抽出
        lines = content.split('\n')
        for i, line in enumerate(lines):
            if 'エラー 5' in line and i > 0:
                prev_line = lines[i-1].strip()
                if '<IP_ADDRESS>' in prev_line:
                    # ファイルパスを抽出
                    match = re.search(r'\\\\172\.16\.5\.109\\share\\(.+)', prev_line)
                    if match:
                        file_path = match.group(1)
                        failed_files.append(file_path)
        
        # フォルダ別に分類
        folder_analysis = defaultdict(list)
        for file_path in failed_files:
            # 最初の2階層でフォルダを分類
            parts = file_path.split('\\')
            if len(parts) >= 2:
                folder = '\\'.join(parts[:2])
            else:
                folder = parts[0] if parts else 'Unknown'
            
            folder_analysis[folder].append(file_path)
        
        return dict(folder_analysis)
        
    except Exception as e:
        print(f"エラー: {e}")
        return {}

if __name__ == "__main__":
    log_file = "logs/logs_prod/robocopy_20250901_225200_full_sync.txt"
    folder_analysis = analyze_failed_folders(log_file)
    
    print(f"=== 失敗ファイルのフォルダ別分析 ===")
    print(f"失敗フォルダ数: {len(folder_analysis)}")
    
    total_files = sum(len(files) for files in folder_analysis.values())
    print(f"総失敗ファイル数: {total_files}")
    
    print(f"\n--- フォルダ別詳細 ---")
    for folder, files in sorted(folder_analysis.items(), key=lambda x: len(x[1]), reverse=True):
        print(f"{folder}: {len(files)}ファイル")
        # サンプルファイル表示
        for i, file_path in enumerate(files[:3]):
            filename = file_path.split('\\')[-1]
            print(f"  - {filename}")
        if len(files) > 3:
            print(f"  ... 他 {len(files) - 3} ファイル")
        print()
