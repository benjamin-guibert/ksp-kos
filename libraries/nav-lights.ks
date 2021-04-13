on abort setNavStatus("EMERGENCY").

global function setNavStatus {
  parameter navStatus.

  local lightList is getNavLights().

  if navStatus = "IDLE" {
    forEachLightModule(lightList, {
      parameter light.

      if light:hasEvent("blink off") light:doEvent("blink off").
      setLightColor(light, rgb(0, 1, 0)).
      if light:hasEvent("lights on") light:doEvent("lights on").
    }).
  }
  else if navStatus = "OPERATING" {
    forEachLightModule(lightList, {
      parameter light.

      if light:hasEvent("blink on") light:doEvent("blink on").
      setLightColor(light, rgb(0, 1, 1)).
      light:setField("blink period", 2).
      if light:hasEvent("lights on") light:doEvent("lights on").
    }).
  }
  else if navStatus = "MANEUVER" {
    forEachLightModule(lightList, {
      parameter light.

      if light:hasEvent("blink on") light:doEvent("blink on").
      setLightColor(light, rgb(0, 1, 0)).
      light:setField("blink period", 1).
      if light:hasEvent("lights on") light:doEvent("lights on").
    }).
  }
  else if navStatus = "BEACON" {
    forEachLightModule(lightList, {
      parameter light.

      if light:hasEvent("blink on") light:doEvent("blink on").
      setLightColor(light, rgb(1, 1, 0)).
      light:setField("blink period", 0.5).
      if light:hasEvent("lights on") light:doEvent("lights on").
    }).
  }
  else if navStatus = "EMERGENCY" {
    forEachLightModule(lightList, {
      parameter light.

      if light:hasEvent("blink on") light:doEvent("blink on").
      setLightColor(light, rgb(1, 0, 0)).
      light:setField("blink period", 0.2).
      if light:hasEvent("lights on") light:doEvent("lights on").
    }).
  }
  else {
    forEachLightModule(lightList, {
      parameter light.

      light:doAction("turn light off", true).
    }).
  }
}

global function getNavLights {
  return ship:PartsNamed("navLight1").
}

local function forEachLightModule {
  parameter lightList.
  parameter action.

  for light in lightList action(light:getModule("ModuleLightExt")).
}

local function setLightColor {
  parameter light.
  parameter color.

  if light:hasField("light r") light:setField("light r", color:r).
  if light:hasField("light g") light:setField("light g", color:g).
  if light:hasField("light b") light:setField("light b", color:b).
}
