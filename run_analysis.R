#
# The run_analysis.R does the following:

# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#

library(reshape2)

filename <- "getdata%2Fprojectfiles%2FUCI HAR Dataset.zip"

# download and unzip the dataset:
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}

# load activity labels + features
act_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
act_labels[,2] <- as.character(act_labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
feat_wanted <- grep(".*mean.*|.*std.*", features[,2])
feat_wanted.names <- features[feat_wanted,2]
feat_wanted.names = gsub('-mean', 'Mean', feat_wanted.names)
feat_wanted.names = gsub('-std', 'Std', feat_wanted.names)
feat_wanted.names <- gsub('[-()]', '', feat_wanted.names)

# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[feat_wanted]
train_act <- read.table("UCI HAR Dataset/train/y_train.txt")
train_sub <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_sub, train_act, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[feat_wanted]
test_act <- read.table("UCI HAR Dataset/test/y_test.txt")
test_sub <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_sub, test_act, test)

# merge datasets and add labels
all_data <- rbind(train, test)
colnames(all_data) <- c("subject", "activity", feat_wanted.names)

# turn activities & subjects into factors
all_data$activity <- factor(all_data$activity, levels = act_labels[,1], labels = act_labels[,2])
all_data$subject <- as.factor(all_data$subject)

all_data.melted <- melt(all_data, id = c("subject", "activity"))
all_data.mean <- dcast(all_data.melted, subject + activity ~ variable, mean)

write.table(all_data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)