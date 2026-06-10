-- ===============
-- STEP 1: CONTEXT
-- ===============

-- Objective:
-- Analyze daily user activity levels, active/inactive days, and user activity profiles


-- =====================
-- STEP 2: DATA OVERVIEW
-- =====================

-- General volume, users, min/max/avg steps

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT Id) AS total_users,
  MIN(TotalSteps) AS min_steps,
  MAX(TotalSteps) AS max_steps,
  ROUND(AVG(TotalSteps),0) AS avg_steps,
  MIN(ActivityDate) AS start_date,
  MAX(ActivityDate) AS end_date
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity_cleaning`

-- Dataset contains 1,373 daily records from 35 users
-- Observation period covers 12 March 2016 to 12 May 2016
-- Average daily steps reach approximately 7,377 steps
-- Step counts range from 0 to 36,019 steps
-- The presence of zero-step days may indicate inactivity or device non-wear
  
-- =====================
-- STEP 3: MAIN ANALYSIS
-- =====================

-- 3.1 Active and inactive days per user

WITH inactive_days AS (
  SELECT
    Id,
    COUNT(ActivityDate) AS nb_inactive_days
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity_cleaning`
  WHERE TotalSteps <= 100
    AND SedentaryMinutes >= 1400
  GROUP BY Id
),

user_days AS (
  SELECT
    Id,
    COUNT(ActivityDate) AS nb_total_days
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity_cleaning`
  GROUP BY Id
)

SELECT
  u.Id,
  u.nb_total_days,
  COALESCE(i.nb_inactive_days, 0) AS nb_inactive_days,
  u.nb_total_days - COALESCE(i.nb_inactive_days, 0) AS nb_active_days,
  ROUND(COALESCE(i.nb_inactive_days, 0) / u.nb_total_days * 100, 1) AS pct_inactive,
  ROUND((u.nb_total_days - COALESCE(i.nb_inactive_days, 0)) / u.nb_total_days * 100, 1) AS pct_active
FROM user_days u
LEFT JOIN inactive_days i USING (Id)
ORDER BY pct_inactive DESC

-- 3.2 User activity category by average daily steps

SELECT
  Id,
  ROUND(AVG(TotalSteps), 0) AS avg_daily_steps,
  CASE
    WHEN AVG(TotalSteps) < 5000  THEN 'Sedentary (< 5,000)'
    WHEN AVG(TotalSteps) < 7500  THEN 'Low active (5,000–7,500)'
    WHEN AVG(TotalSteps) < 10000 THEN 'Somewhat active (7,500–10,000)'
    ELSE                              'Active (≥ 10,000)'
  END AS cdc_category
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity_cleaning`
GROUP BY Id
ORDER BY avg_daily_steps DESC

-- 3.3 Overall active vs inactive day share

SELECT
  ROUND(SUM(nb_active_days) * 100 / SUM(nb_total_days), 1) AS pct_active,
  ROUND(SUM(nb_inactive_days) * 100 / SUM(nb_total_days), 1) AS pct_inactive
FROM (
  WITH inactive_days AS (
    SELECT
      Id,
      COUNT(ActivityDate) AS nb_inactive_days
    FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
    WHERE TotalSteps <= 100
      AND SedentaryMinutes >= 1400
    GROUP BY Id
  ),
  user_days AS (
    SELECT
      Id,
      COUNT(ActivityDate) AS nb_total_days
    FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
    GROUP BY Id
  )
  SELECT
    u.nb_total_days,
    COALESCE(i.nb_inactive_days, 0) AS nb_inactive_days,
    u.nb_total_days - COALESCE(i.nb_inactive_days, 0) AS nb_active_days
  FROM user_days u
  LEFT JOIN inactive_days i USING (Id)
)

-- ====================
-- STEP 4: KEY INSIGHTS
-- ====================

-- 1. Most recorded days are active
-- 2. Only a minority of users reach the 10,000-step threshold
-- 3. Activity levels vary strongly between users


-- ===================
-- STEP 5: LIMITATIONS
-- ===================

-- Limited sample size
-- Non-wear bias
-- Step-based categories do not capture full activity context


-- ==================
-- STEP 6: CONCLUSION
-- ==================

-- Summary
-- Business implication
-- Recommendation
