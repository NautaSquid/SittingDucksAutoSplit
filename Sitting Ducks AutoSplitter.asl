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
        case "ba3331c343aa376e20de60638004043f" :
            version = "EU";
            break;
        // US 2004
        case "5c52ac0992ee9ad489fd7cc021769119" : 
            version = "US";
            break;
        // US 2005
        case "180e2bb39b7c3a935b0f3ad0c90ff864" :
            version = "US";
            break;
        // Polish
        case "fc10de7c91c71717d8585060f8e5adad" :
            version = "RU";
            break;
        // Russian
        case "3dd6bd8942a9797012c7ecc91856c213" :
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
