-- =============================================================
--  GLOBAL ADS PERFORMANCE — COMPREHENSIVE SQL ANALYSIS
--  Compatible: SQLite · PostgreSQL · MySQL (minor syntax notes)
--  Dataset : global_ads_performance_dataset.csv (1 800 rows)
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- SECTION 0 · DDL — CREATE & LOAD TABLE
-- ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS ads_performance (
    id             SERIAL PRIMARY KEY,   -- omit for SQLite / use INTEGER PRIMARY KEY AUTOINCREMENT
    date           DATE          NOT NULL,
    platform       VARCHAR(50)   NOT NULL,
    campaign_type  VARCHAR(50)   NOT NULL,
    industry       VARCHAR(50)   NOT NULL,
    country        VARCHAR(50)   NOT NULL,
    impressions    INTEGER       NOT NULL,
    clicks         INTEGER       NOT NULL,
    CTR            DECIMAL(6,4)  NOT NULL,
    CPC            DECIMAL(8,2)  NOT NULL,
    ad_spend       DECIMAL(12,2) NOT NULL,
    conversions    INTEGER       NOT NULL,
    CPA            DECIMAL(8,2)  NOT NULL,
    revenue        DECIMAL(14,2) NOT NULL,
    ROAS           DECIMAL(8,2)  NOT NULL
);

-- SQLite quick import (run in sqlite3 shell):
-- .mode csv
-- .headers on
-- .import global_ads_performance_dataset.csv ads_performance


-- ─────────────────────────────────────────────────────────────
-- SECTION 1 · EXPLORATORY DATA ANALYSIS
-- ─────────────────────────────────────────────────────────────

-- 1.1  Dataset overview
SELECT
    COUNT(*)                                AS total_rows,
    COUNT(DISTINCT platform)                AS n_platforms,
    COUNT(DISTINCT campaign_type)           AS n_campaign_types,
    COUNT(DISTINCT industry)                AS n_industries,
    COUNT(DISTINCT country)                 AS n_countries,
    MIN(date)                               AS earliest_date,
    MAX(date)                               AS latest_date,
    ROUND(SUM(ad_spend), 2)                 AS total_ad_spend_usd,
    ROUND(SUM(revenue), 2)                  AS total_revenue_usd,
    ROUND(SUM(revenue) / SUM(ad_spend), 2)  AS overall_ROAS
FROM ads_performance;

-- 1.2  Descriptive statistics per numeric metric
SELECT
    'impressions' AS metric,
    ROUND(AVG(impressions), 0)                   AS mean,
    ROUND(MIN(impressions), 0)                   AS min_val,
    ROUND(MAX(impressions), 0)                   AS max_val
FROM ads_performance
UNION ALL
SELECT 'clicks',
    ROUND(AVG(clicks), 0), MIN(clicks), MAX(clicks)
FROM ads_performance
UNION ALL
SELECT 'CTR',
    ROUND(AVG(CTR), 4), MIN(CTR), MAX(CTR)
FROM ads_performance
UNION ALL
SELECT 'CPC',
    ROUND(AVG(CPC), 2), MIN(CPC), MAX(CPC)
FROM ads_performance
UNION ALL
SELECT 'ad_spend',
    ROUND(AVG(ad_spend), 2), MIN(ad_spend), MAX(ad_spend)
FROM ads_performance
UNION ALL
SELECT 'conversions',
    ROUND(AVG(conversions), 0), MIN(conversions), MAX(conversions)
FROM ads_performance
UNION ALL
SELECT 'CPA',
    ROUND(AVG(CPA), 2), MIN(CPA), MAX(CPA)
FROM ads_performance
UNION ALL
SELECT 'revenue',
    ROUND(AVG(revenue), 2), MIN(revenue), MAX(revenue)
FROM ads_performance
UNION ALL
SELECT 'ROAS',
    ROUND(AVG(ROAS), 2), MIN(ROAS), MAX(ROAS)
FROM ads_performance;

-- 1.3  Row counts per categorical dimension
SELECT 'platform'AS dimension, platform AS value, COUNT(*) AS n FROM ads_performance GROUP BY platform
UNION ALL
SELECT 'campaign_type',campaign_type,COUNT(*) FROM ads_performance GROUP BY campaign_type
UNION ALL
SELECT 'industry',industry,COUNT(*) FROM ads_performance GROUP BY industry
UNION ALL
SELECT 'country',country,COUNT(*) FROM ads_performance GROUP BY country
ORDER BY dimension, n DESC;


-- ─────────────────────────────────────────────────────────────
-- SECTION 2 · PLATFORM ANALYSIS
-- ─────────────────────────────────────────────────────────────

-- 2.1  KPI summary per platform
SELECT
    platform,
    COUNT(*)                                             AS campaigns,
    ROUND(SUM(impressions), 0)                           AS total_impressions,
    ROUND(SUM(clicks), 0)                                AS total_clicks,
    ROUND(AVG(CTR) * 100, 2)                             AS avg_CTR_pct,
    ROUND(AVG(CPC), 2)                                   AS avg_CPC_usd,
    ROUND(SUM(ad_spend), 2)                              AS total_spend_usd,
    ROUND(SUM(conversions), 0)                           AS total_conversions,
    ROUND(AVG(CPA), 2)                                   AS avg_CPA_usd,
    ROUND(SUM(revenue), 2)                               AS total_revenue_usd,
    ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2)   AS actual_ROAS,
    ROUND(AVG(ROAS), 2)                                  AS avg_ROAS
FROM ads_performance
GROUP BY platform
ORDER BY actual_ROAS DESC;

-- 2.2  Platform performance by month
SELECT
    platform,
    -- SQLite: strftime('%Y-%m', date)
    -- PostgreSQL: TO_CHAR(date, 'YYYY-MM')
    strftime('%Y-%m', date)                              AS month,
    ROUND(SUM(ad_spend), 2)                              AS spend_usd,
    ROUND(SUM(revenue), 2)                               AS revenue_usd,
    ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2)   AS monthly_ROAS,
    ROUND(AVG(CTR) * 100, 2)                             AS avg_CTR_pct
FROM ads_performance
GROUP BY platform, strftime('%Y-%m', date)
ORDER BY platform, month;

-- 2.3  Platform share of total spend and revenue
SELECT
    platform,
    ROUND(SUM(ad_spend), 2)                                           AS spend_usd,
    ROUND(100.0 * SUM(ad_spend) / SUM(SUM(ad_spend)) OVER(), 1)      AS spend_share_pct,
    ROUND(SUM(revenue), 2)                                            AS revenue_usd,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER(), 1)        AS revenue_share_pct
FROM ads_performance
GROUP BY platform
ORDER BY revenue_usd DESC;


-- ─────────────────────────────────────────────────────────────
-- SECTION 3 · CAMPAIGN TYPE ANALYSIS
-- ─────────────────────────────────────────────────────────────

-- 3.1  KPI per campaign type
SELECT
    campaign_type,
    COUNT(*) AS campaigns,
    ROUND(AVG(CTR) * 100, 2) AS avg_CTR_pct,
    ROUND(AVG(CPC), 2) AS avg_CPC_usd,
    ROUND(AVG(CPA), 2) AS avg_CPA_usd,
    ROUND(AVG(ROAS), 2) AS avg_ROAS,
    ROUND(SUM(conversions), 0) AS total_conversions,
    ROUND(SUM(revenue), 2) AS total_revenue_usd,
    ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2) AS actual_ROAS
FROM ads_performance
GROUP BY campaign_type
ORDER BY actual_ROAS DESC;

-- 3.2  Campaign type × platform cross-tab (ROAS)
SELECT
    campaign_type,
    ROUND(AVG(CASE WHEN platform = 'Google Ads'  THEN ROAS END), 2) AS google_ROAS,
    ROUND(AVG(CASE WHEN platform = 'Meta Ads'    THEN ROAS END), 2) AS meta_ROAS,
    ROUND(AVG(CASE WHEN platform = 'TikTok Ads'  THEN ROAS END), 2) AS tiktok_ROAS
FROM ads_performance
GROUP BY campaign_type
ORDER BY campaign_type;

-- 3.3  Campaign type × platform cross-tab (CPA)
SELECT
    campaign_type,
    ROUND(AVG(CASE WHEN platform = 'Google Ads'  THEN CPA END), 2) AS google_CPA,
    ROUND(AVG(CASE WHEN platform = 'Meta Ads'    THEN CPA END), 2) AS meta_CPA,
    ROUND(AVG(CASE WHEN platform = 'TikTok Ads'  THEN CPA END), 2) AS tiktok_CPA
FROM ads_performance
GROUP BY campaign_type
ORDER BY campaign_type;

-- 3.4  Top 10 most profitable campaign_type × platform combos
SELECT
    platform,
    campaign_type,
    ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2) AS actual_ROAS,
    ROUND(AVG(CPA), 2) AS avg_CPA,
    ROUND(SUM(conversions), 0) AS total_conversions
FROM ads_performance
GROUP BY platform, campaign_type
ORDER BY actual_ROAS DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- SECTION 4 · INDUSTRY ANALYSIS
-- ─────────────────────────────────────────────────────────────

-- 4.1  KPI per industry
SELECT
    industry,
    COUNT(*) AS campaigns,
    ROUND(SUM(ad_spend), 2) AS total_spend_usd,
    ROUND(SUM(revenue), 2) AS total_revenue_usd,
    ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2) AS actual_ROAS,
    ROUND(AVG(CTR) * 100, 2) AS avg_CTR_pct,
    ROUND(AVG(CPA), 2) AS avg_CPA_usd,
    ROUND(SUM(conversions), 0) AS total_conversions
FROM ads_performance
GROUP BY industry
ORDER BY actual_ROAS DESC;

-- 4.2  Best platform per industry (by ROAS)
WITH ranked AS (
    SELECT
        industry,
        platform,
        ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2) AS actual_ROAS,
        ROW_NUMBER() OVER (PARTITION BY industry ORDER BY SUM(revenue)/NULLIF(SUM(ad_spend),0) DESC) AS rk
    FROM ads_performance
    GROUP BY industry, platform
)
SELECT industry, platform, actual_ROAS
FROM ranked
WHERE rk = 1
ORDER BY actual_ROAS DESC;

-- 4.3  Best campaign type per industry
WITH ranked AS (
    SELECT
        industry,
        campaign_type,
        ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2) AS actual_ROAS,
        ROW_NUMBER() OVER (PARTITION BY industry ORDER BY SUM(revenue)/NULLIF(SUM(ad_spend),0) DESC) AS rk
    FROM ads_performance
    GROUP BY industry, campaign_type
)
SELECT industry, campaign_type, actual_ROAS
FROM ranked
WHERE rk = 1
ORDER BY actual_ROAS DESC;


-- ─────────────────────────────────────────────────────────────
-- SECTION 5 · GEOGRAPHIC ANALYSIS
-- ─────────────────────────────────────────────────────────────

-- 5.1  KPI per country
SELECT
    country,
    COUNT(*) AS campaigns,
    ROUND(SUM(ad_spend), 2) AS total_spend_usd,
    ROUND(SUM(revenue), 2) AS total_revenue_usd,
    ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2)   AS actual_ROAS,
    ROUND(AVG(CPC), 2) AS avg_CPC_usd,
    ROUND(AVG(CPA), 2) AS avg_CPA_usd,
    ROUND(AVG(CTR) * 100, 2) AS avg_CTR_pct
FROM ads_performance
GROUP BY country
ORDER BY actual_ROAS DESC;

-- 5.2  Country × platform matrix (ROAS)
SELECT
    country,
    ROUND(AVG(CASE WHEN platform = 'Google Ads'  THEN ROAS END), 2) AS google_ROAS,
    ROUND(AVG(CASE WHEN platform = 'Meta Ads'    THEN ROAS END), 2) AS meta_ROAS,
    ROUND(AVG(CASE WHEN platform = 'TikTok Ads'  THEN ROAS END), 2) AS tiktok_ROAS
FROM ads_performance
GROUP BY country
ORDER BY country;

-- 5.3  Best-performing country per platform
WITH ranked AS (
    SELECT
        platform,
        country,
        ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2) AS actual_ROAS,
        ROW_NUMBER() OVER (PARTITION BY platform ORDER BY SUM(revenue)/NULLIF(SUM(ad_spend),0) DESC) AS rk
    FROM ads_performance
    GROUP BY platform, country
)
SELECT platform, country, actual_ROAS
FROM ranked
WHERE rk = 1;


-- ─────────────────────────────────────────────────────────────
-- SECTION 6 · TIME SERIES & SEASONALITY
-- ─────────────────────────────────────────────────────────────

-- 6.1  Monthly aggregated KPIs
SELECT
    strftime('%Y-%m', date) AS month,
    ROUND(SUM(ad_spend), 2) AS total_spend_usd,
    ROUND(SUM(revenue), 2) AS total_revenue_usd,
    ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2) AS monthly_ROAS,
    ROUND(AVG(CTR) * 100, 2) AS avg_CTR_pct,
    ROUND(SUM(conversions), 0) AS total_conversions
FROM ads_performance
GROUP BY strftime('%Y-%m', date)
ORDER BY month;

-- 6.2  Day-of-week performance pattern
SELECT
    -- SQLite: strftime('%w', date) → 0=Sunday
    -- PostgreSQL: EXTRACT(DOW FROM date)
    CASE strftime('%w', date)
        WHEN '0' THEN '0_Sunday'
        WHEN '1' THEN '1_Monday'
        WHEN '2' THEN '2_Tuesday'
        WHEN '3' THEN '3_Wednesday'
        WHEN '4' THEN '4_Thursday'
        WHEN '5' THEN '5_Friday'
        WHEN '6' THEN '6_Saturday'
    END AS day_of_week,
    ROUND(AVG(CTR) * 100, 2) AS avg_CTR_pct,
    ROUND(AVG(ROAS), 2) AS avg_ROAS,
    ROUND(AVG(CPA), 2) AS avg_CPA_usd,
    COUNT(*) AS n
FROM ads_performance
GROUP BY strftime('%w', date)
ORDER BY day_of_week;

-- 6.3  Quarter over quarter summary
SELECT
    strftime('%Y', date)    AS year,
    CASE
        WHEN strftime('%m', date) IN ('01','02','03') THEN 'Q1'
        WHEN strftime('%m', date) IN ('04','05','06') THEN 'Q2'
        WHEN strftime('%m', date) IN ('07','08','09') THEN 'Q3'
        ELSE 'Q4'
    END AS quarter,
    ROUND(SUM(ad_spend), 2) AS spend_usd,
    ROUND(SUM(revenue), 2) AS revenue_usd,
    ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2) AS ROAS,
    ROUND(SUM(conversions), 0) AS conversions
FROM ads_performance
GROUP BY year, quarter
ORDER BY year, quarter;


-- ─────────────────────────────────────────────────────────────
-- SECTION 7 · PROFITABILITY & EFFICIENCY SEGMENTATION
-- ─────────────────────────────────────────────────────────────

-- 7.1  ROAS tier classification
SELECT
    CASE
        WHEN ROAS >= 10 THEN 'Excellent (≥10)'
        WHEN ROAS >= 5  THEN 'Good (5–9.99)'
        WHEN ROAS >= 2  THEN 'Acceptable (2–4.99)'
        ELSE                 'Unprofitable (<2)'
    END AS roas_tier,
    COUNT(*) AS n_campaigns,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) AS pct,
    ROUND(AVG(ROAS), 2) AS avg_ROAS,
    ROUND(SUM(ad_spend), 2) AS total_spend_usd,
    ROUND(SUM(revenue), 2) AS total_revenue_usd
FROM ads_performance
GROUP BY roas_tier
ORDER BY avg_ROAS DESC;

-- 7.2  High-value campaigns (top 10% by revenue)
SELECT
    date, platform, campaign_type, industry, country,
    ad_spend, revenue, ROAS, CPA, CTR
FROM ads_performance
WHERE revenue >= (
    SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY revenue)   -- PostgreSQL syntax
    FROM ads_performance
    -- SQLite fallback: replace with subquery using ORDER BY / LIMIT approach
)
ORDER BY revenue DESC
LIMIT 20;

-- SQLite-compatible version of 7.2
SELECT
    date, platform, campaign_type, industry, country,
    ad_spend, revenue, ROAS, CPA, CTR
FROM ads_performance
ORDER BY revenue DESC
LIMIT 20;

-- 7.3  Underperforming campaigns (ROAS < 2 and high spend)
SELECT
    platform,
    campaign_type,
    industry,
    country,
    COUNT(*) AS n_campaigns,
    ROUND(SUM(ad_spend), 2) AS wasted_spend_usd,
    ROUND(AVG(ROAS), 2) AS avg_ROAS
FROM ads_performance
WHERE ROAS < 2
GROUP BY platform, campaign_type, industry, country
HAVING SUM(ad_spend) > 5000
ORDER BY wasted_spend_usd DESC
LIMIT 15;

-- 7.4  Efficiency score: composite rank
WITH scored AS (
    SELECT
        platform,
        campaign_type,
        industry,
        country,
        ROUND(AVG(ROAS), 2) AS avg_ROAS,
        ROUND(AVG(CPA), 2) AS avg_CPA,
        ROUND(AVG(CTR) * 100, 2) AS avg_CTR_pct,
        -- Composite: higher ROAS & CTR = better; lower CPA = better
        ROUND(AVG(ROAS) * AVG(CTR) / NULLIF(AVG(CPA), 0), 4)  AS efficiency_score
    FROM ads_performance
    GROUP BY platform, campaign_type, industry, country
)
SELECT *
FROM scored
ORDER BY efficiency_score DESC
LIMIT 20;


-- ─────────────────────────────────────────────────────────────
-- SECTION 8 · A/B TESTING PREPARATION QUERIES
-- (Aggregate data exported to Python for statistical tests)
-- ─────────────────────────────────────────────────────────────

-- 8.1  ROAS distribution by platform (for Kruskal-Wallis)
SELECT platform, ROAS
FROM ads_performance
ORDER BY platform;

-- 8.2  CPA distribution by platform
SELECT platform, CPA
FROM ads_performance
ORDER BY platform;

-- 8.3  CTR distribution by campaign type
SELECT campaign_type, CTR
FROM ads_performance
ORDER BY campaign_type;

-- 8.4  Revenue distribution by campaign type
SELECT campaign_type, revenue
FROM ads_performance
ORDER BY campaign_type;

-- 8.5  ROAS distribution: platform × campaign_type (for paired comparison)
SELECT platform, campaign_type, ROAS, CPA, CTR, revenue
FROM ads_performance
ORDER BY platform, campaign_type;

-- 8.6  Sample size check for each group (power analysis input)
SELECT
    platform,
    campaign_type,
    COUNT(*) AS n,
    ROUND(AVG(ROAS), 2) AS mean_ROAS,
    ROUND(AVG(CPA), 2) AS mean_CPA,
    ROUND(AVG(CTR), 4) AS mean_CTR
FROM ads_performance
GROUP BY platform, campaign_type
ORDER BY platform, campaign_type;


-- ─────────────────────────────────────────────────────────────
-- SECTION 9 · ADVANCED / WINDOW FUNCTIONS
-- ─────────────────────────────────────────────────────────────

-- 9.1  Running total revenue per platform (monthly)
SELECT
    platform,
    strftime('%Y-%m', date) AS month,
    ROUND(SUM(revenue), 2)  AS monthly_revenue,
    ROUND(SUM(SUM(revenue)) OVER (PARTITION BY platform ORDER BY strftime('%Y-%m', date)), 2) AS cumulative_revenue
FROM ads_performance
GROUP BY platform, strftime('%Y-%m', date)
ORDER BY platform, month;

-- 9.2  Month-over-month ROAS growth rate
WITH monthly AS (
    SELECT
        strftime('%Y-%m', date) AS month,
        ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 4) AS ROAS
    FROM ads_performance
    GROUP BY strftime('%Y-%m', date)
),
with_lag AS (
    SELECT
        month,
        ROAS,
        LAG(ROAS) OVER (ORDER BY month) AS prev_ROAS
    FROM monthly
)
SELECT
    month,
    ROUND(ROAS, 2) AS ROAS,
    ROUND(prev_ROAS, 2) AS prev_month_ROAS,
    ROUND(100.0 * (ROAS - prev_ROAS) / NULLIF(prev_ROAS, 0), 1) AS MoM_growth_pct
FROM with_lag
ORDER BY month;

-- 9.3  Percentile rank of each campaign by ROAS within its platform
SELECT
    platform,
    campaign_type,
    industry,
    ROAS,
    ROUND(
        100.0 * RANK() OVER (PARTITION BY platform ORDER BY ROAS) /
        COUNT(*) OVER (PARTITION BY platform),
        1
    ) AS percentile_rank
FROM ads_performance
ORDER BY platform, percentile_rank DESC;

-- 9.4  7-day rolling average CTR per platform
SELECT
    platform,
    date,
    ROUND(AVG(CTR), 4) AS daily_avg_CTR,
    ROUND(AVG(AVG(CTR)) OVER (
        PARTITION BY platform
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 4) AS rolling_7d_CTR
FROM ads_performance
GROUP BY platform, date
ORDER BY platform, date;


-- ─────────────────────────────────────────────────────────────
-- SECTION 10 · BUSINESS RECOMMENDATIONS QUERIES
-- ─────────────────────────────────────────────────────────────

-- 10.1  Budget reallocation: identify best ROI destination per industry
SELECT
    industry,
    platform,
    campaign_type,
    ROUND(SUM(ad_spend), 2) AS current_spend,
    ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2) AS actual_ROAS,
    RANK() OVER (
        PARTITION BY industry
        ORDER BY SUM(revenue)/NULLIF(SUM(ad_spend),0) DESC
    ) AS roas_rank
FROM ads_performance
GROUP BY industry, platform, campaign_type
ORDER BY industry, roas_rank;

-- 10.2  Quick wins: high-volume, high-ROAS, low-CPA segments
SELECT
    platform,
    campaign_type,
    industry,
    country,
    COUNT(*) AS n,
    ROUND(SUM(impressions), 0) AS total_impressions,
    ROUND(AVG(ROAS), 2) AS avg_ROAS,
    ROUND(AVG(CPA), 2) AS avg_CPA,
    ROUND(AVG(CTR) * 100, 2) AS avg_CTR_pct
FROM ads_performance
WHERE ROAS > (SELECT AVG(ROAS) FROM ads_performance)
  AND CPA  < (SELECT AVG(CPA)  FROM ads_performance)
GROUP BY platform, campaign_type, industry, country
HAVING COUNT(*) >= 5
ORDER BY avg_ROAS DESC
LIMIT 15;

-- 10.3  Worst performers to pause / review
SELECT
    platform,
    campaign_type,
    industry,
    country,
    COUNT(*) AS n,
    ROUND(AVG(ROAS), 2) AS avg_ROAS,
    ROUND(AVG(CPA), 2) AS avg_CPA,
    ROUND(SUM(ad_spend), 2) AS total_spend
FROM ads_performance
WHERE ROAS < 1.5
GROUP BY platform, campaign_type, industry, country
HAVING SUM(ad_spend) > 3000
ORDER BY avg_ROAS ASC
LIMIT 10;

-- 10.4  Seasonal budget guidance: average spend & ROAS per month across all years
SELECT
    strftime('%m', date) AS month_num,
    CASE strftime('%m', date)
        WHEN '01' THEN 'January'   WHEN '02' THEN 'February'
        WHEN '03' THEN 'March'     WHEN '04' THEN 'April'
        WHEN '05' THEN 'May'       WHEN '06' THEN 'June'
        WHEN '07' THEN 'July'      WHEN '08' THEN 'August'
        WHEN '09' THEN 'September' WHEN '10' THEN 'October'
        WHEN '11' THEN 'November'  WHEN '12' THEN 'December'
    END AS month_name,
    ROUND(AVG(ad_spend), 2)                              AS avg_daily_spend,
    ROUND(SUM(revenue) / NULLIF(SUM(ad_spend), 0), 2)   AS monthly_ROAS,
    ROUND(SUM(conversions), 0)                           AS total_conversions
FROM ads_performance
GROUP BY strftime('%m', date)
ORDER BY month_num;

-- =============================================================
--  END OF FILE
-- =============================================================
