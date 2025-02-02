#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~~~~ MY SALON ~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

CREATE_APPOINTMENT() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  C_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  C_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/\s//g' -E)
  C_NAME_FORMAT=$(echo $C_NAME | sed 's/\s//g' -E)
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $C_NAME_FORMAT?"
  read SERVICE_TIME
  INSERT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($C_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $C_NAME_FORMAT."
}

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  while true; do
    SERVICES=$($PSQL "SELECT service_id, name FROM services;")
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME Service"
    done

    read SERVICE_ID_SELECTED
    OTHER_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    if [[ -z $OTHER_SERVICE ]]
    then
      echo -e "\nI could not find that service. Please choose from the list above."
    else
      break
    fi
  done

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  HAVE_CUZ=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $HAVE_CUZ ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  CREATE_APPOINTMENT
}

MAIN_MENU
