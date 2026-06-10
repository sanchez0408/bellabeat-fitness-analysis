
SELECT
  Id,
  AVG(TotalSteps) AS avg_steps,
  AVG(asleep) AS avg_sleep,
  AVG(Calories) AS avg_calories,
  AVG(VeryActiveMinutes) AS avg_very_active,
  AVG(restless) AS avg_restless,
  AVG(SedentaryMinutes) AS avg_sedentary,
FROM `mon-projet-bigquery-481616.bellabeat_project_1.activity_and_sleep`
GROUP BY Id
