# This code reproduces the result in Figure 4 of the paper "Local and Anglosphere-Based 
# Geopolitical Risk and Sovereign Stress in the Euro Area" by Francesco Frangiamore 
# and Jamel Saadaoui (2026).

# Clear the environment
rm(list=ls())

# upload package for estimation of robust standard errors
library(sandwich)
library(lmtest)

load("data.RData")

p <- 12 # number of lags
H <- 12 # max horizon (20 quarters - 5 years)

# take local GPR index for Germany from Alonso-Alvarez et al. (2025) and GPR index 
# for Germany from Caldara and Iacoviello (2022) 
GPR_local = cbind(data$Germany,data$GPRC_DEU)

SovCISS = data$SovCISS_EA # take the SovCISS for the Euro Area

# take EA manufacturing industrial production index and compute growth rate
IP = data$IPMN_EA 
IP_gr = diff(log(IP))*100

int_rate = data$IRT3M_EACC # take EA short-term interest rate

N <- ncol(GPR_local) # number of GPR indices for countries and global

# prepare object to store IRFs and standard errors
save_IRF <- array(0, dim = c(H+1,N))
save_se <- array(0, dim = c(H+1,N))

for (r in 1:N) { # estimate local projections for each GPR index
  print(r)
  
  GPR = GPR_local[,r] # take GPR index
  
  # prepare variables (first observation is removed because of the computation of 
  # industrial production growth)
  data_temp = cbind(SovCISS[-1],GPR[-1],IP_gr,int_rate[-1]) 
  
  data_no_nan = na.omit(data_temp) # remove rows with missing data
  
  y <- data_no_nan[-c(1:p),1] # response variable (remove first p observations to include lags)
  
  # Create lags
  variables <- data_no_nan # put variables in a matrix
  TT <- nrow(variables) # time series length
  
  # Create empty object to fill with lags
  lags <- array()
  
  # Loop to create the matrix of regressors (lags of endogenous variables)
  for (l in 1:p) {
    lags <- cbind(lags,variables[((p-l+1):(TT-l)),])  
  }                                      
  
  lags <- lags[,-1] # remove first column of NaN created by the loop
  
  w <- cbind(lags)
  
  x <- data_no_nan[-c(1:p),2] # select GPR index (second column of the data)
  
  # temporary objects to store results in the loop
  IRF <- matrix(0,H+1,1) # IRF
  SE <- matrix(0,H+1,1) # standard errors
  
  h1 <- 0 # horizon where the shock hit 
  
  TT <- length(y) # update time series length after inclusion of lags
  
  # Loop to estimate local projections
  for (h in 1:(H+1)) {
    ytemp <- y[(h+h1):(TT)] # response variable
    xtemp <- cbind(x[1:(TT-h+1)],w[1:(TT-h+1),]) # combine regressors
    
    #Newey-West estimator varcovar matrix
    regr_temp <- lm(ytemp ~ xtemp)
    regr_temp_robust <- coeftest(regr_temp, vcov. = vcovHAC(regr_temp))
    
    # save results
    IRF[h+h1,] <- regr_temp_robust[2,1]
    SE[h+h1,] <- regr_temp_robust[2,2]
  }
  
  delta_times <- sd(x)*3 # compute standard deviation of the GPR index multiplied by 3, 
  #as explained in the paper, to rescale the IRFs
  
  # rescale the IRFs by three standard deviation of the GPR index, as explained in the paper
  # and save the results for each GPR index
  IRF_one_std <- IRF*delta_times
  SE_one_std = SE*delta_times
  save_IRF[,r] <- IRF_one_std
  save_se[,r] <- SE_one_std
}

# Plot Figure 4
plot_names = c("Local GPR Germany","Anglosphere GPR Germany")


min_plot <- min(save_IRF - save_se*qnorm(0.95))
max_plot <- max(save_IRF + save_se*qnorm(0.95))

irf = save_IRF[,1]
up90 <- save_IRF[,1] + (save_se[,1]*qnorm(0.95))
lo90 <- save_IRF[,1] - (save_se[,1]*qnorm(0.95))
up68 <- save_IRF[,1] + (save_se[,1]*1)
lo68 <- save_IRF[,1] - (save_se[,1]*1)

irf2 = save_IRF[,2]
up902 <- save_IRF[,2] + (save_se[,2]*qnorm(0.95))
lo902 <- save_IRF[,2] - (save_se[,2]*qnorm(0.95))
up682 <- save_IRF[,2] + (save_se[,2]*1)
lo682 <- save_IRF[,2] - (save_se[,2]*1)

par(mfrow = c(1,2),mar=c(3, 3, 1.5, 1))
plot(0:H,rep(0,H+1),lwd = 1,type = "l",col = 1,lty = 2,
     xaxs = "i",ylab = "",xlab = "", main = "Local GPR Germany",
     ylim = c(min_plot,max_plot), cex.main = 1)
polygon(c(0:H, rev(0:H)), c(up90, rev(lo90)),col=rgb(1,0.2,0.2,0.25),border=NA)
polygon(c(0:H, rev(0:H)), c(up68, rev(lo68)),col=rgb(1,0.2,0.2,0.25),border=NA)
lines(0:H,irf,lwd = 2,col = "red",lty = 1)
title(ylab="SovCISS (unit)", xlab="months after shock", line=2, cex.lab=0.9)

plot(0:H,rep(0,H+1),lwd = 1,type = "l",col = 1,lty = 2,
     xaxs = "i",ylab = "",xlab = "", main = "Anglosphere GPR Germany",
     ylim = c(min_plot,max_plot), cex.main = 1)
polygon(c(0:H, rev(0:H)), c(up902, rev(lo902)),col=rgb(0,0.4,0.8,0.25),border=NA)
polygon(c(0:H, rev(0:H)), c(up682, rev(lo682)),col=rgb(0,0.4,0.8,0.25),border=NA)
lines(0:H,irf2,lwd = 2,col = 4,lty = 1)
title(ylab="SovCISS (unit)", xlab="months after shock", line=2, cex.lab=0.9)
