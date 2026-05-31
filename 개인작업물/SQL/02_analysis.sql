-- Step 8 : 분석 범위 필터링 (2018년 이후 데이터만 남김)
CREATE TABLE prop_inline AS
SELECT *
FROM prop_copy5
WHERE CTRT_MONTH >= '2018-01';

-- Step 9 : 분기별 거래량 집계
-- 파이썬에서 quarterly_counts로 사용 → 분기별 거래 증감량 추이 시각화에 활용
CREATE TABLE quarterly_counts AS
SELECT
    CTRT_QUARTER,
    COUNT(*) AS 거래량
FROM prop_inline
GROUP BY CTRT_QUARTER
ORDER BY CTRT_QUARTER;

-- Step 10 : 법정동별 건물용도별 접수연도별 평당가 기초통계량
-- 파이썬에서 YR_REGION_SUMMARY로 사용 → 가격 변동률 계산 및 시각화에 활용
CREATE TABLE yr_region_summary AS
WITH ranked AS (
    SELECT
        CGG_NM,
        STDG_NM,
        BLDG_USG,
        RCPT_YR,
        PRICE_PER_KSQ,
        -- 그룹 내에서 PRICE_PER_KSQ 오름차순으로 번호 부여
        ROW_NUMBER() OVER (PARTITION BY CGG_NM, STDG_NM, BLDG_USG, RCPT_YR ORDER BY PRICE_PER_KSQ) AS rn,
        -- 그룹 내 전체 데이터 개수
        COUNT(*) OVER (PARTITION BY CGG_NM, STDG_NM, BLDG_USG, RCPT_YR) AS total_cnt
    FROM prop_inline
)
SELECT
    CGG_NM,
    STDG_NM,
    BLDG_USG,
    RCPT_YR,
    COUNT(*) AS cnt,
    ROUND(AVG(PRICE_PER_KSQ), 2) AS mean,
    ROUND(STD(PRICE_PER_KSQ), 2) AS std, -- STD(): MySQL에서 표준편차를 구하는 집계함수
    ROUND(MIN(PRICE_PER_KSQ), 2) AS min,
    ROUND(MAX(PRICE_PER_KSQ), 2) AS max,
    -- 중앙값 계산
    -- 홀수일 때: (total_cnt+1)/2 번째 값
    -- 짝수일 때: FLOOR, CEIL로 가운데 두 값의 평균
    ROUND(AVG(CASE WHEN rn IN (FLOOR((total_cnt+1)/2), CEIL((total_cnt+1)/2)) THEN PRICE_PER_KSQ END), 2) AS MEDIAN_PRICE
FROM ranked
GROUP BY CGG_NM, STDG_NM, BLDG_USG, RCPT_YR
ORDER BY CGG_NM, STDG_NM, BLDG_USG, RCPT_YR;

-- Step 11 : 가격 변동률 추가 (LAG 윈도우 함수)
-- 파이썬에서 PROFIT_PCT로 사용 → 법정동별 가격 변동률 시각화에 활용
-- LAG() : 이전 행의 값을 가져오는 윈도우 함수
-- (현재연도 평당가 중앙값 - 직전년도 평당가 중앙값) / 직전년도 평당가 중앙값 * 100
CREATE TABLE yr_region_summary_with_profit AS
SELECT
    *,
    ROUND(
        (MEDIAN_PRICE - LAG(MEDIAN_PRICE) OVER (PARTITION BY STDG_NM, BLDG_USG ORDER BY RCPT_YR))
        / LAG(MEDIAN_PRICE) OVER (PARTITION BY STDG_NM, BLDG_USG ORDER BY RCPT_YR) * 100
    , 2) AS PROFIT_PCT
FROM yr_region_summary;

-- Step 12 : 변동계수(CV) 계산
-- 파이썬에서 CAL_FOR_CV로 사용 → 지역별 가격 변동 리스크 측정 및 페르소나별 매물 추천에 활용
-- CV = 부동산 가격의 (표준편차) / (평균) → 값이 클수록 가격 변동성이 높아 안정적인 가격를 원하는 고객에게는 CV가 높은 지역이 리스크일 것이라 예상됨
CREATE TABLE cal_for_cv AS
SELECT
    CGG_NM,
    STDG_NM,
    BLDG_USG,
    RCPT_YR,
    ROUND(AVG(PRICE_PER_KSQ), 2) AS mean_of_price,
    ROUND(STD(PRICE_PER_KSQ), 2) AS std_of_price,
    ROUND(STD(PRICE_PER_KSQ) / AVG(PRICE_PER_KSQ), 4) AS CV_of_price
FROM prop_inline
GROUP BY CGG_NM, STDG_NM, BLDG_USG, RCPT_YR
ORDER BY CGG_NM, STDG_NM, BLDG_USG, RCPT_YR;