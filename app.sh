#!/bin/bash

PSQL="psql -X --username=postgres --dbname=yourstockforecast --tuples-only -c"
PSQL_CreateDatabase="psql -X --username=postgres --dbname=postgres --tuples-only -c"

MAIN_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   echo -e "\n~~~~~ YourStockForecast CLI ~~~~~"
   echo -e "\n0. Database Management Menu\n1. Rent a Bike\n2. Return a Bike\n3. Exit Program\n"
   echo "Enter Command: "
   read MAIN_MENU_SELECTION
   case $MAIN_MENU_SELECTION in
   0) DATABASE_MANAGEMENT_MENU ;;
   1) RENT_MENU ;;
   2) RETURN_MENU ;;
   3) EXIT ;;
   *) MAIN_MENU "Please enter a valid option." ;;
esac
}

RENT_MENU(){
	# Get Available Bikes
	AVAILABLE_BIKES=$($PSQL "SELECT bike_id, type, size FROM bikes WHERE available = true ORDER BY bike_id")
	
	# If no bikes available
	if [[ -z $AVAILABLE_BIKES ]]
	then
		# send to main menu
		MAIN_MENU "Sorry, we don't have any bikes available right now."
	else
		# Display available bikes
		echo -e "\nHere are the bikes we have available: " 
		echo "$AVAILABLE_BIKES" | while read BIKE_ID BAR TYPE BAR SIZE
		do
			echo "$BIKE_ID) $SIZE\" $TYPE Bike"
		done
	
	# Ask for bikes to rent
	echo -e "\nWhich one would you like to rent?"
	read BIKE_ID_TO_RENT
	
	# if input is not a number 
	if [[ ! $BIKE_ID_TO_RENT =~ ^[0-9]+$ ]]
	# Send to main menu
	then
		MAIN_MENU "That is not a valid bike number."
	else
		BIKE_AVAILABILITY=$($PSQL "SELECT available FROM bikes WHERE bike_id = $BIKE_ID_TO_RENT AND available = true")
	
	# if not available
	if [[ -z $BIKE_AVAILABILITY ]]
	then
		# send to main menu
		MAIN_MENU "That bike is not available."
	else
		# get customer info
		echo -e "\nWhat is you phone number?"
		read PHONE_NUMBER
		
		CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$PHONE_NUMBER'")
		
		# if customer doesn't exist
		if [[ -z $CUSTOMER_NAME ]]
		then
			# Get new customer name
			echo -e "\nWhat is your name?"
			read CUSTOMER_NAME
			
			# insert new customer
			INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$PHONE_NUMBER')")
        fi

        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$PHONE_NUMBER'")

        # insert bike rental
        INSERT_RENTAL_RESULT=$($PSQL "INSERT INTO rentals(customer_id, bike_id) VALUES($CUSTOMER_ID, $BIKE_ID_TO_RENT)")

        # set bike availability to false
        SET_TO_FALSE_RESULT=$($PSQL "UPDATE bikes SET available = false WHERE bike_id = $BIKE_ID_TO_RENT")

        # get bike info
        BIKE_INFO=$($PSQL "SELECT size, type FROM bikes WHERE bike_id = $BIKE_ID_TO_RENT")
        BIKE_INFO_FORMATTED=$(echo $BIKE_INFO | sed 's/ |/"/')
        
        # send to main menu
        MAIN_MENU "I have put you down for the $BIKE_INFO_FORMATTED Bike, $CUSTOMER_NAME."
      fi
    fi
  fi
}
		
RETURN_MENU() {
  #get customer info
  echo -e "\nWhat's your phone number?"
  read PHONE_NUMBER
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$PHONE_NUMBER'")

  #if not found
  if [[ -z $CUSTOMER_ID ]]
  then
    #send to main menu
    MAIN_MENU "I could not find a record for that phone number."
  else
    #get customer's rentals
    CUSTOMER_RENTALS=$($PSQL "select bike_id, type, size from bikes inner join rentals using(bike_id) inner join customers using(customer_id) where phone='$PHONE_NUMBER' and date_returned is null order by bike_id")

    if [[ -z $CUSTOMER_RENTALS ]]
    then
      #send to main menu
      MAIN_MENU "You do not have any bikes rented."

      else
      #display rented bikes
      echo -e "\nHere are your rentals:"
      echo "$CUSTOMER_RENTALS" | while read BIKE_ID BAR TYPE BAR SIZE
      do
        echo "$BIKE_ID) $SIZE\" $TYPE Bike"
      done

      #ask for bike to return
      echo -e "\nWhich one would you like to return?"
      read BIKE_ID_TO_RETURN

      #if not a number
      if [[ ! $BIKE_ID_TO_RETURN =~ ^[0-9]+$ ]]
      then
        #send to main menu
        MAIN_MENU "That is not a valid bike number."
      else
        #check if input is rented
        RENTAL_ID=$($PSQL "select rental_id from rentals inner join customers using(customer_id) where bike_id=$BIKE_ID_TO_RETURN and date_returned is null and phone='$PHONE_NUMBER'")

        #if input not rented
        if [[ -z $RENTAL_ID ]]
        then
          #send to main menu
          MAIN_MENU "You do not have that bike rented."
        else
          #update date_returned
          RETURN_BIKE_RESULT=$($PSQL "update rentals set date_returned=NOW() where rental_id=$RENTAL_ID")

          #set bike availability to true
          SET_TO_TRUE_RESULT=$($PSQL "update bikes set available=true where bike_id=$BIKE_ID_TO_RETURN")

          #send to main menu
          MAIN_MENU "Thank you for returning your bike."
        fi
      fi
    fi
  fi
}

DATABASE_MANAGEMENT_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   echo -e "\n~~~~~ DATABASE MANAGEMENT MENU ~~~~~"
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
   echo -e "\n~~~~~ Show Schema Menu ~~~~~"
   echo -e "\n0. Return To Database Management Menu\n1. List Databases\n2. List Tables\n3. List Table Bikes\n4. List Table Customers\n5. List Table Rentals\n"
   echo "Enter Command: "
   read DATABASE_MANAGEMENT_MENU_SELECTION
   case $DATABASE_MANAGEMENT_MENU_SELECTION in
   0) DATABASE_MANAGEMENT_MENU ;;
   1) LIST_DATABASES ;;
   2) LIST_TABLES ;;
   3) LIST_TABLE_BIKES ;;
   4) LIST_TABLE_CUSTOMERS ;;
   5) LIST_TABLE_RENTALS ;;
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

LIST_TABLE_BIKES(){
	$PSQL "\d bikes"
	LIST_SCHEMA_MENU "Listed Table Bikes"
}

LIST_TABLE_CUSTOMERS(){
	$PSQL "\d customers"
	LIST_SCHEMA_MENU "Listed Table Customers"
}

LIST_TABLE_RENTALS(){
	$PSQL "\d rentals"
	LIST_SCHEMA_MENU "Listed Table Rentals"
}

## Create Database & Table Management ##

CREATE_DATABASE_AND_TABLES_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   echo -e "\n~~~~~ Create Database & Tables Menu ~~~~~"
   echo -e "\n0. Return To Database Management Menu\n1. Create Database\n2. Create Table Quotes\n3. Create Table Customers\n4. Create Table Rentals\n"
   echo "Enter Command: "
   read DATABASE_MANAGEMENT_MENU_SELECTION
   case $DATABASE_MANAGEMENT_MENU_SELECTION in
   0) DATABASE_MANAGEMENT_MENU ;;
   1) CREATE_DATABASE ;;
   2) CREATE_TABLE_QUOTES ;;
   3) CREATE_TABLE_CUSTOMERS ;;
   4) CREATE_TABLE_RENTALS ;;
   *) CREATE_DATABASE_AND_TABLES_MENU "Please enter a valid option." ;;
esac
}

CREATE_DATABASE(){
	$PSQL_CreateDatabase "CREATE DATABASE yourstockforecast;"
	CREATE_DATABASE_AND_TABLES_MENU
}

CREATE_TABLE_QUOTES(){
	$PSQL "CREATE TABLE quotes();"
	$PSQL "ALTER TABLE quotes ADD COLUMN bike_id SERIAL PRIMARY KEY;"
	$PSQL "ALTER TABLE quotes ADD COLUMN type VARCHAR(50) NOT NULL;"
	$PSQL "ALTER TABLE quotes ADD COLUMN size INT NOT NULL;"
	$PSQL "ALTER TABLE quotes ADD COLUMN available boolean NOT NULL Default(TRUE)";
	CREATE_DATABASE_AND_TABLES_MENU "Created Tables Quotes"
	
}

CREATE_TABLE_CUSTOMERS(){
	$PSQL "CREATE TABLE customers();"
	$PSQL "ALTER TABLE customers ADD COLUMN customer_id SERIAL PRIMARY KEY;"
	$PSQL "ALTER TABLE customers ADD COLUMN phone VARCHAR(15) NOT NULL UNIQUE;"
	$PSQL "ALTER TABLE customers ADD COLUMN name VARCHAR(40) NOT NULL;"
	CREATE_DATABASE_AND_TABLES_MENU
}

CREATE_TABLE_RENTALS(){
	$PSQL "CREATE TABLE rentals();"
	$PSQL "ALTER TABLE rentals ADD COLUMN rental_id SERIAL PRIMARY KEY;"
	$PSQL "ALTER TABLE rentals ADD COLUMN customer_id INT NOT NULL UNIQUE;"
	$PSQL "ALTER TABLE rentals ADD FOREIGN KEY(customer_id) REFERENCES customers(customer_id);"
	$PSQL "ALTER TABLE rentals ADD COLUMN bike_id INT NOT NULL;"
	$PSQL "ALTER TABLE rentals ADD FOREIGN KEY(bike_id) REFERENCES bikes(bike_id);"
	$PSQL "ALTER TABLE rentals ADD COLUMN date_rented DATE NOT NULL Default(Now());"
	$PSQL "ALTER TABLE rentals ADD COLUMN date_returned DATE;"
	CREATE_DATABASE_AND_TABLES_MENU
}

## Delete Database & Table Management ##

DELETE_DATABASE_MANAGEMENT_MENU(){
   if [[ $1 ]]
   then
      echo -e "\n$1"
   fi
   echo -e "\n~~~~~ Delete Database & Tables Menu ~~~~~"
   echo -e "\n0. Return To Database Management Menu\n1. Delete Database\n2. Delete Table Bikes\n3. Delete Table Customers\n4. Delete Table Rentals\n"
   echo "Enter Command: "
   read DATABASE_MANAGEMENT_MENU_SELECTION
   case $DATABASE_MANAGEMENT_MENU_SELECTION in
   0) DATABASE_MANAGEMENT_MENU ;;
   1) DELETE_DATABASE ;;
   2) DELETE_TABLE_BIKES ;;
   3) DELETE_TABLE_CUSTOMERS ;;
   4) DELETE_TABLE_RENTALS ;;
   *) DELETE_DATABASE_MANAGEMENT_MENU "Please enter a valid option." ;;
esac
}

DELETE_DATABASE(){
	$PSQL_CreateDatabase "DROP DATABASE bikes;"
	DELETE_DATABASE_MANAGEMENT_MENU
}

DELETE_TABLE_BIKES(){
	$PSQL "DROP TABLE bikes;"
	DELETE_DATABASE_MANAGEMENT_MENU
}

DELETE_TABLE_CUSTOMERS(){
	$PSQL "DROP TABLE customers;"
	DELETE_DATABASE_MANAGEMENT_MENU
}

DELETE_TABLE_RENTALS(){
	$PSQL "DROP TABLE rentals;"
	DELETE_DATABASE_MANAGEMENT_MENU
}

## Insert Data Management ##

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
