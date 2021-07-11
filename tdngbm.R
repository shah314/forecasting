# Author: Shalin Shah
# Stock price forecasting using stochastic differential equations
# The equation is very sensitive to initial values (currently all 8 parameters are initialized to 0.01)
# If the confidence intervals appear too wide or if you see NaNs in the output, try the following:
# Try pmle="shoji" in fitsde (or try other methods for MLE)
# Try to use another random seed
# Try to get more data
# Shorten the time horizon
# Change the initial values
# Consider working in log space

library(Sim.DiffProc)
library(ggplot2)
set.seed(314)

# Read the data
data <- read.table("Desktop/data/TSLA.csv", sep=',', header=T)
measure <- data$Close

# Create drift and diffusion equations
d <- expression(theta[1]*x + theta[2]*t + theta[3]*x^2 + theta[4]*t^2)
s <- expression(theta[5]*x + theta[6]*t + theta[7]*x^2 + theta[8]*t^2)

# the last 54 days are for testing
measure_test <- measure[200:253]

# The first 199 days are for training
measure <- measure[1:199]

# The initial value for simulating from the SDE
x_0 = measure_test[1]

# Learn the parameters using fitsde using maximum likelihood estimation
mydata <- ts(measure)
fit <- fitsde(data = mydata, drift = d, diffusion = s, start = list(theta1 = 0.01, theta2 = 0.01, theta3 = 0.01, theta4 = 0.01, theta5 = 0.01, theta6 = 0.01, theta7 = 0.01, theta8 = 0.01), pmle = "kessler")

# Create the four drift and four diffusion parameters from the fitted model
drift1 <- as.numeric(fit$coef[1])
drift2 <- as.numeric(fit$coef[2])
drift3 <- as.numeric(fit$coef[3])
drift4 <- as.numeric(fit$coef[4])
diffusion1 <- as.numeric(fit$coef[5])
diffusion2 <- as.numeric(fit$coef[6])
diffusion3 <- as.numeric(fit$coef[7])
diffusion4 <- as.numeric(fit$coef[8])

# Create drift and diffusion equations from the learned values for simulation
d <- eval(substitute(expression(drift1*x + drift2*t + drift3*x^2 + drift4*t^2), list(drift1 = drift1, drift2=drift2, drift3=drift3, drift4=drift4)))
s <- eval(substitute(expression(diffusion1*x + diffusion2*t + diffusion3*x^2 + diffusion4*t^2), list(diffusion1=diffusion1, diffusion2=diffusion2, diffusion3=diffusion3, diffusion4=diffusion4)))

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
p <- p + geom_line(aes(x=200:253, y=sum_x, color="Predicted using SDE"))
p <- p + ylab("Value of the Stock")
p <- p + xlab("Time in Days")
p <- p + ggtitle("Stock Price Prediction using TDNGBM")
p <- p + geom_ribbon(aes(x=c(200:253), y = sum_x, ymin=lower, ymax=upper), linetype=2, alpha=0.1)
p