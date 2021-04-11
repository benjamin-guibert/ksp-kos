runOncePath("libraries/terminal").
runOncePath("libraries/ship").

global gonogoResult is false.

local minEc is 100.
local minDv is 3400.

main().

local function main {
  if status <> "PRELAUNCH" {
    print "Ship is not ready for launch.".
    return.
  }

  print "Checking all systems for launch...".
  set gonogoResult to true.

  print " ".
  print "Resources:".
  processResult("Electric Charge", ship:electricCharge >= minEc, round(ship:electricCharge)).
  processResult("        Delta V", ship:deltav:vacuum > minDv, round(ship:deltav:vacuum) + " m/s (vacuum)").

  print " ".
  print "Stages".
  processResult("    Stage ready", stage:ready).
  checkLaunchClamps().
  checkEngines().
  checkFairing().


  print " ".
  print " ".
  processResult("    ALL SYSTEMS", gonogoResult).

  print " ".
}

local function checkLaunchClamps {
  local launchClampsStage to stage:number - 2.
  local result is stage:nextDecoupler:isType("LaunchClamp") and stage:nextDecoupler:stage = launchClampsStage.
  local value is choose "At stage #" + launchClampsStage if result else "Not at stage #" + launchClampsStage.

  processResult("  Launch clamps", result, value).
}

local function checkEngines {
  local enginesStage is stage:number - 1.
  local result is hasEnginesAtStage(enginesStage).
  local value is choose "At stage #" + enginesStage if result else "Not at stage #" + enginesStage.

  processResult("        Engines", result, value).
}

local function checkFairing {
  processResult("        Fairing", true, ship:partstagged("kFairing"):length + " part(s)").
}

local function processResult {
  parameter label.
  parameter result.
  parameter value is "".

  if not result set gonogoResult to false.

  print "  - " + label + ": " + (choose "[  GO  ]" if result else "[ NOGO ]") + " " + value.
}
