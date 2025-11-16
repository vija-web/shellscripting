#!/bin/bash

export name1="Up to session it works"

#you can basically use the varibale name1 outside of the script and in the terminal
# as well like echo $name1 you will get the value.But until you can use your session
# live , if you login again to the server then this varibales you can't access.

#suppose if you wnat the varibales after your session expires
#if it should work for even after the session ends then 
# in the home directory of the user .bashrc file include
#export name2="Life time the variable will be present"
#To apply the changes we need to execute the command source .bashrc
