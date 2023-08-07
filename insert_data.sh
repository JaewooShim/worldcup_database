#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")

# year,round,winner,opponent,winner_goals,opponent_goals

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # skip the first line
  if [[ $ROUND != 'round' ]]
  then
    # get winner and opponent id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # winner id not found
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER = 'INSERT 0 1' ]]
      then
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      fi
    fi

    # opponent id not found
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT = 'INSERT 0 1' ]]
      then
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      fi
    fi

    # time to put data into games
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME = 'INSERT 0 1' ]]
    then 
      echo Successfully added
    fi
  fi
done