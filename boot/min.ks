parameter reset is false.

runOncePath("0:/libraries/files").

if reset or status = "PRELAUNCH" {
  addLibrary("terminal").
  addLibrary("ship").
  addProgram("burn").
  list.
  switch to 0.
}
