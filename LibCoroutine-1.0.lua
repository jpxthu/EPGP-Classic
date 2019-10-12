-- A library to make usage of coroutines in wow easier.
--
-- Check LibMapData for how to put this on wowace.
local MAJOR_VERSION = "LibCoroutine-1.0"
local MINOR_VERSION = tonumber(("$Revision: 1023 $"):match("%d+")) or 0

local lib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local AT = LibStub("AceTimer-3.0")
local AE = LibStub("AceEvent-3.0")

local function running_co_checked()
  local co = coroutine.running()
  assert(co, "Should not be called from the main thread")
  return co
end

local function runner(co, ...)
  local ok, err = coroutine.resume(co, ...)
  if not ok then
    error(err)
  end
end

function lib:Yield()
  return self:Sleep(0)
end

function lib:Sleep(t)
  local co = running_co_checked()
  AT:ScheduleTimer(runner, t, co)
  return coroutine.yield(co)
end

local function event_runner(co, event, ...)
  AE.UnregisterEvent(co, event)
  runner(co, ...)
end

function lib:WaitForEvent(event)
  local co = running_co_checked()
  AE.RegisterEvent(co, event, event_runner, co)
  return coroutine.yield(co)
end

local function message_runner(co, message, ...)
  AE.UnregisterMessage(co, message)
  runner(co, ...)
end

function lib:WaitForMessage(message)
  local co = running_co_checked()
  AE.RegisterMessage(co, message, message_runner, co)
  return coroutine.yield(co)
end

function lib:RunAsync(fn, ...)
  local co = coroutine.create(fn)
  AT:ScheduleTimer(function(args) runner(args[1], unpack(args, 2)) end,
                   0, {co, ...})
end

-- /run LibStub("LibCoroutine-1.0"):UnitTest()
function lib:UnitTest()
  function RunTests(i)
    print("running tests async. expecting 1 as arg. got ", i)

    print("waiting for foo message")
    lib:WaitForMessage("foo")
    print("done")

    print("waiting for foo message with 1 as arg")
    n = lib:WaitForMessage("foo")
    print("done. got: ", n)

    print("sleeping for 1 sec")
    lib:Sleep(1)
    print("done")
  end

  lib:RunAsync(RunTests, 1)

  AT:ScheduleTimer(function() AE:SendMessage("foo") end, 1)
  AT:ScheduleTimer(function() AE:SendMessage("foo", 1) end, 2)
end
