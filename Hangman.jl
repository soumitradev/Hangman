# RECOMMENDED: Use macOS or linux, Gtk on Windows is too slow. I made this on Windows :(
using  Gtk, Graphics, Cairo

# Create canvas on which man is drawn
c = @GtkCanvas(600, 600)

# Render a line on the canvas: No documentation found, but thanks to Casey Kneale!
# Original snippet by Casey Kneale here: https://gist.github.com/caseykneale/49e447f41427cfdcc1efbd681c8f6833
function render_line(ctx::CairoContext, start, finish ; dash = nothing, RGB = (0,0,0))
    @assert(length(start) == 2); @assert(length(finish) == 2); @assert(length(RGB) == 3)
    set_source_rgb(ctx, RGB...);
    if !isa(dash, Nothing)
        set_dash(ctx, dash)
    end
    move_to(ctx, start...);
    line_to(ctx, finish...);
    Gtk.stroke(ctx)
    return nothing
end

# Get input recursively: If error, call same function again
# needs_word specifies if the input required is a word or letter: true if word, or false if letter
function get_input(text_to_print, needs_word, in_same_line)
    in_same_line ? print(text_to_print) : println(text_to_print)
    txtin = lowercase(readline());
    if needs_word && length(split(txtin, " ")) > 1
        println("Please enter valid input (1 word only)")
        get_input(text_to_print, needs_word, in_same_line)
    elseif !needs_word && length(split(txtin, "")) > 1
        println("Please enter valid input (1 letter only)")
        get_input(text_to_print, needs_word, in_same_line)
    else
        return txtin
    end        
end

# Draw the initial setup for hangman
@guarded draw(c) do widget
    ctx = getgc(c)
    h = height(c)
    w = width(c)

    render_line(ctx, [200, 80], [200, 30])
    render_line(ctx, [200, 30], [300, 30])
    render_line(ctx, [300, 500], [300, 30])
    render_line(ctx, [250, 500], [350, 500])
end

# Draw the man according to the number of guesses left
function render_man(lefta)
    abc = [([200, 180], [200, 350]), ([200, 180], [150, 280]), ([200, 180], [250, 280]), ([200, 350], [150, 450]), ([250, 350], [200, 450])]
    @guarded draw(c) do widget
        ctx = getgc(c)
        h = height(c)
        w = width(c)
        
        ind = 6 - lefta

        if ind == 1
            arc(ctx, 200, 130, 50, 0, 2pi)
            render_line(ctx, [200, 80], [200, 80])
        elseif ind > 1
            render_line(ctx, abc[ind-1][1], abc[ind-1][2])
        end
    end
end

# Print start screen
println("""
    
██   ██   █████   ███    ██   ██████   ███    ███   █████   ███    ██
██   ██  ██   ██  ████   ██  ██        ████  ████  ██   ██  ████   ██
███████  ███████  ██ ██  ██  ██   ███  ██ ████ ██  ███████  ██ ██  ██
██   ██  ██   ██  ██  ██ ██  ██    ██  ██  ██  ██  ██   ██  ██  ██ ██
██   ██  ██   ██  ██   ████   ██████   ██      ██  ██   ██  ██   ████                                                                
""")

# Hide previous input line and overwrite with current partially guessed word
function show_word()
    print("\u1b[1F")
    print(join(current_array, " "))
    print("\u1b[0K")
end

# Start up game using get_input
word = get_input("Player 1, please enter your word (word will disappear once entered): ", true, true)

# Open and setup window for man to be drawn
game_window = GtkWindow("Hangman", 600, 600)

g = GtkGrid()
g[1, 1] = c

set_gtk_property!(g, :column_homogeneous, true)
set_gtk_property!(g, :column_spacing, 15)  # introduce a 15-pixel gap between columns
push!(game_window, g)
showall(game_window)

# Create a empty word (not revealed at all), and display it
current_array = ["__" for x in 1:length(word)]
show_word()

# Define number of wrong guesses left
left = 6

# Run game until end game state is reached
while true
    # Make wrong guesses left global so we can use it inside the while loop. If this is removed, it stops working for some reason.
    global left

    # Print the prompt for guessing the letter, and get its input
    println()
    letter = get_input("Player 2, guess a letter in the word: You have $left guesses left!", false, false)    
    print("\u1b[1F")

    # Check if letter guessed is in the word
    for (index, check_letter) in enumerate(split(word, ""))
        if letter == check_letter
            current_array[index] = letter
        end
    end

    # If letter is not in word and is not guessed already, reduce number of wrong left chances by one, and render the man again
    if !(letter in current_array)
        left -= 1
        render_man(left)
    end

    # Show updated word with partially guessed letters
    show_word()

    # If game is in ending state, break out of the loop and declare winner
    if !("__" in current_array) || (left == 0)
        break
    end
end

# Declare winner
println()
if left == 0
    println("Player 1 wins! Sorry Player 2, you took the L here. The word was \"$word\"")
else
    println("Player 2 wins! Sorry, Player 1, let's have a harder one next time.")
end

# Create recursive function to ask if player wnats to play again.
function replay_prompt()
    print("Play again? (y/n): ")
    reply = lowercase(readline());
    if reply == "y"
        visible(game_window, false)
        run(`julia $PROGRAM_FILE`)
        exit()
    elseif reply == "n"
        exit()
    else
        println("Please enter a valid response: ")
        replay_prompt()
    end
end

# Run replay_prompt to ask if player wants to replay.
replay_prompt()