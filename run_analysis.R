
# getting the data
if(!file.exists("./CourseProject")){dir.create("./CourseProject")}
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(Url,destfile="./CourseProject/Dataset.zip")
unzip(zipfile="./CourseProject/Dataset.zip",exdir="./CourseProject")
path <- file.path("./CourseProject" , "UCI HAR Dataset")

# read in training data
activity_training <- read.table(file.path(path, "train", "y_train.txt"),header = FALSE)
subject_training <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
features_training <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

# read in test data
activity_test  <- read.table(file.path(path, "test" , "y_test.txt" ),header = FALSE)
subject_test  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)
features_test  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)


# 1. Merge the training and the test sets to create one data set
activity <- rbind(activity_training, activity_test)
colnames(activity) <-  "activity"
features <- rbind(features_training, features_test)
feature_names <- read.table(file.path(path, "features.txt"),head=FALSE)
colnames(features) <- feature_names$V2
subject <- rbind(subject_training, subject_test)
colnames(subject) <- "subject"
data <- cbind(subject, activity, features)

# 2. Extract only the measurements on the mean and standard deviation for each measurement
mean_std <- sort(c(grep("mean\\(\\)", names(data)), grep("std()", names(data))))
data_mean_std <- data[ , c(1, 2, mean_std)]

# 3. Use descriptive activity names to name the activities in the data set
activity_labels <- read.table(file.path(path, "activity_labels.txt"), head=FALSE)
activity_labels <- as.vector(activity_labels[ , 2])
data_mean_std$activity <- factor(data_mean_std$activity, labels=activity_labels)

# 4. Appropriately label the data set with descriptive variable names
names(data_mean_std) <- gsub("^t", "time", names(data_mean_std))
names(data_mean_std) <- gsub("^f", "frequency", names(data_mean_std))
names(data_mean_std) <- gsub("Acc", "Accelerometer", names(data_mean_std))
names(data_mean_std) <- gsub("Gyro", "Gyroscope", names(data_mean_std))
names(data_mean_std) <- gsub("Mag", "Magnitude", names(data_mean_std))
names(data_mean_std) <- gsub("BodyBody", "Body", names(data_mean_std))

# 5. From the data set in step 4, create a second, independent tidy data set with 
#    the average of each variable for each activity and each subject
library(plyr)
TidyData <- aggregate(. ~ subject + activity, data_mean_std, mean)
TidyData <- TidyData[order(TidyData$subject,TidyData$activity), ]
write.table(TidyData, file = "./CourseProject/TidyData.txt",row.name=FALSE)
