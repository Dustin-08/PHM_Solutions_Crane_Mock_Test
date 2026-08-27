# -*- coding: utf-8 -*-
"""
features.py
-----------
9채널(가속도계 3축 x 3지점 등) x N샘플 진동 신호 1개(=.mat 파일 1개, 보통 1초 분량)에서
시간영역 + 주파수영역 특징을 뽑아 1개의 feature vector(dict)로 만든다.

주파수영역 특징은 freq_calc.py 로 계산한 '이론 결함주파수' 주변의 band power를
그대로 뽑아내는 방식(physics-informed feature engineering) 이라
- 왜 그 특징을 쓰는지 설명 가능하고 (해석 가능성 -> 결함 위치 추정에 활용)
- 학습 데이터가 아직 적어도(특히 베어링 결함 클래스) 비교적 안정적으로 작동한다.
"""

import numpy as np
from scipy.stats import kurtosis, skew
from scipy.fft import rfft, rfftfreq

from freq_calc import FrequencyCalculator

_CALC = FrequencyCalculator()

CHANNEL_NAMES = [f"ch{i}" for i in range(9)]  # 실제 센서 위치/축 이름을 알면 여기에 매핑하세요
                                               # 예: ["motor_x","motor_y","motor_z","gear_x",...]


def _band_power(freqs, mag, center_hz, rel_bw=0.06, min_bw_hz=0.5):
    """center_hz 주변 ±(center*rel_bw, 최소 min_bw_hz) 구간의 스펙트럼 파워 합.
    회전체 특성상 실제 rpm은 미세하게 흔들리므로 상대폭(rel_bw)을 둔다."""
    if center_hz <= 0 or np.isnan(center_hz):
        return 0.0
    bw = max(center_hz * rel_bw, min_bw_hz)
    lo, hi = center_hz - bw, center_hz + bw
    mask = (freqs >= lo) & (freqs <= hi)
    if not mask.any():
        return 0.0
    return float(np.sum(mag[mask] ** 2))


def _time_domain_features(x: np.ndarray, prefix: str) -> dict:
    rms = float(np.sqrt(np.mean(x ** 2)))
    peak = float(np.max(np.abs(x)))
    return {
        f"{prefix}_rms": rms,
        f"{prefix}_peak": peak,
        f"{prefix}_crest": (peak / rms) if rms > 1e-12 else 0.0,
        f"{prefix}_std": float(np.std(x)),
        f"{prefix}_kurtosis": float(kurtosis(x, fisher=True)),
        f"{prefix}_skew": float(skew(x)),
        f"{prefix}_p2p": float(np.max(x) - np.min(x)),
    }


def _freq_domain_features(x: np.ndarray, fs: float, f_set: float, prefix: str) -> dict:
    n = len(x)
    window = np.hanning(n)
    xw = x * window
    spec = rfft(xw)
    mag = np.abs(spec) / n
    freqs = rfftfreq(n, d=1.0 / fs)

    targets = _CALC.all_targets(f_set) if f_set else {}
    feats = {}
    for name, fhz in targets.items():
        feats[f"{prefix}_bp_{name}"] = _band_power(freqs, mag, fhz)

    # 전체 스펙트럼 요약 통계 (미지의 결함 패턴 대비용, 물리식만으로 못 잡는 것 보완)
    total_power = float(np.sum(mag ** 2)) + 1e-12
    dom_idx = int(np.argmax(mag[1:])) + 1  # DC 제외 최대 성분
    feats[f"{prefix}_dominant_freq"] = float(freqs[dom_idx])
    feats[f"{prefix}_dominant_amp"] = float(mag[dom_idx])
    feats[f"{prefix}_spec_energy"] = total_power
    # 저/중/고역 에너지 비율 (0-100Hz / 100-500Hz / 500Hz~)
    for lo, hi, tag in [(0, 100, "low"), (100, 500, "mid"), (500, fs / 2, "high")]:
        m = (freqs >= lo) & (freqs < hi)
        feats[f"{prefix}_band_{tag}_ratio"] = float(np.sum(mag[m] ** 2) / total_power)
    return feats


def extract_features_from_signals(signals: np.ndarray, fs: float, f_set: float = None) -> dict:
    """
    signals : shape (n_channels, n_samples)  -- .mat 의 'signals'
    fs      : 샘플링 주파수 (.mat 의 'fs')
    f_set   : 해당 세그먼트의 설정 Hz (60/70/80). 모르면 None -> 물리 기반 밴드파워 생략.
    """
    feats = {}
    for ch_idx in range(signals.shape[0]):
        ch_name = CHANNEL_NAMES[ch_idx] if ch_idx < len(CHANNEL_NAMES) else f"ch{ch_idx}"
        x = signals[ch_idx].astype(float)
        feats.update(_time_domain_features(x, ch_name))
        feats.update(_freq_domain_features(x, fs, f_set, ch_name))
    return feats
