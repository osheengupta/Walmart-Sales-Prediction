# Walmart Sales Prediction - Time Series Forecasting Project

## Overview
This project presents a comprehensive time series analysis and forecasting of Walmart's weekly aggregated sales across 45 stores using historical data from 2010 to 2012. The goal was to build accurate forecasting models to support sales planning and inventory management.

## Dataset
- Source: Kaggle Walmart Retail Sales dataset
- Data includes weekly sales across 45 stores, spanning February 2010 to October 2012
- Additional variables (holiday flags, temperature, fuel price, CPI, unemployment) were explored but excluded from final models due to low correlation

## Methods
Three forecasting models were developed and compared:
1. **Linear Regression Model with Trend and Seasonality**  
   Captures long-term trend and weekly seasonal patterns using time index and seasonal dummy variables.
2. **Two-Level Forecasting Model**  
   Combines linear regression with a trailing moving average smoothing on regression residuals to improve accuracy.
3. **Automatic ARIMA Model**  
   Utilizes automatic parameter selection to model seasonal and autoregressive components.

## Evaluation
- Models were evaluated using RMSE, MAE, MAPE, ACF1, and Theil’s U metrics.
- The Two-Level Forecasting model outperformed others with the lowest RMSE (~913K) and MAPE (~1.4%), indicating high predictive accuracy.
- Linear Regression model also provided a strong and interpretable baseline.
- Auto ARIMA underperformed relative to regression-based models.

## Results
- Forecasts for the next 12 weeks were generated using the best-performing model.
- The analysis highlighted clear seasonal spikes aligning with retail events such as Black Friday and holiday seasons.
- The approach provides actionable insights for Walmart's operational planning.

## Tools & Technologies
- Programming Language: R
- Key Packages: `forecast`, `zoo`
- Techniques: Time Series Decomposition, Linear Regression, Moving Average, ARIMA

## How to Use
1. Clone the repository.
2. Load the dataset (`Walmart.csv`).
3. Run the scripts to preprocess data, build models, evaluate performance, and generate forecasts.
4. Explore `forecast_results.csv` for detailed predictions.

## Author
Osheen Gupta
Master of Science in Business Analytics

---

Feel free to explore and adapt this project for retail sales forecasting and time series analytics applications.

