parameter circTarget is "".

runOncePath("libraries/terminal").

main().

local function main {
  if not circTarget set circTarget to choose "APOAPSIS" if promptBool("Circularize orbit on apoapsis?", false) else "PERIAPSIS".

  circOrbit().
}

local function circOrbit {
  local tgtAlt is choose orbit:apoapsis if circTarget = "APOAPSIS" else orbit:periapsis.
  local tgtEta is choose eta:apoapsis if circTarget = "APOAPSIS" else eta:periapsis.

  local futureVelocity is sqrt(velocity:orbit:mag^2 - 2 * body:mu *
    (1 / (body:radius + altitude) - 1 / (body:radius + tgtAlt))).
  local circVelocity is sqrt(body:mu / (tgtAlt + body:radius)).

  add node(time:seconds + tgtEta, 0, 0, circVelocity - futureVelocity).
  print "Orbit circularization maneuver node added on " + circTarget + ".".
}
