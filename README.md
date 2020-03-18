# Matlab_Wrap_for_JHU_COVID19

This repository contains a very simple Matlab wrapper for Johns Hopkins University's COVID-19 data set.

At present, it doesn't do much -- it just loads the data into Matlab and allows the user to plot the infections and deaths versus time for all countries or a selected subset of contries.

It also allows for you to plot a simple trend lines based on the past 'N' days.  

It also computes doubling time from last N days and displays in a table and as a histogram.

To use the wrapper, you first need to clone the JHU repository at: https://github.com/CSSEGISandData/COVID-19

To run from the Matlab command window, just navigate to the correct folder and type: "COVID19_Matlab_App". If you place both this and the JHU repositories in a common folder, it should run directly.  Otherwise, you will be prompted to find the appropriate data.  These are found in the folder "COVID-19/COVID-19/csse_covid_19_data/csse_covid_19_time_series/".

Please let me know if you would like to see any added functionality. 
