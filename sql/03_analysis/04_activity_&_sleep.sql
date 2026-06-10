


CREATE OR REPLACE TABLE `mon-projet-bigquery-481616.bellabeat_project_1.activity_and_sleep` AS
SELECT
  a.Id,
  a.ActivityDate,
  a.TotalSteps,
  a.TotalDistance,
  a.TrackerDistance,
  a.LoggedActivitiesDistance,
  a.VeryActiveDistance,
  a.ModeratelyActiveDistance,
  a.LightActiveDistance,
  a.SedentaryActiveDistance,
  a.VeryActiveMinutes,
  a.FairlyActiveMinutes,
  a.LightlyActiveMinutes,
  a.SedentaryMinutes,
  a.Calories,
  b.asleep,
  b.restless,
  b.awake,
  b.total_minutes_sleep
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity_frequency` a
INNER JOIN `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time_cleaning` b
  ON CAST(a.Id AS STRING) = CAST(b.Id AS STRING)
  AND b.Date = DATE_ADD(a.ActivityDate, INTERVAL 1 DAY)


-- =============== --
-- STEP 1: CONTEXT --
-- =============== --

-- Analyze the relationship between activity and sleep quality
-- Analyze the relationship between activity and calories consumed



-- ===================== --
-- STEP 2: DATA OVERVIEW --
-- ===================== --

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT Id) AS total_users,
  MIN(ActivityDate) AS first_date,
  MAX(ActivityDate) AS last_date
FROM `mon-projet-bigquery-481616.bellabeat_project_1.activity_and_sleep`

-- Observation:
  -- In this analysis we will have 24 of the 35 Fitbit users
  -- 605 rows covering the period where both activity and sleep were recorded on the same day



-- ===================== --
-- STEP 3: MAIN ANALYSIS --
-- ===================== --

-- 3.1 Sport activity vs sleep quality

WITH user_averages AS (
  SELECT
    Id,
    ROUND(AVG(VeryActiveMinutes), 1) AS avg_very_active_min,
    ROUND(AVG(asleep), 1) AS avg_asleep_min,
    ROUND(AVG(restless), 1) AS avg_restless_min,
    ROUND(AVG(awake), 1) AS avg_awake_min
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.activity_and_sleep`
  GROUP BY Id
),

user_segment AS (
  SELECT *,
    CASE
      WHEN avg_very_active_min = 0 THEN 'no active'
      WHEN avg_very_active_min < 15 THEN 'very little active'
      WHEN avg_very_active_min < 30 THEN 'moderate'
      ELSE 'very active'
    END AS activity_segment
  FROM user_averages
)

SELECT
  activity_segment,
  COUNT(*) AS total_users,
  ROUND(AVG(avg_very_active_min), 1) AS avg_very_active_min,
  ROUND(AVG(avg_asleep_min), 1) AS avg_asleep_min,
  ROUND(AVG(avg_restless_min), 1) AS avg_restless_min,
  ROUND(AVG(avg_awake_min), 1) AS avg_awake_min
FROM user_segment
GROUP BY activity_segment
ORDER BY total_users DESC

-- Observation:
  -- Very little active users represent the largest share of all users: 11 out of 24 and 
  -- The most active people are those with the lowest average amount of restless sleep (15.6 minutes)
  -- The users with no physical activity have the worst sleep quality (55.8 minutes of restless and 26.6 minutes of awake)


-- 3.1b Total activity score vs sleep quality

WITH user_averages AS (
  SELECT
    Id,
    ROUND(AVG(VeryActiveMinutes), 1)   AS avg_very_active_min,
    ROUND(AVG(FairlyActiveMinutes), 1)  AS avg_fairly_active_min,
    ROUND(AVG(LightlyActiveMinutes), 1) AS avg_lightly_active_min,
    ROUND(AVG(asleep), 1)               AS avg_asleep_min,
    ROUND(AVG(restless), 1)             AS avg_restless_min,
    ROUND(AVG(awake), 1)                AS avg_awake_min
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.activity_and_sleep`
  GROUP BY Id
),

user_score AS (
  SELECT *,
    ROUND(
      (avg_very_active_min * 3) +
      (avg_fairly_active_min * 2) +
      (avg_lightly_active_min * 1)
    , 1) AS activity_score
  FROM user_averages
),

user_segment AS (
  SELECT *,
    CASE
      WHEN activity_score < 100  THEN 'low activity'
      WHEN activity_score < 250  THEN 'moderate activity'
      WHEN activity_score < 450  THEN 'active'
      ELSE                            'very active'
    END AS activity_segment
  FROM user_score
)

SELECT
  activity_segment,
  COUNT(*) AS total_users,
  ROUND(AVG(activity_score), 1)        AS avg_activity_score,
  ROUND(AVG(avg_very_active_min), 1)   AS avg_very_active_min,
  ROUND(AVG(avg_fairly_active_min), 1) AS avg_fairly_active_min,
  ROUND(AVG(avg_lightly_active_min), 1) AS avg_lightly_active_min,
  ROUND(AVG(avg_asleep_min), 1)        AS avg_asleep_min,
  ROUND(AVG(avg_restless_min), 1)      AS avg_restless_min,
  ROUND(AVG(avg_awake_min), 1)         AS avg_awake_min
FROM user_segment
GROUP BY activity_segment
ORDER BY avg_activity_score ASC

-- Observation:
  -- 3 activity segments emerged from the weighted score (low activity segment is absent:
    -- all 24 users accumulate enough light activity to score >= 100)
  -- A clear gradient appears across all three sleep metrics:
    -- avg_restless_min drops sharply with activity: 35.1 → 25.8 → 22.1 min
    -- avg_awake_min also decreases: 11.6 → 4.6 → 4.3 min
 


-- 3.2 Activity, sleep and calories

WITH user_averages AS (
  SELECT
    Id,
    ROUND(AVG(VeryActiveMinutes), 1)    AS avg_very_active_min,
    ROUND(AVG(FairlyActiveMinutes), 1)  AS avg_fairly_active_min,
    ROUND(AVG(LightlyActiveMinutes), 1) AS avg_lightly_active_min,
    ROUND(AVG(asleep), 1)               AS avg_asleep_min,
    ROUND(AVG(restless), 1)             AS avg_restless_min,
    ROUND(AVG(awake), 1)                AS avg_awake_min,
    ROUND(AVG(Calories), 1)             AS avg_calories
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.activity_and_sleep`
  GROUP BY Id
),

user_score AS (
  SELECT *,
    ROUND(
      (avg_very_active_min * 3) +
      (avg_fairly_active_min * 2) +
      (avg_lightly_active_min * 1)
    , 1) AS activity_score
  FROM user_averages
),

user_segment AS (
  SELECT *,
    CASE
      WHEN activity_score < 100 THEN 'low activity'
      WHEN activity_score < 250 THEN 'moderate activity'
      WHEN activity_score < 450 THEN 'active'
      ELSE                           'very active'
    END AS activity_segment
  FROM user_score
)

SELECT
  activity_segment,
  COUNT(*) AS total_users,
  ROUND(AVG(activity_score), 1)         AS avg_activity_score,
  ROUND(AVG(avg_very_active_min), 1)    AS avg_very_active_min,
  ROUND(AVG(avg_fairly_active_min), 1)  AS avg_fairly_active_min,
  ROUND(AVG(avg_lightly_active_min), 1) AS avg_lightly_active_min,
  ROUND(AVG(avg_asleep_min), 1)         AS avg_asleep_min,
  ROUND(AVG(avg_restless_min), 1)       AS avg_restless_min,
  ROUND(AVG(avg_awake_min), 1)          AS avg_awake_min,
  ROUND(AVG(avg_calories), 1)           AS avg_calories
FROM user_segment
GROUP BY activity_segment
ORDER BY avg_activity_score ASC

-- Observation:
  -- Sleep quality improves as activity intensity increases:
    -- avg_restless_min decreases: 35.1 → 25.8 → 22.1 min
    -- avg_awake_min decreases:    11.6 → 4.6 → 4.3 min

  -- Sleep duration does not follow a perfectly linear pattern:
    -- active users average 329 min asleep,
    -- while very active users reach 418.3 min

  -- Calorie expenditure increases strongly with activity:
    -- avg_calories rises from 2,205 → 2,474 → 3,504 kcal
  -- Very active users burn 59% more calories than moderate users (+1,299 kcal/day)



-- 3.3 Sedentary behavior vs sleep quality

SELECT
  CASE
    WHEN avg_sedentary_min < 600 THEN 'low sedentary (< 10h)'
    WHEN avg_sedentary_min < 900 THEN 'moderate sedentary (10-15h)'
    ELSE                              'high sedentary (> 15h)'
  END AS sedentary_segment,
  COUNT(*) AS total_users,
  ROUND(AVG(avg_sedentary_min), 1) AS avg_sedentary_min,
  ROUND(AVG(avg_asleep_min), 1)    AS avg_asleep_min,
  ROUND(AVG(avg_restless_min), 1)  AS avg_restless_min,
  ROUND(AVG(avg_awake_min), 1)     AS avg_awake_min
FROM (
  SELECT
    Id,
    AVG(SedentaryMinutes) AS avg_sedentary_min,
    AVG(asleep)           AS avg_asleep_min,
    AVG(restless)         AS avg_restless_min,
    AVG(awake)            AS avg_awake_min
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.activity_and_sleep`
  GROUP BY Id
)
GROUP BY sedentary_segment
ORDER BY avg_sedentary_min ASC

-- Observation:
  -- avg_asleep_min drops sharply as sedentary time increases: 446 → 392 → 155 min
  -- high sedentary users sleep less than 3h on average an extreme signal likely reflecting users who rarely wear the device at night
  -- avg_restless_min peaks in the moderate sedentary segment (33.6 min) then drops in high sedentary not a paradox: users sleeping only ~2.5h have less total time to accumulate restless minutes
  -- low sedentary segment contains only 1 user — not representative, to be treated with caution in the analysis
 


-- ================ --
-- STEP 4: INSIGHTS --
-- ================ --

-- 1. Only 24 out of 33 users recorded both activity and sleep on the same day
--    9 users either did not track sleep or had no matching activity days after cleaning

-- 2. Very little actives users represent the largest segment (11/24 based on VeryActiveMinutes),
--    however when using the weighted activity score, 
--    no user falls below 100 all users accumulate enough light activity to score in the moderate tier minimum

-- 3. A clear relationship emerges between activity, sleep quality and calories:
--    avg_restless_min decreases with activity: 35.1 → 25.8 → 22.1 min
--    avg_awake_min decreases with activity:    11.6 → 4.6 → 4.3 min
--    avg_calories increases with activity:     2205 → 2474 → 3504 kcal

-- 4. Very active users burn 59% more calories than moderate users
--    (+1299 kcal/day), highlighting the impact of activity intensity driven primarily by intensity rather than light movement alone

-- 5. Sedentary time dominates the day at 798 min (~13h) on average, even among users who record active minutes, inactivity is the default state

-- 6. High sedentary users sleep drastically less: 155 min vs 446 min for low sedentary
--    however this likely reflects low device usage at night rather than true sleep deprivation for all users in this segment



-- =================== --
-- STEP 5: LIMITATIONS --
-- =================== --

-- 1. Reduced sample: the INNER JOIN limits the dataset to 24 users and 605 rows
--    only days where both activity AND sleep were recorded are included, which may introduce selection bias toward more engaged users

-- 2. Weighted activity score (Very × 3 + Fairly × 2 + Lightly × 1) is an analytical
--    proxy, not a validated scientific scale weights reflect relative intensity 
--    and were chosen for analytical purposes (to be documented in the portfolio)

-- 3. Low sedentary segment contains only 1 user results for this group are not statistically representative and should be treated with caution

-- 4. No causal inference: correlations between activity, sleep and calories
--    do not establish causality confounding factors (age, health status, stress, lifestyle) cannot be controlled without demographic data

-- 5. Short observation window: ~2 months of data may not reflect stable long-term habits — some users may have had atypical periods during the study

-- 6. Device wear compliance: low sleep minutes in high sedentary users likely
--    reflects non-wear at night rather than actual sleep deprivation device usage patterns confound sleep metrics



-- ================== --
-- STEP 6: CONCLUSION --
-- ================== --

-- The combined activity and sleep data reveals three consistent findings:
--   1. More active users experience better sleep quality
--      (less restless and awake time)
--   2. More active users burn substantially more calories
--   3. High sedentary time is associated with reduced sleep duration

-- The weighted activity score confirms that even moderate daily movement (mostly light activity) is associated with better sleep quality than
-- near-total inactivity, intensity amplifies the benefit but is now the only lever available to users

-- Recommendations for Bellabeat:
  -- Promote intensity over duration: market the benefit of short bursts of
  --      vigorous activity (even 15-30 min/day) on sleep quality and calorie burn
  -- Target the inactive majority: design low-barrier entry features
  --      (guided 10-min workouts, step challenges) to move users toward the active tier
  -- Connect activity and sleep scores in the app: show users directly how their
  --      active minutes today impacted their sleep quality last night
  --      creating a feedback loop that drives both engagement and behavior change
  -- Address sedentary time with hourly movement nudges: 13h/day sedentary
  --      is a health risk signal that Bellabeat can directly act on via notifications
  -- Encourage consistent night wear: low sleep recording rates suggest many users
  --      do not wear the device at night — onboarding prompts and comfort-focused
  --      marketing could improve sleep data coverage and user engagement
