#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re

def extract_exact_failed_files(log_file):
    """失敗ファイルの正確なパス、ファイル名、容量を抽出"""
    failed_files = []
    
    try:
        with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # エラー112の直前行を検索
        lines = content.split('\n')
        for i, line in enumerate(lines):
            if 'エラー 112' in line and i > 0:
                prev_line = lines[i-1].strip()
                
                # 新しいファイルの行を解析
                if '新しいファイル' in prev_line and '<IP_ADDRESS>' in prev_line:
                    # サイズとパスを抽出
                    # パターン: \t\t   サイズ\t\\<IP_ADDRESS>\share\パス
                    match = re.search(r'\t+([0-9.]+\s*[kmg]?)\t+(\\\\172\.16\.5\.245\\share\\.*)', prev_line)
                    if match:
                        size = match.group(1).strip()
                        full_path = match.group(2).strip()
                        
                        # ファイル名を抽出
                        filename = full_path.split('\\')[-1]
                        
                        failed_files.append({
                            'size': size,
                            'full_path': full_path,
                            'filename': filename
                        })
        
        return failed_files
        
    except Exception as e:
        print(f"エラー: {e}")
        return []

if __name__ == "__main__":
    log_file = "logs/logs_prod/robocopy_20250830_020000.txt"
    failed_files = extract_exact_failed_files(log_file)
    
    print(f"失敗ファイル総数: {len(failed_files)}")
    print("\n=== 失敗ファイル詳細一覧 ===")
    print(f"{'No.':<4} {'サイズ':<10} {'ファイル名':<50} {'フルパス'}")
    print("-" * 120)
    
    for i, file_info in enumerate(failed_files[:50]):  # 最初の50件
        print(f"{i+1:<4} {file_info['size']:<10} {file_info['filename']:<50} {file_info['full_path']}")
    
    if len(failed_files) > 50:
        print(f"\n... 他 {len(failed_files) - 50} 件")
    
    # サイズ別統計
    mb_files = [f for f in failed_files if 'm' in f['size'].lower()]
    gb_files = [f for f in failed_files if 'g' in f['size'].lower()]
    kb_files = [f for f in failed_files if 'k' in f['size'].lower() or f['size'].isdigit()]
    
    print(f"\n=== サイズ別統計 ===")
    print(f"GB単位ファイル: {len(gb_files)}件")
    print(f"MB単位ファイル: {len(mb_files)}件") 
    print(f"KB単位ファイル: {len(kb_files)}件")
