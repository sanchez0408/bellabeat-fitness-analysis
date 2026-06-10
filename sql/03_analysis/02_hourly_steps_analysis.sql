-- =============== --
-- STEP 1: CONTEXT --
-- =============== --

-- Objective:
 -- Analyse hourly user activity patterns
 -- To identify peak activity periods and behavioral trends



-- ===================== --
-- STEP 2: DATA OVERVIEW --
-- ===================== --

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT Id) AS total_users,
  MIN(steps_total) AS min_StepTotal,
  MAX(steps_total) AS max_StepTotal,
  ROUND(AVG(steps_total)) AS avg_StepTotal
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps_cleaning`

-- Observation:
 -- Dataset contains 35.784 rows for 34 users
 -- The minimum step count is 0 and maximum is 10.565, with an average of 374 steps per hour
 -- This presence of 0 steps suggests inactive periods (likely during nigthtime, sedentary time or the non-use of the tracker)
 -- To be confirmed by analyzing the hourly data
 -- The maximum value appears unusually high and may indicate intense activity (likely running)

WITH avg_step AS (
  SELECT
    EXTRACT(DAYOFWEEK FROM DATE(activity_date)) AS day_num,
    steps_total
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps_cleaning`
)

SELECT
  ROUND(AVG(CASE WHEN day_num NOT IN (1, 7) THEN steps_total END)) AS avg_weekday,
  ROUND(AVG(CASE WHEN day_num IN (1, 7) THEN steps_total END)) AS avg_weekend
FROM avg_step

-- Observation:
 -- average weekday step is 372 and average weekend is 380
 -- The analysis shows that the difference between weekday and weekend activity is very small, approximately 2%
 -- It can be conclused that Bellabeat users maintain consistent activity habits during both weekdays and weekends



-- ===================== --
-- STEP 3: MAIN ANALYSIS --
-- ===================== --

-- 3.1 peak hourly activity

SELECT
  EXTRACT(HOUR FROM activity_date) AS hour,
  ROUND(AVG(steps_total)) AS avg_steps,
  ROUND(STDDEV(steps_total)) AS std_steps --> determine if the behavior is homogeneous or heterogeneous
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps_cleaning`
GROUP BY Hour
ORDER BY Hour

-- Observation:
  -- During the day, from 8am to 8pm, a fairly close average number of steps can be observed (between 490 and 685), with peaks at 12pm, 6pm and 7pm
  -- The consistently high standard deviation across most hours indicates significant variability in user behavior, suggesting that activity patterns differ widely between individuals
  -- This heterogeneity implies that some users are highly active during peak hours, while others remain inactive at the same time
  -- Activity levels drop significantly during nighttime hours, with both average steps and variability decreasing, reflecting consistent inactivity during night periods



-- 3.2 time of day segmentation

SELECT
  CASE
    WHEN EXTRACT(HOUR FROM activity_date) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM activity_date) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN EXTRACT(HOUR FROM activity_date) BETWEEN 18 AND 23 THEN 'Evening'
    ELSE 'Night'
  END AS time_of_day,
  ROUND(AVG(steps_total)) AS avg_steps
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps_cleaning`
GROUP BY time_of_day
ORDER BY avg_steps DESC

-- Observation:
  -- Activity is higher in the afternoon, average steps, higher at this time (484) then the average is fairly balanced between the morning (361) and the evening (347)
  -- This pattern suggests that engagement features (e.g., reminders or challenges) would be more effective if triggered later in the day or early in the morning



-- 3.3 day activity

SELECT
  EXTRACT(DAYOFWEEK FROM activity_date) AS day_num,
  FORMAT_DATE('%A', activity_date) AS day_activity,
  ROUND(AVG(steps_total)) AS avg_steps
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps_cleaning`
GROUP BY day_num, day_activity
ORDER BY day_num

-- Observation:
  -- Weekday activity is balanced, with no significant difference from Monday to Friday, however, there is a peak in activity on Saturday and a decrease in activity on Sunday
  -- This could explain regular activity during the week due to work, with a peak on Saturday for the first day of the weekend to engage in more physical activity and on Sunday for rest



-- 3.4 Active and inactive time

SELECT
  COUNTIF(steps_total > 0) AS Active_hour,
  COUNTIF(steps_total = 0) AS Inactive_hour,
  ROUND(COUNTIF(steps_total > 0) * 100 / COUNT(*), 0) AS Percent_active,
  ROUND(COUNTIF(steps_total = 0) * 100 / COUNT(*), 0) AS Percent_inactive
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps_cleaning`
WHERE EXTRACT(HOUR FROM activity_date) BETWEEN 7 AND 23 --> exclude night hours

-- Observation:
  -- Even after excluding nighttime hours, 31% of daytime hours remain inactive
  -- This indicates that inactivity is not limited to sleep periods but is also present during waking hours
  -- This suggests potential opportunities to encourage short bursts of activity throughout the day (e.g., micro-reminders or step goals)



-- 3.5 weekday/weekend

WITH avg_step AS
  (
  SELECT
    Id,
    EXTRACT(DAYOFWEEK FROM DATE(activity_date)) AS day_type,
    steps_total
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps_cleaning`
  ),
user_avg AS(
  SELECT
    Id,
    ROUND(AVG(CASE WHEN day_type NOT IN (1, 7) THEN steps_total END)) AS avg_weekday,
    ROUND(AVG(CASE WHEN day_type IN (1, 7) THEN steps_total END)) AS avg_weekend
  FROM avg_step
  GROUP BY Id
),
behavior_analysis AS(
SELECT
  Id,
  avg_weekday,
  avg_weekend,
  CASE
    WHEN avg_weekday > avg_weekend THEN 'More active on weekday'
    WHEN avg_weekday < avg_weekend THEN 'More active on weekend'
    ELSE 'Equal'
  END AS behavior
FROM user_avg
)
SELECT
  behavior,
  COUNT(*) AS nb_users
FROM behavior_analysis
GROUP BY behavior

-- Observation:
  -- The equal distribution between weekday-active and weekend-active users suggests that there is no dominant behavioral pattern across the user base
  -- This reinforces the idea of heterogeneous user habits, where activity is driven more by individual schedules than by a shared routine
  -- As a result, a one-size-fits-all engagement strategy may be ineffective



-- 3.6 hourly behavioral segmentation

WITH user_profile AS (
  SELECT
    Id,
    ROUND(AVG(CASE WHEN EXTRACT(HOUR FROM activity_date) BETWEEN 6 AND 11 THEN steps_total END), 0) AS morning,
    ROUND(AVG(CASE WHEN EXTRACT(HOUR FROM activity_date) BETWEEN 12 AND 17 THEN steps_total END), 0) AS afternoon,
    ROUND(AVG(CASE WHEN EXTRACT(HOUR FROM activity_date) BETWEEN 18 AND 23 THEN steps_total END), 0) AS evening
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps_cleaning`
  GROUP BY Id
)

SELECT
  CASE
    WHEN morning > evening * 1.20 AND morning > afternoon THEN 'Morning user'
    WHEN evening > morning * 1.20 AND evening > afternoon THEN 'Evening user'
    WHEN afternoon > morning AND afternoon > evening THEN 'Afternoon user'
    ELSE 'Balanced / Consistent'
  END AS profile,
  COUNT(*) AS nb_users
FROM user_profile
GROUP BY profile

--Observation:
  -- This analysis reveals distinct user behavior patterns, with users split between morning-active and evening-active profiles
  -- This confirms that user activity is not driven by a single daily routine but varies significantly across individuals
  -- These differences suggest that engagement strategies should be personalized, as users are more likely to respond to prompts aligned with their preferred activity periods
  -- For example, morning users may benefit from early-day reminders, while evening users may be more responsive to end-of-day engagement features



-- ==================== --
-- STEP 4: KEY INSIGHTS --
-- ==================== --

-- 1. Strong intra-day variability in user activity:
  -- Hourly activity shows moderate average values but high variability across users, indicating that behavior is highly individual rather than driven by a shared daily routine. Peaks occur mainly at midday and evening.

-- 2. Distinct behavioral patterns across users:
  -- The dispersion in hourly step counts suggests different lifestyle structures, likely influenced by work schedules, daily obligations, and flexible routines. This confirms that users cannot be treated as a homogeneous group.

-- 3. Limited global behavioral trend:
  -- No dominant activity pattern emerges across the full user base. This suggests that engagement strategies based on a single behavioral model would have limited effectiveness.

-- 4. Business implication:
  -- A segmented or personalized engagement strategy (e.g., time-based notifications or adaptive activity goals) would likely be more effective than a generic approach.



-- =================== --
-- STEP 5: LIMITATIONS --
-- =================== --

-- 1.Limited sample size:
-- The dataset contains only 34 users, which is a relatively small sample. This limits the statistical representativeness of the results and makes it difficult to generalize findings to the entire Bellabeat user base

-- 2. Lack of demographic and contextual data:
  -- No demographic information (age, occupation, lifestyle) is available. As a result, it is not possible to explain user behavior with precision or to build more meaningful user segments

-- 3. Short observation period:
  -- The data covers a limited time window (approximately two months). This may not fully capture long-term behavioral patterns, seasonal effects, or changes in user habits over time

-- 4. Device usage bias:
  -- The analysis assumes that the tracker is worn consistently. However, periods of low or zero activity may also reflect non-wear time, leading to potential underestimation of real activity levels.



-- ================== --
-- STEP 6: CONCLUSION --
-- ================== --

-- 1. Summary of key findings:
  -- The analysis of hourly step data reveals that user activity is highly time-dependent and unevenly distributed throughout the day. Activity peaks occur mainly in the afternoon and evening, while nighttime periods show consistently low engagement
  -- At the same time, a strong variability between users indicates that there is no single dominant behavioral pattern across the population. Instead, activity is highly heterogeneous, reflecting different daily routines and lifestyle constraints
  -- Finally, no significant difference is observed between weekday and weekend behavior, suggesting that user activity is more influenced by individual schedules than by the day type

-- 2. Main takeaway:
  -- Overall, Bellabeat users cannot be described through a single behavioral model. Their activity patterns are fragmented, individualized, and strongly dependent on personal routines rather than external calendar effects

-- 3. Business implication:
  -- This heterogeneity suggests that a generic engagement strategy would likely be suboptimal. Instead, user engagement should be driven by behavioral segmentation and personalization.
  -- Time-based targeting appears particularly relevant, as users show clear activity peaks at specific times of the day (afternoon and evening)

--4. Recommendation:
  -- Bellabeat should consider shifting from a uniform engagement strategy to a more adaptive approach, such as:
    -- Time-based notifications aligned with user activity peaks
    -- Personalized daily step goals based on user behavior profiles
    --Segmentation of users by active periods (morning, afternoon, evening users)

  -- This would allow the product to better align with real user behavior and potentially improve overall engagement and activity levels

-- 5. Final statement:
  -- This analysis provides a behavioral foundation for understanding user activity patterns. While limited by sample size and contextual data, it highlights clear opportunities for improving user engagement through personalization and timing-based strategies
