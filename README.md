Cochran-Armitage Trend Test (CA):

• Parametric (sort of) — it assumes a linear trend in binary proportions across ordered groups.

• Sensitive to linear patterns — it’s powerful if you expect a consistent increase or decrease.

• Assumes the ordinal nature of the independent variable and a linear change in response.

• Example use: Proportion of patients infected over increasing age groups or years.

Mann-Kendall Trend Test (MK):

• Non-parametric — makes no assumption about the shape of the trend (i.e., doesn’t assume linearity).

• Tests whether there is a monotonic trend (consistently increasing or decreasing), which can be non-linear.

• Works with continuous or ordinal data, and is often used for environmental or epidemiologic time series (e.g., yearly incidence rates).

• More robust to outliers and missing data.

• Example use: Disease rates that go up for a few years, level off, then rise again — as long as the general direction is increasing, MK can detect it.

So why both?

• CA: If you expect a steady, linear trend in binary data across time (or ordered categories), CA is more powerful.

• MK: If the trend is non-linear or more irregular, but still moving in a consistent direction overall, MK is better suited.

• CA when the increase in incidence looked linear across years.

• MK when incidence rates fluctuated year to year but still had an overall upward (or downward) trend

Cochran-Armitage Trend Test in Infectious Disease Studies



While the C-A test is commonly used in dose-response scenarios, it also applies to assessing trends in proportions across ordered groups in infectious disease research. For example:

• Alcohol Consumption and Esophageal Cancer: An exercise based on a French case-control study examines the relationship between alcohol intake levels and the incidence of esophageal cancer. Here, the C-A test can assess whether higher alcohol consumption correlates with increased cancer cases, illustrating its utility in evaluating exposure-response relationships in epidemiology.



Mann-Kendall Trend Test in Infectious Disease Studies



The M-K test is particularly valuable for analyzing time-series data in infectious diseases, as it detects monotonic trends without assuming a specific data distribution. Notable applications include:

• COVID-19 Case Trends in the U.S.: Researchers applied the M-K test to identify significant trends and change points in the progression of COVID-19 cases across different states. This approach helped in understanding the temporal dynamics of the pandemic and evaluating the impact of public health interventions. 

• Hepatitis B Incidence in Xinjiang, China: The M-K test was utilized to analyze time-series data of Hepatitis B cases from 2006 to 2021, identifying periods with significant changes in incidence rates. Such analyses are crucial for informing targeted public health strategies. 

So, when not to use C-A or M-K?

• If you need:

• Adjustments for confounders → use regression

• Effect size estimates → use regression

• Flexible trend modeling (non-monotonic, seasonality, etc.) → use time-series or spline models

• Complex designs (e.g., multilevel data) → use hierarchical or mixed models
