#!/usr/bin/python3

## Script to download data from GreenFeed system using API 
## Written by Guillermo Martinez Boggio 
## July 2024

#Open libraries
from urllib import request
from datetime import date
import os

#Define today's date
today = date.today()

#First Authenticate to receive token (Change here the username and password):
USER = "your_username"
PASS = "your_password"

#Define here the FeederID, start and end date of experiment, and directory to save the files
FID = [

        {'Exp': 'EXP1',
         'Unit': '1',
         'StartDate': '2024-03-11%2012:00:00',
         'EndDate': today.strftime("%Y-%m-%d") + '%2023:59:59',
         'dir': '/Users/EXP1'},

        {'Exp': 'EXP2',
         'Unit': '2',
         'StartDate': '2024-02-01%2012:00:00',
         'EndDate': today.strftime("%Y-%m-%d") + '%2023:59:59',
         'dir': '/Users/EXP2'},

        {'Exp': 'EXP2',
         'Unit': '3',
         'StartDate': '2024-02-01%2012:00:00',
         'EndDate': today.strftime("%Y-%m-%d") + '%2023:59:59',
         'dir': '/Users/EXP2'}

        ]


# Loop to download data for each FID
for idx in range(len(FID)):

        Experiment = FID[idx]['Exp']
        Unit = FID[idx]['Unit']
        StartDate = FID[idx]['StartDate']
        EndDate = FID[idx]['EndDate']
        Dir_path = FID[idx]['dir']

        req = request.urlopen("https://portal.c-lockinc.com/api/login", bytes('user=' + USER + '&pass=' + PASS, 'ascii'))
        TOK = req.read().decode('ascii').strip()

        # Now get data using the login token
        URL = "https://portal.c-lockinc.com/api/getemissions?d=visits&fid=" + Unit + "&st=" + StartDate + "&et=" + EndDate
        req = request.urlopen(URL, bytes('token=' + TOK, 'ascii'))
        data = req.read()

        # Output the data to a file
        name_file = Experiment + '_' + Unit + '.txt'
        with open(os.path.join(Dir_path, name_file), 'w') as file:
                file.write(data.decode("ascii"))

