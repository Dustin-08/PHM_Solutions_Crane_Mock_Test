# -*- coding: utf-8 -*-
"""
train.py
--------
dataset_builder.py 로 만든 feature CSV를 읽어 결함 분류 모델을 학습한다.

주의(데이터 누수 방지):
같은 녹화 세션 내에서 연속된 1초 파일들은 서로 거의 동일한 운전상태(진폭/노이즈 특성)를 공유한다.
그냥 랜덤 split을 하면 "같은 세션의 옆 초 데이터"가 train/test에 나눠 들어가면서
실제보다 성능이 부풀려질 수 있다. 그래서 파일 타임스탬프를 10초 단위로 묶어
그 묶음(group) 단위로 train/test를 분리한다 (GroupShuffleSplit).
"""

import re
import argparse
import numpy as np
import pandas as pd
import joblib

from sklearn.model_selection import GroupShuffleSplit, cross_val_score, GroupKFold
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report, confusion_matrix

NON_FEATURE_COLS = ["file", "hz_setting", "raw_folder", "label", "condition",
                     "fs", "n_samples", "plc_code", "plc_label", "_group"]

FNAME_RE = re.compile(r"(\d{8})_(\d{6})_(\d{3})_Vib\.mat$")


def _session_group(file_path: str) -> str:
    """파일명에서 '연-월-일_시-분-초/10' 단위로 그룹 키를 만든다 (같은 세션 묶음)."""
    m = FNAME_RE.search(file_path)
    if not m:
        return file_path
    date_s, time_s, _ = m.groups()
    bucket = int(time_s[-2:]) // 10  # 초 단위를 10초 버킷으로
    return f"{date_s}_{time_s[:-2]}{bucket}"


def load_dataset(csv_paths):
    dfs = [pd.read_csv(p) for p in csv_paths]
    df = pd.concat(dfs, ignore_index=True)
    df["_group"] = df["file"].apply(_session_group)
    return df


def train(df: pd.DataFrame, model_out: str = "model.joblib", n_estimators=400):
    feature_cols = [c for c in df.columns if c not in NON_FEATURE_COLS]
    X = df[feature_cols].fillna(0).values
    y_raw = df["label"].values
    groups = df["_group"].values

    le = LabelEncoder()
    y = le.fit_transform(y_raw)

    gss = GroupShuffleSplit(n_splits=1, test_size=0.25, random_state=42)
    train_idx, test_idx = next(gss.split(X, y, groups))

    clf = RandomForestClassifier(
        n_estimators=n_estimators, max_depth=None,
        class_weight="balanced_subsample", n_jobs=-1, random_state=42
    )
    clf.fit(X[train_idx], y[train_idx])

    y_pred = clf.predict(X[test_idx])
    print("=== Hold-out(그룹 분리) 성능 ===")
    print(classification_report(y[test_idx], y_pred, target_names=le.classes_))
    print("Confusion matrix (rows=실제, cols=예측):")
    cm = confusion_matrix(y[test_idx], y_pred)
    print(pd.DataFrame(cm, index=le.classes_, columns=le.classes_))

    # 그룹 기반 5-fold 교차검증으로 안정성 재확인
    gkf = GroupKFold(n_splits=5)
    cv_scores = cross_val_score(clf, X, y, groups=groups, cv=gkf, scoring="f1_macro", n_jobs=-1)
    print(f"\nGroupKFold(5) f1_macro: {cv_scores.mean():.4f} +- {cv_scores.std():.4f}")

    # 전체 데이터로 최종 재학습 후 저장 (배포용)
    clf_final = RandomForestClassifier(
        n_estimators=n_estimators, class_weight="balanced_subsample", n_jobs=-1, random_state=42
    )
    clf_final.fit(X, y)

    # 특징 중요도 Top 20 -> 어떤 물리량이 결함 판별에 중요한지 확인 (해석/설명용)
    importances = pd.Series(clf_final.feature_importances_, index=feature_cols)
    print("\n=== Feature importance Top 20 ===")
    print(importances.sort_values(ascending=False).head(20))

    # 정상 데이터의 feature별 평균/표준편차 저장 -> 실시간 추론시 "어디가 이상한지" 설명(z-score)용
    normal_mask = df["label"].values == "정상"
    normal_mean = df.loc[normal_mask, feature_cols].fillna(0).mean()
    normal_std = df.loc[normal_mask, feature_cols].fillna(0).std().replace(0, 1e-6)

    joblib.dump({
        "model": clf_final,
        "label_encoder": le,
        "feature_cols": feature_cols,
        "normal_mean": normal_mean,
        "normal_std": normal_std,
    }, model_out)
    print(f"\n모델 저장 완료: {model_out}")
    return clf_final, le, feature_cols


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("csvs", nargs="+", help="dataset_builder.py로 만든 csv 파일(들)")
    p.add_argument("--out", default="model.joblib")
    args = p.parse_args()

    df = load_dataset(args.csvs)
    train(df, model_out=args.out)
