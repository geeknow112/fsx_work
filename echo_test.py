#!/usr/bin/env python3
"""
FSx Schedule Test Script (Python)
スケジュールタスクの動作確認用Pythonスクリプト
"""

import datetime
import os
import getpass
import sys

def main():
    """メイン処理"""
    # ログファイル名生成
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = f"echo_test_{timestamp}.log"
    
    # 出力内容
    output_lines = [
        "=" * 64,
        "FSx Schedule Test - SUCCESS (Python)",
        f"Time: {datetime.datetime.now()}",
        f"Working Directory: {os.getcwd()}",
        f"User: {getpass.getuser()}",
        f"Python Version: {sys.version}",
        f"Platform: {sys.platform}",
        "=" * 64
    ]
    
    try:
        # ログファイルに出力
        with open(log_file, 'w', encoding='utf-8') as f:
            for line in output_lines:
                f.write(line + '\n')
        
        # コンソールにも出力
        for line in output_lines:
            print(line)
        
        print(f"Log saved to: {log_file}")
        return 0
        
    except Exception as e:
        error_msg = f"Error: {str(e)}"
        print(error_msg)
        
        # エラーログも保存
        error_log = f"echo_test_error_{timestamp}.log"
        try:
            with open(error_log, 'w', encoding='utf-8') as f:
                f.write(f"Error occurred at {datetime.datetime.now()}\n")
                f.write(f"Error message: {str(e)}\n")
                f.write(f"Working directory: {os.getcwd()}\n")
        except:
            pass
        
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
