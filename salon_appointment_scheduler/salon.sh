#! /bin/bash

RUN() {
  INIT
  GREET
  READ_SERVICE
  READ_PHONE
  READ_TIME
  SCHEDULE_APPOINTMENT
}

INIT() {
  PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
}

GREET() {
  echo -e "\n~~~~~ MY SALON ~~~~~"
  echo -e "\nWelcome to My Salon, how can I help you?\n"
}

READ_SERVICE() {
  if [[ -n $1 ]]; then
    echo -e "\n$1"
  fi

  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  CHECK_VALID_SERVICE 
}

CHECK_VALID_SERVICE() {
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]$ ]]; then
    READ_SERVICE "I could not find that service. What would you like today?"
    return
  fi

  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME_SELECTED ]]; then
    READ_SERVICE "I could not find that service. What would you like today?"
  fi
}

READ_PHONE() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CHECK_CUSTOMER_EXISTS
}

CHECK_CUSTOMER_EXISTS() {
  CUSTOMER_INFO=$($PSQL "SELECT customer_id, phone, name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_INFO ]]; then
    REGISTER_CUSTOMER
  else
    IFS="|" read CUSTOMER_ID CUSTOMER_PHONE CUSTOMER_NAME <<< $CUSTOMER_INFO
  fi
}

REGISTER_CUSTOMER() {
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  QUERY_RESULT=$($PSQL "INSERT INTO customers(phone, name) values ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
}

READ_TIME() {
  echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
  read SERVICE_TIME
}

SCHEDULE_APPOINTMENT() {
  QUERY_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo "I have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
}

RUN