-- 사용하지 않는 컬럼 삭제 : "신고구분", "신고한 개업공인중개사 시군구명"
CREATE TABLE prop_copy AS
SELECT
    접수연도 AS RCPT_YR,
    자치구코드 AS CGG_CD,
    자치구명 AS CGG_NM,
    법정동코드 AS STDG_CD,
    법정동명 AS STDG_NM,
    지번구분 AS LOTNO_SE,
    지번구분명 AS LOTNO_SE_NM,
    본번 AS MNO,
    부번 AS SNO,
    건물명 AS BLDG_NM,
    계약일 AS CTRT_DAY,
    `물건금액(만원)` AS THING_AMT,
    `건물면적(㎡)` AS ARCH_AREA,
    `토지면적(㎡)` AS LAND_AREA,
    층 AS FLR,
    권리구분 AS RGHT_SE,
    취소일 AS RTRCN_DAY,
    건축년도 AS ARCH_YR,
    건물용도 AS BLDG_USG
FROM unions_v2;