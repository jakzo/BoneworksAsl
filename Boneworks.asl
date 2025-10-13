//	Autosplitter created by Jakz0 and Sychke
//	Boneworks Speedrunning Discord Server: https://discord.gg/MW2zUcV2Fv

//	levelNumber is the ID of the current level
// 	Main Menu = 1, CutsceneOne = 2, BreakRoom = 3, Museum = 4, Streets = 5,
// Runoff = 6, Sewers = 7, Warehouse = 8,
//	Central Station = 9, Tower = 10, Time Tower = 11, CutsceneTwo = 12,
// Dungeon = 13, Arena = 14, Throne Room = 15

state("BONEWORKS") { // levelNumber should always be accurate
  int levelNumber : "GameAssembly.dll", 0x01E7E4E0, 0xB8, 0x590;
}

startup {
  vars.boneworksAslHelper =
      Assembly.Load(File.ReadAllBytes(@"Components\BoneworksAslHelper.dll"))
          .CreateInstance("BoneworksAslHelper");
}

init {
  vars.isLoading = false;
  vars.stillLoading = 0;
  vars.levelNumGreater = 0;
  vars.boneworksAslHelper.Initialize();
}

update {
  if (vars.boneworksAslHelper == null)
    return false;
  vars.isLoading = vars.boneworksAslHelper.IsLoading();
}

isLoading { return vars.isLoading; }

start {
  // Starts if the levelNumber is greater than 1 and isLoading is true
  if (current.levelNumber > 1) {
    return vars.isLoading;
  }
}

split {
  // Checks if the new levelNumber is greater than the old levelNumber
  if (current.levelNumber > old.levelNumber) {
    vars.levelNumGreater = 1;
  }
  // If you are in throne room and loading
  if (current.levelNumber == 1 && old.levelNumber == 15 && vars.isLoading) {
    return true;
  }
  // When the new levelNumber is greater than the old levelNumber and you are
  // loading, it will split once
  else if (vars.levelNumGreater == 1 && vars.stillLoading == 0 &&
           vars.isLoading) {
    vars.stillLoading = 1;
    return true;
  }
  // Activates when you stop loading
  else if (vars.stillLoading == 1 && !vars.isLoading) {
    vars.stillLoading = 0;
    vars.levelNumGreater = 0;
  }
}

reset {
  // Allows restarting a level, but does not work in Throne Room
  if (current.levelNumber < old.levelNumber && old.levelNumber != 15) {
    return true;
  }
}

exit {
  timer.IsGameTimePaused = true;
  vars.boneworksAslHelper.Shutdown();
}
