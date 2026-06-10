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

-- Observation:
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

-- Observation:
  -- Most users recorded a majority of active days during the observation period
  -- However, inactivity levels vary considerably between individuals, indicating different engagement levels with physical activity
  -- Some users accumulate a substantial number of inactive days, suggesting either sedentary behavior or potential periods of device non-wear

  
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

-- Observation:
  -- Most users fall within the sedentary, low active, or somewhat active categories
  -- Only a small proportion of users achieve the commonly recommended threshold of 10,000 daily steps
  -- Average daily step counts vary widely across users, highlighting significant differences in activity behavior

  
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

-- Observation:
  -- Active days account for the majority of recorded observations, while inactive days represent a smaller share of the dataset
  -- Despite this, inactivity remains present across the user base and should not be overlooked
  -- The results suggest that users generally engage in some level of physical activity but do not maintain consistently active behavior every day


-- ====================
-- STEP 4: KEY INSIGHTS
-- ====================

-- 1. Activity is present on most recorded days:
  -- Most users maintain active days throughout the observation period, although inactivity levels vary substantially between individuals

-- 2. The majority of users do not reach recommended activity targets:
  -- Only a minority of users achieve the commonly recommended threshold of 10,000 daily steps, indicating room for increased physical activity

-- 3. User activity behavior is highly heterogeneous:
  -- Daily step counts and inactivity rates differ considerably across users, suggesting that activity habits are driven by individual lifestyles rather than a common behavioral pattern

-- 4. Sedentary behavior remains visible across the dataset:
  -- Even among active users, periods of inactivity are regularly observed, highlighting opportunities to encourage more consistent movement


-- ===================
-- STEP 5: LIMITATIONS
-- ===================

-- 1. Limited sample size:
  -- The dataset contains activity records from only 35 users. This relatively small sample limits the representativeness of the findings and makes it difficult to generalize results to the broader Bellabeat user population

-- 2. Potential device non-wear bias:
  -- Days classified as inactive may not always reflect true sedentary behavior. Some records could result from users not wearing their Fitbit device, leading to potential overestimation of inactivity

-- 3. Activity measured primarily through step counts:
  -- User activity levels are categorized using daily step counts, which may not fully capture all forms of physical activity. Activities such as cycling, strength training, or other non-step-based exercises may therefore be underrepresented


-- ==================
-- STEP 6: CONCLUSION
-- ==================

-- 1. Summary of key findings:
  -- The analysis shows that most users maintain active days throughout the observation period, although activity levels vary considerably between individuals
  -- While the majority of recorded days are active, only a small proportion of users consistently achieve the commonly recommended threshold of 10,000 daily steps

-- 2. Main takeaway:
  -- User activity behavior is highly heterogeneous. Some users maintain relatively high activity levels, while others experience frequent inactive days or lower average step counts

-- 3. Business implication:
  -- These differences suggest that Bellabeat users cannot be effectively addressed through a single engagement strategy
  -- Instead, activity goals and motivational features should adapt to individual behavior patterns and current activity levels

-- 4. Recommendation:
  -- Bellabeat should consider implementing personalized activity targets, progressive step goals, and tailored engagement strategies based on user activity profiles
  -- This approach may improve long-term user motivation while remaining realistic for less active users

-- 5. Final statement:
  -- Although the dataset is limited in size and scope, it highlights significant variability in user activity habits and reinforces the importance of personalization as a key driver of user engagement
