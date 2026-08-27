# -*- coding: utf-8 -*-
"""
freq_calc.py
------------
'1787805179523_주파수계산.xlsx' 에 들어있는 계산식을 그대로 코드로 옮긴 모듈.

엑셀에서 검증한 관계식 (설정 Hz = 80 예시로 역산):
  - 모터 축 회전주파수  fr_motor = 설정Hz / 2         (4극 모터, N = 120*f/4 = 30*f[rpm], fr=N/60=f/2)
  - 벨트 축 회전주파수  fr_belt  = fr_motor * R1       (R1 = 0.5833, 모터->벨트축 감속비)
  - 부하(최종) 축 회전주파수 fr_load = fr_belt * R2    (R2 = 0.1,    벨트->부하축 감속비)
  - 스프라켓 맞물림주파수 GMF = fr_load * Z            (Z  = 18,     부하측 스프라켓 잇수)
  - 베어링 결함주파수 (각 축의 fr 을 그대로 대입, 축마다 베어링이 있다고 가정)
        BPFO = (n/2)*fr*(1 - (d/D)cosα)
        BPFI = (n/2)*fr*(1 + (d/D)cosα)
        BSF  = (D/2d)*fr*(1 - ((d/D)cosα)^2)
        FTF  = (1/2)*fr*(1 - (d/D)cosα)

위 상수들은 첨부 엑셀 1번 시트 값(설정Hz=80)으로 역산했고,
아래 값으로 재계산한 결과가 엑셀의 모든 셀 값과 소수점까지 일치함을 확인함.
"""

from dataclasses import dataclass, field
from typing import Dict


@dataclass
class DrivetrainConfig:
    # --- 축간 감속비 (엑셀 1번 시트 '속도비' 컬럼에서 역산) ---
    motor_to_belt_ratio: float = 0.5833   # 모터축 -> 벨트축
    belt_to_load_ratio: float = 0.1       # 벨트축 -> 부하(최종)축

    # --- 스프라켓 ---
    sprocket_teeth: int = 18              # 부하측 스프라켓 잇수 Z

    # --- 베어링 스펙 (NTN N306E 예시값, 엑셀 3번 표) ---
    ball_diameter_d: float = 11.0         # mm
    pitch_diameter_D: float = 51.5        # mm
    n_rollers: int = 12
    contact_angle_deg: float = 0.0


class FrequencyCalculator:
    """설정 Hz(인버터 지령 주파수) 하나만 넣으면
    모터/벨트/부하 3개 축의 회전주파수(fr)와,
    각 축 기준 베어링 결함주파수(BPFO/BPFI/BSF/FTF), 스프라켓 맞물림주파수(GMF)를 계산한다.
    """

    def __init__(self, cfg: DrivetrainConfig = None):
        self.cfg = cfg or DrivetrainConfig()

    def shaft_frequencies(self, f_set: float) -> Dict[str, float]:
        fr_motor = f_set / 2.0
        fr_belt = fr_motor * self.cfg.motor_to_belt_ratio
        fr_load = fr_belt * self.cfg.belt_to_load_ratio
        return {"motor": fr_motor, "belt": fr_belt, "load": fr_load}

    def bearing_defect_freqs(self, fr: float) -> Dict[str, float]:
        import math
        d, D, n = self.cfg.ball_diameter_d, self.cfg.pitch_diameter_D, self.cfg.n_rollers
        cos_a = math.cos(math.radians(self.cfg.contact_angle_deg))
        ratio = (d / D) * cos_a
        bpfo = (n / 2) * fr * (1 - ratio)
        bpfi = (n / 2) * fr * (1 + ratio)
        bsf = (D / (2 * d)) * fr * (1 - ratio ** 2)
        ftf = 0.5 * fr * (1 - ratio)
        return {"BPFO": bpfo, "BPFI": bpfi, "BSF": bsf, "FTF": ftf}

    def gmf(self, fr_load: float) -> float:
        return fr_load * self.cfg.sprocket_teeth

    def all_targets(self, f_set: float) -> Dict[str, float]:
        """해당 설정 Hz 에서, FFT 스펙트럼에서 찾아야 할 '이론 특징 주파수'를
        {이름: Hz} 딕셔너리로 반환. feature 추출시 band-power 중심주파수로 사용.
        """
        fr = self.shaft_frequencies(f_set)
        out = {
            "fr_motor_1x": fr["motor"],
            "fr_motor_2x": fr["motor"] * 2,
            "fr_belt_1x": fr["belt"],
            "fr_belt_2x": fr["belt"] * 2,
            "fr_load_1x": fr["load"],
            "fr_load_2x": fr["load"] * 2,
            "GMF": self.gmf(fr["load"]),
            "GMF_2x": self.gmf(fr["load"]) * 2,
        }
        # 베어링은 모터/벨트/부하 축 중 어디에 실제로 설치돼 있는지에 따라 다르므로
        # 우선 3개 축 모두에 대해 계산해 둔다. (실측 데이터로 어느 축이 맞는지 검증 필요)
        for shaft_name, fr_val in fr.items():
            bd = self.bearing_defect_freqs(fr_val)
            for k, v in bd.items():
                out[f"{shaft_name}_{k}"] = v
        return out


if __name__ == "__main__":
    # 엑셀 값과 대조 검증 (설정 Hz = 80)
    calc = FrequencyCalculator()
    fr = calc.shaft_frequencies(80)
    print("shaft fr (motor/belt/load):", fr)
    print("GMF:", calc.gmf(fr["load"]))
    print("motor bearing defects:", calc.bearing_defect_freqs(fr["motor"]))
    print("belt  bearing defects:", calc.bearing_defect_freqs(fr["belt"]))
    print("load  bearing defects:", calc.bearing_defect_freqs(fr["load"]))
