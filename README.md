# Scripts to work with GreenFeed and Insentec feeders data

Here you will find scripts to work with:
1. GreenFeed data (C-Lock)
2. Intake files from Insentec system (Hokofarm Group)


## GreenFeed data
We provide Python, R, and Rmarkdown scripts to download and processing data from multiple GreenFeed systems at once. Also, you have PDF files with all what you need to know when you start to work with GreenFeed at the farm.

Work with daily data from GreenFeed system could be a labor-intensive work if we do not use the tools that we have available. Daily data from GreenFeed (usually) implies multiple visits from multiple cows across the day and across weeks. So, we must have scripts that allow us to download GreenFeed data and process it in a daily basis.

The workflow consist in 2 steps:
1. Download data from C-Lock server through the API.
2. Processing GreenFeed data from each unit and period of time requested, and generate easy-to-read reports (in PDF or HTML)

In this GreenFeed repository, we provide scripts necessary to download and process the GreenFeed data (download_data.R) from multiple units and multiple studies simultaneously. But also, the script in Rmarkdown to generate a daily report from each GreenFeed study (ReportsGF.Rmd).


## Feed Intake data
We provide an R script to process the VRfiles from Insentec system.
 
Once you have the VRfile.dat from the system, you can use macro_intakes.R to process the file and get as a output: 
 - Daily Excel file with the processed intakes
 - Compiled Excel file with the intake data

Also, there is a script (AP_intakes.R) to process the intakes from GreenFeed. The output is a file with the daily intakes in grams per animal ID.
