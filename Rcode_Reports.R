
#Script R - Processing GreenFeed Data
#Written by Guillermo Martinez Boggio

#Open libraries
library(readr)
library(readxl)
library(dplyr)
library(lubridate)
library(knitr)
library(rmarkdown)


rm(list = ls()) # initialization

#List of experiments with Dates, GF units, and file path 
list_of_experiments <- list(FP700 = list(StartDate = "2024-03-18", 
                                         EndDate = as.character(Sys.Date()), 
                                         Units = list("579" = 43), 
                                         fileEID_path = "~/GreenFeed_UW/Methane/FP700/FP700_EID.csv"),
  
                            FP696 = list(StartDate = "2024-03-11", 
                                         EndDate = as.character(Sys.Date()), 
                                         Units = list("212" = 34), 
                                         fileEID_path = "~/GreenFeed_UW/Methane/FP696/FP696_EID.csv"),
                  
                            HMW677 = list(StartDate = "2024-02-01", 
                                          EndDate = as.character(Sys.Date()), 
                                          Units = list("592" = 43, "593" = 43), 
                                          fileEID_path = "~/GreenFeed_UW/Methane/HMW677/HMW677_EID.csv"))


#Generate report as PDF for each of the experiments specified in the list above:

for (i in 1:length(list_of_experiments)){

  selected_experiment <- names(list_of_experiments)[i]
  Exp_PERIOD <- paste(list_of_experiments[[i]]["StartDate"], list_of_experiments[[i]]["EndDate"], sep = "_")

  UNIT <- names(list_of_experiments[[selected_experiment]][["Units"]])


  #Read cow's ID table included in the experiment
  file_path <- list_of_experiments[[selected_experiment]][["fileEID_path"]]
  if (tolower(tools::file_ext(file_path)) == "csv") {
    CowsInExperiment <- read_table(file_path, col_types = cols(FarmName = col_character(), 
                                                               EID = col_character()))
  
  } else if (tolower(tools::file_ext(file_path)) %in% c("xls", "xlsx")) {
    CowsInExperiment <- read_excel(file_path, col_types = c("text", "text", "numeric", "text"))
  
  } else {
    stop("Unsupported file format.")
  }


  #Open summarized data
  Summarized_Data <- data.frame()
  for (unit in UNIT){
    file_path <- paste0("~/GreenFeed_UW/Methane/", selected_experiment, "/", selected_experiment, "_", unit,".txt")
    data <- read_csv(file_path, skip = 1)
    Summarized_Data <- rbind(Summarized_Data, data)
  }

  ##Remove leading zeros from RFID column
  Summarized_Data$RFID <- gsub("^0+", "", Summarized_Data$RFID)

  ##Summarized data has the gas production data for a long period of time, so you should select the specific period of your experiment
  ##Selecting data only from cows in the current experiment
  Summarized_Data <- Summarized_Data %>%
    
    #Step 1: Retained only those cows in the experiment
    dplyr::inner_join(CowsInExperiment, by = c("RFID" = "EID")) %>%
    dplyr::distinct_at(vars(1:5), .keep_all = TRUE) %>%
    
    ##Change the format of good data duration column: Good Data Duration column to minutes with two decimals
    dplyr::mutate(GoodDataDuration = round(period_to_seconds(hms(as.character(as.POSIXct(GoodDataDuration), format = "%H:%M:%S"))) / 60, 2),
                  HourOfDay = round(period_to_seconds(hms(as.character(as.POSIXct(StartTime), format = "%H:%M:%S"))) / 3600, 2)) %>%
  
    #Step 2: Removing data with Airflow below the threshold (20 l/s)
    dplyr::filter(AirflowLitersPerSec >= 25)

    
  #Create PDF report using Rmarkdown
  render("~/API_GreenFeed/ReportsGF.Rmd", output_file = paste0("~/Downloads/Report_", selected_experiment))

}

