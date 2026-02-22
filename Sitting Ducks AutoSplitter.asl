// US 
state("overlay", "US") {
    short loading: "overlay.exe", 0x1D5A5C, 0x70, 0x5FC;
    short missionComplete: "overlay.exe", 0x1D5A48, 0x8, 0x268;
    float duckTimeSeconds: "overlay.exe", 0x1D5A50, 0x26DC;
    float duckTimeHours: "overlay.exe", 0x1D5A50, 0x26D8;
    int featherCount: "overlay.exe", 0x1D5A50, 0x1F54;
}

// EU
state("overlay", "EU") {
    short loading: "overlay.exe", 0x1D5A4C, 0x70, 0x5FC;
    short missionComplete: "overlay.exe", 0x1D5A38, 0x8, 0x268;
    float duckTimeSeconds: "overlay.exe", 0x1D5A40, 0x26DC;
    float duckTimeHours: "overlay.exe", 0x1D5A40, 0x26D8;
    int featherCount: "overlay.exe", 0x1D5A40, 0x1F54;
}

// Polish/Russian
state("overlay", "RU") {
    short loading: "overlay.exe", 0x1D6A8C, 0x70, 0x5FC; 
    short missionComplete: "overlay.exe", 0x1D6A90, 0x18, 0x9C, 0x4BC, 0x560, 0x40, 0x38, 0xE08;
    float duckTimeSeconds: "overlay.exe", 0x1D6A80, 0x26DC;
    float duckTimeHours: "overlay.exe", 0x1D6A80, 0x26D8;
    int featherCount: "overlay.exe", 0x1D6A80, 0x1F54;
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
        case "187C265A5D847D2A228E353811CD44EF" :
            version = "EU";
            break;
        // US 2004
        case "CB91214A0AC1808C1C76A50FF7976009" : 
            version = "US";
            break;
        // US 2005
        case "05E56949D1691e866229ad3d9c19abd6" :
            version = "US";
            break;
        // Polish
        case "6D6D78B540C23FC0DCFE37C669B820D8" :
            version = "RU";
            break;
        // Russian
        case "A564ABCFAD98CF4676721F0144FC0F6B" :
            version = "RU";
            break;
        // Unknown
        default :
            version = "EU";
            MessageBox.Show(timer.Form,
                "Unknown Game Version:\n\n"
                + "This autosplitter does not support this game version.\n"
                + "Please contact (@.nautasquid on Discord)\n"
                + "with the following string\n\n"
                + "MD5Hash: " + MD5Hash + "\n\n"
                + "Defaulting to EU",
                "Sitting Ducks Autosplitter Error",
                  MessageBoxButtons.OK,
                  MessageBoxIcon.Error);
            break;
    }
    print(version);
    vars.bonks = 0;
    vars.totalLoads = TimeSpan.Zero;
}

onReset {
    vars.bonks = 0;
    vars.totalLoads = TimeSpan.Zero;
}

update {
    // Get Duck Time (In game timer) and store it
    if (timer.CurrentPhase == TimerPhase.Running) {
        int milliseconds = (int)Math.Round(current.duckTimeSeconds * 1000f);
        vars.duckTime = new TimeSpan(0, (int)current.duckTimeHours, 0, 0, milliseconds);
        vars.duckTimeFormatted = vars.duckTime.ToString(@"hh\:mm\:ss\.ff");
        // Calculate Time dilation (Duck Milliseconds Per Millisecond)
        vars.rtms = (float)((TimeSpan)timer.CurrentTime.RealTime).Ticks / 10000;
        vars.dtms = (float)(((TimeSpan)vars.duckTime).Ticks) / 10000;
        vars.timeDilation = (vars.dtms / vars.rtms).ToString("n4");
        // Bonk Counter - Doesn't work if fewer than 3 feathers or playing Aldo
        if (current.featherCount == (old.featherCount - 3)) { vars.bonks ++; }
    }
}

gameTime {
    TimeSpan interval = (vars.duckTime - vars.totalLoads);
    return interval;
}

split { if (current.missionComplete > old.missionComplete) { return true; } }

start { if (current.duckTimeSeconds < old.duckTimeSeconds) { return true; } }
