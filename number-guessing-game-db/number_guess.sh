#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

DISPLAY() {
  echo -e "\n~~~~~ Number Guessing Game ~~~~~\n" 

  # Get username
  echo "Enter your username:"
  read USERNAME

  # Get user ID from the database
  USER_ID=$($PSQL "select u_id from users where name = '$USERNAME'")

  # If user is present
  if [[ $USER_ID ]]; then
    # Get games played
    GAMES_PLAYED=$($PSQL "select count(u_id) from games where u_id = '$USER_ID'")

    # Get best game (fewest guesses)
    BEST_GUESS=$($PSQL "select min(guesses) from games where u_id = '$USER_ID'")

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
  else
    # If username not present in the database
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

    # Insert new user into the users table
    INSERTED_TO_USERS=$($PSQL "insert into users(name) values('$USERNAME')")
    # Get user ID after insertion
    USER_ID=$($PSQL "select u_id from users where name = '$USERNAME'")
  fi

  # Start the game
  GAME
}

GAME() {
  # Secret number generation
  SECRET=$((1 + $RANDOM % 1000))

  # Count of tries
  TRIES=0
  GUESSED=0
  echo -e "\nGuess the secret number between 1 and 1000:"

  while [[ $GUESSED = 0 ]]; do
    read GUESS

    # Validate input
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
    elif [[ $SECRET = $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
      
      # Insert game result into the database
      INSERTED_TO_GAMES=$($PSQL "insert into games(u_id, guesses) values($USER_ID, $TRIES)")
      GUESSED=1
    elif [[ $SECRET -gt $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's higher than that, guess again:"
    else
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's lower than that, guess again:"
    fi
  done
}

# Start the game
DISPLAY
