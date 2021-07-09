# Bayesian filter for forecasting stock prices
# Author: Shalin Shah
# Based on the following implementation:
# https://www.r-bloggers.com/2020/07/kalman-filter-as-a-form-of-bayesian-updating/

library(ggplot2)
library(forecast)

update <- function(mean1, var1, mean2, var2) 
{
	new_mean <- (var2*mean1 + var1*mean2) / (var1 + var2)
	new_var <- 1/(1/var1 + 1/var2)
	return(c(new_mean, new_var))
}

predict <- function(mean1, var1, mean2, var2) 
{
	new_mean <- mean1 + mean2
	new_var  <- var1 + var2
	return(c(new_mean, new_var))
}

var_measure <- 1000 # variance measure
var_motion <- 1000 # variance motion
pos <- c(0, 10000) # Starting values position and variance

set.seed(314)

# Read the data
data <- read.table("Desktop/data/TSLA.csv", sep=',', header=T)
measure <- data$Close

# the last 54 days are for testing
measure_test <- measure[200:253]

# The first 199 days are for training
measure <- measure[1:199]

x_0 = measure_test[1]
motion <- c(0, diff(measure))

# Smoothed training values
kalman_update <- c()

# The variances
var <- rep(0, length(measure_test))

# Run the Bayesian filter on the training data
for (i in 1:length(measure)) 
{
	pos <- update(pos[1], pos[2], measure[i], var_measure)
	first_value <- pos[1]
	first_variance <- pos[2]
	kalman_update <- c(kalman_update, pos[1])
	pos <- predict(pos[1], pos[2], motion[i], var_motion)
}

previous_value = measure[length(measure)]
kalman_update_test <- c()

# Fit a basic ARIMA model which the Bayesian filter can use to generate smoothed forecasts
fit <- arima(ts(measure), c(3, 0, 0))
fore <- forecast(fit, 54)

motion <- c(0, diff(fore$mean))
first_value <- fore$mean[1]

for (i in 1:length(measure_test)) {
  pos <- update(first_value, first_variance, x_0, var_measure)
  motion_i <- motion[i]
  pos <- predict(pos[1], pos[2], motion_i, var_motion)
  kalman_update_test <- c(kalman_update_test, pos[1])
  previous_value <- x_0
  x_0 <- pos[1]
  first_value <- pos[1]
  first_variance <- pos[2]
  var[i] <- first_variance
}
mean(abs(kalman_update_test - measure_test))
cor(kalman_update_test, measure_test)

lower <- kalman_update_test - 1.96*sqrt(var)
upper <- kalman_update_test + 1.96*sqrt(var)

p <- ggplot()
p <- p + geom_line(aes(x=1:199, y=measure, color="Original Data"))
p <- p + geom_line(aes(x=200:253, y=measure_test, color="Original Data TEST"))
p <- p + geom_line(aes(x=200:253, y=kalman_update_test, color="Predicted using Bayesian Filter"))
p <- p + geom_ribbon(aes(x=c(200:253), y = kalman_update_test, ymin=lower, ymax=upper), linetype=2, alpha=0.1)
p <- p + ylab("Value of the Stock")
p <- p + xlab("Time in Days")
p <- p + ggtitle("Stock Price Prediction using Bayesian Filter")
p