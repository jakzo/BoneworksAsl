## Usage

1. Go to the
   [latest release](https://github.com/jakzo/BoneworksAsl/releases/latest)
1. Download `BoneworksAslHelper.dll` and `boneworks_openvr.asl`
   - https://github.com/jakzo/BoneworksAsl/releases/latest/download/BoneworksAslHelper.dll
   - https://github.com/jakzo/BoneworksAsl/releases/latest/download/boneworks_openvr.asl
1. Put them both in your `LiveSplit/Components` directory
1. Edit your layout in LiveSplit and add a "scriptable autosplitter" which
   points to `boneworks_openvr.asl`
1. Edit splits and deactivate the default Boneworks autosplitter

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

## Comparison

In testing the ASL picks up the loading state around 0.01 or 0.02 seconds faster
than the old version, so the timing is not perfectly compatible. However it is
more consistent and the time difference should add up to less than a second
faster compared to the old approach for even the longest runs like 100%.

[Here is a video](https://www.youtube.com/watch?v=-L4t130py9M) where the two
LiveSplit instances on the left use the `openvr_api.dll` approach while the two
on the right use the old `vrclient_x64.dll` memory pointer approach.
