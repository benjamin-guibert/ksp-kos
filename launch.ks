parameter tgtAlt is -999.
parameter tgtInc is -999.

runOncePath("libraries/terminal").
runOncePath("libraries/ship").
runOncePath("libraries/nav-lights").

local voice is getVoice(0).
local voiceAbortNote is note(330, 0.5, 0.25, 0.25).
local voiceTickNote is note(440, 0.25, 0.25, 0.25).
local voiceLiftOffNote is note(880, 1, 0.25, 0.25).
local minTgtAltKm is 80.
local minLaunchTwr is 1.50.
local altTolerance is 10.
local launchTwr is 1.50.
local flightTwr is 1.3.
local gravityTurn1VThreshold is 50.
local halfPitchAltThreshold is 12_000.
local gravityTurn2AltThreshold is 20_000.
local gravityTurn3AltThreshold is 40_000.
local fairingAltThreshold is 60_000.
local deploymentAltThreshold is 70_000.
local circManeuverAltThreshold is 70_000.

local launchAborted is false.
local ascentStep is 0.
local deploymentStep is 0.
local lastAlt is altitude.

main().

local function main {
  if tgtAlt = -999 promptTgtAlt().
  if tgtInc = -999 promptTgtInc().

  print "Target is " + tgtAlt / 1000 + " km at " + tgtInc + " deg.".
  if not promptBool("Proceed?", true) return.

  on abort abortLaunch("Abort triggered manually.").

  run gonogo.
  if not gonogoResult return.

  wait 5.
  countdown().
  if launchAborted return.
  liftOff().

  until apoapsis > tgtAlt or launchAborted {
    checkThrust().
    checkAltitude().

    if (ascentStep = 0 and velocity:surface:mag > gravityTurn1VThreshold) executeGravityTurn1().
    else if (ascentStep = 1 and altitude > gravityTurn2AltThreshold) executeGravityTurn2().
    else if (ascentStep = 2 and altitude > gravityTurn3AltThreshold) executeGravityTurn3().
    else if (ascentStep = 3) checkDeployment().
  }

  if launchAborted return.
  reachApoapsis().

  until altitude > circManeuverAltThreshold or launchAborted {
    checkAltitude().
    checkDeployment().
  }

  if launchAborted return.
  checkDeployment().
  run circorbit("APOAPSIS").
  run burn.
}

local function promptTgtAlt {
  local input is prompt("Target altitude (km)", { parameter v. return v:tonumber(-999) >= minTgtAltKm. }, "80").
  set tgtAlt to input:tonumber() * 1000.
}

local function promptTgtInc {
  local input is prompt(
    "Target inclination (deg)",
    { parameter v. set v to v:tonumber(-999). return v >= -180 and v <= 180. },
    "0").
  set tgtInc to input:tonumber().
}

local function countdown {
  print " ".
  from { local t is 10. } until t = 0 or launchAborted step { set t to t - 1. } do {
    voice:play(voiceTickNote).
    print "T - " + t + " seconds.".

    wait 0.5.
    if t = 5 {
      sas off.
      lock steering to up + r(0, 0, 180).
      print "Steering locked.".
    }
    else if t = 3 {
      lock throttle to 1.
      print "Full throttle engaged.".
    }
    else if t = 1 {
      stage.
      print "Thrusters ignited.".
    }
    wait 0.5.
  }
}

local function liftOff {
  print " ".
  if getTwr() > minLaunchTwr {
    wait until stage:ready.
    stage.
    limitThrustToTwr(launchTwr).
    voice:play(voiceLiftOffNote).
    print "Lift off.".
  }
  else abortLaunch("Subnominal thrust detected.").
}

local function executeGravityTurn1 {
  print " ".
  print "Executing first gravity turn...".
  lock steering to heading(getTgtHeading(), getTgtPitch()) + r(0, 0, 360 - getTgtHeading()).
  print "Steering adjusted.".
  set ascentStep to 1.
}

local function executeGravityTurn2 {
  print " ".
  print "Executing second gravity turn...".
  limitThrustToTwr(flightTwr).
  set ascentStep to 2.
}

local function executeGravityTurn3 {
  print " ".
  print "Executing third gravity turn...".
  set navMode to "ORBIT".
  lock steering to prograde + r(0,0, 360 - getTgtHeading()).
  print "Steering locked to prograde.".
  set ascentStep to 3.
}

local function reachApoapsis {
  print " ".
  print "Apoapsis reached.".
  releaseControl().
}

local function checkThrust {
  if (throttle < 1 and getTwr() < flightTwr - 0.1) limitThrustToTwr(flightTwr).
}

local function checkAltitude {
  if (altitude < lastAlt - altTolerance) abortLaunch("Altitude loss detected.", true).

  set lastAlt to altitude.
}

local function checkDeployment {
  if deploymentStep = 0 and altitude > fairingAltThreshold {
    for part in getDeploy1Parts() {
      if part:hasModule("ModuleProceduralFairing") {
        local partModule is part:getModule("ModuleProceduralFairing").

        if partModule:hasEvent("deploy") partModule:doEvent("deploy").
      }
    }
    set deploymentStep to 1.
    print "Fairing deployed.".
  }
  else if deploymentStep = 1 and altitude > deploymentAltThreshold {
    for part in getDeploy2Parts() {
      if part:hasModule("ModuleDeployableSolarPanel") {
        local partModule is part:getModule("ModuleDeployableSolarPanel").

        if partModule:hasEvent("extend solar panel") partModule:doEvent("extend solar panel").
      }
      else if part:hasModule("ModuleDeployableAntenna") {
        local partModule is part:getModule("ModuleDeployableAntenna").

        if partModule:hasEvent("extend antenna") partModule:doEvent("extend antenna").
      }
    }
    setNavStatus("IDLE").
    lights on.
    set deploymentStep to 2.
    print "Deployable equipment extended.".
  }
}

local function abortLaunch {
  parameter reason.
  parameter triggerAbortAction is false.

  if triggerAbortAction abort on.

  set launchAborted to true.
  print "Launch aborted: " + reason.
  releaseControl().
  voice:play(voiceAbortNote).
}

local function getTgtPitch {
  return 90 * halfPitchAltThreshold / (altitude + halfPitchAltThreshold).
}

local function getTgtHeading {
  local tgtHeading is 90 - tgtInc.
  if tgtHeading < 0 {
    set tgtHeading to 360 + tgtHeading.
  }

  local triAng is abs(90 - tgtHeading).
  local vH is sqrt(1_774_800 - 475_200 * cos(triAng)).
  local correction to arcSin(180 * sin(triAng) / vH).
  if tgtInc > 0 {
    set correction to -1 * correction.
  }

  if (tgtHeading + correction) < 0 {
    return tgtHeading + correction + 360.
  }
  else {
    return tgtHeading + correction.
  }
}
