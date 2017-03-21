library(dplyr)
library(reshape2)
#Samsung data folder ("getdata%2Fprojectfiles") is in working directory 
#Step 1: Read train and test datasets, as well as activity and subject ID from designated text files, properly labled, 
#and generate a combined dataset from train and test sets. 
features<-read.table("features.txt")             #read feature names from file "features.txt" 
train_acti_code<-read.table("train/y_train.txt") #read activity code for train set (value = 1-6, correponding to walking, laying etc.)
train_ID<-read.table("train/subject_train.txt")  #read train set subject ID from "subject_train.txt
train_data<-read.table("train/X_train.txt")      #read train data (not the raw data) from file "X_train.txt"
test_acti_code<-read.table("test/y_test.txt") #read activity code for test set (value = 1-6, correponding to walking, laying etc.)
test_ID<-read.table("test/subject_test.txt")  #read test set subject ID from "subject_test.txt"
test_data<-read.table("test/X_test.txt")      #read test data (not the raw data) from file "X_test.txt"

colnames(train_acti_code)<-"activity"         #name the train_acti_code column with "activity" instead of "V.1"
colnames(train_ID)<-"subID"                   #name the train_ID column with "subID" instead of "V.1
colnames(train_data)<-features[,2]            #name the train_data column with feature (variable) names
colnames(test_acti_code)<-"activity"          #name the test_acti_code column with "activity" instead of "V.1"
colnames(test_ID)<-"subID"                    #name the test_ID column with "subID" instead of "V.1"
colnames(test_data)<-features[,2]             #name the test_data column with feature (varaible) names

named_train<-cbind(train_ID, train_acti_code, train_data)  #column-bind the subject ID, activity code for train dataset
named_test<-cbind(test_ID, test_acti_code, test_data)      #column-bind the subject ID, activity code for test dataset
combined<-rbind(named_train, named_test)                   #row-bind train and test datasets (they have matched column names)

#Step 2: From the combined dataset, generate a dataframe that contains only mean and std for measured variables.
index4extract<-grep("mean\\(\\)|std\\(\\)", colnames(combined))        #locate which columns store mean() and std() variables
data4ana<-combined[,c(1,2,index4extract)]                  #extract the 'subID' and 'activity' columnn, and 
                                                           #columns with mean() and std() variables 
data4ana<-tbl_df(data4ana)                                 #generate dataframe to analyze with dplyr package

#Step 3: Rename the 'activity' column with discriptive activity names. 
#'label'is a function defined to "translate" activity code 1-6 to descriptive phrases
label <-function(num) {
    result = vector()
    for (i in 1:length(num))       
    {
    if (num[i] == 1L) {result[i]  <- "walking"}
        else if (num[i] == 2L) {result[i]  <- "walkingUpstairs"}
              else if (num[i] == 3L) {result[i]  <- "walkingDownstairs"}
                    else if (num[i]== 4L) {result[i]  <- "sitting"}
                          else if (num[i]== 5L) {result[i]  <- "standing"}
                                else            {result[i]  <- "laying"}
    }
    return(result)
}
#add a column of descriptive activity names, and remove the original one.
data4ana<-(data4ana %>% mutate("activities" = label(activity)) %>% select(subID, activities, 3:68))


#Step 4: rename the column names with more readable variable names
ColNames<-colnames(data4ana)
#replace all the "-" and "()"
recolnames<-gsub("\\-", "", ColNames) 
recolnames<-gsub("\\(\\)", "", recolnames)
#label all the mean and std as "Mean" and "Std"
recolnames<-gsub("mean", "Mean", recolnames)           
recolnames<-gsub("std", "Std", recolnames)   
#replace "t" with "Time" (time domain signals)
recolnames<-gsub("^t", "Time", recolnames)
#replace "f" with "Fre" (they are transformed values applied to frequency domain signals)
recolnames<-gsub("^f", "Fre", recolnames)
colnames(data4ana)<-recolnames

#Step 5: reshape the renamed data frame into a long skinny one, and take mean of each variable for each subID doing each activity
#melt the data frame: dimension will be from 10299*68 (68 = 66 features plus 2 identity variables) to (10299*66)*4
variableNames<-colnames(data4ana[3:68])
datamelt<-melt(data4ana, id = c("subID","activities"), variableNames)
#dcast the melted data frame: from a long skinny data frame back to a wide one where each colume storing one variable
result<-dcast(datamelt, subID + activities ~ variable, mean)

#finally write the resultant data frame into a text file, and reload it to check if it works fine
write.table(result, "TidyData.txt", row.names = F)
tidydata<-read.table("TidyData.txt", header = T)
tidydata<-tbl_df(tidydata)
tidydata
         