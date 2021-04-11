local logFile is "0:/logs/inventory.yml".

print "Saving ship inventory to: " + logFile.

if exists(logFile) deletePath(logFile).

log "ship: '" + ship:name + "'" to logFile.
log "parts:" to logFile.

for part in ship:parts {
  log "  - '" + part:name + "':" to logFile.
  log "    title: '" + part:title + "'" to logFile.
  log "    tag: '" + part:tag + "'" to logFile.
  log "    modules:" to logFile.

  for i in range(0, part:modules:length) {
    local module is part:getModuleByIndex(i).

    log "      - '" + module:name + "':" to logFile.

    if module:allFieldNames:length {
      log "        fields:" to logFile.
      for field in module:allFieldNames log "          - '" + field + "'" to logFile.
    }

    if module:allEventNames:length {
      log "        events:" to logFile.
      for event in module:allEventNames log "          - '" + event + "'" to logFile.
    }

    if module:allActionNames:length {
      log "        actions:" to logFile.
      for action in module:allActionNames  log "          - '" + action + "'" to logFile.
    }
  }
}

print "Ship inventory saved.".
edit logFile.
