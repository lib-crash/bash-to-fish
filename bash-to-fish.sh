#!/bin/bash
IF_FILE=bash.sh
OF_FILE=/dev/stdout
IS_DEBUG=0

if [ "$#" == "0" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]
then
    echo "usage: $(basename "$0") [OPTIONS] <bash file> [fish file]"
    echo "description:"
    echo "  it tries to convert all bash syntax to fish syntax"
    echo "  and then prints it to stdout. Or writes it to given"
    echo "  fish file."
    echo "options:"
    echo "  --debug"
    exit 0
fi
if [ "$1" == "--debug" ]
then
    IS_DEBUG="1"
    shift
fi
IF_FILE="$1"
if [ ! -f "$IF_FILE" ]
then
    echo "Error: file '$IF_FILE' does not exist." 2>&1
    exit 1
fi
if [ "$2" != "" ]
then
    OF_FILE="$2"
    echo "writing output to '$OF_FILE' ..."
fi

function rule() {
    if [ "$IS_DEBUG" != "1" ]
    then
        return
    fi
    printf '%s: ' "$1"
}

while read -r line
do
    sed_line="$(echo "$line" | \
        sed 's/#!\/bin\/bash/#!\/usr\/bin\/env fish/' | \
        sed 's/#!\/usr\/bin\/env bash/#!\/usr\/bin\/env fish/' | \
        sed 's/; then/;/; s/;then/;/; s/^then$//' | \
        sed 's/^fi$/end/g; s/^fi;/end;/g; s/;fi;/;end;/g; s/; fi;/; end;/g' | \
        sed 's/^}$/end/; s/^{$//' | \
        sed 's/if \! \[\[ \$- == \*i\* \]\]/if status --is-login/' | \
        sed 's/\$1/\$argv[1]/g; s/\$2/\$argv[2]/g' | \
        sed 's/\$3/\$argv[3]/g; s/\$4/\$argv[4]/g' | \
        sed 's/\$5/\$argv[5]/g; s/\$6/\$argv[6]/g' | \
        sed 's/\$7/\$argv[7]/g; s/\$8/\$argv[8]/g' | \
        sed 's/\$9/\$argv[9]/g; s/\$0/\$argv[0]/g' | \
        sed 's/\$@/\$argv/g' | \
        sed 's/\$?/\$status/g')"
    if [ "$sed_line" != "$line" ]
    then
        rule 0
        line="$sed_line"
    fi

    if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9]**)=\"\$\((.*)\)\"$ ]]
    then
        # subshell
        rule 1
        echo "set ${BASH_REMATCH[1]} \"(${BASH_REMATCH[2]})\""
    elif [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9]**)=\"\$\((.*)\\$ ]]
    then
        # multiline subshell
        rule 2
        echo "set ${BASH_REMATCH[1]} \"(${BASH_REMATCH[2]}\\"
    elif [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9]**)=\"\$(.*)\"$ ]]
    then
        # variable set
        rule 3
        echo "set ${BASH_REMATCH[1]} \"${BASH_REMATCH[2]}\""
    elif [[ "$line" =~ (.*)if\ \[(.*)\](.*) ]]
    then
        # if statement comparision '==' -> '='
        rule 4
        echo "${BASH_REMATCH[1]}if [$(echo "${BASH_REMATCH[2]}" | \
            sed 's/" == "/" = "/g')]${BASH_REMATCH[3]}"
    elif [[ "$line" =~ ^function\ (.*)\(\)$ ]]
    then
        # function header 1
        rule 5
        echo "function ${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^function\ (.*)\(\)\ \{$ ]]
    then
        # function header 2
        rule 6
        echo "function ${BASH_REMATCH[1]}"
    else
        rule 7
        echo "$line"
    fi
done < "$IF_FILE" > "$OF_FILE"

if [ "$OF_FILE" != /dev/stdout ] && [ -f "$OF_FILE" ]
then
    chmod +x "$OF_FILE"
fi

