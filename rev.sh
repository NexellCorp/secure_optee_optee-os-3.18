#!/bin/bash

# var="12345678"
var=$1
len=${#var}
for((i=$len-2;i>=0;i-=2)); do rev="$rev${var:$i:2}"; done

# echo "var: $var, rev: $rev"
echo -e $rev
