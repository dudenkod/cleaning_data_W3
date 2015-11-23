## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library("data.table")
library("reshape2")

if(!file.exists("./scratch")){dir.create("./scratch")}

Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(Url,destfile="./FUCI_HAR_Dataset.zip",method="curl")
unzip(zipfile="./FUCI_HAR_Dataset.zip",exdir="./scratch")

full_path <- file.path("./scratch" , "UCI HAR Dataset")

#Preparation stage
# Loading activity labels and features

activity_labels <- read.table(file.path(full_path,"activity_labels.txt"), header = FALSE)[,2]
features <- read.table(file.path(full_path,"features.txt"), header = FALSE)[,2]

# Loading traing and test sets
X_train <- read.table(file.path(full_path,"train/X_train.txt"), header = FALSE)
X_test <- read.table(file.path(full_path,"test/X_test.txt"), header = FALSE)
y_train <- read.table(file.path(full_path,"train/y_train.txt"), header = FALSE)
y_test <- read.table(file.path(full_path,"test/y_test.txt"), header = FALSE)
subject_train <- read.table(file.path(full_path,"train/subject_train.txt"), header = FALSE)
subject_test <- read.table(file.path(full_path,"test/subject_test.txt"), header = FALSE)

#NAMING
names(X_train) = features
names(X_test) = features

# Extracting only the measurements on the mean and standard deviation for each measurement.

extract_features <- grepl("mean|std", features)
X_test = X_test[,extract_features]
X_train = X_train[,extract_features]


# Labeling

y_test[,2] = activity_labels[y_test[,1]]
y_train[,2] = activity_labels[y_train[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"
names(subject_train) = "subject"

# CBinding data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Merge test and train data
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Producing tidy data
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./final_resulting_tidy_data.txt",  row.name=FALSE)
