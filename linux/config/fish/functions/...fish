function .. -a n -d "cd up n-times"
    test -z "$n"
    and set $n 1
    for i in (seq "$n")
        cd ..
    end
end
