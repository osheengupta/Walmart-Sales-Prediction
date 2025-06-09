## USE FORECAST LIBRARY.

library(forecast)
library(zoo)


## CREATE DATA FRAME. 

# Set working directory for locating files.
setwd("/Users/osheen/Desktop/MSBA/3rd Term/Time serires/Final Project")

# Create data frame.
Walmart.data <- read.csv("Walmart.csv")

# See the first 6 records of the file.
head(Walmart.data)
tail(Walmart.data)

# Aggregate the data by date 
agg_data <- aggregate(Weekly_Sales ~ Date, data = Walmart.data, sum)

# Sort the dataset 
agg_data$Date <- as.Date(agg_data$Date, format = "%d-%m-%Y")
agg_data <- agg_data[order(agg_data$Date), ]


head(agg_data)
tail(agg_data)

walmart.ts <- ts(agg_data$Weekly_Sales, start = c(2010, 6), end = c(2012, 43), freq = 52)

walmart.ts

# Find minimum value
min(walmart.ts)

# Find maximum value
max(walmart.ts)

plot(walmart.ts, 
     xlab = "Time", ylab = "Sales", 
     ylim = c(30000000, 90000000), xaxt = 'n',
     main = "Walmart Weekly Sales Across 45 stores")


# Add x-axis ticks every year from 2010 to 2013
axis(1, at = seq(2010, 2013, 1), labels = seq(2010, 2013, 1))

walmart.stl <- stl(walmart.ts, s.window = "periodic")
autoplot(walmart.stl, main = "Walmart Time Series Components")

# ACF
autocor <- Acf(walmart.ts, lag.max = 52, 
               main = "Autocorrelation for Walmart Sales")

Lag <- round(autocor$lag, 0)
ACF <- round(autocor$acf, 3)
data.frame(Lag, ACF)

## TEST PREDICTABILITY OF Walmart Revenue.

# Use Arima() function to fit AR(1) model.
# The ARIMA model of order = c(1,0,0) gives an AR(1) model.
revenue.ar1<- Arima(walmart.ts, order = c(1,0,0))
summary(revenue.ar1)

# Apply z-test to test the null hypothesis that beta 
# coefficient of AR(1) is equal to 1.
ar1 <- 0.3354
s.e. <- 0.0787
null_mean <- 1
alpha <- 0.05
z.stat <- (ar1-null_mean)/s.e.
z.stat
p.value <- pnorm(z.stat)
p.value
if (p.value<alpha) {
  "Reject null hypothesis"
} else {
  "Accept null hypothesis"
}


nValid <- 28 
nTrain <- length(walmart.ts) - nValid
train.ts <- window(walmart.ts, end = time(walmart.ts)[nTrain])
valid.ts <- window(walmart.ts, start = time(walmart.ts)[nTrain + 1])

valid.ts
nValid
#________________________________________________________________________________________________________________________________________________
# Model 1
# Regression model with linear trend and seasonality
# Use tslm() function to create linear trend and seasonal model.
train.lin.season <- tslm(train.ts ~ trend + season)

# See summary of linear trend and seasonality model and associated parameters.
summary(train.lin.season)

# Apply forecast() function to make predictions for ts with 
# linear trend and seasonality data in validation set.  
train.lin.season.pred <- forecast(train.lin.season, h = nValid, level = 0)

train.lin.season.pred$mean
#________________________________________________________________________________________________________________________________________________
# Model 2 : TWO level Model (Regression + Trailing MA)
trend.seas <- tslm(train.ts ~ trend + season)
summary(trend.seas)

trend.seas.pred <- forecast(trend.seas, h = nValid, level = 0)
trend.seas.pred

# Identify and display regression residuals for training
# partition (differences between actual and regression values 
# in the same periods).
trend.seas.res <- trend.seas$residuals
trend.seas.res

# Apply trailing MA for residuals with window width k = 4
# for training partition.
ma.trail.res <- rollmean(trend.seas.res, k = 4, align = "right")
ma.trail.res

# Create residuals forecast for validation period.
ma.trail.res.pred <- forecast(ma.trail.res, h = nValid, level = 0)
ma.trail.res.pred

# Develop two-level forecast for validation period by combining  
# regression forecast and trailing MA forecast for residuals.
fst.2level <- trend.seas.pred$mean + ma.trail.res.pred$mean
fst.2level
# Create a table for validation period: validation data, regression 
# forecast, trailing MA for residuals and total forecast.
valid.df <- round(data.frame(valid.ts, trend.seas.pred$mean, 
                             ma.trail.res.pred$mean, 
                             fst.2level), 3)
names(valid.df) <- c("Sales", "Regression.Fst", 
                     "MA.Residuals.Fst", "Combined.Fst")
valid.df
#________________________________________________________________________________________________________________________________________________
# Model 3: AUTO ARIMA MODEL.

# Use auto.arima() function to fit ARIMA model.
# Use summary() to show auto ARIMA model and its parameters.
train.auto.arima <- auto.arima(train.ts)
summary(train.auto.arima)

# Apply forecast() function to make predictions for ts with 
# auto ARIMA model in validation set.  
train.auto.arima.pred <- forecast(train.auto.arima, h = nValid, level = 0)
train.auto.arima.pred$mean

round(accuracy(train.lin.season.pred$mean, valid.ts), 3)
round(accuracy(fst.2level, valid.ts), 3)
round(accuracy(train.auto.arima.pred$mean, valid.ts), 3)


table.df <- round(data.frame(valid.ts, train.lin.season.pred$mean, 
                             fst.2level, train.auto.arima.pred$mean),3)
names(table.df) <- c("Actual.Sales", "Lin.Seas.Forecast", "2.lvl.Forecast","Auto.Arima")
table.df
#________________________________________________________________________________________________________________________________________________
#________________________________________________________________________________________________________________________________________________

## For Entire Dataset

# Model 1 : Regression model with Linear trend and seasonality.
# Use tslm() function to create linear trend and seasonal model.
lin.season <- tslm(walmart.ts ~ trend + season)

# See summary of quadratic trend and seasonality model and associated parameters.
summary(lin.season)

# Apply forecast() function to make predictions for ts with 
# trend and seasonality data in validation set.  
lin.season.pred <- forecast(lin.season, h = 12, level = 0)

lin.season.pred

#________________________________________________________________________________________________________________________________________________
# Fit a regression model with linear trend and seasonality for
# entire data set.
tot.trend.seas <- tslm(walmart.ts ~ trend  + season)
summary(tot.trend.seas)

# Create regression forecast for future 12 periods.
tot.trend.seas.pred <- forecast(tot.trend.seas, h = 12, level = 0)
tot.trend.seas.pred

# Identify and display regression residuals for entire data set.
tot.trend.seas.res <- tot.trend.seas$residuals
tot.trend.seas.res

# Use trailing MA to forecast residuals for entire data set.
tot.ma.trail.res <- rollmean(tot.trend.seas.res, k = 4, align = "right")
tot.ma.trail.res

# Create forecast for trailing MA residuals for future 12 periods.
tot.ma.trail.res.pred <- forecast(tot.ma.trail.res, h = 12, level = 0)
tot.ma.trail.res.pred$mean

# Develop 2-level forecast for future 12 periods by combining 
# regression forecast and trailing MA for residuals for future
# 12 periods.
tot.fst.2level <- tot.trend.seas.pred$mean + tot.ma.trail.res.pred$mean
tot.fst.2level



#________________________________________________________________________________________________________________________________________________

## FIT AUTO ARIMA MODEL FOR ENTIRE DATASET.

# Use auto.arima() function to fit ARIMA model for entire data set.
# use summary() to show auto ARIMA model and its parameters for entire data set.
auto.arima <- auto.arima(walmart.ts)
summary(auto.arima)

# Apply forecast() function to make predictions for ts with 
# auto ARIMA model for the future 4 periods. 
auto.arima.pred <- forecast(auto.arima, h = 12, level = 0)
auto.arima.pred$mean

#________________________________________________________________________________________________________________________________________________

# Create a table with regression forecast, trailing MA for residuals,
# and total forecast for future 12 periods.
future12.df <- round(data.frame(lin.season.pred$mean, tot.fst.2level, auto.arima.pred$mean ), 3)
names(future12.df) <- c("Lin.Seas.Fst", "2.lvl.Fst", "Auto.Arima")
future12.df

round(accuracy(tot.trend.seas.pred$fitted, walmart.ts), 3)
round(accuracy(tot.trend.seas.pred$fitted+tot.ma.trail.res, walmart.ts), 3)
round(accuracy(auto.arima.pred$fitted, walmart.ts), 3)
round(accuracy((snaive(walmart.ts))$fitted, walmart.ts), 3)









