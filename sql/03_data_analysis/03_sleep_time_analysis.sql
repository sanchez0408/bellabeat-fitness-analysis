-- =============== --
-- STEP 1: CONTEXT --
-- =============== --

-- Understanding users' Fitbit device usage habits in relation to sleep
-- Evaluate sleep time by users



-- ===================== --
-- STEP 2: DATA OVERVIEW --
-- ===================== --

-- How many Fitbit users use their Fitbit to record their sleep?

SELECT
  COUNT(DISTINCT Id) AS total_users
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time_cleaning`

-- Observation:
  -- 25 users use their watch at night to record their sleep

-- What is the average amount of sleep for each day of the week?

SELECT
  FORMAT_DATE('%A', Date) AS day_of_week,
  EXTRACT(DAYOFWEEK FROM Date) AS day_num,
  AVG(total_minutes_sleep) AS avg_day_sleep
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time_cleaning`
GROUP BY day_of_week, day_num
ORDER BY avg_day_sleep DESC

-- Observation:
  -- Users have a higher average sleep duration on weekends and also on Wednesdays



-- ===================== --
-- STEP 3: MAIN ANALYSIS --
-- ===================== --

-- 3.1 Average users sleep time and days:

SELECT
  Id,
  ROUND(AVG(total_minutes_sleep), 0) AS avg_total_minutes_sleep,
  COUNT(id) AS total_usage_days
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time_cleaning`
GROUP BY Id
ORDER BY avg_total_minutes_sleep DESC

-- Observation:
  -- The average is between 69 and 534 minutes with a very heterogeneous number of uses: 1 and 62 days


-- 3.2 Sleep quality: ratio of actual sleep vs time in bed

SELECT
  Id,
  ROUND(AVG(asleep), 0) AS avg_minutes_asleep,
  ROUND(AVG(total_minutes_sleep), 0) AS avg_minutes_in_bed,
  ROUND(AVG(asleep) / AVG(total_minutes_sleep) * 100, 1) AS sleep_efficiency_pct
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time_cleaning`
GROUP BY Id
ORDER BY sleep_efficiency_pct ASC

-- Observation:
  -- 3 users have a sleep percentage below 80%, for the remaining users, the percentage is between 88.4% and 98.8%


-- 3.3 Sleep duration segmentation: how many users meet the recommended 7-8h?

WITH user_sleep_avg AS (
  SELECT
    Id,
    AVG(asleep) AS avg_sleep
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time_cleaning`
  GROUP BY Id
)

SELECT
  CASE
    WHEN avg_sleep < 360 THEN 'Under 6h'
    WHEN avg_sleep < 420 THEN '6h to 7h'
    WHEN avg_sleep < 480 THEN '7h to 8h (recommended)'
    ELSE 'Over 8h'
  END AS sleep_category,
  COUNT(Id) AS total_users
FROM user_sleep_avg
GROUP BY sleep_category
ORDER BY total_users DESC

-- Observation:
  -- 12 out of 25 users sleep less than 6 hours and only 6 users are within the recommended sleep time


-- 3.4 Restlessness breakdown: average time asleep, restless and awake per user

SELECT
  Id,
  ROUND(AVG(asleep), 0)    AS avg_asleep,
  ROUND(AVG(restless), 0)  AS avg_restless,
  ROUND(AVG(awake), 0)     AS avg_awake
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time_cleaning`
GROUP BY Id
ORDER BY avg_restless DESC

-- Observation:
  -- Users at the top of this ranking are the most agitated sleepers
  -- A potential target segment for Bellabeat stress/recovery features



-- ================ --
-- STEP 4: INSIGHTS --
-- ================ --


-- 1. Only 25 out of 33 activity users record their sleep — roughly 24% do not wear the device at night, limiting data coverage and suggesting a comfort or habit gap

-- 2. Sleep duration is highly variable across users (from ~1h to ~9h average), indicating very different user profiles that could benefit from personalized nudges

-- 3. Weekend and Wednesday nights show higher average sleep duration — weekday constraints (work schedule) likely compress sleep on other nights

-- 4. Sleep efficiency (asleep / time in bed) varies across users — some spend significant time restless or awake, pointing to sleep quality issues beyond duration

-- 5. A significant share of users likely fall below the recommended 7h threshold an opportunity for Bellabeat to promote its sleep tracking and bedtime reminders



-- =================== --
-- STEP 5: LIMITATIONS --
-- =================== --


-- 1. Small sample: only 25 users recorded sleep data — results are indicative, not statistically representative of a broader population

-- 2. No demographic data: age, gender, lifestyle context are unknown, making it impossible to control for confounding factors

-- 3. Short time window: data covers ~2 months (April–May 2016), which may not capture seasonal sleep patterns or long-term habits

-- 4. Self-selection bias: users who wear their device at night may already be more health-conscious than average — results may skew positive

-- 5. Device accuracy: restless/awake minutes are estimated by the accelerometer, not measured by clinical-grade sleep tracking (no EEG)



-- ================== --
-- STEP 6: CONCLUSION --
-- ================== --


  -- Sleep data reveals that Fitbit users struggle with both sleep duration and quality:
  -- most users fall below the 7-8h recommendation, and a notable share spend significant time awake or restless in bed

  -- Recommendations for Bellabeat:

  --   → Introduce a smart bedtime reminder feature in the app, triggered when the user has not started winding down by their usual sleep time

  --   → Surface a daily "sleep score" combining duration + efficiency to increase awareness and engagement with sleep tracking

  --   → Target under-sleepers (<6h segment) with in-app content on sleep hygiene, positioning Bellabeat as a wellness coach, not just a tracker

  --   → Investigate why ~24% of users don't record sleep — consider device comfort improvements or onboarding prompts to encourage night wear

