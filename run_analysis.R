
#set the paths for use in loading the data from the disk
train_path = "~\\R\\Class\\data\\UCI HAR Dataset\\train\\X_train.txt"
train_lbl_path = "~\\R\\Class\\data\\UCI HAR Dataset\\train\\Y_train.txt"
train_id_path =  "~\\R\\Class\\data\\UCI HAR Dataset\\train\\Subject_train.txt"

test_path = "~\\R\\Class\\data\\UCI HAR Dataset\\test\\X_test.txt"
test_lbl_path = "~\\R\\Class\\data\\UCI HAR Dataset\\test\\Y_test.txt"
test_id_path =  "~\\R\\Class\\data\\UCI HAR Dataset\\test\\Subject_test.txt"


features_path = "~\\R\\Class\\data\\UCI HAR Dataset\\Features.txt"
activity_path = "~\\R\\Class\\data\\UCI HAR Dataset\\activity_labels.txt"

  
# load data into table for reading
train_Table <-read.table(train_path, sep="",row.names=NULL, na.strings="NA",fill=TRUE,strip.white=TRUE)
train_lbl_Table <-read.table(train_lbl_path, sep="",row.names=NULL, na.strings="NA",fill=TRUE,strip.white=TRUE)
train_id_Table <-read.table(train_id_path, sep="",row.names=NULL, na.strings="NA",fill=TRUE,strip.white=TRUE)

test_Table <-read.table(test_path, sep="",row.names=NULL, na.strings="NA",fill=TRUE,strip.white=TRUE)
test_lbl_Table <-read.table(test_lbl_path, sep="",row.names=NULL, na.strings="NA",fill=TRUE,strip.white=TRUE)
test_id_Table <-read.table(test_id_path, sep="",row.names=NULL, na.strings="NA",fill=TRUE,strip.white=TRUE)

features_Table <-read.table(features_path, sep="", na.strings="NA",fill=TRUE,strip.white=TRUE)
actvity_file <-read.table(activity_path, sep="", na.strings="NA",fill=TRUE,strip.white=TRUE)

#Merge the activity names with the label table since is easier to do with just the one field.
#Will add these to the main table next.
colnames(actvity_file)[1] <- "ActivityKey"
colnames(train_lbl_Table)[1] <- "ActivityKey"
train_lbl_Table_adj <- merge(train_lbl_Table,actvity_file,by="ActivityKey")

colnames(test_lbl_Table)[1] <- "ActivityKey"
test_lbl_Table_adj <- merge(test_lbl_Table,actvity_file,by="ActivityKey")

#This part will process the data
#First add the labels to each table.  This needs to be done before
# merge the two tables.  The assumption is the labels match record for
# record for the train and test data.  The record counts match and there
# was nothing in the documentation that indicated otherwise.
train_Table_w_lbl <- cbind(train_Table,train_lbl_Table_adj)
test_Table_w_lbl <- cbind(test_Table,test_lbl_Table_adj)

#First add the ID's to each table.  This needs to be done before
# merge the two tables.  The assumption is the ID's match record for
# record for the train and test data.  The record counts match and there
# was nothing in the documentation that indicated otherwise.
train_Table_w_ID <-cbind(train_Table_w_lbl,train_id_Table)
test_Table_w_ID <-cbind(test_Table_w_lbl,test_id_Table)

# Now add the activity label to each row using the match function

#Now merge the two tables into one
TotalData = rbind(test_Table_w_ID,train_Table_w_ID)


#Add the titles to the labels on each record
colnames(TotalData) <- features_Table[,2]
colnames(TotalData)[562] <- "ActivityKey"
colnames(TotalData)[563] <- "ActivityDescription"
colnames(TotalData)[564] <- "IDKey"

# extract the columns meand and std
totalDataSet <- TotalData[,grep("mean|std|ActivityKey|ActivityDescription|IDKey" , names(TotalData), value=TRUE)]

#Build the averages
library(reshape2)
Molten <- melt(totalDataSet, id.vars = c("ActivityDescription", "IDKey"))
Molten$value <- as.numeric(Molten$value)
utput <- dcast(IDKey+ActivityDescription~variable, data = Molten, fun = mean)

#output the data
write.table(output, "~\\R\\Class\\data\\Output.txt",row.name=FALSE, sep="|")