#We want to remove all but the first row with a specific ID. 
	#To do this we first add a column called row_num which has a sequential number starting at 1 for the first row with a specific ID. 
	#This means for example that the third row with ID x will have 3 as its row_num. 
	#We also take this oppertunity to remove all columns we won't be using. The resulting table is saved in a new table called hurricanes_fixed. 
create table hurricanes_temp SELECT ID, Date, Time,   
    ROW_NUMBER() OVER(PARTITION BY ID) AS row_num
FROM hurricanes; 

#Since the rows which share ID with an earlier row has row_num > 1 we can just delete all such rows. 
	#Note that we are deleting rows which we don't find using a primary key, so we need to turn off safe mode here.
DELETE FROM hurricanes_temp WHERE row_num > 1;

#The resulting table has been ordered by ID, which is not ideal. 
	#We reorder the table while also recreating the original named `hurricanes` and also take this oppertunity to drop the row_num column;
drop table hurricanes;
create table hurricanes SELECT ID,Date,Time FROM hurricanes_temp Order by Date, Time;
drop table hurricanes_temp;
  
#Now the table is ready to be saved to a .csv file. 
(SELECT 'ID', 'Date', 'Time')
UNION	
(SELECT * FROM hurricanes)
	INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Hurricanes.csv' 
	FIELDS ENCLOSED BY '"' 
	TERMINATED BY ';' 
	ESCAPED BY '"' 
	LINES TERMINATED BY '\r\n';

#REFLECTION: It is not ideal to create two new tables but given the small data set there is no reason to optimize for speed or storage. 
	#If I decide to spend more time on this project then I will figure out a better way to do it.