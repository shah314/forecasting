# Author: Shalin Shah
# Stock price forecasting using stochastic differential equations
# Geometric Brownian Motion (GBM)
# The equation is very sensitive to initial values (currently all 8 parameters are initialized to 0.01)
# If the confidence intervals appear too wide or if you see NaNs in the output, try the following:
# Try pmle="shoji" in fitsde (or try other methods for MLE)
# Try to use another random seed
# Try to get more data
# Shorten the time horizon
# Change the initial values
# Consider working in log space

library(Sim.DiffProc)
set.seed(314)
library(ggplot2)

# Read the data
data <- read.table("Desktop/data/TSLA.csv", sep=',', header=T)
measure <- data$Close

# the last 54 days are for testing
measure_test <- measure[200:253]

# The first 199 days are for training
measure <- measure[1:199]

x_0 = measure_test[1]
mydata <- ts(measure)

# Create drift and diffusion equations
d <- expression(theta[1]*x)
s <- expression(theta[2]*x)

# Learn the parameters using fitsde using maximum likelihood estimation
fit <- fitsde(data = mydata, drift = d, diffusion = s, start = list(theta1 = 0.01, theta2 = 0.01), pmle = "kessler")

drift <- as.numeric(fit$coef[1])
diffusion <- as.numeric(fit$coef[2])

# Create drift and diffusion equations from the learned values for simulation
d <- eval(substitute(expression(drift * x), list(drift = drift)))
s <- eval(substitute(expression(diffusion * x), list(diffusion = diffusion)))

# Number of simulations
Nsim <- 100

# sum_x creates a cumulative sum of the simulated values for calculating the mean
sum_x <- rep(0, 54)

# all_x is used to store all simulated values for calculating the standard deviation for the confidence intervals
all_x <- data.frame()

for(i in 1:Nsim)
{
	# Create a new random seed for each simulation
	rand <- as.integer(1000 * runif(1))
	set.seed(rand)
	
	# Simulate the SDE using the Euler method for 54 days into the future
	X <- snssde1d(N=53, x0=x_0, Dt=0.00001, drift=d, diffusion=s, method="euler", M=1)
	
	sum_x = sum_x + X$X
	all_x = rbind(all_x, as.numeric(X$X))
}

sum_x <- sum_x / Nsim # the mean value
sd_x <- sapply(all_x, sd) # standard deviations

mean(abs(measure_test - sum_x)) # MAE
cor(measure_test, sum_x) # Correlation (square it to get the R-squared)

# Create upper and lower confidence bounds
upper <- sum_x + 1.96 * sd_x
lower <- sum_x - 1.96 * sd_x

p <- ggplot()
p <- p + geom_line(aes(x=1:199, y=measure, color="Original Data"))
p <- p + geom_line(aes(x=200:253, y=measure_test, color="Original Data TEST"))
p <- p + geom_line(aes(x=200:253, y=sum_x, color="Predicted using GBM"))
p <- p + ylab("Value of the Stock")
p <- p + xlab("Time in Days")
p <- p + ggtitle("Stock Price Prediction using Geometric Brownian Motion")
p <- p + geom_ribbon(aes(x=c(200:253), y = sum_x, ymin=lower, ymax=upper), linetype=2, alpha=0.1)
p