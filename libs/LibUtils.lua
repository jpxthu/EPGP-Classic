local MAJOR_VERSION = "LibUtils-1.0"
local MINOR_VERSION = 10000

local lib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local Debug = LibStub("LibDebug-1.0")

function EPGPSearchG(s, parent, pre, lvl)
  if not parent then parent = _G end
  if not pre then pre = "_G." end
  if not lvl then lvl = 0 end
  for i, v in pairs(parent) do
    if type(v) == "table" then
      if lvl < 4 and type(i) == "string" and i ~= "_G" then
        EPGPSearchG(s, v, pre .. i .. ".", lvl + 1)
      end
    elseif v == s then
      print(pre .. i)
    -- elseif type(v) == "string" then
    --   if string.sub(v, 1, string.len(s)) == s then
    --     print(pre .. i)
    --   end
    else
      -- print(pre .. tostring(i), type(v))
    end
  end
end

local function copyTable(src, dest)
  for i, v in pairs(src) do
    if type(v) == "table" then
      dest[i] = {}
      copyTable(v, dest[i])
    else
      dest[i] = v
    end
  end
end

function lib:CopyTable(src, dest)
  if not src or type(src) ~= "table" then return end
  if not dest or type(dest) ~= "table" then return end
  table.wipe(dest)
  copyTable(src, dest)
end

function lib:PrintTable(t, spaces)
  if not spaces then spaces = "" end
  for i, v in pairs(t) do
    if type(v) == "table" then
      Debug(spaces .. tostring(i) .. " =")
      self:PrintTable(v, spaces .. "-")
    else
      Debug(spaces .. tostring(i) .. " = " .. tostring(v))
    end
  end
end

function lib:Join(separator, arr)
  if not arr or #arr == 0 then return "" end
  local s = tostring(arr[1])
  for i = 2, #arr do
    s = s .. separator .. tostring(arr[i])
  end
  return s
end
