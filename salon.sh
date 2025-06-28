#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

CREATE_APPOINTMENT() {
  # Get and clean customer ID and name
  CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUST_ID=$(echo "$CUST_ID" | sed -E 's/^\s+|\s+$//g')
  CUST_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUST_NAME=$(echo "$CUST_NAME" | sed -E 's/^\s+|\s+$//g')

  # Get and clean service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo "$SERVICE_NAME" | sed -E 's/^\s+|\s+$//g')

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUST_NAME?"
  read SERVICE_TIME

  # Insert appointment
  INSERTED=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUST_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUST_NAME."
  exit 0
}

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Display list of services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  # Validate service
  HAVE_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $HAVE_SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Check if customer exists
  CUST_INFO=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUST_INFO ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERTED=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # Create appointment
  CREATE_APPOINTMENT
}

MAIN_MENU
