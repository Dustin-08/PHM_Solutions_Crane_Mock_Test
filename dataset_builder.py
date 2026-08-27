# -*- coding: utf-8 -*-
"""
dataset_builder.py
-------------------
폴더 구조 가정 (extract_zip.py로 푼 결과):

    <root>/
      60/
        정상/Vib/*.mat, 정상/Log/state_log.csv
        정상2/...
        정상3/...
        감속기/...
        스프라킷/...
        체인마모/...
        체인마모2/...
        체인이탈/...
      70/...
      80/...

이 스크립트는:
 1) 폴더명을 라벨로 매핑 (정상/정상2/정상3 -> '정상', 체인마모/체인마모2 -> '체인마모' 등 -- 필요시 수정)
 2) 같은 폴더의 state_log.csv 를 읽어, 각 .mat 파일의 타임스탬프와 가장 가까운 로그 행을 찾아
    '정속 구간(code 3=정방향정속 또는 4=역방향정속)'인지 표시 (가속/감속/대기 구간은 결함주파수 분석에 부적합)
 3) features.py 로 특징을 뽑아 전체를 DataFrame 으로 만들고 CSV 로 저장한다.
"""

import os
import re
import glob
import datetime as dt

import numpy as np
import pandas as pd
import scipy.io as sio

from features import extract_features_from_signals

# 폴더명 -> 최종 라벨 매핑 (반복 실험 폴더 정상2/정상3, 체인마모2 등을 하나로 합침)
LABEL_MAP = {
    "정상": "정상", "정상2": "정상", "정상3": "정상",
    "스프라킷": "스프라킷결함",
    "감속기": "감속기결함",
    "체인마모": "체인마모", "체인마모2": "체인마모",
    "체인이탈": "체인이탈",
    "베어링외륜": "베어링외륜결함",
    "베어링내륜": "베어링내륜결함",
    "베어링롤러": "베어링롤러결함",
}

FNAME_RE = re.compile(r"(\d{8})_(\d{6})_(\d{3})_Vib\.mat$")


def _parse_ts_from_filename(fname: str):
    m = FNAME_RE.search(os.path.basename(fname))
    if not m:
        return None
    date_s, time_s, ms_s = m.groups()
    return dt.datetime.strptime(date_s + time_s + ms_s, "%Y%m%d%H%M%S%f")


def _load_state_log(log_csv_path: str) -> pd.DataFrame:
    df = pd.read_csv(log_csv_path, encoding="utf-8-sig")
    df["timestamp"] = pd.to_datetime(df["timestamp"])
    return df


def _nearest_state(log_df: pd.DataFrame, ts) -> dict:
    if log_df is None or ts is None:
        return {"code": None, "label": None, "is_steady": None}
    idx = (log_df["timestamp"] - ts).abs().idxmin()
    row = log_df.loc[idx]
    return {"code": int(row["code"]), "label": row["label"], "is_steady": int(row["code"]) in (3, 4)}


def build_dataset(root: str, condition: str = "base", steady_only: bool = True,
                   max_files_per_label: int = None) -> pd.DataFrame:
    """
    root : extract_zip.py 로 푼 최상위 폴더 (예: data/260826)
    condition : 'base' | 'B' | 'G' | 'hi_fs' 등 데이터 출처 태그 (감속기+무게, 베어링+무게, 12800Hz 등)
    steady_only : True면 정속구간(가속/감속/대기 제외) 데이터만 사용
    max_files_per_label : 클래스당 최대 파일 수 (None=제한없음, 디버그/속도용)
    """
    rows = []
    hz_dirs = sorted([d for d in glob.glob(os.path.join(root, "*")) if os.path.isdir(d)])

    for hz_dir in hz_dirs:
        hz_name = os.path.basename(hz_dir)
        try:
            f_set = float(hz_name)
        except ValueError:
            continue  # test1, test2 등 라벨 없는 폴더는 건너뜀 (실시간 추론 데모용으로 별도 사용)

        label_dirs = sorted([d for d in glob.glob(os.path.join(hz_dir, "*")) if os.path.isdir(d)])
        for label_dir in label_dirs:
            raw_label = os.path.basename(label_dir)
            if raw_label not in LABEL_MAP:
                continue
            final_label = LABEL_MAP[raw_label]

            vib_dir = os.path.join(label_dir, "Vib")
            log_path = os.path.join(label_dir, "Log", "state_log.csv")
            if not os.path.isdir(vib_dir):
                continue

            log_df = _load_state_log(log_path) if os.path.exists(log_path) else None

            mat_files = sorted(glob.glob(os.path.join(vib_dir, "*.mat")))
            if max_files_per_label:
                mat_files = mat_files[:max_files_per_label]

            for mat_path in mat_files:
                try:
                    m = sio.loadmat(mat_path)
                    signals = m["signals"]
                    fs = float(np.ravel(m["fs"])[0])
                except Exception as e:
                    print(f"[skip] {mat_path}: {e}")
                    continue

                ts = _parse_ts_from_filename(mat_path)
                state = _nearest_state(log_df, ts)

                if steady_only and state["is_steady"] is False:
                    continue  # 가속/감속/대기 구간 제외

                feats = extract_features_from_signals(signals, fs, f_set)
                feats.update({
                    "file": mat_path,
                    "hz_setting": f_set,
                    "raw_folder": raw_label,
                    "label": final_label,
                    "condition": condition,
                    "fs": fs,
                    "n_samples": signals.shape[1],
                    "plc_code": state["code"],
                    "plc_label": state["label"],
                })
                rows.append(feats)

    return pd.DataFrame(rows)


if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("root")
    p.add_argument("--condition", default="base")
    p.add_argument("--out", default="dataset.csv")
    p.add_argument("--max-per-label", type=int, default=None)
    p.add_argument("--no-steady-filter", action="store_true")
    args = p.parse_args()

    df = build_dataset(args.root, condition=args.condition,
                        steady_only=not args.no_steady_filter,
                        max_files_per_label=args.max_per_label)
    df.to_csv(args.out, index=False, encoding="utf-8-sig")
    print(f"saved {len(df)} rows -> {args.out}")
    print(df["label"].value_counts())
