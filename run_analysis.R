# #########################################################################
#
# Script: run_analysis.R
# -------------------------------------------------------------------------
#
# Purpose: course assignment for Getting and Cleaning Data
# Date: 25 Apr 2015
#
# Steps to run:
# 1.) place this script in the same directory as the input data files
#     note: the code will attempt to fetch the data files if needed
# 2.) set your R environment's working directory to this same directory
# 3.) load and then run this script
# #########################################################################

# *************************************************************************
# Step 1) SET UP THE ENVIRONMENT
# *************************************************************************
#library("plyr")
library("utils")
library("dplyr")


# ----------------------------------------------------------------
# inputfilename function establishes the right path to find the
# input file.  Its purpose is to suppor the possibility that the
# user has unzip all the input files and placed them, as a group,
# in the current working directory
# ----------------------------------------------------------------
inputfilename <- function(sdir, filename, dataset) {
  if (sdir == ".") {
    infilename <- paste(sdir, filename, sep = "/")
  } else {
    infilename <- paste(sdir, dataset, filename, sep="/")
  }
  infilename 
}

sourcehtml <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
sourcezip <- "getdata-projectfiles-UCI HAR Dataset.zip"
sourcedir <- "UCI HAR Dataset"


# establish a matrix of needed work files extracted from the zipped data
workfiles <- c("features.txt", "X_train.txt", "Y_train.txt", "subject_train.txt", "Y_test.txt", "X_test.txt", "subject_test.txt")

# -------------------------------------------------------------------------
# check that the appropriate data files exists
# working our way backwards to finally fetching the source zip if needed
# -------------------------------------------------------------------------
fetchfiles <- FALSE
# loop through the list of input files and see if they already exists in
# this directory, which means the user has extracted the needed files
# individually from the source zip and placed them in this directory
for (i in 1:length(workfiles)){
  if (!file.exists(workfiles[i])){
    fetchfiles <- TRUE
    break
  }
}

# if they don't exists then does the unzipped source directory exist
# and, if that doesn't exist, then see if the source zip is there
# if not then see if we can download the source zip
if (fetchfiles){
  if (!file.exists(sourcedir)){
    if (!file.exists(sourcezip)){
      print("attempting to download the source data from the web...")
      download.file(sourcehtml, destfile = sourcezip)
      if (!file.exists(sourcezip)){
        stop("Data does not exists locally and an attempt to download from the web failed...")
      }
      unzip(sourcezip)
    }
  }
} else {sourcedir = "."} #all files are local to script so set the source directory to here...

# Stop the script if the data still isn't available
if (!file.exists(sourcedir)){
  stop(paste("The source data files are missing and an attempt to download them failed."))
}


# *************************************************************************
#  Step 2) READ IN THE COLUMN NAMES FOR BOTH DATA SETS
# *************************************************************************
# -----------------------------------------------
# read in the meaningful variable names for the test data
# -----------------------------------------------
tcolnames <- read.table(paste(sourcedir,"features.txt", sep="/"))

# *************************************************************************
#  Step 3) READ IN THE TRAINING DATA SET
# *************************************************************************
# -----------------------------------------------
# read the training data into a data frame based
# on the location of the data files
# -----------------------------------------------
train <- read.table(inputfilename(sourcedir,"X_train.txt", "train")) 

# -----------------------------------------------
# assign the meaningful variable names to the training data set
# -----------------------------------------------
colnames(train) <- tcolnames[,2]

# -----------------------------------------------
# now get the training activities
# -----------------------------------------------
train_acts <- read.table(inputfilename(sourcedir,"y_train.txt", "train"))


# -----------------------------------------------
# assign the activity column a understandable name
# -----------------------------------------------
colnames(train_acts) <- c("ActivityCode")

# -----------------------------------------------
# now bind the activity column as the first column in the data set
# -----------------------------------------------
train <- cbind(train_acts,train)

# -----------------------------------------------
# now get the subject list for each test
# -----------------------------------------------
train_subs <- read.table(inputfilename(sourcedir,"subject_train.txt", "train"))

# -----------------------------------------------
# now assign a meaningful name to the subjects column
# -----------------------------------------------
colnames(train_subs) = c("SubjectCode")

# -----------------------------------------------
# now bind the subjects column as the new first column in the data set
# -----------------------------------------------
train <- cbind(train_subs,train)

# -----------------------------------------------
# create a blank matrix with the same row count as test
# -----------------------------------------------
tmatrix2 <- matrix(c("Train"),nrow = nrow(train), ncol=1)

# -----------------------------------------------
# now bind the test/train indicator column as the new first column in the data set
# -----------------------------------------------
train <- cbind(tmatrix2, train)
colnames(train)[1] = "DatasetIndicator"

# *************************************************************************
#  Step 4) READ IN THE TEST DATA SET
# *************************************************************************
# -----------------------------------------------
# read the test data into a data frame
# -----------------------------------------------
test <- read.table(inputfilename(sourcedir,"X_test.txt", "test"))
#str(test) # one can check the results if desired

# -----------------------------------------------
# assign the meaningful variable names to the test data set
# -----------------------------------------------
colnames(test) <- tcolnames[,2]

# -----------------------------------------------
# now get the test activities
# -----------------------------------------------
test_acts <- read.table(inputfilename(sourcedir,"y_test.txt", "test"))

# -----------------------------------------------
# assign the activity column a understandable name
# -----------------------------------------------
colnames(test_acts) <- c("ActivityCode")

# -----------------------------------------------
# now bind the activity column as the first column in the data set
# -----------------------------------------------
test <- cbind(test_acts,test)

# -----------------------------------------------
# now get the subject list for each test
# -----------------------------------------------
test_subs <- read.table(inputfilename(sourcedir,"subject_test.txt", "test"))

# -----------------------------------------------
# now assign a meaningful name to the subjects column
# -----------------------------------------------
colnames(test_subs) = c("SubjectCode")

# -----------------------------------------------
# now bind the subjects column as the new first column in the data set
# -----------------------------------------------
test <- cbind(test_subs,test)

# -----------------------------------------------
# create a blank matrix with the same row count as test
# -----------------------------------------------
tmatrix <- matrix(c("Test"),nrow = nrow(test), ncol=1)

# -----------------------------------------------
# now bind the test/train indicator column as the new first column in the data set
# -----------------------------------------------
test <- cbind(tmatrix, test)
colnames(test)[1] = "DatasetIndicator"

# *************************************************************************
#  Step 5) DETERMINE THE LIST OF MEAN() & STD() COLUMNS
# *************************************************************************
# note that one could run grepl against either the test or train data frames 
# as they have the same column names, this script uses the test data frame

msnames = matrix(names(test))

# now determine the index values for the subset of column names
# 
cmatrix <- which(grepl(c("std()|mean()"), colnames(test)) & !grepl(c("Freq"), colnames(test)))

# include the first three columns: DatasetIndicator, SubjectCode, activity code along with the other column index values
cmatrix <- c(1,2,3,cmatrix)

# create a subset of the test and train datasets containing just these targeted columns
subtest <- test[,cmatrix]
subtrain <- train[,cmatrix]

# *************************************************************************
#  Step 6) COMBINE BOTH THE TRAINING AND TEST DATA SETS INTO A COMMON DATA SET
# *************************************************************************
results <- rbind(subtrain,subtest)

# Clean up the variable names by removing dashes and parathesis
names(results) <- gsub("-","",names(results))
names(results) <- gsub("\\()","",names(results))

# Now to facilitate a camel case variable naming approach, capitalize any
# instances of either 'mean' or 'std' in a variable name
names(results) <- gsub("mean","Mean",names(results))
names(results) <- gsub("std","Std",names(results))


# *************************************************************************
#  Step 7) ASSIGN APPROPRIATE ACTIVITY LABELS IN THE ACTIVITY COLUMN
# *************************************************************************
# Add an Activity column as column #4 in the results data set
# the following code then populates that column with the name of the
# activity associated with the orginal data's activity code value
# through a simple set of data frame filters and column value assignments

# -----------------------------------------------
# Add an Activity column to go with the activity code
# by creating a blank matrix with the same row count as results
# -----------------------------------------------
actmatrix <- matrix(c(" "),nrow = nrow(results), ncol=1)
actmatrix <- as.character(actmatrix)

results <- cbind(results[,c(1,2,3)], actmatrix, results[,4:69])
colnames(results)[4] <- "Activity"
results$Activity <- as.character(results$Activity)

# -----------------------------------------------
# now populate the Activity column
# -----------------------------------------------
results[results$ActivityCode==1,][,4] <- "Walking"
results[results$ActivityCode==2,][,4] <- "Walking Upstairs"
results[results$ActivityCode==3,][,4] <- "Walking Downstairs"
results[results$ActivityCode==4,][,4] <- "Sitting"
results[results$ActivityCode==5,][,4] <- "Standing"
results[results$ActivityCode==6,][,4] <- "Laying"


# *************************************************************************
#  Step 8) FINAL STEP, CREATE THE TIDY DATA FILE
# *************************************************************************
# Use the dplyr group_by and summarise_each to find the mean of each of the
# factor columns grouping by subject and then activity
# this will produce a wide, rather than long, tidy data set
sum1 <- tbl_df(select(results,SubjectCode,Activity,5:70)) %>%
group_by(SubjectCode, Activity) %>%
summarise_each(funs(mean), -SubjectCode, -Activity)

# now write the result to a text file per requirement number 5
write.table(sum1, "./tidydata.txt", row.name=FALSE)
