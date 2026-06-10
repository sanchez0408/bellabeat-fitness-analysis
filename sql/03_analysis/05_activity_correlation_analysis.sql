
SELECT
  Id,
  AVG(TotalSteps) AS avg_steps,
  AVG(asleep) AS avg_sleep
FROM activity_and_sleep
GROUP BY Id


SELECT
  Id,
  AVG(TotalSteps) AS avg_steps,
  AVG(Calories) AS avg_calories
FROM activity_and_sleep
GROUP BY Id


SELECT
  Id,
  AVG(VeryActiveMinutes) AS avg_very_active,
  AVG(restless) AS avg_restless
FROM activity_and_sleep
GROUP BY Id


SELECT
  Id,
  AVG(SedentaryMinutes) AS avg_sedentary,
  AVG(asleep) AS avg_sleep
FROM activity_and_sleep
GROUP BY Id
