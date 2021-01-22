state("Fusion") {
    //These three bytes are for the timer ticking up during a race
    //They count the number of frames since the race started
    //Seconds & Minutes both use their hex values, so need that hex value to be converted to an int to be useful if >= 10
    byte timerFrames: 0x2A52D4, 0xA53;
    byte timerSeconds: 0x2A52D4, 0xA55;
    byte timerMinutes: 0x2A52D4, 0xA54;
    //These two bytes are updated when you cross the finish line - they record the exact number of frames that your race took.
    byte finalLoops: 0x2A52D4, 0xAC6;
    byte finalFrames: 0x2A52D4, 0xAC7;
    //Your position in the race, obviously. Uses hex value, but as we're only interested in whether the player qualified (finished in the top 3), there's no need to convert to int as the int and hex values are the same
    byte position: 0x2A52D4, 0x6B3;
    //A number that represents a particular menu being viewed. Is set to 0 during a race
    int menuScreen: 0x043588, 0x0;
    //A number that is set to 1 when you reach the finish line
    byte raceFinished: 0x2A52D4, 0x5F5;
    //Indicates whether the start button is pressed
    byte startPressed: 0x0491BC, 0xB;
}

init {
    vars.igt = 0;
    vars.cumulativeigt = TimeSpan.FromMilliseconds(0);
    vars.timerFrames = 0;
    vars.timerSeconds = 0;
    vars.timerMinutes = 0;
}

start {
    //Transition out of the menu begins once you release the start button
    //Checking 'old' rather than 'current' menuScreen as it changes from 29568 to 128 at some point during the transition
    if(old.menuScreen == 29568 && current.startPressed == 0 && old.startPressed == 128) {
        return true;
    }
    return false;
}

split {
    //If the race is finished and you finished in the top 3, split. Simple.
    if(current.raceFinished == 1 && old.raceFinished != 1 && current.position <= 3) {
        return true;
    }
    return false;
}

reset {
    //The trigger for this may be subject to change. It currently works for Kega Fusion when the emulator is hard reset. It does NOT work when you soft reset
    if(current.menuScreen == 80 && old.menuScreen != 80) {
        vars.menuLoaded = false;
        vars.cumulativeigt = TimeSpan.FromMilliseconds(0);
        return true;
    }
}

isLoading {
    //Keep track of game time while the race is running
    if(current.menuScreen == 0 && current.timerFrames != old.timerFrames) {
        return true;
    }
    return false;
}

update {
    print("StartPressed is " + current.startPressed);
}

gameTime {
    //I wanted the in-game timer to run for the entirety of a race, but the final framecounts are only updated once right at the end of the race
    //This code block converts the race's minutes and seconds (and frames between seconds) into milliseconds to report the in-game time throughout a race
    vars.timerMinutes = int.Parse(current.timerMinutes.ToString("x")) * 60000;
    vars.timerSeconds = int.Parse(current.timerSeconds.ToString("x")) * 1000;
    vars.timerFrames = (int)Math.Floor((double)(current.timerFrames / 6)) * 100;
    vars.igt = TimeSpan.FromMilliseconds(((vars.timerFrames) + (vars.timerSeconds) + (vars.timerMinutes)));

    //When we finish the race, we take the final race framecount that has now been updated, convert that to milliseconds, and add it to the cumulative IGT to be used when we split
    //In-game, IGT only displays tenths of a second, so Math.Floor is used to eliminate the hundredths and thousandths
    if(current.raceFinished == 1 && old.raceFinished != 1){
        vars.igt = TimeSpan.FromMilliseconds(Math.Floor(((double)(current.finalLoops * 256) + current.finalFrames)/6)*100) + vars.cumulativeigt;
        vars.cumulativeigt = vars.igt;
        return vars.igt;
    }

    //Once we've got the cumulative time for our split, we can reset IGT back to 0 ready for the next race
    if(old.raceFinished == 1 && vars.cumulativeigt == vars.igt){
        vars.igt = TimeSpan.FromMilliseconds(0);
    }
    return vars.igt;
}