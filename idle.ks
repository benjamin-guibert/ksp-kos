runOncePath("libraries/nav-lights").

main().

local function main {
  setNavStatus("IDLE").

  print "Idle mode activated. Press [CTRL + C] to exit idle mode.".

  wait until false.
}
