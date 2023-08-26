//    Analyses for Ho/Saadaoui, Asymmetric Money Demand in Viet-Nam

*cd "C:\Users\jamel\Dropbox\stata\vn"		 // Set the directory
do crdata1                                   // creation of database 
do an1                                       // ARDL/NARDL regressions 
do an2                                       // Residuals checks 

do graph1                                    // Plot dyn. mutli. ARDL
do graph2                                    // Plot dyn. mutli. NARDL

do lag_check                                 // Lag order checks

exit
