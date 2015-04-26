# READ ME
## Getting and Cleaning Data: Course Assignment - run_analysis.R
The repository contains R programming code in the file run_analysis.R for the course Getting and Cleaning Data, part of the John Hopkins Data Scientist Toolbox curriculum.  The R code processes data captured in a University of Michigan motion study discussed here: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

The data files are sourced from here: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.

### The code can be run by: 
1. copying the **run_analysis.R** file into your local R environment that supports the latest version of the **dplyr** package; that is version 0.4.1 as of this writing (0.4.0 will likely work as well).  

2. Either: allowing the script to download the aforementioned zip data file and process it within the directory containing the run_analysis.R code **OR** placing a copy of the aforementioned zip file into this same working directory **OR** extracting the UCI HAR Dataset directory from the zip file and placing in this working directory **OR**, as a final option extracting these six text files from the zip and placing them in this same working directory: "features.txt", "X_train.txt", "Y_train.txt", "subject_train.txt", "Y_test.txt", "X_test.txt", "subject_test.txt".
**NOTE:** the download and unzip functionality has only be tested on a Windows (8.1) based R environment. As such the curlz option was not used, as it can break in Windows environments, and this omission may cause issues for non-Windows environments.

### Output Produced
The script produces a single output file: **tidydata.txt**.  This file can be read back into R using the **read.table()** function or optionally opened with a text editor, such as Notepad++.

### Code Book
The [code book](https://github.com/rogerthatdata/getdata-assignment/blob/master/Code%20Book.md) describing the output can be found within this repository. 

### Design Considerations
1. The resulting tidy data file is wide rather than tall.  
2. The value names for each column are in camel case for readability purposes; this approach was based upon a good class discussion and advance given by Community TA David Hood (who's provided awesome advice and insights) and can be referenced [here](https://class.coursera.org/getdata-013/forum/thread?thread_id=154#comment-467). 
3. The minimal number of measure columns related to mean or standard deviation were selected for the tidy data output. Thus columns that referenced measures such as mean frequency were not included.  Again, this design decision was based on insights from course discussion forum with some thoughts by David Hood that can be referenced [here](https://class.coursera.org/getdata-013/forum/thread?thread_id=147#comment-357). 
