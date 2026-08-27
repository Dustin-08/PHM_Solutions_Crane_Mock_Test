# -*- coding: utf-8 -*-
"""
extract_zip.py
--------------
제공된 zip들(260826.zip, 260826_12800.zip, 260826_B.zip, 260826_G.zip 등)은
macOS에서 압축되어 한글 폴더/파일명이 깨져 보인다 (cp437로 잘못 디코딩됨).
이 스크립트는 원래 UTF-8(NFD) 이름을 복원해서 지정 폴더에 풀어준다.

사용법:
    python extract_zip.py 260826.zip data/260826
    python extract_zip.py 260826_B.zip data/260826_B
"""

import sys
import os
import zipfile
import unicodedata


def safe_name(raw_name: str) -> str:
    """cp437로 깨진 zip 내부 파일명을 원래 UTF-8 한글로 복원 + NFC 정규화."""
    try:
        fixed = raw_name.encode("cp437").decode("utf-8")
    except (UnicodeDecodeError, UnicodeEncodeError):
        fixed = raw_name  # 이미 정상 UTF-8인 경우 (OS/zip 도구에 따라 다름)
    return unicodedata.normalize("NFC", fixed)


def extract(zip_path: str, out_dir: str, keep_exts=(".mat", ".csv")):
    os.makedirs(out_dir, exist_ok=True)
    count = 0
    with zipfile.ZipFile(zip_path) as z:
        for info in z.infolist():
            name = info.filename
            if "__MACOSX" in name or info.is_dir():
                continue
            fixed = safe_name(name)
            if keep_exts and not fixed.lower().endswith(keep_exts):
                continue
            # 최상위 zip 루트 폴더명은 제거하고 그 아래 구조만 유지
            parts = fixed.split("/")
            rel = os.path.join(*parts[1:]) if len(parts) > 1 else parts[0]
            out_path = os.path.join(out_dir, rel)
            os.makedirs(os.path.dirname(out_path), exist_ok=True)
            with z.open(info) as src, open(out_path, "wb") as dst:
                dst.write(src.read())
            count += 1
    print(f"[extract_zip] {zip_path} -> {out_dir} : {count}개 파일 추출 완료")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("사용법: python extract_zip.py <zip경로> <출력폴더>")
        sys.exit(1)
    extract(sys.argv[1], sys.argv[2])
