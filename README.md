## Usage

1. Go to the
   [latest release](https://github.com/jakzo/BoneworksAsl/releases/latest)
1. Download `BoneworksAslHelper.dll` and `boneworks_openvr.asl`
   - https://github.com/jakzo/BoneworksAsl/releases/latest/download/BoneworksAslHelper.dll
   - https://github.com/jakzo/BoneworksAsl/releases/latest/download/boneworks_openvr.asl
1. Put them both in your `LiveSplit/Components` directory
1. Edit your layout in LiveSplit and add a "scriptable autosplitter" which
   points to `boneworks_openvr.asl`

## Lore

Boneworks autosplitters have historically detected the loading state by finding
a memory address within `vrclient_x64.dll`. However this sucks because that file
is part of SteamVR which gets constant updates, so even though Boneworks goes
years without updates we have to keep updating the pointer in the ASL. We tried
using sigscanning but eventually an update broke that too.

The new approach is to get the loading state using SteamVR's public APIs. These
should be guaranteed stable since Valve changing them would cause old games like
Boneworks to stop working in SteamVR. The ASL loads `BoneworksAslHelper.dll`
which in turn finds `openvr_api.dll` within the Boneworks directory then
initializes it and calls `IsCurrentSceneFocusAppLoading` to get the loading
state.
