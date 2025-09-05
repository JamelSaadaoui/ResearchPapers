**# Replicaction package for 
* "Real exchange rate and international reserves in the era of financial integration"

capture log close _all                                
log using RERTOT_JIMF_VIMM.smcl, name(RERTOT_JIMF_VIMM) smcl replace

use datafintransformed-22-11-17, clear

**# Fig. 2. 3-D plot for the buffer effect.

**One lag for reserves + Balanced panel**
areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres yr* ///
if count_lgovexp==20, ///
absorb(cn) vce(bootstrap, reps(200))

// Create predictions for the interaction and store them
margins, at( L1lres=(1(0.1)5) etot=(1(0.1)5))

matrix predictions =r(at) , r(b)'

clear

svmat predictions, names(col)

rename r1 pred_lreer

save contour-plot-08-19-yr-effects, replace

// Use python to plot the 3-D figure

python search

*cmd then, "C:\Users\jamel\AppData\Local\Programs\Python\Python313\python.exe" -m pip install matplotlib

clear

python:

import pandas as pd
data = pd.read_stata("contour-plot-08-19-yr-effects.dta")
data[['etot','L1lres','pred_lreer']]

end

// Create the three-dimensional surface plot with Python
// Install matplotlib with conda (cmd)
python:
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # Needed for 3D plots

# Load the Stata dataset
data = pd.read_stata("contour-plot-08-19-yr-effects.dta")

# Create a new 3D figure
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# Plot the 3D surface using triangular surface interpolation
ax.plot_trisurf(
    data['etot'],
    data['L1lres'],
    data['pred_lreer'],
    cmap=plt.cm.Spectral_r
)

# Set axis ticks
ax.set_xticks(np.arange(1, 5, step=1))
ax.set_yticks(np.arange(1, 5, step=1))
ax.set_zticks(np.arange(4.42, 4.62, step=0.04))

# Set title and axis labels (only once!)
ax.set_title("Buffer Effect")
ax.set_xlabel("Log of effective terms of trade")
ax.set_ylabel("Log of lagged reserves")
ax.zaxis.set_rotate_label(False)
ax.set_zlabel("Predicted REER", rotation=90)

# Set the view angle (elevation and azimuth)
ax.view_init(elev=30, azim=75)

# Save the figure in high resolution
plt.savefig("Margins3d.png", dpi=1200)
# plt.savefig("Margins3d.pdf", dpi=1200)

# Close the plot to prevent duplicate displays
plt.close()
end

**# Fig. B.2. Panel LP for the buffer effect on the RER.

use datafintransformed-22-11-17, clear

// Set scheme 

set scheme Cleanplots

*ssc install locproj

locproj lreer etot L1lres (c.etot#c.L1lres) l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr if count_lgovexp==20, fe ///
 z robust irfn(A) save noisily stats ///
 lcs((c.etot#c.L1lres)) title(`"lcs((c.etot#c.L1lres))"')

graph rename Graph ivfi_lcs, replace
 
locproj lreer etot L1lres (c.etot#c.L1lres) l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr if count_lgovexp==20, fe ///
 z robust irfn(B) save noisily stats ///
 lcs(etot+(c.etot#c.L1lres)) title(`"lcs(etot+(c.etot#c.L1lres))"')
 
graph rename Graph ivfi_lcs1, replace
 
locproj lreer etot L1lres (c.etot#c.L1lres) l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr if count_lgovexp==20, fe ///
 z robust irfn(C) save noisily stats ///
 lcs(L1lres+(c.etot#c.L1lres)) title(`"lcs(L1lres+(c.etot#c.L1lres))"')
 
graph rename Graph ivfi_lcs2, replace

graph close ivfi_lcs*
 
lpgraph A B C, h(0/5) tti(Horizon) ///
 lab1(`"lcs((c.etot#c.L1lres))"') ///
 lab2(`"lcs(etot+(c.etot#c.L1lres))"') ///
 lab3(`"lcs(L1lres+(c.etot#c.L1lres))"') ///
 lc1(red) lc2(green) lc3(blue) ///
 title(Panel LP for the buffer effect on the RER, ///
 size(3)) separate ///
 zero grname(B2) grsave(B2) as(png)


**# Fig. B.3. Panel LP for the buffer effect on the RER.

reg d.lres lreer cny* if count_lgovexp==20, robust 
capture drop residuals_lres
predict residuals_lres, residuals

reg d.etot lreer cny* if count_lgovexp==20, robust
capture drop residuals_etot
predict residuals_etot, residuals

locproj lreer (c.residuals_etot#c.residuals_lres) ///
 if count_lgovexp==20, ///
 c(l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr) ///
 z h(4) yl(1) sl(1) fe cluster(cn) conf(90 95) ///
 title(`"Full sample"') tti("Horizon") ///
 save irfname(full) noisily stats
 
graph rename Graph fullfi, replace

locproj lreer (c.residuals_etot#c.residuals_lres) if l2.fi<0.48 ///
 & count_lgovexp==20, ///
 c(l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr) ///
 z h(4) yl(1) sl(1) fe cluster(cn) conf(90 95) ///
 title(`"Below the threshold for FI"') tti("Horizon")  ///
 save irfname(below) noisily stats
 
graph rename Graph belowfi, replace 

locproj lreer (c.residuals_etot#c.residuals_lres) if l2.fi>=0.48 ///
 & count_lgovexp==20, ///
 c(l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr) ///
 z h(4) yl(1) sl(1) fe cluster(cn) conf(90 95) ///
 title(`"Above the threshold for FI"') tti("Horizon")  ///
 save irfname(above) noisily stats
 
graph rename Graph abovefi, replace 

graph close fullfi belowfi abovefi

graph combine fullfi belowfi abovefi, row(1) ///
 title(`"Panel LP for the Buffer Effect on the RER"', size(4)) ///
 subtitle(`"Term-of-trade shock"' ///
 `"(shock on c.residuals_etot#c.residuals_lres)"', size(3)) ///
 name(B3, replace)
 
graph export "PANEL_LP_RES.png", as(png) name("B3") replace
 
log close _all
exit

**# End of Program