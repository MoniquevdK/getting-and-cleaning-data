## CodeBook Course Project


### The data

This Course Project makes use of data collected from the accelerometers from the Samsung Galaxy S Smartphone. The collected data contains information from experiments that have been carries out with a group of 30 volunteers aged between 19-48 years. The volunteers performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) while they were wearing a smartphone (Samsung Galaxy S II) on their waist. the smartphone Uses its embedded accelerometer and gyroscope, with which it captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The obtained dataset was randomly split into training set (containing 70% of the volunteers) and a test set (containing 30% of the volunteers).


### The variables

The data contains information on the following variables:
- an identifier of the 30 volunteers of the experiment
- labels for the 6 different activities that the subjects performed: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING
- triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration
- triaxial Angular velocity from the gyroscope
- a vector with time and frequency domain variables 


### Getting the data

The following code was used to first create a directory in which the downloaded files are unzipped. The path to these files is used to read in the data to R:

if(!file.exists("./CourseProject")){dir.create("./CourseProject")}
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(Url,destfile="./CourseProject/Dataset.zip")
unzip(zipfile="./CourseProject/Dataset.zip",exdir="./CourseProject")
path <- file.path("./CourseProject" , "UCI HAR Dataset")


### Reading in the (training and test) data

The following code was used to read in the both the training and test data in R, seperately:

activity_training <- read.table(file.path(path, "train", "y_train.txt"),header = FALSE)
subject_training <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
features_training <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)
activity_test  <- read.table(file.path(path, "test" , "y_test.txt" ),header = FALSE)
subject_test  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)
features_test  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)


### Merging the training and the test data

Next the training and test datasets are merged to create one data set. The 'complete' three variables are also provided with their appropiate names to improve readability:

activity <- rbind(activity_training, activity_test)
colnames(activity) <-  "activity"
features <- rbind(features_training, features_test)
feature_names <- read.table(file.path(path, "features.txt"),head=FALSE)
colnames(features) <- feature_names$V2
subject <- rbind(subject_training, subject_test)
colnames(subject) <- "subject"
data <- cbind(subject, activity, features)


### Extracting only the measurements on the mean and standard deviation for each measurement

Since the data still consists of many variables and we are only interested in the mean and standard deviation for each measurement, we extract only this part from the data:

mean_std <- sort(c(grep("mean\\(\\)", names(data)), grep("std()", names(data))))
data_mean_std <- data[ , c(1, 2, mean_std)]


### Using descriptive activity names to name the activities in the data set

To improve readability, the activities names are provided with their appropiate acitivty names with the following code:

activity_labels <- read.table(file.path(path, "activity_labels.txt"), head=FALSE)
activity_labels <- as.vector(activity_labels[ , 2])
data_mean_std$activity <- factor(data_mean_std$activity, labels=activity_labels)


### Appropriately label the data set with descriptive variable names

To improve readability, the data set is provided with descriptive variable names. This produces a tidy dataset:

names(data_mean_std) <- gsub("^t", "time", names(data_mean_std))
names(data_mean_std) <- gsub("^f", "frequency", names(data_mean_std))
names(data_mean_std) <- gsub("Acc", "Accelerometer", names(data_mean_std))
names(data_mean_std) <- gsub("Gyro", "Gyroscope", names(data_mean_std))
names(data_mean_std) <- gsub("Mag", "Magnitude", names(data_mean_std))
names(data_mean_std) <- gsub("BodyBody", "Body", names(data_mean_std))


### Creating a second, independent tidy data set with the average of each variable for each activity and each subject

As we still have quite a large dataset and we are only interested in the average of each variable for each activity and each subject, we extract this part of the data. This produces a second, tidy dataset:

library(plyr)
TidyData <- aggregate(. ~ subject + activity, data_mean_std, mean)
TidyData <- TidyData[order(TidyData$subject,TidyData$activity), ]


### Create a new table for the tidy dataset

Finally, the clean and tidy dataset is stored in your directory:

write.table(TidyData, file = "./CourseProject/TidyData.txt",row.name=FALSE)