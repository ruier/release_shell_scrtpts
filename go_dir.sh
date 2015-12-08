#godir is a function
godir () 
{
    if [[ -z "$1" ]]; then
        echo "Usage: godir <regex>";
        return;
    fi;
    T=$PWD;
    if [[ ! -f $T/filelist ]]; then
        echo -n "Creating index...";
        ( \cd $T;
        find . -wholename ./out -prune -o -wholename ./.repo -prune -o -type f > filelist );
        echo " Done";
        echo "";
    fi;
    local lines;
    lines=($(\grep "$1" $T/filelist | sed -e 's/\/[^/]*$//' | sort | uniq));
    if [[ ${#lines[@]} = 0 ]]; then
        echo "Not found";
        return;
    fi;
    local pathname;
    local choice;
    if [[ ${#lines[@]} > 1 ]]; then
        while [[ -z "$pathname" ]]; do
            local index=1;
            local line;
            for line in ${lines[@]};
            do
                printf "%6s %s\n" "[$index]" $line;
                index=$(($index + 1));
            done;
            echo;
            echo -n "Select one: ";
            unset choice;
            read choice;
            if [[ $choice -gt ${#lines[@]} || $choice -lt 1 ]]; then
                echo "Invalid choice";
                continue;
            fi;
            pathname=${lines[$(($choice-1))]};
        done;
    else
        pathname=${lines[0]};
    fi;
    \cd $T/$pathname
}
