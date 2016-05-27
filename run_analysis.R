library(dplyr)
library(data.table)
library(tidyr)
file_prefix <- ""

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header=FALSE)
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", header=FALSE)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", header=FALSE)

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header=FALSE)
X_train <- read.table("UCI HAR Dataset/train/X_train.txt", header=FALSE)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", header=FALSE)

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", header=FALSE)
features <- read.table("UCI HAR Dataset/features.txt", header=FALSE)

# step 1 merge the test and train datatests
subject_merged <- rbind(subject_test, subject_train)
X_merged <- rbind(X_test, X_train)
y_merged <- rbind(y_test, y_train)

# step 2 extract only mean and std variables
# filter mean or std variables from features df
features_mean_or_std <- filter(features, grepl('mean()|std()', V2))
X_data <- select(X_merged, num_range("V", features_mean_or_std$V1))

# step 3 add in the activity names
y_labels <- inner_join(y_merged, activity_labels, by = c("V1"))
y_labels <- mutate(y_labels, id = 1:n())
y_labels <- mutate(y_labels, Activity = V2)
y_labels <- select(y_labels, id, Activity)

X_data <- mutate(X_data, id = 1:n())
X_data <- inner_join(X_data, y_labels, by = c("id"))

# step 4 label the variable names
setnames(X_data, old = paste("V", features_mean_or_std$V1, sep = ""), new = as.character(features_mean_or_std$V2))


# step 5 avg each variable for each subject and each activity
subject_merged <- mutate(subject_merged, id = 1:n())
subject_merged <- rename(subject_merged, Subject = V1)
X_data_subjects <- inner_join(X_data, subject_merged, by = c("id"))
#X_data_subjects.tidy <- gather(X_data_subjects, Calculation, Measurement, -id, -Activity, -Subject)
X_data_subjects <- select(X_data_subjects, -id)
X_data_subjects_agg <- summarise_each(group_by(X_data_subjects, Activity, Subject), funs(mean))

write.table(X_data_subjects_agg, "X_data_subjects_agg.txt", row.name = FALSE)
