#!/bin/bash

echo "Please enter the names"
read PERSON1 #these are the variables no spaces b/w variable name and = and value
read PERSON2

echo "Please enter the pin"
read -s PIN # it will not show the entered value on the screen.

echo "your pin is $PIN "
echo "$PERSON1 :: Hello $PERSON2! How are you ?" 
echo "$PERSON2 :: Hai $PERSON1 , Yes I'am fine what about you ?"
echo "$PERSON1 :: I'am Fine $PERSON2"

#we will call the vaule with the variables names specifiying with the $ 
#Note there should be no spaces 
#PERSON1 = "Mahesh" 
#PERSON2 = "Poojitha"

# if you want to give the inputs as args to the script 
# sh varibales.sh vijay poojitha 
# PERSON1 = $1 (vijay)
# PERSON2 = $2 (Poojitha)

# suppose if you want to pass the values in the runtime then 
# read -s used to read the secret values
# read <Variable_Name>
