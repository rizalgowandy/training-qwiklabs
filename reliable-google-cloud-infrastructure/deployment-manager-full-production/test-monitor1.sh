#!/bin/bash
for ((c = 1; c <= 250; c++)); do
  echo "$c"
  curl -s "http://34.95.86.33:8080/"
done
