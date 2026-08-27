# -*- coding: utf-8 -*-
"""
infer.py
--------
학습된 모델로 새 진동 데이터 1개(.mat, 1초 분량)를 받아
1) 어떤 상태(정상/결함종류)인지, 확률과 함께 판단
2) 어떤 채널/주파수 성분이 '정상' 대비 가장 비정상적인지(z-score) 근거를 함께 제시
   -> "어디가 문제인지" 설명에 사용 (예: ch4 채널의 GMF 대역 파워가 정상 대비 8배 -> 감속기/체인 계열 이상 의심)

사용 예:
    python infer.py model_260826.joblib path/to/새파일_Vib.mat --hz 60

실시간 폴더 감시 데모:
    python infer.py model_260826.joblib --watch data_260826_test/test1/Vib --hz 60
"""

import argparse
import time
import glob
import os

import numpy as np
import joblib
import scipy.io as sio

from features import extract_features_from_signals


def load_bundle(model_path: str):
    return joblib.load(model_path)


def diagnose_signals(bundle, signals: np.ndarray, fs: float, f_set: float, top_k: int = 5):
    feats = extract_features_from_signals(signals, fs, f_set)
    feature_cols = bundle["feature_cols"]
    x = np.array([[feats.get(c, 0.0) for c in feature_cols]])

    model = bundle["model"]
    le = bundle["label_encoder"]

    pred_idx = model.predict(x)[0]
    proba = model.predict_proba(x)[0]
    pred_label = le.inverse_transform([pred_idx])[0]

    # 정상 대비 z-score로 "어디가 이상한지" Top-K 근거 제시
    normal_mean = bundle["normal_mean"]
    normal_std = bundle["normal_std"]
    z = {}
    for c in feature_cols:
        z[c] = abs((feats.get(c, 0.0) - normal_mean[c]) / normal_std[c])
    top_features = sorted(z.items(), key=lambda kv: kv[1], reverse=True)[:top_k]

    result = {
        "predicted_label": pred_label,
        "probabilities": {cls: float(p) for cls, p in zip(le.classes_, proba)},
        "top_abnormal_features": top_features,  # [(feature_name, z_score), ...]
    }
    return result


def diagnose_mat_file(bundle, mat_path: str, f_set: float, top_k: int = 5):
    m = sio.loadmat(mat_path)
    signals = m["signals"]
    fs = float(np.ravel(m["fs"])[0])
    result = diagnose_signals(bundle, signals, fs, f_set, top_k=top_k)
    result["file"] = mat_path
    return result


def _print_result(result: dict):
    print(f"\n[{os.path.basename(result.get('file','(stream)'))}]")
    print(f"  판정: {result['predicted_label']}")
    probs = sorted(result["probabilities"].items(), key=lambda kv: kv[1], reverse=True)
    print("  확률: " + ", ".join(f"{k}={v:.2f}" for k, v in probs))
    print("  근거(정상 대비 z-score 상위):")
    for name, zscore in result["top_abnormal_features"]:
        print(f"    - {name}: {zscore:.2f}σ")


def watch_folder(bundle, folder: str, f_set: float, poll_sec: float = 1.0):
    """실시간 PLC/진동 수집 폴더를 감시하며 새 .mat 파일이 생기면 즉시 진단 (데모/실배포 초기버전용)."""
    seen = set(glob.glob(os.path.join(folder, "*.mat")))
    print(f"[watch] {folder} 감시 시작 (이미 존재하는 {len(seen)}개는 건너뜀)")
    while True:
        current = set(glob.glob(os.path.join(folder, "*.mat")))
        new_files = sorted(current - seen)
        for fpath in new_files:
            try:
                result = diagnose_mat_file(bundle, fpath, f_set)
                _print_result(result)
            except Exception as e:
                print(f"[watch] {fpath} 처리 실패: {e}")
        seen = current
        time.sleep(poll_sec)


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("model_path")
    p.add_argument("mat_file", nargs="?", default=None)
    p.add_argument("--hz", type=float, required=True, help="해당 데이터의 설정 Hz (60/70/80)")
    p.add_argument("--watch", default=None, help="실시간 감시할 폴더 경로 (mat_file 대신 사용)")
    args = p.parse_args()

    bundle = load_bundle(args.model_path)

    if args.watch:
        watch_folder(bundle, args.watch, args.hz)
    elif args.mat_file:
        result = diagnose_mat_file(bundle, args.mat_file, args.hz)
        _print_result(result)
    else:
        print("mat_file 또는 --watch 중 하나를 지정하세요.")
