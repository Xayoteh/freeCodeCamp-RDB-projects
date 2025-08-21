#/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
QUERY_COLUMS="SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id)"

SHOW_ELEMENT_INFO() {
  if [[ ! $1 ]]; then
    echo Please provide an element as an argument.
    return
  fi

  if [[ $1 =~ ^[0-9]+$ ]]; then
    QUERY_FILTER="atomic_number=$1"
  else
    QUERY_FILTER="name='$1' OR symbol='$1'"
  fi

  QUERY_RESULT=$($PSQL "$QUERY_COLUMS WHERE $QUERY_FILTER");

  if [[ -z $QUERY_RESULT ]]; then
    echo I could not find that element in the database.
    return
  fi
  
  IFS='|' read  ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE <<< $QUERY_RESULT
  
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
}

SHOW_ELEMENT_INFO $1
