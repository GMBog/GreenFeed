# Downloading and processing GreenFeed data from C-Lock

We provide Python, R, and Rmarkdown scripts to download and processing data from multiple GreenFeed systems at once. Also, you have PDF files with all what you need to know when you start to work with GreenFeed at the farm.

Work with daily data from GreenFeed system could be a labor-intensive work if we do not use the tools that we have available. Daily data from GreenFeed (usually) implies multiple visits from multiple cows across the day and across weeks. So, we must have scripts that allow us to download GreenFeed data and process it in a daily basis.

The workflow consist in 2 steps:
1. Download data from C-Lock server through the API.
2. Processing GreenFeed data from each unit and period of time requested, and generate easy-to-read reports (in PDF or HTML)

In this GreenFeed repository, we provide scripts necessary to download and process the GreenFeed data (download_data.R) from multiple units and multiple studies simultaneously. But also, the script in Rmarkdown to generate a daily report from each GreenFeed study (ReportsGF.Rmd).
