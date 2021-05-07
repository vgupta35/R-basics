# Load RODBC package
#install.packages("RODBC")
#install.packages("stringr")
library(RODBC)
library(stringr)

pathAccounts <- "C:\\Users\\vgupta\\Documents\\Test Banco Files\\Account_DIM_20210228.csv"
pathCustomers <- "C:\\Users\\vgupta\\Documents\\Test Banco Files\\Customer_DIM_20210228.csv"
pathTransactions <- "C:\\Users\\vgupta\\Documents\\Test Banco Files\\Transaction_DIM_20210228.csv"



#Connection for SQL Server
channel <- odbcDriverConnect("driver=SQL Server;server=NCIGICSQL05")

TablePull <- function(conn,string) {
  Table <- sqlQuery(conn, paste("SELECT * FROM BancoPopularAnalysis..",string,sep = ""))
  Table <- Table[order(as.character(Table$PK)),]
  return(Table)
}

TableSplit <- function(dataframe) {
  SplitTable <- data.frame(do.call("rbind",strsplit(as.character(dataframe), "\",\"")))
  SplitTable[,1] <- str_replace(SplitTable[,1],"\"",'')
  SplitTable[,ncol(SplitTable)] <- str_replace(SplitTable[,ncol(SplitTable)],"\"",'')
  return(SplitTable)
}


AccountSample <- TablePull(channel,"TXDVSampleAccounts")
CustomerSample <- TablePull(channel,"TXDVSampleCustomers")
TransactionSample <- TablePull(channel,"TXDVSampleTransactions")

AccountSplit <- TableSplit(AccountSample$Line)
CustomerSplit <- TableSplit(CustomerSample$Line)
TransactionSplit <- TableSplit(TransactionSample$Line)


#Close Channel Once Finished
odbcClose(channel)



library(data.table)

#fd1 <- data.table::fread(pathAccounts, colClasses = 'character', data.table = F)
fd2 <- data.table::fread(pathCustomers, colClasses = 'character', data.table = F)
#fd3 <- data.table::fread(pathTransactions, colClasses = 'character', data.table = F)



#RawAccountSample <- fd1[fd1$ACCOUNT_SURR_KEY %in% AccountSample$PK,]
RawCustomerSample <- fd2[fd2$CUSTOMER_SURR_KEY %in% CustomerSample$PK,]
RawTransactionSample <- fd3[fd3$SEQUENCE_NUMBER %in% TransactionSample$SEQUENCE_NUMBER,]
  
RawTransactionSample2 <- RawTransactionSample[paste(RawTransactionSample$SEQUENCE_NUMBER,RawTransactionSample$DATE_OF_TRANSACTION,RawTransactionSample$REGION,sep="_") %in% TransactionSample$PK,]

#RawAccountSample[] <- RawAccountSample[order(RawAccountSample$ACCOUNT_SURR_KEY),]
RawCustomerSample[] <- RawCustomerSample[order(RawCustomerSample$CUSTOMER_SURR_KEY),] 
RawTransactionSample2[] <- RawTransactionSample2[order(paste(RawTransactionSample2$SEQUENCE_NUMBER,RawTransactionSample2$DATE_OF_TRANSACTION,RawTransactionSample2$REGION,sep="_")),]

RawCustomerSample2 <- RawCustomerSample[,-6]

names(RawCustomerSample)[6]

library(dplyr)

##fd1 <- read.csv(pathAccounts, stringsAsFactors=FALSE)

library(stringr)


Output <- function(table,location) {
  path <- paste("C:\\Users\\vgupta\\Documents\\Test Banco Files\\",location,sep = "")
  write.csv(table, path, na = "\"\"", row.names=FALSE)
}

Output(RawAccountSample,"RawDataAccounts202102.csv")
Output(AccountSplit,"DBDataAccounts202102.csv")
Output(RawCustomerSample2,"RawDataCustomers202102.csv")
Output(CustomerSplit,"DBDataCustomers202102.csv")

Output(RawTransactionSample2,"RawDataTransactions202102.csv")
Output(TransactionSplit,"DBDataTransactions202102.csv")

#write.csv(RawAccountSample , "C:\\Users\\vgupta\\Documents\\Test Banco Files\\RawDataAccounts202102.csv", na = "\"\"", row.names=FALSE)
#write.csv(AccountSplit   , "C:\\Users\\vgupta\\Documents\\Test Banco Files\\DBDataAccounts202102.csv", na = "\"\"", row.names=FALSE)
#write.csv(RawCustomerSample, "C:\\Users\\vgupta\\Documents\\Test Banco Files\\RawDataCustomers202102.csv", na = "\"\"", row.names=FALSE)
#write.csv(CustomerSplit   , "C:\\Users\\vgupta\\Documents\\Test Banco Files\\DBDataCustomers202102.csv", na = "\"\"", row.names=FALSE)


