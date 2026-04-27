# This code reproduces Figure 1 of the paper "Local and Anglosphere-Based 
# Geopolitical Risk and Sovereign Stress in the Euro Area" by Francesco Frangiamore 
# and Jamel Saadaoui (2026).

# clear all
rm(list=ls())

load("data.RData")

# take time series of the SovCISS index for the Euro Area
SovCISS <- na.omit(data$SovCISS_EA)

# create time series of the SovCISS
ts_SovCISS <- ts(SovCISS,start = c(2000,9),end = c(2025,4), frequency = 12)

# Plot Figure 1 with the shaded areas as indicated in the note of Figure 1 of the paper
par(mfrow = c(1,1),mar=c(2, 2, 1, 1))
plot(ts_SovCISS, type = "l", col = 0,xlab = "",lwd = 2,xaxs = "i")

# Shaded areas:

# from first threats of Russia-Ukrainian tensions  
rect(
  xleft  = 2021 + 9/12,
  xright = 2025 + 3/12,
  ybottom = par("usr")[3],
  ytop    = par("usr")[4],
  col = rgb(1,0.2,0.2,0.25),
  border = NA
)

# Russian-Ukrainian war + Israeli-Palestinian war
rect(
  xleft  = 2022 + 1/12,
  xright = 2025 + 3/12,
  ybottom = par("usr")[3],
  ytop    = par("usr")[4],
  col = rgb(1,0.2,0.2,0.25),
  border = NA
)

# Global Financial Crisis
rect(
  xleft  = 2007 + 7/12,
  xright = 2009 + 2/12,
  ybottom = par("usr")[3],
  ytop    = par("usr")[4],
  col = rgb(0.7, 0.7, 0.7, 0.3),
  border = NA
)

# Sovereing debt crisis
rect(
  xleft  = 2009 + 9/12,
  xright = 2012 + 6/12,
  ybottom = par("usr")[3],
  ytop    = par("usr")[4],
  col = rgb(0.7, 0.7, 0.7, 0.3),
  border = NA
)

# Covid-19
rect(
  xleft  = 2020 + 1/12,
  xright = 2020 + 6/12,
  ybottom = par("usr")[3],
  ytop    = par("usr")[4],
  col = rgb(0.7, 0.7, 0.7, 0.3),
  border = NA
)

# add line of the time series for the SovCISS
lines(ts_SovCISS,lwd = 2)
