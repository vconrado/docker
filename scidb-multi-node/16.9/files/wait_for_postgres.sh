#/bin/bash

printf "Waiting postgresql startup "
until pg_isready >> /dev/null; do 
  printf "." 
  sleep 1
done
sleep 2
echo -e "\nDone"
