#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import sys

def extract_non_video_failed_files(log_file):
    """動画以外の失敗ファイルを抽出"""
    failed_files = []
    video_extensions = ['.mp4', '.avi', '.mov', '.wmv', '.mkv', '.flv', '.webm', '.m4v']
    
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
                if '<IP_ADDRESS>' in prev_line and '新しいファイル' in prev_line:
                    # ファイルパスを抽出
                    match = re.search(r'\\\\172\.16\.5\.245\\share\\.*', prev_line)
                    if match:
                        file_path = match.group(0)
                        # 動画ファイルでないかチェック
                        is_video = any(file_path.lower().endswith(ext) for ext in video_extensions)
                        if not is_video:
                            # ファイルサイズも抽出
                            size_match = re.search(r'(\d+(?:\.\d+)?\s*[kmg]?)\s*\\\\', prev_line)
                            size = size_match.group(1) if size_match else "不明"
                            failed_files.append((file_path, size))
        
        return failed_files
        
    except Exception as e:
        print(f"エラー: {e}")
        return []

if __name__ == "__main__":
    log_file = "logs/logs_prod/robocopy_20250830_020000.txt"
    failed_files = extract_non_video_failed_files(log_file)
    
    print(f"動画以外の失敗ファイル数: {len(failed_files)}")
    print("\n=== 動画以外の失敗ファイル一覧 ===")
    
    # ファイル種別で分類
    office_files = []
    pdf_files = []
    image_files = []
    other_files = []
    
    for file_path, size in failed_files:
        if any(ext in file_path.lower() for ext in ['.xlsx', '.xls', '.pptx', '.ppt', '.docx', '.doc']):
            office_files.append((file_path, size))
        elif '.pdf' in file_path.lower():
            pdf_files.append((file_path, size))
        elif any(ext in file_path.lower() for ext in ['.jpg', '.jpeg', '.png', '.gif', '.ai', '.psd']):
            image_files.append((file_path, size))
        else:
            other_files.append((file_path, size))
    
    print(f"\n--- Officeファイル ({len(office_files)}件) ---")
    for i, (path, size) in enumerate(office_files[:10]):
        filename = path.split('\\')[-1]
        print(f"{i+1:2d}: {size:>8} - {filename}")
    
    print(f"\n--- PDFファイル ({len(pdf_files)}件) ---")
    for i, (path, size) in enumerate(pdf_files[:10]):
        filename = path.split('\\')[-1]
        print(f"{i+1:2d}: {size:>8} - {filename}")
    
    print(f"\n--- 画像ファイル ({len(image_files)}件) ---")
    for i, (path, size) in enumerate(image_files[:10]):
        filename = path.split('\\')[-1]
        print(f"{i+1:2d}: {size:>8} - {filename}")
    
    print(f"\n--- その他ファイル ({len(other_files)}件) ---")
    for i, (path, size) in enumerate(other_files[:10]):
        filename = path.split('\\')[-1]
        print(f"{i+1:2d}: {size:>8} - {filename}")
