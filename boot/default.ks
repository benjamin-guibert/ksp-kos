parameter reset is false.

runOncePath("0:/libraries/files").

if reset or status = "PRELAUNCH" {
  addLibrary("terminal").
  addLibrary("ship").
  addLibrary("nav-lights").
  addProgram("idle").
  addProgram("navlights").
  addProgram("burn").
  addProgram("circorbit").
  list.
  switch to 0.
}
else {
  list.
  run idle.
}
