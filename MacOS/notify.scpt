on run argv

    set Message to item 1 of argv
    set Title to item 2 of argv
    set aud to item 3 of argv
    set STitle to "Status"
    set Snd to "Submarine.aiff"


    if (aud = "sound") then

        display notification Message with title Title subtitle STitle sound name Snd
    else
        display notification Message with title Title subtitle STitle
    end if

end run