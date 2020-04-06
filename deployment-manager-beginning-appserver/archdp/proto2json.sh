#!/usr/bin/env bash

echo "$1"
sed -i 's/string/"string"/g' "$1"
sed -i 's/boolean/"boolean"/g' "$1"
sed -i 's/integer/"integer"/g' "$1"
sed -i 's/unsigned long/"unsigned long"/g' "$1"
sed -i 's/bytes/"bytes"/g' "$1"
sed -i 's/(key)/"(key)"/g' "$1"
sed -i 's/float/"float"/g' "$1"
sed -i 's/etag/"etag"/g' "$1"
sed -i 's/long,/"long",/g' "$1"
