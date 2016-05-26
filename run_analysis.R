library(dplyr)
library(data.table)
library(tidyr)
file_prefix <- "C:\\coursera\\datacleaning\\UCI HAR Dataset\\"

subject_test <- read.table(paste(file_prefix, "test\\subject_test.txt", sep = ""), header=FALSE)
X_test <- read.table(paste(file_prefix, "test\\X_test.txt", sep = ""), header=FALSE)
y_test <- read.table(paste(file_prefix, "test\\y_test.txt", sep = ""), header=FALSE)

subject_train <- read.table(paste(file_prefix, "train\\subject_train.txt", sep = ""), header=FALSE)
X_train <- read.table(paste(file_prefix, "train\\X_train.txt", sep = ""), header=FALSE)
y_train <- read.table(paste(file_prefix, "train\\y_train.txt", sep = ""), header=FALSE)

activity_labels <- read.table(paste(file_prefix, "activity_labels.txt", sep = ""), header=FALSE)
features <- read.table(paste(file_prefix, "features.txt", sep = ""), header=FALSE)

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
X_data.tidy <- gather(X_data, Calculation, Measurement, -id, -Activity)
X_data.tidy <- select(X_data.tidy, -id)


# step 5 avg each variable for each subject and each activity
subject_merged <- mutate(subject_merged, id = 1:n())
subject_merged <- rename(subject_merged, Subject = V1)
X_data_subjects <- inner_join(X_data, subject_merged, by = c("id"))
X_data_subjects.tidy <- gather(X_data_subjects, Calculation, Measurement, -id, -Activity, -Subject)
X_data_subjects.tidy <- select(X_data_subjects.tidy, -id)
X_data_subjects_agg <- summarise(group_by(X_data_subjects.tidy, Activity, Subject), avg = mean(Measurement))
