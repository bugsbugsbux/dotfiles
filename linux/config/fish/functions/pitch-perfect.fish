function _guess_note_play
    if not set -qg _guess_note
        echo "Error: Could not find the global var '_guess_note'" >&2
        exit 1
    end
    alda play -c "piano: o4 $_guess_note"2
end

function _guess_note_next
    if not set -qg _guess_notes
        echo "Error: Could not find the global var '_guess_notes'" >&2
        exit 1
    end
    set -g _guess_note (random choice $_guess_notes)
end

function _guess_note_init
    _guess_note_next
    _guess_note_play
end

function _guess_note_handler -a guess
    set guess (string trim -- "$guess")
    switch "$guess"
        case ''
            echo "Guess which note you hear:
    | | Db| Eb| | | Gb| Ab| Bb| | |   |
    | |   |   | | |   |   |   | | |   |
    | |C# |D# | | |F# |G# |A# | | |   |
    | |___|___| | |___|___|___| | |___|
    |   |   |   |   |   |   |   |   |
    | C | D | E | F | G | A | B | C |
 ...|__4|___|___|___|___|___|___|__5|..."
        case '?'
            echo "$_pitch_perfect_help"
        case c C
            if test "$_guess_note" = c; set -eg _guess_note; end
        case c+ C+ 'c#' 'C#' db Db d- D-
            if test "$_guess_note" = c+; set -eg _guess_note; end
        case d D
            if test "$_guess_note" = d; set -eg _guess_note; end
        case d+ D+ 'd#' 'D#' eb Eb e- E-
            if test "$_guess_note" = d+; set -eg _guess_note; end
        case e E
            if test "$_guess_note" = e; set -eg _guess_note; end
        case f F
            if test "$_guess_note" = f; set -eg _guess_note; end
        case f+ F+ 'f#' 'F#' gb Gb g- G-
            if test "$_guess_note" = f+; set -eg _guess_note; end
        case g G
            if test "$_guess_note" = g; set -eg _guess_note; end
        case g+ G+ 'g#' 'G#' ab Ab a- A-
            if test "$_guess_note" = g+; set -eg _guess_note; end
        case a A
            if test "$_guess_note" = a; set -eg _guess_note; end
        case a+ A+ 'a#' 'A#' bb Bb b- B-
            if test "$_guess_note" = a+; set -eg _guess_note; end
        case b B
            if test "$_guess_note" = b; set -eg _guess_note; end
        case '*'
            echo "Invalid command"
    end

    # Give feedback, get next note if needed.
    if not set -qg _guess_note
        echo \
            (set_color -o green)"Congratulations!"\
            "Here comes the next note..."\
            (set_color normal)
        _guess_note_next
    else
        echo \
            (set_color -o red)'False. Try again...'\
            (set_color normal)
    end

    # play next note
    _guess_note_play
end

function pitch-perfect
    set -g _pitch_perfect_help (set_color -o red)"\
pitch-perfect: Train your pitch recognition.

This drops you into a repl playing a note and asking which it was. You
will hear the tone in every iteration. Just hit Enter to hear it again.

Commands:
    ?               Print this help.
    '' (empty)      Show the piano keys of the 4th octave.
    a b c d e f g   Guess this note; may be capitalized.
                    May be followed by a sharp sign (# or +) or
                    a flat sign (b or -).
    ^C (ctrl+c)     End game.

Options:
    -h --help       Print this help.
    --easy          Only use 8 notes (a-g) instead of 12
"(set_color normal)

    set -g _guess_notes c c+ d d+ e f f+ g g+ a a+ b

    switch "$argv[1]"
        case -h --help
            echo "$_pitch_perfect_help"
            exit 0
        case --easy
        set -g _guess_notes a b c d e f g
    end

    # check dependencies
    if not type -q alda
        echo "Error: Could not find 'alda' in your path!" >&2
        exit 1
    end

    _repl_prompt="Your Guess (? for help, Enter to replay): " \
    _repl_type=2 \
    _repl_init=_guess_note_init \
    repl _guess_note_handler
end
