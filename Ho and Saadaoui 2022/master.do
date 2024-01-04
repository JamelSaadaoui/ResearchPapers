//  Analyses for Ho/Saadaoui 
//  Bank Credit Threshold in Growth in ASEAN

cls
clear

// Set the directory
// Open the file in your own folder
*cd C:\Users\jamel\Dropbox\stata\gcasean	 

// Import database 
do database_import
                           
// Threshold regressions 
do endo_thresh
               
// Causality tests 
do causality  
                               
// Put results in Excel
do results_putexcel                          

save final_dataset.dta, replace

exit
