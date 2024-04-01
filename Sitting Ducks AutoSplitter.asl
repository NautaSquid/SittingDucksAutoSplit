// US 
state("overlay", "US") {
    short loading: "overlay.exe", 0x1D5A5C, 0x70, 0x5FC;
    short inGame: "overlay.exe", 0x1C52B0;
    int frameCount: "overlay.exe", 0x1D5CB0;
    short missionComplete: "overlay.exe", 0x001D5A48, 0x8, 0x268;
}

// EU
state("overlay", "EU") {
    short loading: "overlay.exe", 0x1D5A4C, 0x70, 0x5FC;
    short inGame: "overlay.exe", 0x1C52B0;
    int frameCount: "overlay.exe", 0x1D5CA0;
    short missionComplete: "overlay.exe", 0x001D5A38, 0x8, 0x268;
}

// Polish/Russian
state("overlay", "RU") {
    short loading: "overlay.exe", 0x1D6A8C, 0x70, 0x5FC; 
    short inGame: "overlay.exe", 0x1C62F0;
    int frameCount: "overlay.exe", 0x1D6CE0;
    short missionComplete: "overlay.exe", 0x001D6A90, 0x18, 0x9C, 0x4BC, 0x560, 0x40, 0x38, 0xE08;
}

init {
    //MD5 checksum code adapted from Zment's Defy Gravity and R30hedron's Dead Cells autosplitters
    byte[] exeMD5HashBytes = new byte[0];
    using (var md5 = System.Security.Cryptography.MD5.Create())
    {
        using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
        {
            exeMD5HashBytes = md5.ComputeHash(s);
        }
    }
    var MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
    vars.MD5Hash = MD5Hash;
    print("MD5: " + MD5Hash);
    switch(MD5Hash){
        // EU
        case "83741E0C07C419AF146AC959C1E6815C" :
            version = "EU";
            break;
        // US 2004
        case "A44B67537F2BEC1623A79B78C712AE1B" : 
            version = "US";
            break;
        // US 2005
        case "CF32A494802DDB0CD353ACA4F6443998" :
            version = "US";
            break;
        // Polish
        case "0EC347B6A96E50A3F6BC77BF675AB193" :
            version = "RU";
            break;
        // Russian
        case "E8D8FA35FF9FEC771BFDFA81E10CF904" :
            version = "RU";
            break;
        // Unknown
        default :
            version = "US";
            MessageBox.Show(timer.Form,
                "Unknown Game Version:\n\n"
                + "This autosplitter does not support this game version.\n"
                + "Please contact (@.nautasquid on Discord)\n"
                + "with the following string\n\n"
                + "MD5Hash: " + MD5Hash + "\n\n"
                + "Defaulting to US",
                "Sitting Ducks Autosplitter Error",
                  MessageBoxButtons.OK,
                  MessageBoxIcon.Error);
            break;
    }
    print(version);
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