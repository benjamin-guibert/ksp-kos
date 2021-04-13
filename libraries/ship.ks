global function releaseControl {
  set ship:control:pilotmainthrottle to 0.
  unlock all.
  sas on.
  print "Ship control released.".
}

global function limitThrustToTwr {
  parameter twrLimit.

  local thrustLimit is getThrottleToTwr(twrLimit).
  lock throttle to thrustLimit.
  print "Thrust limited to TWR: " + twrLimit.
}

global function getCurrentIsp {
   list engines in engineList.
   local sum1 to 0.
   local sum2 to 0.

   for engine in engineList {
      if engine:ignition {
         set sum1 to sum1 + engine:availableThrust.
         set sum2 to sum2 + engine:availableThrust / engine:isp.
      }
   }

  return choose sum1 / sum2 if (sum2 > 0) else -1.
}

global function getTwr {
  parameter pressure is 0.

  return (ship:availablethrustat(pressure) * throttle) / (mass * constant:g0).
}

global function getThrottleToTwr {
  parameter targetTwr.

  lock gravityForce to (body:mu/(body:radius + altitude) ^ 2) * mass.
  return min((targetTwr * gravityForce) / (availableThrust + 0.001), 1).
}

global function hasEnginesAtStage {
  parameter stageNumber.

  local firstEnginesStage to stageNumber.
  list engines in engineList.
  for engine in engineList {
    if engine:stage = firstEnginesStage return true.
  }

  return false.
}

global function getDeploy1Parts {
  return ship:partsTagged("kDeploy1").
}

global function getDeploy2Parts {
  return ship:partsTagged("kDeploy2").
}
