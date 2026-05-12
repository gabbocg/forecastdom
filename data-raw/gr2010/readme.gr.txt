Raffaella Giacomini and Barbara Rossi, "Forecast Comparisons in Unstable
Environments", Journal of Applied Econometrics, Vol. 25, No. 4, 2010, 
pp. 595-620.

There are two zip files. They contain data ASCII files in DOS format as 
well as .m files in Matlab format. The two zip files are:

(1) Empirical.zip (which contains files to replicate the results in the
empirical application of the paper, Section 5), and

(2) MonteCarlo.zip (which contains files to replicate the results in the 
Monte Carlo section of the paper, Section 4). Users should unzip these 
files in either one or two different directories.

All files are in DOS format, so Unix/Linux users should use "unzip -a".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMPIRICAL REPLICATION (inside the Empirical.zip file) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

The main files are the following:

Tables3and4for1973to200410.m replicates the left panel in tables 3 and 4

Tables3and4for1973to200801.m replicates the right panel in tables 3 and 4

PlotFigures.m plots the figures in the paper

These files use the following data:

Taylor rule fundamentals data_updated20080217.txt contains data for 
macroeconomic Taylor rule fundamentals from 1971M1 to 2008M1. Columns 1 
to 12 are exchange rate data for the following countries relative to the 
U.S., respectively: Japan, Canada, Switzerland, UK, France, Germany, 
Italy, Sweden, Australia, Denmark, Netherlands, Portugal. Columns 14:28 
are money data (M1), columns 30-39 are interest rate data, columns 41-53 
are output data and columns 55-67 are annual inflation rates. All data 
are from the IMF's International Financial Statistics database. See 
Molodtsova and Papell (2007) for a detailed description of the data.

Taylor rule fundamentals data.txt contains data for macroeconomic Taylor
rule fundamentals from 1971M1 to 2004M10. 

There are also several functions:

calendar.m creates monthly calendar dates for the database, where the first
column is the year and the second column is the month

calendar_plot.m creates calendar dates that are readable for plotting
pictures

calds2n.m associates at each calendar date a scalar (this function is 
useful for plotting pictures)

cleanNaN.m selects only available observations (discarding NaN's, that is
missing values)

cols.m and rows.m determine the number of columns and rows of a matrix

CW_test_nan1.m calculates the Clark and West's p-value

CW_test_nanJAE.m calculates the Clark and West's statistic

GiacominiRossiCV contains the critical values for the "fluctuation" test
proposed in the paper

media.m calculates column averages of matrices

olsbeta.m calculates ols estimates

Opttest.m the p-value of the one-time test proposed in this paper and the
p-value of the break test on LM2. 

pvcalc.m is a function to calculate p-values for the tests 

pvqlropt.txt contains critical values for the "one time" test proposed in
the paper

pvqlrsb.txt contains critical values for the structural break test (QLR
test) used in the paper

testoos2.m calculates Clark-West's (2005) and the Diebold-Mariano-West's
traditional tests and p-values

testoos3.m calculates Giacomini-Rossi's Fluctuation test with both the 
Clark-West's (2005) and the Diebold-Mariano-West's statistics, and plots 
the Giacomini-Rossi's Fluctuations bands

testoosBREAK.m calculates Giacomini-Rossi's One-time test


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MONTE CARLO REPLICATION (inside the MonteCarlo.zip file) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

runMCnew.m replicates size results; it uses the function MCsize_new.m to
calculate the test statistics

runpower_const.m calculates power for the constant but unequal predictive
ability case, using the function MCpower_const.m and the data in 
MCxdata.txt

runpower_tv.m replicates power results for the break in the relative
performance, using the function MCpower_onetime.m

