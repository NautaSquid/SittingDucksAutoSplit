state("overlay") {
    short loading: "overlay.exe", 0x1D5A5C, 0x70, 0x5FC;
    short missionComplete: "overlay.exe", 0x1D5A48, 0x8, 0x268;
    float duckTime: "overlay.exe", 0x1D5A50, 0x26DC;
    int featherCount: "overlay.exe", 0x1D5A50, 0x1F54;
}

isLoading {
    return current.loading != 0;
    // This isn't perfect as it pauses for loads during missions even when the mission timer is still counting down
    // Could use float missionTimerDisplay: "overlay.exe", 0x1D5A44, 0x8, 0x8F4, 0x10, 0x200; //(EU)
    // This would not count loads for quack the ripper where they should count though
}

start { if (current.duckTime < old.duckTime) { return true; } }

split { if (current.missionComplete > old.missionComplete) { return true; } }

update {
    if (current.featherCount == (old.featherCount - 3)) { vars.bonks ++; }
}