#
# Program Name:  GAS_MK analysis_20250418 
# Author:        Mikhail Hoskins
# Date Created:  04/18/2025
# Date Modified: .
# Description:   Mann-Kendall analysis for non-linear factors of increased group A strep infection in North Carolina
#				  (https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2831512#) (https://www.geeksforgeeks.org/how-to-perform-a-mann-kendall-trend-test-in-r/)
#        
# Inputs:       gas_trends_20250418.xlsx:T:\HAI\Code library\Epi curve example\ncedss extracts\Datasets
# Output:       .
#  Notes:       
#            
    

#Install ZYP and MK if necessary        
install.packages("zyp")
install.packages("Kendall")
install.packages("rmarkdown")
install.packages("tinytex")
install.packages("CATT")
install.packages("DescTools")

#Load packages (install if necessary)
library(haven)
library(Kendall)
library(ggplot2)
library(dplyr)
library(readxl)
library(DescTools)


# file.create("GAS_mk_analysis_20250418.Rmd")
# rmarkdown::render("GAS_mk_analysis_20250418.Rmd", output_format = "pdf_document")



gas_excel <- read_excel("T:/HAI/Code library/Epi curve example/ncedss extracts/Datasets/gas_trends_20250418.xlsx")

#For IV drug use we need to confine it to 2018-2024 (not 2012)
gas_excel_inj <- gas_excel |> 
    filter(GAS_inj !=0) 
mk_inj <- MannKendall(gas_excel_inj$GAS_inj)
print(mk_inj)


# Calculate the trend line
trend_line_inj <- predict(loess(gas_excel_inj$GAS_inj ~ gas_excel_inj$report_yr))

# Create a trend line plot
inj_plot <-
    ggplot() +
    geom_point(aes(x = gas_excel_inj$report_yr, y = gas_excel_inj$GAS_inj), color = "blue") +
    geom_line(aes(x = gas_excel_inj$report_yr, y = trend_line_inj), color = "red") +
    labs(x = "Year", y = "IV Drug Use GAS Cases", title = "Trend Line Plot - IV Drug Use") +
    theme_minimal()

print(inj_plot)
print(mk_inj)

#
#
#Now other non-linear RISK variables (without confining year)
#
#


#Healthcare experience = Surgical Operation
mk_surg <- MannKendall(gas_excel$GAS_surg)

# Calculate the trend line
trend_line_surg <- predict(loess(gas_excel$GAS_surg ~ gas_excel$report_yr))

# Create a trend line plot
surg_plot <-
    ggplot() +
    geom_point(aes(x = gas_excel$report_yr, y = gas_excel$GAS_surg), color = "blue") +
    geom_line(aes(x = gas_excel$report_yr, y = trend_line_surg), color = "red") +
    labs(x = "Year", y = "Post Surgery GAS Cases", title = "Trend Line Plot - Surgery") +
    theme_minimal()

print(surg_plot)
print(mk_surg)


#Mortality(deaths)
mk_mortality <- MannKendall(gas_excel$GAS_died_y)



# Calculate the trend line
trend_line_mortality <- predict(loess(gas_excel$GAS_died_y ~ gas_excel$report_yr))

# Create a trend line plot
mortality_plot <-
    ggplot() +
    geom_point(aes(x = gas_excel$report_yr, y = gas_excel$GAS_died_y), color = "blue") +
    geom_line(aes(x = gas_excel$report_yr, y = trend_line_mortality), color = "red") +
    labs(x = "Year", y = "GAS Deaths", title = "Trend Line Plot - Mortality") +
    theme_minimal()

print(mortality_plot)
print(mk_mortality)

#
#
#Now other non-linear RACE variables (without confining year)
#
#

#Race classified as "Asian"
mk_asian <- MannKendall(gas_excel$GAS_asian)



# Calculate the trend line
trend_line_asian <- predict(loess(gas_excel$GAS_asian ~ gas_excel$report_yr))

# Create a trend line plot
asian_plot <-
    ggplot() +
    geom_point(aes(x = gas_excel$report_yr, y = gas_excel$GAS_asian), color = "blue") +
    geom_line(aes(x = gas_excel$report_yr, y = trend_line_asian), color = "red") +
    labs(x = "Year", y = "Cases Race= Asian", title = "Trend Line Plot - Race: Asian") +
    theme_minimal()

print(asian_plot)
print(mk_asian)

#Race classified as "American Indian/Alaska Native"
mk_AIAN <- MannKendall(gas_excel$GAS_AIAN)



# Calculate the trend line
trend_line_AIAN <- predict(loess(gas_excel$GAS_AIAN ~ gas_excel$report_yr))

# Create a trend line plot
AIAN_plot <-
    ggplot() +
    geom_point(aes(x = gas_excel$report_yr, y = gas_excel$GAS_AIAN), color = "blue") +
    geom_line(aes(x = gas_excel$report_yr, y = trend_line_AIAN), color = "red") +
    labs(x = "Year", y = "Cases Race= American Indian/Alaska Native", title = "Trend Line Plot - Race: AI/AN") +
    theme_minimal()

print(AIAN_plot)
print(mk_AIAN)


#Race classified as "Other"
mk_oth <- MannKendall(gas_excel$GAS_other)



# Calculate the trend line
trend_line_oth <- predict(loess(gas_excel$GAS_other ~ gas_excel$report_yr))

# Create a trend line plot
Oth_plot <-
    ggplot() +
    geom_point(aes(x = gas_excel$report_yr, y = gas_excel$GAS_other), color = "blue") +
    geom_line(aes(x = gas_excel$report_yr, y = trend_line_oth), color = "red") +
    labs(x = "Year", y = "Cases Race= Other", title = "Trend Line Plot - Race: Other") +
    theme_minimal()

print(Oth_plot)
print(mk_oth)





