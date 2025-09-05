#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re

def analyze_robocopy_errors(log_file):
    """Robocopyログからエラーを解析"""
    errors = []
    
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
        
        # エラーパターンを検索
        lines = content.split('\n')
        for i, line in enumerate(lines):
            # エラー5 (アクセス拒否)
            if 'エラー 5' in line or 'ERROR 5' in line:
                if i > 0:
                    prev_line = lines[i-1].strip()
                    errors.append({
                        'type': 'アクセス拒否 (エラー5)',
                        'file': prev_line,
                        'error': line.strip()
                    })
            
            # エラー112 (容量不足)
            elif 'エラー 112' in line or 'ERROR 112' in line:
                if i > 0:
                    prev_line = lines[i-1].strip()
                    errors.append({
                        'type': '容量不足 (エラー112)',
                        'file': prev_line,
                        'error': line.strip()
                    })
            
            # その他のエラー
            elif 'エラー' in line or 'ERROR' in line:
                errors.append({
                    'type': 'その他エラー',
                    'file': '',
                    'error': line.strip()
                })
        
        return errors
        
    except Exception as e:
        print(f"エラー: {e}")
        return []

if __name__ == "__main__":
    log_file = "logs/logs_prod/robocopy_20250901_225200_full_sync.txt"
    errors = analyze_robocopy_errors(log_file)
    
    print(f"=== エラー解析結果 ===")
    print(f"総エラー数: {len(errors)}")
    
    # エラー種別で分類
    error_types = {}
    for error in errors:
        error_type = error['type']
        if error_type not in error_types:
            error_types[error_type] = []
        error_types[error_type].append(error)
    
    for error_type, error_list in error_types.items():
        print(f"\n--- {error_type} ({len(error_list)}件) ---")
        for i, error in enumerate(error_list[:10]):  # 最初の10件
            if error['file']:
                filename = error['file'].split('\\')[-1] if '\\' in error['file'] else error['file']
                print(f"{i+1:2d}: {filename}")
        if len(error_list) > 10:
            print(f"    ... 他 {len(error_list) - 10} 件")
