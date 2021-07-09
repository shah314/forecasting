# Author: Shalin Shah
# Stock price forecasting using Kalman filter
library(stats)
library(ggplot2)
set.seed(314)

# Read the data
data <- read.table("Desktop/data/TGT.csv", sep=',', header=T)
measure <- data$Close

# the last 54 days are for testing
measure_test <- measure[200:253]

# The first 199 days are for training
measure <- measure[1:199]

# Fit an initial basic ARIMA model
fit3 <- arima(measure, c(3, 0, 0))

# Forecast 54 days using the Kalman filter working on the ARIMA model
kal_forecast <- KalmanForecast(54, fit3$model, update=TRUE)
kal <- kal_forecast$pred + fit3$coef[4] # Add the intercept

mean(abs(measure_test - kal)) # MAE
cor(measure_test, kal) # Correlation (square this to get R-squared)

lower <- kal - 1.96*sqrt(kal_forecast$var) # lower bound
upper <- kal + 1.96*sqrt(kal_forecast$var) # upper bound

p <- ggplot()
p <- p + geom_line(aes(x=1:199, y=measure, color="Original Data"))
p <- p + geom_line(aes(x=200:253, y=measure_test, color="Original Data TEST"))
p <- p + geom_line(aes(x=200:253, y=kal, color="Predicted using Kalman Filter"))
p <- p + ylab("Value of the Stock")
p <- p + xlab("Time in Days")
p <- p + ggtitle("Stock Price Prediction using Kalman Filter")
p <- p + geom_ribbon(aes(x=c(200:253), y = kal, ymin=lower, ymax=upper), linetype=2, alpha=0.1)
p