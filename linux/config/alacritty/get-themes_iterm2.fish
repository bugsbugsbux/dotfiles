if test -d themes_iterm2collection
    echo ERROR: themes_iterm2collection/ exists...
end

set -l tmpdir iTerm2-Color-Schemes
for i in (seq 11)
    test "$i" -lt 11
        or break
    test -d "$tmpdir"
    and set tmpdir "$tmpdir"_
    or break
end
if test "$i" -eq 11
    echo ERROR: could not create temporary directory... >&2
    exit 1
end

if git clone https://github.com/mbadolato/iTerm2-Color-Schemes.git "$tmpdir"
    mv "$tmpdir"/alacritty ./themes_iterm2collection
else
    begin
        echo -- ERROR: could not clone from mbadolato/iTerm2-Color-Schemes.git
        echo -- Do you have a working network connection?
    end >&2
    exit 1
end

rm -rf "$tmpdir"
