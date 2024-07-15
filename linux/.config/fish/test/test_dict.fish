# TODO:
# test if trailing whitespace is handled correctly
#   eg: _get foo = " starts and ends with a space "
# test if the encapsulation of dictionaries works
#   eg: set some locals in a function and then
#   perform some dictionary operation. 


# these vars have to be globals
# (to not be confused with keys):
set -ql fish_trace
    and set -g fish_trace $fish_trace && set -el fish_trace
set -g red (set_color red)
set -g green (set_color green)
set -g normal (set_color normal)
set -g err_file /tmp/test_dict_stderr
# and these must not be locals:
echo -- "$green"checking for local variables..."$normal"
if test (set -nl | string match -v argv | count) -ne 0
    begin
        echo "$red"You must not have local variables set 
        echo when running this test file.
        echo These were found:
        echo -- (set -nl) $normal
    end >&2
    exit 1
end

# source the file to test
# (this script assumes to be in fish/test/)
echo -n $red
source ../dict.fish
    or exit 1
echo -n $normal


function assert_stderr \
-V err_file -V red -V green -V normal \
-d 'false if "$argv" != (cat $err_file)'
    if test "$argv" != ( # cat file and handle empty files
            count (cat $err_file) &>/dev/null
            and cat $err_file
            or echo "")
        begin
            echo $red(status function) error:
            echo ---
            cat $err_file
            echo ---
            echo should be:
            echo "$argv"
            echo --- $normal
        end >&2
        return 1
    end
end

function assert_out \
-S -V err_file -V red -V green -V normal \
-d 'false if values of $argv and $out are not the same - element by element'

    # same amount of elements
    set -l len_out (count $out)
    test (count $argv) -eq "$len_out"
        or begin
            begin
                echo $red(status function) error:
                echo output has (count $argv) args but should have "'$len_out'" $normal
            end >&2
            return 1
        end

    # same string for each element
    set -l i 0
    while test "$i" -le "$len_out"
        set i (math $i + 1)
        test "$argv[$i]" = "$out[$i]"
            or begin
                begin
                    echo $red(status function) error:
                    echo element $i is:
                    echo -n \>
                    echo -n -- $out[$i]
                    echo \<
                    echo but should be:
                    echo -n \>
                    echo -n -- $argv[$i]
                    echo \< $normal
                end
                return 1
            end
    end
end

function print_title -V green -V normal
    echo -- (set_color --bold )"$green""$argv""$normal"
end
function print_subtitle -V green -V normal
    echo -e -- "$green""\t+ $argv""$normal"
end
function fail
    echo -n -- (set_color --bold)"$red"FAIL"$normal"
    count $argv &>/dev/null
    and echo -- "$red"": $argv""$normal"
    or echo  # end line
    exit 1
end

########## test _keys ##########
print_title testing _keys ...
##### 
print_subtitle completely empty dict
rm -f $err_file
function T
    eval $argv
end
set -- out (T _keys 2>$err_file)
test "$status" -eq 1
and assert_out  # none
# and assert_stderr <++ msg>
or fail

#####
print_subtitle no keys
rm -f $err_file
function T
    set -l __dict (status function)
    eval $argv
end
set -- out (T _keys 2>$err_file)
test "$status" -eq 1
and assert_out  # none
# and assert_stderr <++ msg>
or fail

#####
print_subtitle one key
rm -f $err_file
function T
    set -l foo bar baz "multi
line" "string with space"
    set -l __dict (status function)
    eval $argv
end
set -- out (T _keys 2>$err_file)
test "$status" -eq 0
and assert_out foo
and assert_stderr ""
or fail

#####
print_subtitle multiple keys
rm -f $err_file
function T
    set -l foo bar baz "multi
line" "string with space"
    set -l bar              # no value
    set -l baz ""           # empty value
    set -l _baz x y z 1 2 3 # key with underscore
    set -l __dict (status function)
    eval $argv
end
# the following `sort` are necessary because i cant
# predict the order of `set -n`
set -- out (T _keys 2>$err_file | sort -)
test "$status" -eq 0
and assert_out (for key in foo bar baz _baz
                    echo $key
                end | sort -)
and assert_stderr ""
or fail

########## test _get ##########
print_title testing _get ...
##### wrong number of args
rm -f $err_file
function T
    eval $argv
end
#
print_subtitle no args instead of 1
# NOTE: _get has to be used with string-split0
set -- out (T _get 2>$err_file | string split0)  # no arg
test "$pipestatus[1]" -eq 101
and assert_out  # none
    or fail
#
print_subtitle too many args instead of 1
rm -f $err_file
set -- out (T _get foo bar 2>$err_file | string split0)  # too many args
test "$pipestatus[1]" -eq 101
and assert_out  # none
    or fail
#
print_subtitle completely empty dict
rm -f $err_file
set -- out (T _get foo 2>$err_file | string split0)
test "$pipestatus[1]" -eq 101
and assert_out  # none
    or fail
#
print_subtitle key does not exist in empt dict
rm -f $err_file
set -- out (T _get foo 2>$err_file | string split0)
test "$pipestatus[1]" -eq 101
    # = syntax error; dont use _get
    # for existance checking
and assert_out  # none
    or fail
#
print_subtitle no keys bc argv and __\* do not count
rm -f $err_file
function T
    set -l __dict (status function)
    eval $argv
end
set -- out (T _get foo 2>$err_file | string split0)
test "$pipestatus[1]" -eq 101
    # = syntax error; dont use _get
    # for existance checking
and assert_out  # none
    or fail
#
print_subtitle 'key not contained'
rm -f $err_file
function T
    set -l baz 1 2 3  # a valid key
    set -l __dict (status function)
    eval $argv
end
set -- out (T _get foo 2>$err_file | string split0)
# yes syntax err bc _get is not for existance checking:
test "$pipestatus[1]" -eq 101
and assert_out  # none
    or fail
#
print_subtitle 'empty value'
rm -f $err_file
function T
    set -l foo  # a valid key without a value
    set -l __dict (status function)
    eval $argv
end
set -- out (T _get foo 2>$err_file | string split0)
test "$pipestatus[1]" -eq 1  # because there is no value
and assert_out  # none
    or fail
#
print_subtitle 'value is an empty string'
rm -f $err_file
function T
    set -l foo ''
    set -l __dict (status function)
    eval $argv
end
set -- out (T _get foo 2>$err_file | string split0)
test "$pipestatus[1]" -eq 0  # bc there is a value: an empty string
and assert_out ""
    or fail
##
print_subtitle 'get simple value'
rm -f $err_file
function T
    set -l foo bar
    set -l __dict (status function)
    eval $argv
end
set -- out (T _get foo 2>$err_file | string split0)
test "$pipestatus[1]" -eq 0
and assert_out bar
    or fail
#
print_subtitle 'value is a simple list'
rm -f $err_file
function T
    set -l foo bar baz 3 foobar
    set -l __dict (status function)
    eval $argv
end
set -- out (T _get foo 2>$err_file | string split0)
test "$pipestatus[1]" -eq 0
and assert_out bar baz 3 foobar
    or fail
#
print_subtitle 'value contains empty strings'
rm -f $err_file
function T
    set -l foo bar "" baz "" foobar
    set -l __dict (status function)
    eval $argv
end
set -- out (T _get foo 2>$err_file | string split0)
test "$pipestatus[1]" -eq 0
and test (count $out) -eq 5
and assert_out bar "" baz "" foobar
or fail
#
print_subtitle 'value is a list of strings'
rm -f $err_file
function T
    set -l foo bar "baz foobar"
    set -l __dict (status function)
    eval $argv
end
set -- out (T _get foo 2>$err_file | string split0)
test "$pipestatus[1]" -eq 0
and assert_out bar "baz foobar"
    or fail
#
print_subtitle 'get a multiline string'
rm -f $err_file
function T
    set -l foo "multiline
string"
    set -l __dict (status function)
    eval $argv
end
set -- out (T _get foo 2>$err_file | string split0)
test "$pipestatus[1]" -eq 0
and test (count $out) -eq 1
and assert_out "multiline
string"
    or fail
#
print_subtitle 'get list with multiline strings'
rm -f $err_file
function T
    set -l foo hello world "it is my honor
to present to you:" "dictionaries with
support for multiline strings" enjoy!
    set -l __dict (status function)
    eval $argv
end
set -- out (T _get foo 2>$err_file | string split0)
test "$pipestatus[1]" -eq 0
and test (count $out) -eq 5
and assert_out hello world "it is my honor
to present to you:" "dictionaries with
support for multiline strings" enjoy!
    or fail
#


########## test _rebuild ##########
print_title testing _rebuild ...
#
print_subtitle 'rebuilding dict without __dict fails'
rm -f $err_file
function T
    eval $argv
end
set -- out (T _rebuild 2>$err_file)
test "$status" -eq 1
and assert_out
and assert_stderr
    or fail
#
print_subtitle 'dict without items rebuilds successfully'
rm -f $err_file
function T
    set -l __dict (status function)
    eval $argv
end
set -- out (T _rebuild 2>$err_file)
test "$status" -eq 0
and assert_out
and assert_stderr
    or fail
set locals (T set -nl)
test (count $locals) -eq 2  # argv, __dict
and contains argv $locals
and contains __dict $locals
and test (T echo \$__dict) = T  # __dict gives function-name
    or fail
#
print_subtitle 'rebuild dict with items'
rm -f $err_file
function T
    set -l x
    set -l X ""
    set -l y hello
    set -l z "hello world" what is up?
    set -l foo Now comes a "multiline
string" So cool, "isn't" it!

    set -l __dict (status function)
    eval $argv
end
set -- out (T _rebuild 2>$err_file)
test "$status" -eq 0
and assert_out
and assert_stderr
    or fail
set locals (T set -nl)
test (count $locals) -eq 7  # argv,x,X,y,z,foo,__dict
    or fail
for local in argv x X y z foo __dict
    contains $local $locals
        or fail
end
T 'test (count $x) -eq 0
or fail'
T 'test (count $X) -eq 1
and test -z "$X[1]"
or fail'
T 'test (count $y) -eq 1
and test "$y[1]" = hello
or fail'
T 'test (count $z) -eq 4
and test "$z[1]" = "hello world"
and test "$z[2]" = what
and test "$z[3]" = is
and test "$z[4]" = up?
or fail'
T 'test (count $foo) -eq 8
and test "$foo[1]" = Now
and test "$foo[2]" = comes
and test "$foo[3]" = a 
and test "$foo[4]" = "multiline
string"
and test (count (string split \n $foo[4])) -eq 2
and test "$foo[5]" = So
and test "$foo[6]" = cool,
and test "$foo[7]" = isn\\\'t
and test "$foo[8]" = it!
or fail'
# ' # this quote fixes the vims bash-syntax-highlighting
print_subtitle 'rebuild with updated keys/values'
rm -f $err_file
function T
    set -l foo old value
    set -l bar not mentioned but must stay
    set -l baz to delete
    set -l __ignore because _keys ignores it

    set -l __dict (status function)  # rebuild keeps this explicitly
    eval $argv
end
function some_new_method -S
    set -l foo new value
    # bar not mentioned
    set -el baz  # deleted
    set -l new_item this item is new
    _rebuild
end
test (count (T set -nl)) -eq 6
    or fail "faulty test: T should have 6 locals"
set -- out (T some_new_method 2>$err_file)
test "$status" -eq 0
    or fail wrong exit status
assert_out
    or fail wrong stdout
assert_stderr
    or fail wrong stderr
test (count (T set -nl)) -eq 5  # argv,__dict,foo,bar,new_item
    or fail "deleting key or ignoring local didn't work"
test (for key in foo bar __dict new_item
        echo $key
    end | sort - | string collect -N) = \
    (T set -nl | string match -v argv \
        | sort - | string collect -N)
or fail T should have different locals
T 'test (count $foo) -eq 2
and test "$foo" = "new value"
    or fail value of foo wasnt changed correctly
test (count $bar) -eq 5
and test "$bar[1]" = not
and test "$bar[2]" = mentioned
and test "$bar[3]" = but
and test "$bar[4]" = must
and test "$bar[5]" = stay
    or fail value of bar is incorrect
test "$__dict" = T
    or fail value of __dict if incorrect
test (count $new_item) -eq 4
and test "$new_item[1]" = this
and test "$new_item[2]" = item
and test "$new_item[3]" = is
and test "$new_item[4]" = new
    or fail value of new_item is incorrect
'
#
