state("Fusion") {
    ushort position: 0x1A1470, 0xA84;
    int menuScreen: 0x043588, 0x0;
    int raceFinished: 0x2A52D4, 0x5F4;
}

init {
    vars.menuLoaded=false;
    vars.qualified=false;
}

start {
    if(current.menuScreen == 128 && old.menuScreen == 29568) {
        if(vars.menuLoaded==false){
            vars.menuLoaded = true;
            return false;
        } else {
            return true;
        }
    }
    return false;
}

split {
    if((current.position - 49285) / 256 <= 3) {
        vars.qualified = true;
    } else {
        vars.qualified = false;
    }
    if(current.raceFinished == 256 && old.raceFinished != 256 && vars.qualified) {
        return true;
    }
    return false;
}

reset {
    if(current.menuScreen == 80 && old.menuScreen != 80) {
        vars.menuLoaded = false;
        return true;
    }
    return false;
}