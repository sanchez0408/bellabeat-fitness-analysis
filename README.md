# bellabeat-fitness-analysis
End-to-end fitness data analysis using SQL, BigQuery and Tableau to identify user behavior patterns and provide business recommendations for Bellabeat.

---

## 🏃 Bellabeat Fitness Data Analysis

### 💻 Project Overview

This project was completed as part of the Google Data Analytics Professional Certificate.

The objective was to analyze smart device fitness data to identify user behavior patterns and provide actionable business recommendations for Bellabeat, a wellness technology company focused on women's health.

Using SQL (BigQuery) and Tableau, the analysis explores physical activity, sleep habits, sedentary behavior, and the relationships between these metrics.

### 🎯 Business Task

Bellabeat wants to better understand how consumers use smart fitness devices and how these insights can support future marketing and product strategies.

- Key Questions
- How active are Bellabeat users?
- What are their sleep habits?
- Are there identifiable behavioral patterns?
- How are activity and sleep related?
- What business opportunities emerge from the analysis?
  Dataset
  
Source

FitBit Fitness Tracker Data (Kaggle)

### 📅 Period

March 2016 – May 2016

| Table          | Description            |
| -------------- | ---------------------- |
| Daily Activity | Daily activity metrics |
| Hourly Steps   | Hourly step counts     |
| Sleep Time     | Sleep tracking records |

| Table          | Description            |
| -------------- | ---------------------- |
| Daily Activity | Daily activity metrics |
| Hourly Steps   | Hourly step counts     |
| Sleep Time     | Sleep tracking records |

Data Preparation

The analysis followed a structured workflow:

1. Exploratory Analysis
- Dataset structure review
- User coverage validation
- Duplicate detection
- Date range verification
- Data quality assessment

2. Data Cleaning
- Duplicate removal
- Date standardization
- Validation of activity metrics
- Creation of analysis-ready tables

SQL queries are available in the /sql folder.

Analysis Highlights
## 1. Activity Patterns
Key Findings
Activity peaks occur around 12 PM, 6 PM, and 7 PM.
Saturday records the highest average activity level.
User behavior is fragmented rather than uniform.
Insight

Approximately 50% of users are classified as afternoon-active users, suggesting that engagement strategies should adapt to different activity schedules.

## 2. Sleep Habits
Key Findings
12 of 25 users average less than 6 hours of sleep.
Only 6 users meet the recommended 7–8 hour range.
Users sleep longer on weekends.
Insight

Sleep deprivation appears common within the sample, creating opportunities for sleep-focused coaching and engagement features.

## 3. Activity & Sleep
Key Findings
More active users generally sleep longer.
Higher activity levels are associated with fewer restless minutes.
Sedentary time remains high across all groups.
Insight

Activity alone does not fully explain sleep quality, but users with healthier activity profiles tend to show better sleep outcomes.

## 4. Activity Correlation Analysis
Key Findings
No significant relationship between daily steps and sleep duration (R² ≈ 0.01).
Daily steps show only a weak relationship with calorie expenditure (R² ≈ 0.05).
No significant relationship between very active minutes and restless sleep (R² ≈ 0.02).
Sedentary behavior shows the strongest observed relationship with sleep duration (R² ≈ 0.64).
Insight

Sedentary behavior appears more strongly associated with sleep duration than overall activity volume. Reducing inactivity may have a greater impact on sleep outcomes than simply increasing daily step counts.

Dashboard Preview
Behavioral Habit Dashboard

(Insert image here)

Sleep Habit Dashboard

(Insert image here)

Activity Correlation Dashboard

(Insert image here)

Recommendations Dashboard

(Insert image here)

Business Recommendations
1. Personalize Engagement by Activity Profile

Deliver notifications, challenges, and coaching content aligned with each user's preferred activity window.

2. Highlight the Sleep–Sedentary Behavior Connection

Provide personalized insights showing how sedentary behavior may affect sleep duration.

3. Target the Under-Sleeping Majority

Develop features focused on sleep improvement, including bedtime reminders and sleep quality tracking.

4. Address Sedentary Time Through Movement Nudges

Encourage regular movement throughout the day to reduce inactivity.

5. Encourage Consistent Night Wear

Increase sleep data coverage through onboarding prompts and sleep-tracking education.

Project Links
Tableau Dashboard

(Ton lien Tableau Public)

Kaggle Notebook

(Ton lien Kaggle)

Author

Guillaume Sanchez

Data Analyst | SQL • BigQuery • Tableau • Data Storytelling
