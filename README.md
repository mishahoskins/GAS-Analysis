Cochran-Armitage Trend Test (CA):

• Parametric (sort of): it assumes a linear trend in binary proportions across ordered groups.

• Sensitive to linear patterns: it’s powerful if you expect a consistent increase or decrease.

• Assumes the ordinal nature (year over year in this case) of the independent variable and a linear change in response.

• Example use: Proportion of patients infected over increasing age groups or years.

Mann-Kendall Trend Test (MK):

• Non-parametric: makes no assumptions about the shape of the trend (i.e., doesn’t assume linearity).

• Tests whether there is a monotonic trend (consistently increasing or decreasing), which can be non-linear. (Think two-sided it could measure decrease in trend if applicable)

• Works with continuous or ordinal data, and is often used for time series (e.g., yearly incidence rates we use it here for case counts, but could/should(?) apply to rates).

• More robust to outliers and missing data.

• Example use: Disease rates that go up for a few years, level off, then rise again; if the general direction is increasing, MK can detect it. (re: COVID years saw a leveling off of HAI's because of lack of reporting and increased barrier/visit precautions (and other factors)). 

Why do we use a combination:

• CA: If we expect a steady, linear trend in binary data across time (or ordered categories), CA is more powerful. We test linearity at the Rsq >= 0.50 (arbitrary but still indicative of a linear trend).

• MK: If the trend is non-linear or more wonky, but still moving in a consistent direction overall, MK is better suited. See leveling off of HAIs during COVID (2020-2021 mainly).




When do we see Cochran-Armitage Trend tesing in Infectious Disease Studies

While the C-A test is commonly used in dose-response scenarios, it can apply to assessing trends in proportions across ordered groups in infectious disease research:

• Alcohol Consumption and Esophageal Cancer: An exercise based on a French case-control study examines the relationship between alcohol intake levels and the incidence of esophageal cancer. Here, the CA test can assess whether higher alcohol consumption correlates with increased cancer cases, illustrating its utility in evaluating exposure-response relationships in epidemiology. Dose increase is ordinal 1, 2, 3 drinks etc and rate of esophageal cancer is linear in it's increase.



Mann-Kendall Trend Test in Infectious Disease Studies



The MK test is particularly valuable for analyzing time-series data in infectious diseases, as it detects  trends without assuming a specific data distribution. Example: 

• COVID-19 Case Trends in the U.S.: Researchers applied the MK test to identify significant trends and change points in the progression of COVID-19 cases across different states. This approach helped in understanding the time based trends of the pandemic and evaluating the impact of public health interventions. 

• Hepatitis B Incidence in Xinjiang, China: The MK test was utilized to analyze time-series data of Hepatitis B cases from 2006 to 2021, identifying periods with significant changes in incidence rates. Such analyses are crucial for informing targeted public health strategies. Ie: what happened during 2006-2021 that led to the increase?

So, when not to use CA or MK?

• If you need:

• Adjustments for confounders → use regression **** huge point here

• Effect size estimates → use regression

Key takeway: these are complex methods for a simple evaluation.
