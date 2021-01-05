import re
import os
import glob
import numpy as np
import logging
from hurry.filesize import size

logfiledir = "/home/ctroupin/Projects/EMODnet/Chemistry4/Logs"
IP_discard_list = ["130.186.16.21"]

# Configure logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logging.info("Starting")

# Regex to get the download info
regex = ' ([(\d\.)]+) - - \[(.*?)\] "GET (.*?)" (\d*) (\d*) "-" "(.*?)"'
#             |               |            |            |           |
#             IP             date         URL          size       browser info

# Loop on month
for month in range(1, 13):
    logger.info("Working on month {}/12".format(month))
    mmonth = str(month).zfill(2)

    # Generate list of files
    filelist = sorted(glob.glob(os.path.join(logfiledir, "http_emodnet01.cineca.it_8081_access.log-2020{}*".format(mmonth))))
    nfiles = len(filelist)
    logger.info("Found {} log files".format(nfiles))

    # Allocate lists
    IPlist = []
    datelist = []
    urllist = []
    sizelist = []
    for logfile in filelist:
        with open(logfile, "r") as f:
            for line in f:
                m = re.match(regex, line)
                if m:
                    IP = m.group(1)
                    # Check if download by bot
                    if "semrush.com" in m.group(6):
                        logger.debug("Semrush Bot")
                    else:
                        # Check if not EMODnet or SeaDataNet IP address
                        if IP not in IP_discard_list:
                            IPlist.append(IP)
                            datelist.append(m.group(2))
                            urllist.append(m.group(3))
                            sizelist.append(int(m.group(5)))

    nIP = np.unique(IPlist)
    sizearray = np.array(sizelist)
    logger.info("Total size for month {}: {}".format(mmonth, size(sizearray.sum())))
