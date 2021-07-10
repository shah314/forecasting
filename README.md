# Stock Market Forecasting Exercise
#### Shalin Shah
The R code in this repository is an exercise in forecasting using one year of stock price data for four companies (TSLA, MSFT, TGT, WMT).
<br><br>
The data in the data folder contains one year of stock prices (downloaded from Yahoo finance) of each of the four stocks (2020-06-24 to 2021-06-24).<br><br>
The first 199 days are used as training data and the last 54 days are used as a test set for prediction.<br><br>
The code is used in the paper "Comparison of Stochastic Forecasting Models" which will be uploaded soon.<br><br>
<b>Cite this code:</b>
<pre>
@misc{shah2021gforecast,
  title={Comparison of Stochastic Forecasting Models},
  author={Shah, Shalin},
  year={2021}
}
</pre><br>
There are five algorithms in the five R scripts:<br>
<ol>
  <li>tdngbm: Geometric Brownian motion with time dependent and non-linear terms (stochastic differential equation)</li>
  <li>gbm: Geometric Brownian motion (stochastic differential equation)</li>
  <li>ARIMA: Auto-regressive integrated moving average</li>
  <li>Bayesian Filter</li>
  <li>Kalman Filter</li>
</ol>
<br>
<img src="images/tdngbm_tsla.png" height="500" width="500" alt="TDNGBM Predictions for Tesla" title="TDNGBM Predictions for Tesla">
