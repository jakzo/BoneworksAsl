state("BONEWORKS") {
  int levelNumber : "GameAssembly.dll", 0x01E7E4E0, 0xB8, 0x590;
}

startup {
  vars.boneworksAslHelper =
      Assembly.Load(File.ReadAllBytes(@"Components\BoneworksAslHelper.dll"))
          .CreateInstance("BoneworksAslHelper");
}

init {
  vars.boneworksAslHelper.Initialize();

  vars.isLoading = false;
  vars.start = false;
  vars.split = false;
  vars.reset = false;

  vars.levelNumGreater = false;
}

update {
  if (vars.boneworksAslHelper == null)
    return false;

  const int LEVEL_MAIN_MENU = 1;
  const int LEVEL_CUTSCENE_1 = 2;
  const int LEVEL_BREAK_ROOM = 3;
  const int LEVEL_MUSEUM = 4;
  const int LEVEL_STREETS = 5;
  const int LEVEL_RUNOFF = 6;
  const int LEVEL_SEWERS = 7;
  const int LEVEL_WAREHOUSE = 8;
  const int LEVEL_CENTRAL_STATION = 9;
  const int LEVEL_TOWER = 10;
  const int LEVEL_TIME_TOWER = 11;
  const int LEVEL_CUTSCENE_2 = 12;
  const int LEVEL_DUNGEON = 13;
  const int LEVEL_ARENA = 14;
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
