state("BONEWORKS") {
  int levelNumber : "GameAssembly.dll", 0x01E7E4E0, 0xB8, 0x590;
}

startup {
  vars.boneworksAslHelper =
      Assembly.Load(File.ReadAllBytes(@"Components\BoneworksAslHelper.dll"))
          .CreateInstance("BoneworksAslHelper");

  settings.Add("il_mode", false, "IL mode");
  settings.SetToolTip(
      "il_mode",
      "Resets 3 seconds after loading starts for any level and never splits");
}

init {
  vars.boneworksAslHelper.Initialize();

  vars.isLoading = false;
  vars.start = false;
  vars.split = false;
  vars.reset = false;

  vars.levelNumGreater = false;
  vars.loadStartTime = DateTime.Now;
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

  const double IL_RESET_WAIT_SECONDS = 3.0;

  var wasLoading = vars.isLoading;
  vars.isLoading = vars.boneworksAslHelper.IsLoading();

  // Start timer when loading into any level beyond Main Menu regardless of mode
  vars.start = vars.isLoading && current.levelNumber > LEVEL_MAIN_MENU;

  var.split = false;
  var.reset = false;

  // IL mode
  if (settings["il_mode"]) {
    if (vars.isLoading) {
      if (!wasLoading) {
        vars.loadStartTime = DateTime.Now;
      }

      var loadingElapsed = DateTime.Now - vars.loadStartTime;
      if (current.levelNumber <= LEVEL_MAIN_MENU ||
          loadingElapsed.TotalSeconds >= IL_RESET_WAIT_SECONDS) {
        vars.reset = true;
      }
    }
    return true;
  }

  // Classic mode
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

  return true;
}

isLoading { return vars.isLoading; }
start { return vars.start; }
split { return vars.split; }
reset { return vars.reset; }

onStart { timer.IsGameTimePaused = true; }

exit {
  timer.IsGameTimePaused = true;
  vars.boneworksAslHelper.Shutdown();
}
