# Github의 주피터노트북 파일 렌더링 오류로 인해 동일한 코드를 파이썬 파일로 제작

import pandas as pd
import numpy as np

# prop_copy4 불러오기
df = pd.read_csv("../../개인작업물/prop_copy4_202605311901.csv", encoding='utf-8')

# 상위 이상치의 경계값을 구하는 함수
def high_outlier_idx_group(s, weight=1.5):
    q_1 = np.percentile(s.values, 25)
    q_3 = np.percentile(s.values, 75)
    IQR = q_3 - q_1
    high = q_3 + IQR * weight
    
    # high보다 큰 값들의 index 반환
    return s.index[s > high]

# 자치구명 + 건물용도 기준으로 그룹화해서 프리미엄 index 추출
pm_idx = df.groupby(["CGG_NM", "BLDG_USG"])["THING_AMT"].apply(high_outlier_idx_group)

# 중첩된 index를 1차원으로 펼치고 정수형으로 변환
pm_idx_2 = pm_idx.explode().astype(int)

# 원본 데이터프레임에서 해당 index면 1, 아니면 0
df["is_PM"] = df.index.isin(pm_idx_2).astype(int)

# 결과 확인
total = len(df)
pm_count = df["is_PM"].sum()
pm_ratio = pm_count / total * 100

print(f"전체 데이터: {total:,}건")
print(f"프리미엄(is_PM=1): {pm_count:,}건")
print(f"프리미엄 비율: {pm_ratio:.2f}%")

# CSV로 저장
df.to_csv("../../개인작업물/prop_copy5.csv", encoding='utf-8-sig', index=False)
print("저장 완료!")