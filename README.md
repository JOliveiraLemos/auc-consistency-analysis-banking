# Auc-consistency-analysis-banking
Financial data consistency analysis for Assets Under Custody (AUC), including anomaly detection, data reconciliation, and trend evaluation using Python.

# Context

Financial institutions rely on consistency across different systems (custodial, accounting, and transactional) to ensure the accurate calculation of assets under custody (AUC). Discrepancies between these sources can lead to operational errors, distortions in financial reports, and misguided decisions.
This project simulates a real-world scenario of data inconsistency and proposes a structured approach to:

 - Identify anomalies between different data sources
 - Develop metrics for consistency validation
 - Analyze the evolution of assets under custody
 - Compare performance with (simulated) competitor data

# Data Generation and SQL layer

The dataset used in this project was synthetically generated to simulate a financial environment. SQL scripts were created to model transactional, accounting, and custody data. These scripts were executed in a SQL environment to generate structured tables, which were then exported as CSV files and analyzed using Python.

# Objective

 - Detect inconsistencies between custody balances, book balances, and transaction activity
 - Classify anomalies based on business rules
 - Construct an adjusted AUC proxy for temporal analysis
 - Evaluate monthly changes in AUC
 - Compare trends with competitors (on a normalized basis)

# Methodology
1. Exploratory Data Analysis (EDA)
An initial analysis was conducted to understand:
The distribution of balances over time
The presence of negative values
Discrepancies between sources (custodial vs. accounting)
The following were used:
Scatter plots
Box plots
Time series

## Data Preparation
Sorting by client and date
Calculation of daily percentage change (pct_change) for:
 - custodial balance
 - accounting balance
PS: The percentage change was used only as an auxiliary indicator, as it can introduce distortions at values close to zero.

## Consistency Metrics
### Comparison between sources

Evaluation of the difference between the accounting balance and the custody balance Using of a combined threshold:
difference > 10%
absolute difference > 100

### Flow vs. Stock Ratio
Comparison between today’s transactions and yesterday’s balance in order to verify whether the balance justifies the transaction volume

## Classification of Anomalies
Three main categories were defined:

### System Discrepancy
Opposing signals between custody and accounting or Difference > 10% and > 100 (absolute value) indicating:

integration failure
calculation inconsistency

### Transaction Anomaly
Transaction volume above the 95th percentile excluding cases with a very low base indicating:
atypical behavior
possible error or significant event

### Low Base Effect
Transactions associated with very low balances Values below the 5th percentile indicating:
mathematical distortion
not necessarily an actual error

