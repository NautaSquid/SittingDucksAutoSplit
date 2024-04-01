state("overlay") {
    short loading: "overlay.exe", 0x1D5A5C, 0x70, 0x5FC;
    short inGame: "overlay.exe", 0x1C52B0;
    int frameCount: "overlay.exe", 0x1D5CB0;
    short missionComplete: "overlay.exe", 0x001D5A48, 0x8, 0x268;
}

isLoading {
    return current.loading != 0;
    // This isn't perfect as it pauses for loads during missions even when the mission timer is still counting down
    // Could use float missionTimerDisplay: "overlay.exe", 0x1D5A44, 0x8, 0x8F4, 0x10, 0x200; //(EU)
    // This would not count loads for quack the ripper where they should count though
}

start {
    if ((current.frameCount > 800) & (current.inGame > old.inGame)) {
        return true;
    }
    // The inGame condition briefly triggers when the game is first launched, so added a framecount delay to compensate for this.
    // Since loading times are tied to framerate this should work at any framerate 
}

split {
    if (current.missionComplete > old.missionComplete) {
        return true;
    }
}