#!/bin/bash

PSQL="psql -X --username=postgres --dbname=yourstockforecast --tuples-only -c"
PSQL_CreateDatabase="psql -X --username=postgres --dbname=postgres --tuples-only -c"

MAIN_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   clear
   echo -e "\n~~~~~ YourStockForecast CLI ~~~~~"
   echo -e "\n0. Database Management Menu\n1. Exit Program\n"
   echo "Enter Command: "
   read MAIN_MENU_SELECTION
   case $MAIN_MENU_SELECTION in
   0) DATABASE_MANAGEMENT_MENU ;;
   1) EXIT ;;
   *) MAIN_MENU "Please enter a valid option." ;;
esac
}


DATABASE_MANAGEMENT_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   clear
   echo -e "\n~~~~~ Database Management Menu ~~~~~"
   echo -e "\n0. Return To Main Menu\n1. List Schema Menu\n2. Create Databases & Tables Menu\n3. Delete Databases & Tables Menu\n4. Insert Data Menu\n5. Select Data Menu\n6. Update Bikes Menu\n"
   echo "Enter Command: "
   read DATABASE_MANAGEMENT_MENU_SELECTION
   case $DATABASE_MANAGEMENT_MENU_SELECTION in
   0) MAIN_MENU ;;
   1) LIST_SCHEMA_MENU ;;
   2) CREATE_DATABASE_AND_TABLES_MENU ;;
   3) DELETE_DATABASE_MANAGEMENT_MENU ;;
   4) INSERT_DATA_MENU ;;
   5) SELECT_DATA_MENU ;;
   6) UPDATE_DATA_MENU ;;
   *) DATABASE_MANAGEMENT_MENU "Please enter a valid option." ;;
esac
}

## Show Schema Management ##

LIST_SCHEMA_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   echo -e "\n~~~~~ Schema Menu ~~~~~"
   echo -e "\n0. Return To Database Management Menu\n1. List Databases\n2. List Tables\n3. List Table yahoo_finance\n"
   echo "Enter Command: "
   read DATABASE_MANAGEMENT_MENU_SELECTION
   case $DATABASE_MANAGEMENT_MENU_SELECTION in
   0) DATABASE_MANAGEMENT_MENU ;;
   1) LIST_DATABASES ;;
   2) LIST_TABLES ;;
   3) LIST_TABLE_YAHOO_FINANCE ;;
   *) LIST_SCHEMA_MENU "Please enter a valid option." ;;
esac
}

LIST_DATABASES(){
	$PSQL_CreateDatabase "\l"
	LIST_SCHEMA_MENU "Listed Databases"
}

LIST_TABLES(){
	$PSQL "\dt+"
	LIST_SCHEMA_MENU "Listed Tables"
}

LIST_TABLE_YAHOO_FINANCE(){
	$PSQL "\d yahoofinance"
	LIST_SCHEMA_MENU "Listed Table yahoo_finance"
}

CREATE_DATABASE_AND_TABLES_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   echo -e "\n~~~~~ Create Database & Tables Menu ~~~~~"
   echo -e "\n0. Return To Database Management Menu\n1. Create Database yourstockforecast\n2. Create Table yahoofinance"
   echo "Enter Command: "
   read DATABASE_MANAGEMENT_MENU_SELECTION
   case $DATABASE_MANAGEMENT_MENU_SELECTION in
   0) DATABASE_MANAGEMENT_MENU ;;
   1) CREATE_DATABASE ;;
   2) CREATE_TABLE_YAHOO_FINANCE ;;
   *) CREATE_DATABASE_AND_TABLES_MENU "Please enter a valid option." ;;
esac
}

CREATE_DATABASE(){
	$PSQL_CreateDatabase "CREATE DATABASE yourstockforecast;"
	CREATE_DATABASE_AND_TABLES_MENU
}

CREATE_TABLE_YAHOO_FINANCE(){
	$PSQL "CREATE TABLE yahoofinance();"
	$PSQL "ALTER TABLE yahoofinance ADD COLUMN yahoofinance_id SERIAL PRIMARY KEY;"
	$PSQL "ALTER TABLE yahoofinance ADD COLUMN date DATE NOT NULL;"
	$PSQL "ALTER TABLE yahoofinance ADD COLUMN high REAL NOT NULL;"
	$PSQL "ALTER TABLE yahoofinance ADD COLUMN low REAL NOT NULL;"
	$PSQL "ALTER TABLE yahoofinance ADD COLUMN close REAL NOT NULL;"
	$PSQL "ALTER TABLE yahoofinance ADD COLUMN adj_close REAL NOT NULL;"
	$PSQL "ALTER TABLE yahoofinance ADD COLUMN volume int NOT NULL;"
	CREATE_DATABASE_AND_TABLES_MENU "Created Tables Quotes"
	
}

DELETE_DATABASE_MANAGEMENT_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   echo -e "\n~~~~~ Delete Database & Tables Menu ~~~~~"
   echo -e "\n0. Return To Database Management Menu\n1. Delete Database yourstockforecast\n2. Delete Table yahoofinance"
   echo "Enter Command: "
   read DATABASE_MANAGEMENT_MENU_SELECTION
   case $DATABASE_MANAGEMENT_MENU_SELECTION in
   0) DATABASE_MANAGEMENT_MENU ;;
   1) DELETE_DATABASE ;;
   4) DELETE_TABLE_YAHOO_FINANCE ;;
   *) DELETE_DATABASE_MANAGEMENT_MENU "Please enter a valid option." ;;
esac
}

DELETE_DATABASE(){
	$PSQL_CreateDatabase "DROP DATABASE yourstockforecast;"
	DELETE_DATABASE_MANAGEMENT_MENU
}

DELETE_TABLE_YAHOO_FINANCE(){
	$PSQL "DROP TABLE yahoofinance;"
	DELETE_DATABASE_MANAGEMENT_MENU
}

INSERT_DATA_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   echo -e "\n~~~~~ Insert Data Menu ~~~~~"
   echo -e "\n0. Return To Database Management Menu\n1. Insert Example Bikes Data\n"
   echo "Enter Command: "
   read DATABASE_MANAGEMENT_MENU_SELECTION
   case $DATABASE_MANAGEMENT_MENU_SELECTION in
   0) DATABASE_MANAGEMENT_MENU ;;
   1) INSERT_EXAMPLE_BIKES_DATA ;;
   *) INSERT_DATA_MENU "Please enter a valid option." ;;
esac
}

INSERT_EXAMPLE_BIKES_DATA(){
	$PSQL "INSERT INTO bikes (type, size) VALUES ('Mountain', 27);"
	$PSQL "INSERT INTO bikes (type, size) VALUES ('Mountain', 28);"
	$PSQL "INSERT INTO bikes (type, size) VALUES ('Mountain', 29);"
	$PSQL "INSERT INTO bikes (type, size) VALUES ('Road', 27);"
	$PSQL "INSERT INTO bikes (type, size) VALUES ('Road', 28);"
	$PSQL "INSERT INTO bikes (type, size) VALUES ('Road', 29);"
	$PSQL "INSERT INTO bikes (type, size) VALUES ('BMX', 19);"
	$PSQL "INSERT INTO bikes (type, size) VALUES ('BMX', 20);"
	$PSQL "INSERT INTO bikes (type, size) VALUES ('BMX', 21);"
	DATABASE_MANAGEMENT_MENU "Inserted Example Bikes"
}

## Data Selection Management ##

SELECT_DATA_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   echo -e "\n~~~~~ Insert Data Menu ~~~~~"
   echo -e "\n0. Return To Database Management Menu\n1. Select All Bikes\n"
   echo "Enter Command: "
   read DATABASE_MANAGEMENT_MENU_SELECTION
   case $DATABASE_MANAGEMENT_MENU_SELECTION in
   0) DATABASE_MANAGEMENT_MENU ;;
   1) SELECT_ALL_BIKES ;;
   *) SELECT_DATA_MENU "Please enter a valid option." ;;
esac
}

SELECT_ALL_BIKES(){
	AVAILABLE_BIKES=$($PSQL "SELECT bike_id, type, size FROM bikes WHERE available=TRUE ORDER BY bike_id")
	echo "$AVAILABLE_BIKES"
	SELECT_DATA_MENU
}

## Update Data Management ##

UPDATE_DATA_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   echo -e "\n~~~~~ Update Bikes Available ~~~~~"
   echo -e "\n0. Return To Database Management Menu\n1. Update All Bikes as Available\n2. Update All Bikes as Unavailable\n3. Update all bikes available except BMX\n"
   echo "Enter Command: "
   read UPDATE_MENU_SELECTION
   case $UPDATE_MENU_SELECTION in
   0) DATABASE_MANAGEMENT_MENU ;;
   1) UPDATE_ALL_BIKES_AVAILABLE ;;
   2) UPDATE_ALL_BIKES_UNAVAILABLE ;;
   3) UPDATE_ALL_BIKES_AVAILABLE_EXCEPT_BMX ;;
   *) SELECT_DATA_MENU "Please enter a valid option." ;;
esac
}

UPDATE_ALL_BIKES_AVAILABLE(){
	AVAILABLE_BIKES=$($PSQL "UPDATE bikes SET AVAILABLE = true;")
	UPDATE_DATA_MENU
}

UPDATE_ALL_BIKES_AVAILABLE_EXCEPT_BMX(){
	AVAILABLE_BIKES=$($PSQL "UPDATE bikes SET available = TRUE WHERE type != 'BMX';")
	UPDATE_DATA_MENU
}

UPDATE_ALL_BIKES_UNAVAILABLE(){
	AVAILABLE_BIKES=$($PSQL "UPDATE bikes SET AVAILABLE = false;")
	UPDATE_DATA_MENU
}

## Exit & End Program Management ##

EXIT(){
   echo -e "\nClosing Program.\n"
}

MAIN_MENU
