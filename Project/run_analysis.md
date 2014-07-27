run_analysis
============
Last updated 2014-07-27 18:04:23 using R version 3.1.0 (2014-04-10).


1. Project Background and Instructions
--------------------------------------
>The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called `CodeBook.md`*. You should also include a `README.md` in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

>One of the most exciting areas in all of data science right now is wearable computing - see for example this article. Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 

>A full description is available at the site where the data was obtained: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

>Here are the data for the project:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

>You should create one R script called `run_analysis.R` that does the following:

>1. Merges the training and the test sets to create one data set.
1. Extracts only the measurements on the mean and standard deviation for each measurement.
1. Uses descriptive activity names to name the activities in the data set.
1. Appropriately labels the data set with descriptive activity names.
1. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

**\* The codebook is created below at the end of this document.**

2. Setup and Configuration
--------------------------
**Load required packages.**

```r
packages <- c("data.table", "markdown", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
```

```
## data.table   markdown   reshape2 
##       TRUE       TRUE       TRUE
```

**Set path to be current working directory.**

```r
path <- getwd()
path
```

```
## [1] "C:/Users/Achilles/Documents/Education/MOOC/JHUDataScience/03 - Getting and Cleaning Data course/Project"
```

3. UCI HAR DataSet Retrieval
----------------------------
**Download the dataset file.** (***Last downloaded: 27 Jul 2014.  Default evaluation is set to false to save time.***)

```r
dataSetUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- "UciHarDataset.zip"

if (!file.exists(path)) { dir.create(path) }

download.file(dataSetUrl, file.path(path, fileName))
```

**Unzip the dataset file.** (***Last unzipped: 27 Jul 2014.  Default evaluation is set to false to save time.***)

```r
## Unzip the UCI activity data.
# if (!file.exists(file.path(path, fileName)))
#      message("ERROR: UCI HAR zipped data file could not be found!")
# else
     unzip(file.path(path, fileName)) # Unzips to new "UCI HAR Dataset" directory.
```

**Set unzipped `UCI HAR Dataset` directory as input path and list its files.**

```r
inputPath <- file.path(path, "UCI HAR Dataset")
list.files(inputPath, recursive=TRUE)
```

```
##  [1] "activity_labels.txt"                         
##  [2] "features.txt"                                
##  [3] "features_info.txt"                           
##  [4] "README.txt"                                  
##  [5] "test/Inertial Signals/body_acc_x_test.txt"   
##  [6] "test/Inertial Signals/body_acc_y_test.txt"   
##  [7] "test/Inertial Signals/body_acc_z_test.txt"   
##  [8] "test/Inertial Signals/body_gyro_x_test.txt"  
##  [9] "test/Inertial Signals/body_gyro_y_test.txt"  
## [10] "test/Inertial Signals/body_gyro_z_test.txt"  
## [11] "test/Inertial Signals/total_acc_x_test.txt"  
## [12] "test/Inertial Signals/total_acc_y_test.txt"  
## [13] "test/Inertial Signals/total_acc_z_test.txt"  
## [14] "test/subject_test.txt"                       
## [15] "test/X_test.txt"                             
## [16] "test/y_test.txt"                             
## [17] "train/Inertial Signals/body_acc_x_train.txt" 
## [18] "train/Inertial Signals/body_acc_y_train.txt" 
## [19] "train/Inertial Signals/body_acc_z_train.txt" 
## [20] "train/Inertial Signals/body_gyro_x_train.txt"
## [21] "train/Inertial Signals/body_gyro_y_train.txt"
## [22] "train/Inertial Signals/body_gyro_z_train.txt"
## [23] "train/Inertial Signals/total_acc_x_train.txt"
## [24] "train/Inertial Signals/total_acc_y_train.txt"
## [25] "train/Inertial Signals/total_acc_z_train.txt"
## [26] "train/subject_train.txt"                     
## [27] "train/X_train.txt"                           
## [28] "train/y_train.txt"
```

\* *For detailed dataset information, view the `README.txt` file in "C:/Users/Achilles/Documents/Education/MOOC/JHUDataScience/03 - Getting and Cleaning Data course/Project/UCI HAR Dataset".*

4. File Data Loading
--------------------
**Read the subject training and test data files.**

```r
subjectTrainDataTable <- fread(file.path(inputPath, "train", "subject_train.txt"))
subjectTestDataTable <- fread(file.path(inputPath, "test" , "subject_test.txt" ))
```

**Read the activity training and test data files.**

```r
activityTrainDataTable <- fread(file.path(inputPath, "train", "Y_train.txt"))
activityTestDataTable <- fread(file.path(inputPath, "test" , "Y_test.txt" ))
```

**Read the data files.***

```r
## Func. 'fread' fails on the lines below with known bug when dealing with empty 1st
## column entries: "Not positioned correctly after testing format of header row.".
# trainDataTable <- fread(file.path(inputPath, "train", "X_train.txt"))
# testDataTable <- fread(file.path(inputPath, "test" , "X_test.txt" ))

# Function to convert from file -> data frame -> data table.
convertFileToDataTable <- function (file) { dataTable <- data.table(read.table(file)) }

trainDataTable <- convertFileToDataTable(file.path(inputPath, "train", "X_train.txt"))
testDataTable <- convertFileToDataTable(file.path(inputPath, "test" , "X_test.txt" ))
```

\* *NOTE: Current version of `fread` doesn't like empty values in first column, so I used a
different (fairly time-consuming) technique (file->data frame->data table) for loading train and test data above.*

5. Training and Test DataSet Merge
----------------------------------
**Merge the data tables.**

```r
subjectDataTable <- rbind(subjectTrainDataTable, subjectTestDataTable)
setnames(subjectDataTable, "V1", "subject")
activityDataTable <- rbind(activityTrainDataTable, activityTestDataTable)
setnames(activityDataTable, "V1", "activityNum")
dataDataTable <- rbind(trainDataTable, testDataTable)
```

**Merge data table columns.**

```r
subjectDataTable <- cbind(subjectDataTable, activityDataTable)
dataDataTable <- cbind(subjectDataTable, dataDataTable)
```

**Set data table key.**

```r
setkey(dataDataTable, subject, activityNum)
```

6. Mean and Standard Deviation Extraction
-----------------------------------------
**Read the `features.txt` file to determine which `dataDataTable` variables are measurements for the mean and standard deviation.**

```r
dataDataTableFeatures <- fread(file.path(inputPath, "features.txt"))

setnames(dataDataTableFeatures, 
         names(dataDataTableFeatures), 
         c("featureNum", "featureName"))
```

**Subset the mean and standard deviation measurements.**

```r
dataDataTableFeatures <- dataDataTableFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
```

**Convert the column numbers to match columns in `dataDataTable`.**

```r
dataDataTableFeatures$featureCode <- dataDataTableFeatures[, paste0("V", featureNum)]
head(dataDataTableFeatures)
```

```
##    featureNum       featureName featureCode
## 1:          1 tBodyAcc-mean()-X          V1
## 2:          2 tBodyAcc-mean()-Y          V2
## 3:          3 tBodyAcc-mean()-Z          V3
## 4:          4  tBodyAcc-std()-X          V4
## 5:          5  tBodyAcc-std()-Y          V5
## 6:          6  tBodyAcc-std()-Z          V6
```

```r
dataDataTableFeatures$featureCode
```

```
##  [1] "V1"   "V2"   "V3"   "V4"   "V5"   "V6"   "V41"  "V42"  "V43"  "V44" 
## [11] "V45"  "V46"  "V81"  "V82"  "V83"  "V84"  "V85"  "V86"  "V121" "V122"
## [21] "V123" "V124" "V125" "V126" "V161" "V162" "V163" "V164" "V165" "V166"
## [31] "V201" "V202" "V214" "V215" "V227" "V228" "V240" "V241" "V253" "V254"
## [41] "V266" "V267" "V268" "V269" "V270" "V271" "V345" "V346" "V347" "V348"
## [51] "V349" "V350" "V424" "V425" "V426" "V427" "V428" "V429" "V503" "V504"
## [61] "V516" "V517" "V529" "V530" "V542" "V543"
```

**Subset variables by variable names.**

```r
selectedVariables <- c(key(dataDataTable), dataDataTableFeatures$featureCode)
dataDataTable <- dataDataTable[, selectedVariables, with=FALSE]
```

7. Descriptive Activity Name Labeling
-------------------------------------
**Read `activity_labels.txt` file to add descriptive names to the activities.**

```r
dataDataTableActivityNames <- fread(file.path(inputPath, "activity_labels.txt"))

setnames(dataDataTableActivityNames, 
         names(dataDataTableActivityNames), 
         c("activityNum", "activityName"))
```

**Merge activity labels.**

```r
dataDataTable <- merge(dataDataTable, 
                       dataDataTableActivityNames, 
                       by="activityNum", 
                       all.x=TRUE)
```

**Make `activityName` the data table key.**

```r
setkey(dataDataTable, subject, activityNum, activityName)
```

**Reshape data table to tall and narrow format for easier reading.**

```r
dataDataTable <- data.table(melt(dataDataTable, 
                                 key(dataDataTable), 
                                 variable.name="featureCode"))
```

**Merge activity name into data table.**

```r
dataDataTable <- merge(dataDataTable, 
                       dataDataTableFeatures[, list(featureNum, featureCode, featureName)],
                       by="featureCode", 
                       all.x=TRUE)
```

**Create new variables `activity` (==`activityName`) and `feature` (==`featureName`).**

```r
dataDataTable$activity <- factor(dataDataTable$activityName)
dataDataTable$feature <- factor(dataDataTable$featureName)
```

**Separate features from `featureName` using custom `grepTerm` function.**

```r
grepTerm <- function (regex) { grepl(regex, dataDataTable$feature) }

## Features with 1 category:
dataDataTable$featJerk <- factor(grepTerm("Jerk"), 
                                 labels=c(NA, "Jerk"))

dataDataTable$featMagnitude <- factor(grepTerm("Mag"), 
                                      labels=c(NA, "Magnitude"))

## Features with 2 categories:
n <- 2
y <- matrix(seq(1, n), nrow=n)

x <- matrix(c(grepTerm("^t"), grepTerm("^f")), ncol=nrow(y))
dataDataTable$featDomain <- factor(x %*% y, 
                                   labels=c("Time", "Freq"))

x <- matrix(c(grepTerm("Acc"), grepTerm("Gyro")), ncol=nrow(y))
dataDataTable$featInstrument <- factor(x %*% y, 
                                       labels=c("Accelerometer", "Gyroscope"))

x <- matrix(c(grepTerm("BodyAcc"), grepTerm("GravityAcc")), ncol=nrow(y))
dataDataTable$featAcceleration <- factor(x %*% y, 
                                         labels=c(NA, "Body", "Gravity"))

x <- matrix(c(grepTerm("mean()"), grepTerm("std()")), ncol=nrow(y))
dataDataTable$featVariable <- factor(x %*% y, 
                                     labels=c("Mean", "SD"))

## Features with 3 categories:
n <- 3
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(grepTerm("-X"), grepTerm("-Y"), grepTerm("-Z")), ncol=nrow(y))
dataDataTable$featAxis <- factor(x %*% y, 
                                 labels=c(NA, "X", "Y", "Z"))
```

**Validate that all possible combinations of `feature` are accounted for by all possible combinations of the `activity` and `feature` variables.**

```r
r1 <- nrow(dataDataTable[, .N, by=c("feature")])
r2 <- nrow(dataDataTable[, .N, by=c("featDomain", "featAcceleration", "featInstrument", "featJerk", "featMagnitude", "featVariable", "featAxis")])
r1 == r2
```

```
## [1] TRUE
```

8. Tidy DataSet Creation
------------------------
**Create a data set with the average of each variable for each activity and each subject.**

```r
setkey(dataDataTable, subject, activity, featDomain, 
       featAcceleration, featInstrument, featJerk, 
       featMagnitude, featVariable, featAxis)

dataDataTableTidy <- dataDataTable[, 
                                   list(count = .N, average = mean(value)), 
                                   by=key(dataDataTable)]
```

**Create CodeBook.**

```r
knit("create_codebook.Rmd", 
     output="CodeBook.md", 
     encoding="ISO8859-1", 
     quiet=TRUE)
```

```
## [1] "CodeBook.md"
```

```r
markdownToHTML("CodeBook.md", "CodeBook.html")
```
