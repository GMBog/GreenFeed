#Processing daily data from GreenFeed

Here we provide Python, R, and Rmarkdown scripts to processing daily data from multiple GreenFeed systems at once.

Work with daily data from GreenFeed system could be a labor-intensive work if we do not use the tools that we have available. Daily data from GreenFeed (usually) implies multiple visits from multiple cows across the day and across the days. So, we should have scripts that allow us to download the data and process it in a daily basis.

Basically the process includes:
1. Download data from C-Lock server through the API.
2. Processing GreenFeed data from each unit and period of time requested.
3. Generate easy-to-read reports (in PDF)

So, we provide in this repository the codes necessary to download and process the data from multiple units and multiple studies simultaneously.

