println("""
    

██   ██   █████   ███    ██   ██████   ███    ███   █████   ███    ██
██   ██  ██   ██  ████   ██  ██        ████  ████  ██   ██  ████   ██
███████  ███████  ██ ██  ██  ██   ███  ██ ████ ██  ███████  ██ ██  ██
██   ██  ██   ██  ██  ██ ██  ██    ██  ██  ██  ██  ██   ██  ██  ██ ██
██   ██  ██   ██  ██   ████   ██████   ██      ██  ██   ██  ██   ████                                                                

""")


function show_word()
    print("\u1b[1F")
    for i in 1:length(word)
        print(current_array[i], " ")
    end
    print("\u1b[0K")
end

print("Player 1, please enter your word (word will disappear once entered): ")
word = lowercase(readline());

current_array = ["__" for x in 1:length(word)]
show_word()

left = 6

while true
    global left
    print("Player 2, guess a letter in the word: ")
    println("You have $left guesses left!")
    letter = lowercase(readline());

    for (index, check_letter) in enumerate(split(word, ""))
        if letter == check_letter
            current_array[index] = letter
        end
    end

    if !(letter in current_array)
        left -= 1
    end    
    show_word()

    if !("__" in current_array) || (left == 0)
        break
    end
end
println()
if left == 0
    println("Player 1 wins! Sorry Player 2, you took the L here. The word was \"$word\"")
else
    println("Player 2 wins! Sorry, Player 1, let's have a harder one next time.")
end