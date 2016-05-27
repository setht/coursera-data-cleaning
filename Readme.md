## Readme
## Variables and Transformations
I have variables for the subjects by number, test and train X data which includes the measurements, test and train y data which includes the activity values, and activity labels, and features file.

I first merge the test and train datasets for X, y, and subject using rbind.
I then choose the matching features that contain mean() or std() using grep via filter command.
I then add an id column which is used to join the data to the activity labels.
I then use setname to rename all the columns to the feature measurement name.
I use gather to tidy up the dataset and turn all the features into column with new Calculation and Measurement columns.

For problem #5, I take the wide dataset and join to the subject data to include subject numbers. I use gather again to turn it into a dataset with just Activity, Subject, Calculation, Measurement. Then use group_by and summarise to create a new column avg of Measurement.

