# This code reproduces Figure 3 of the paper "Local and Anglosphere-Based 
# Geopolitical Risk and Sovereign Stress in the Euro Area" by Francesco Frangiamore 
# and Jamel Saadaoui (2026).

# clear all
rm(list=ls())

# upload data
load("data.RData")

# take GPRs for selected countries and global GPR between 2021 and 2024
GPR_Germany <- data[271:309,6]
GPR_France <- data[271:309,7]
GPR_Belgium <- data[271:309,10]
GPR <- data[271:309,3]

# Plot Figure 3
min_plot <- min(GPR_Germany,GPR_France,GPR_Belgium,GPR)
max_plot <- max(GPR_Germany,GPR_France,GPR_Belgium,GPR)

dates <- data.frame(data[271:309,1],cbind(GPR_Germany,GPR_France,GPR_Belgium,GPR))

par(mfrow = c(1,1),mar=c(2, 2, 1, 1))
plot(GPR, type = "l", col = 0,xlab = "",lwd = 2,xaxs = "i",ylim = c(min_plot,max_plot),xaxt = "n")
axis(1,c(1,7,13,19,25,31,37),c("Jul 2021","Jan 2022","Jul 2022","Jan 2023","Jul 2023","Jan 2024","Jul 2024"))
grid(nx = NA, ny = NULL,
     lty = 2,      # Grid line type
     col = "darkgray", # Grid line color
     lwd = 1)      # Grid line width
abline(v = c(7,13,19,25,31,37),lty = 2, lwd = 1,col = "darkgray")
lines(GPR, lwd = 2)
lines(GPR_Germany, lwd = 2, col = "red",type = "p",pch = 19)
lines(GPR_Germany,lwd = 1.5, col ="red")
lines(GPR_France,lwd = 2, col ="blue", lty = 1)
lines(GPR_Belgium,lwd = 2, col ="darkgreen", lty = 1)
abline(v = c(8),lty = 2, lwd = 2,col = 1)
abline(v = c(28),lty = 2, lwd = 2,col = 1)
legend("topright",legend = c("Global GPR","GPR Germany","GPR France","GPR Belgium"),
       col = c("black","red","blue","darkgreen"),lwd = c(2,2,2,2),lty=c(1,1,1,1),cex = 0.8,pch = c(NA,19,NA,NA))
