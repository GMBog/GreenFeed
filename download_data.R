
## Script to download data from GreenFeed system using API 
## Written by Guillermo Martinez Boggio 
## July 2024

#Open libraries
library(readr)
library(readxl)
library(dplyr)
library(lubridate)
library(knitr)
library(rmarkdown)
library(httr)
library(stringr)

rm(list = ls()) # initialization 

#Change to login: USER & PASSWORD
USER <- "your_username"     #Change to your login
PASS <- "your_password"     #Change to your password

#List of studies
FID <- list(
  list(
    Exp = "ADSA2024",          #Set the name of your study
    Unit = "579",              #Define the units (if multiples define as: "579,580")
    StartDate = "2023-12-04",  #Define the start date for period request
    EndDate = "2024-01-11",    #Define the end date for period request
    dir = "~/ADSA2024/",       #Set the directory to save your data
    EIDdir = "~/ADSA2024/ADSA2024_EID.csv")  #Specify the file with the animals ID in your study (useful to remove no animal ID and errors)
)

#Loop to download data for each study in your list of studies
for (i in seq(FID)){

  #STEP 1: DOWNLOAD DATA
  
  #First Authenticate to receive token:
  req <- POST("https://portal.c-lockinc.com/api/login", body=list(user=USER, pass=PASS))
  stop_for_status(req)
  TOK <- trimws(content(req))
  print(TOK)
  
  #Now get data using the login token
  URL <- paste0("https://portal.c-lockinc.com/api/getemissions?d=visits&fids=", FID[[i]]$Unit, "&st=", FID[[i]]$StartDate, "&et=", FID[[i]]$EndDate, "%2012:00:00")
  print(URL)
  
  #Replace with your Request URL
  req <- POST(URL, body=list(token=TOK))
  stop_for_status(req)
  a <- content(req)
  print(a)
  
  #Split the lines
  perline <- str_split(a, "\\n")[[1]]
  print(perline)
  
  #Split the commas into a dataframe, while getting rid of the "Parameters" line and the headers line
  df <- do.call("rbind", str_split(perline[3:length(perline)], ","))
  df <- as.data.frame(df)
  colnames(df) <- c('FeederID', 'AnimalName', 'RFID', 'StartTime', 'EndTime', 'GoodDataDuration', 
                   'CO2GramsPerDay', 'CH4GramsPerDay', 'O2GramsPerDay', 'H2GramsPerDay', 'H2SGramsPerDay', 
                   'AirflowLitersPerSec', 'AirflowCf', 'WindSpeedMetersPerSec', 'WindDirDeg', 'WindCf', 
                   'WasInterrupted', 'InterruptingTags', 'TempPipeDegreesCelsius', 'IsPreliminary','RunTime')
  
  #Data should be save as .csv to avoid formatting issues
  name_file <- paste0(FID[[i]]$dir, FID[[i]]$Exp, "_GFdata.csv")
  write_excel_csv(df, file = name_file)

  
  #STEP 2: GENERATE DAILY REPORT FROM DATA
  
  #Generate report as PDF for each of the experiments specified in the list above:
  selected_experiment <- FID[[i]]$Exp
  
  #Read cow's ID table included in the experiment
  file_path <- FID[[i]]$EIDdir
  if (tolower(tools::file_ext(file_path)) == "csv") {
    CowsInExperiment <- read_table(file_path, col_types = cols(FarmName = col_character(), EID = col_character()))
    
  } else if (tolower(tools::file_ext(file_path)) %in% c("xls", "xlsx")) {
    CowsInExperiment <- read_excel(file_path, col_types = c("text", "text", "numeric", "text"))
    
  } else {
    stop("Unsupported file format.")
  }
  
  
  ##Remove leading zeros from RFID column
  df$RFID <- gsub("^0+", "", df$RFID)
  
  ##Summarized data has the gas production data for a long period of time, so you should select the specific period of your experiment
  ##Selecting data only from cows in the current experiment
  df <- df %>%
    
    dplyr::filter(EndTime < as.POSIXct(paste(FID[[i]]$EndDate, "00:00:00"), tz = "UTC")) %>%
    
    #Step 1: Retained only those cows in the experiment
    dplyr::inner_join(CowsInExperiment, by = c("RFID" = "EID")) %>%
    dplyr::distinct_at(vars(1:5), .keep_all = TRUE) %>%
    
    ##Change the format of good data duration column: Good Data Duration column to minutes with two decimals
    dplyr::mutate(GoodDataDuration = round(period_to_seconds(hms(GoodDataDuration)) / 60, 2),
                  HourOfDay = round(period_to_seconds(hms(format(as.POSIXct(StartTime), "%H:%M:%S"))) / 3600, 2)) %>%
    
    #Step 2: Removing data with Airflow below the threshold (20 l/s)
    dplyr::filter(AirflowLitersPerSec >= 25)
  
  
  cows_missing <- anti_join(CowsInExperiment, df, by = c("EID" = "RFID"))
  
  CowsInExperiment <- CowsInExperiment %>%
    dplyr::mutate(Actual_DIM = DIM + floor(as.numeric(difftime(max(df$StartTime), min(as.Date(df$StartTime)), units = "days") + 1)),
                  MeP = ifelse(EID %in% cows_missing$EID, "No", "Yes")) %>%
    dplyr::relocate(Actual_DIM, MeP, .after = DIM) %>%
    dplyr::arrange(desc(Actual_DIM))
  
  
  #Create PDF report using Rmarkdown (Define here the name and folde to save your daily report)
  render("~/ADSA2024/ReportsGF.Rmd", output_file = paste0("~/Downloads/Report_", FID[[i]]$Exp))
  
}

