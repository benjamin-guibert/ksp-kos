global function resetLocalVolume {
  parameter bootFileName.

  print "Resetting local volume...".
  switch to 1.
  removeAll().
  installBootFile(bootFileName).
  print "Local volume reset.".
  runPath("boot/" + bootFileName, true).
}

global function installBootFile {
  parameter fileName.

  switch to 1.

  local filePath is "0:/boot/" + fileName.

  if not exists(filePath) {
    print "Boot file does not exist: " + fileName.
    return.
  }

  if not exists("boot") createDir("boot").

  copyPath(filePath, "boot").
  print "Boot file installed: " + fileName.
}

global function addProgram {
  parameter fileName.

  addFile("", fileName).
}

global function addLibrary {
  parameter fileName.

  addFile("libraries", fileName).
}

local function addFile {
  parameter dirPath.
  parameter fileName.

  local archiveFilePath is path("0:/"):combine(dirPath, fileName).
  local localFilePath is path():combine(dirPath, fileName).

  switch to 1.
  if exists(localFilePath) return.
  if not exists(dirPath) createDir(dirPath).
  if not exists(archiveFilePath) {
    print "File does not exist: " + archiveFilePath.
    return.
  }

  compile archiveFilePath to localFilePath.
  print "File compiled: " + localFilePath.
}

local function removeAll {
  list files in fileList.
  for file in fileList {
    deletePath(file:name).
    print "Deleted: " + file:name.
  }
}
