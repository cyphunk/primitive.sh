#!/usr/bin/env bash
# Some functions used often in other scripts. This can be sourced but is discouraged. We copy+paste code from here instead. This avoids specific security concerns and makes original scripts easier to comprehend.

# Check that this script ($0) only modifable by root
#  Avoid potential local priviledge escalation vulnerabilities.
root_check ()
{
    # check symlink security as well
    test -L $0 \
    && l=($(cd $(dirname $1) && pwd)) \
    || l=($(/usr/bin/ls -l `/usr/bin/readlink -f $0`))
    [ ${l[0]:2:1} != "-" ] && [ "${l[2]}" != "root" ] ||
    [ ${l[0]:5:1} != "-" ] && [ "${l[3]}" != "root" ] ||
    [ ${l[0]:8:1} != "-" ] && { echo -e "only root should be able to modify\n${l[@]}"; exit 1;}
}
# stop if a command is missing
require_commands () 
{
    err=0
    for cmd in $*; do
        command -v $cmd >/dev/null && continue || { echo "$cmd command not found."; err=1; }
    done
    test $err -eq 1 && exit 1
}
###
# create usage from case statement. 
# Strict formatting: space tabbed exactly 2 or 4 depth
# 
#  case "$1" in
#    list)
#    # description line
#    # description line2 
#    # ...
usage_self ()
{
    echo -en "usage: $(basename "$0") ";
    grep  -P '^ {2,4}[^ \(\*]*\)' $0 | sed -e 's/)//g' -e 's/ +/ /g' -e 's/--//g' | xargs | sed 's/ /\|/g' ;
    echo "";
    grep -P '^ {2,4}[^ \(\*]*\)' -A 30 $0 | grep -P -B 1 '^ {2,4}#' | sed -e 's/# //' -e 's/--//g' ;
    echo "";
}



###
# alert if target script contains different helper.sh functions
##
test "$1" = "" && \
echo -e "usage: $0 <script_to_check>" \
     "\n" \
     "Running on script checks if functions found in target script differ from those found in $0"

check_helpers () 
{
    # get function name line to check from helpers.sh
    IFS=$'\n'
    funcs=$(grep -v '^#' helpers.sh | grep '()[ {]*$' monitor)
    for sh in $*; do
        for func in $funcs; do
            # echo ">> $sh: $func"
            name=$(echo "$func" | sed 's/ *function *//')
            name=$(echo "$name" | cut -d' ' -f 1)
            type -t $name >/dev/null || continue
            source=$(type $name | tail +2)
            length=$(echo "$source" | wc -l)
            target=$(grep -v '^#' $sh | grep --fixed-strings "$func" -A$length)
            diff=$(diff -y -a --ignore-blank-lines --ignore-tab-expansion --ignore-all-space --suppress-common-lines \
              <(echo "$source") <(echo "$target") )
            test "$diff" = "" && continue
            echo "$name differs in '$sh'"
            echo "$diff"
        done
    done
}

check_helpers $*
