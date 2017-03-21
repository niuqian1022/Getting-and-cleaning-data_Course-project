Summary:
The script (run_analysis.R) takes five steps to generate a tidy dataset. The data frame is in dimention of 30 row * 68 columns, each row is a mean measurement
taken from individual subjective, and each column indicates the subjective ID, activities, or is the mean and std of a feature measured from the
given individual subjective while doing the corresponding activity. 

Methods to generate the tidy dataset:
Step 1: Read train and test datasets, as well as activity and subject ID from designated text files, properly labled, 
and generate a combined dataset from train and test sets.
Step 2: From the combined dataset, generate a dataframe that contains only mean and std for measured variables.
Step 3: Rename the 'activity' column with discriptive activity names. 
Step 4: Rename the column names with more readable variable names
Step 5: Reshape the renamed data frame into a long skinny one, and take mean of each variable for each subID doing each activity
Then finally write the resultant data frame into a text file, and reload it to check if it works fine

Information about the system:
R version: 3.3.3 (2017-03-06)
Windows 10 Home, 64-bit Operating System x64-based processor



