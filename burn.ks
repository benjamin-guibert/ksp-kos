runOncePath("libraries/terminal").
runOncePath("libraries/ship").
runOncePath("libraries/nav-lights").

local lockEta is 30.
local refTwr is 0.9.
local minThrottle is 0.05.
local minBurnTime is 3.
local reduceStartSeconds is 2.
local burnVDevTolerance is 0.5.

local manAborted is false.
local targetNode is false.
local startVector is false.
local targetBurnStart is false.
local stopTime is false.

main().

local function main {
  if not hasNode {
    print "No maneuver node found.".
    return.
  }
  if getCurrentIsp() <= 0 {
    print "No active engine.".
    return.
  }

  on abort abortManeuver("Abort triggered manually.").

  set targetNode to nextNode.
  set startVector to targetNode:burnvector.
  set targetBurnStart to getBurnStart().

  if getBurnTime() < minBurnTime abortManeuver("Burn time too short.").
  else if targetBurnStart - time:seconds < 10 abortManeuver("Maneuver ETA is too close.").

  wait until targetBurnStart - time:seconds < lockEta or manAborted.

  if manAborted return.
  lockControl().

  wait until (targetBurnStart - time:seconds < 10) or manAborted.

  if manAborted return.
  countdown().

  wait until targetBurnStart - time:seconds < 0.1 or manAborted.

  if manAborted return.
  startBurn().

  wait until getBurnTime() - reduceStartSeconds < 0.1 or manAborted.

  if manAborted return.
  decreaseBurn().

  wait until stopTime - time:seconds < 0.1 or manAborted.

  if manAborted return.
  lock throttle to minThrottle.
  print "Throttle descreased to minimum.".

  wait until isManComplete() or manAborted.

  if manAborted return.
  print " ".
  print "Maneuver complete.".
  releaseControl().
  run idle.
}

local function lockControl {
  print " ".
  setNavStatus("MANEUVER").
  lock throttle to 0.
  print "Throttle locked.".
  sas off.
  lock steering to targetNode:burnVector.
  print "Steering locked.".
}

local function countdown {
  print " ".
  from { local t is 10. } until t = 0 or manAborted step { set t to t - 1. } do {
    print "T - " + t + " seconds.".
    wait 1.
  }
}

local function startBurn {
  print " ".
  lock throttle to 1.
  print "Thrust ignited.".
}

local function decreaseBurn {
  local reduceTime is reduceStartSeconds * (-1) * ln(0.1) / refTwr.
  local startTime is time:seconds - 0.5.
  set stopTime to time:seconds + reduceTime - 0.5.
  local scale is constant:e ^ (-refTwr / reduceStartSeconds).

  lock throttle to scale ^ (time:seconds - startTime).
  print "Thrust decreased.".
}

local function abortManeuver {
  parameter reason.

  print "Maneuver aborted: " + reason.
  set manAborted to true.
  releaseControl().
  setNavStatus("IDLE").
}

local function getBurnStart {
  return time:seconds + targetNode:eta - getBurnTime(0.5) - reduceStartSeconds / 2.
}

local function getBurnTime {
  parameter proportion is 1.

  local deltaV is targetNode:burnvector:mag * proportion.
  local finalMass is mass / (constant:e ^ (deltaV / (getCurrentIsp() * constant:g0))).

  if availableThrust > 0 {
    return deltaV *  (mass - finalMass) / availableThrust / ln(mass / finalMass).
  }
  else {
    return -1.
  }
}

local function isManComplete {
  return vectorAngle(startVector, targetNode:burnVector) > burnVDevTolerance.
}
