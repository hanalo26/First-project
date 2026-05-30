import pandas as pd
import numpy as np

# 1. 데이터 로드
df = pd.read_csv('20260530_전처리-일부완료.csv', encoding='utf-8')

# 2. 파생변수 정의: 프리미엄 매물 여부 계산
# - IQR(Interquartile Range) 기준 상위 이상치를 프리미엄 매물로 정의
def high_outlier_idx_group(s, weight=1.5):
    q_1 = np.percentile(s.values, 25)
    q_3 = np.percentile(s.values, 75)
    IQR = q_3 - q_1
    high = q_3 + IQR * weight
    
    # 상위 경계값(high)보다 큰 매물의 index 반환
    return s.index[s > high]

# 3. 자치구명(CGG_NM) + 건물용도(BLDG_USG) 기준으로 그룹화하여 프리미엄 index 추출
pm_idx = df.groupby(["CGG_NM", "BLDG_USG"])["THING_AMT"].apply(high_outlier_idx_group)

# 4. 중첩된 Multi-index를 1차원으로 전개 및 정수형 변환
pm_idx_flatten = pm_idx.explode().astype(int)

# 5. 원본 데이터프레임 매핑 (프리미엄 대상 index면 1, 아니면 0으로 한 번에 변환)
df["is_PM"] = df.index.isin(pm_idx_flatten).astype(int)

# 6. 전처리 결과 요약 출력
total = len(df)
pm_count = df["is_PM"].sum()  # 1/0 구조이므로 sum()으로 바로 카운트 가능
pm_ratio = pm_count / total * 100

print(f"전체 데이터: {total:,}건")
print(f"프리미엄(is_PM=1): {pm_count:,}건")
print(f"프리미엄 비율: {pm_ratio:.2f}%")

# 7. 최종 데이터 저장
df.to_csv("prop_copy5.csv", index=False)
print("저장 완료!")