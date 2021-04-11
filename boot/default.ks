parameter reset is false.

runOncePath("0:/libraries/files").

if reset or status = "PRELAUNCH" {
  addLibrary("terminal").
  addLibrary("ship").
  addProgram("burn").
  addProgram("circorbit").
  list.
  switch to 0.
}
