state("Fusion") {
    int position: 0x1A1470, 0xA84;
    int menuScreen: 0x043588, 0x0;
    int raceFinished: 0x2A52D4, 0x5F4;
}

init {
    vars.menuLoaded=0;
}

start {
    if(current.menuScreen == 128 && old.menuScreen == 29568){
        if(vars.menuLoaded==0){
            vars.menuLoaded = 1;
            return false;
        } else {
            return true;
        }
    }
}

split {
    if(current.raceFinished == 256 && old.raceFinished != 256) {
        return true;
    }
}

reset {
    if(current.menuScreen == 80 && old.menuScreen != 80) {
        vars.menuLoaded = 0;
        return true;
    }
}