#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GAME() {
  READ_USER
  GUESS
  REGISTER_SCORE
}

READ_USER() {
  echo "Enter your username:" 
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  if [[ -z $USER_ID ]]; then
    REGISTER_USER
  else
    GREET
  fi
}

REGISTER_USER() {
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
}

GREET() {
  USER_GAMES_INFO=$($PSQL "SELECT COUNT(*), MIN(guesses) FROM games WHERE user_id=$USER_ID GROUP BY user_id")
  if [[ -z $USER_GAMES_INFO ]]; then
    GAMES=0
    BEST_GAME_GUESSES=0
  else
    IFS='|' read GAMES BEST_GAME_GUESSES <<< $USER_GAMES_INFO
  fi

  echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST_GAME_GUESSES guesses."
}

GUESS() {
  SECRET_NUMBER=$(($RANDOM % 1000 + 1))
  GUESS_COUNT=0
  echo "Guess the secret number between 1 and 1000:" 
  read USER_GUESS

  while [ true ]
  do
    ((GUESS_COUNT++))
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
      ((GUESS_COUNT--))
    elif [[ $USER_GUESS -gt $SECRET_NUMBER ]]; then
      echo "It's lower than that, guess again:"
    elif [[ $USER_GUESS -lt $SECRET_NUMBER ]]; then
      echo "It's higher than that, guess again:"
    else
      break
    fi

    read USER_GUESS
  done

  echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
}

REGISTER_SCORE() {
  RESULT=$($PSQL "INSERT INTO games(user_id, guesses) values($USER_ID, $GUESS_COUNT)")
}

GAME
