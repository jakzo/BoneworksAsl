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
  vars.levelNumGreater = false;
  vars.boneworksAslHelper.Initialize();
}

update {
  if (vars.boneworksAslHelper == null)
    return false;

  const int LEVEL_MAIN_MENU = 1;
  const int LEVEL_THRONE_ROOM = 15;

  vars.isLoading = vars.boneworksAslHelper.IsLoading();

  vars.start = current.levelNumber > LEVEL_MAIN_MENU && vars.isLoading;

  vars.split = false;
  if (current.levelNumber > old.levelNumber) {
    vars.levelNumGreater = true;
  }
  if (vars.isLoading) {
    // Split when loading into next level
    if (vars.levelNumGreater) {
      vars.split = true;
      vars.levelNumGreater = false;
    }
    // Split on returning to Main Menu from Throne Room
    if (current.levelNumber == LEVEL_MAIN_MENU &&
        old.levelNumber == LEVEL_THRONE_ROOM) {
      vars.split = true;
    }
  }

  // Reset when going back to a previous level (except from Throne Room)
  vars.reset = current.levelNumber < old.levelNumber &&
               old.levelNumber != LEVEL_THRONE_ROOM;
}

isLoading { return vars.isLoading; }
start { return vars.start; }
split { return vars.split; }
reset { return vars.reset; }

exit {
  timer.IsGameTimePaused = true;
  vars.boneworksAslHelper.Shutdown();
}
