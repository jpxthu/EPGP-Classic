--[[ EPGP User Interface ]]--

local mod = EPGP:NewModule("ui")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local LE = LibStub("AceLocale-3.0"):GetLocale("LibEncounters")
local GS = LibStub("LibGuildStorage-1.2")
local GP = LibStub("LibGearPoints-1.3")
local DLG = LibStub("LibDialog-1.0")
local GUI = LibStub("AceGUI-3.0")
local LIU = LibStub("LibItemUtils-1.0")
local LUI = LibStub("LibEPGPUI-1.0")

local callbacks = EPGP.callbacks

local EPGPWEB = "http://www.epgpweb.com"

local BUTTON_TEXT_PADDING = 15
local BUTTON_HEIGHT = 22
local EDITBOX_HEIGHT = 24
local ROW_TEXT_PADDING = 5

local function Debug(fmt, ...)
  DEFAULT_CHAT_FRAME:AddMessage(string.format(fmt, ...))
end

local function DebugFrame(frame, r, g, b)
  local t = frame:CreateTexture()
  t:SetAllPoints(frame)
  t:SetTexture(r or 0, g or 1, b or 0, 0.05)
end

local function DebugPoints(frame, name)
  Debug("%s top=%d bottom=%d left=%d right=%d height=%d width=%d", name,
        frame:GetTop(), frame:GetBottom(), frame:GetLeft(), frame:GetRight(),
        frame:GetHeight(), frame:GetWidth())
end

local SIDEFRAMES = {}
local function ToggleOnlySideFrame(frame)
  for _,f in ipairs(SIDEFRAMES) do
    if f == frame then
      if f:IsShown() then
        f:Hide()
      else
        f:Show()
      end
    else
      f:Hide()
    end
  end
end

local disableWhileNotInRaidList = {}
local function DisableWhileNotInRaid()
  if UnitInRaid("player") then
    for i, v in pairs(disableWhileNotInRaidList) do v:Enable() end
  else
    for i, v in pairs(disableWhileNotInRaidList) do v:Disable() end
  end
end

local function CreateEditBox(name, parent)
  local eb = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
  eb:SetFontObject("GameFontHighlightSmall")
  eb:SetHeight(EDITBOX_HEIGHT)
  eb:SetAutoFocus(false)
  return eb
end

local function EnableEditBox(eb, v)
  eb:SetAlpha(1)
  eb:Enable()
  if v then
    eb:SetText(v)
  end
end

local function DisableEditBox(eb, v)
  eb:SetAlpha(0.25)
  eb:Disable()
  if v then
    eb:SetText(v)
  end
end

local function EnableSelectBox(sb, v)
  sb:SetAlpha(1)
  sb:Enable()
  sb:SetChecked(v)
end

local function DisableSelectBox(sb, v)
  sb:SetAlpha(0.25)
  sb:Disable()
  sb:SetChecked(v)
end

local function CreateEPGPFrame()
  -- EPGPFrame
  local f = CreateFrame("Frame", "EPGPFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate");
  f:Hide()
  f:SetToplevel(true)
  f:EnableMouse(true)
  f:SetMovable(true)
  f:SetAttribute("UIPanelLayout-defined", true)
  f:SetAttribute("UIPanelLayout-enabled", true)
  f:SetAttribute("UIPanelLayout-area", "left")
  f:SetAttribute("UIPanelLayout-pushable", 5)
  f:SetAttribute("UIPanelLayout-whileDead", true)

  f:SetWidth(384)
  f:SetHeight(512)
  f:SetPoint("TOPLEFT", nil, "TOPLEFT", 0, -104)
  f:SetHitRectInsets(0, 30, 0, 45)
  f:SetScript(
    "OnMouseDown",
    function (self) self:StartMoving() end)
  f:SetScript(
    "OnMouseUp", function (self) self:StopMovingOrSizing() end)

  local t = f:CreateTexture(nil, "BACKGROUND")
  t:SetTexture("Interface\\PetitionFrame\\GuildCharter-Icon")
  t:SetWidth(60)
  t:SetHeight(60)
  t:SetPoint("TOPLEFT", f, "TOPLEFT", 7, -6)

  t = f:CreateTexture(nil, "ARTWORK")
  t:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft")
  t:SetWidth(256)
  t:SetHeight(256)
  t:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)

  t = f:CreateTexture(nil, "ARTWORK")
  t:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight")
  t:SetWidth(128)
  t:SetHeight(256)
  t:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)

  t = f:CreateTexture(nil, "ARTWORK")
  t:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
  t:SetWidth(256)
  t:SetHeight(256)
  t:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)

  t = f:CreateTexture(nil, "ARTWORK")
  t:SetTexture(
    "Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
  t:SetWidth(128)
  t:SetHeight(256)
  t:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)

  t = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  t:SetWidth(250)
  t:SetHeight(16)
  t:SetPoint("TOP", f, "TOP", 3, -16)
  t:SetText("EPGP-Classic "..EPGP.version)

  local cb = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -30, -8)

  f:SetScript("OnHide", ToggleOnlySideFrame)
end

local function CreateEPGPExportImportFrame()
  local f = CreateFrame("Frame", "EPGPExportImportFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate");
  f:Hide()
  f:SetPoint("CENTER")
  f:SetFrameStrata("TOOLTIP")
  f:SetToplevel(true)
  f:SetHeight(350)
  f:SetWidth(500)
  f:SetBackdrop({
                  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                  tile = true, tileSize = 32, edgeSize = 32,
                  insets = { left=11, right=12, top=12, bottom=11 },
                })
  f:SetBackdropColor(0, 0, 0, 1)
  local help = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  help:SetPoint("TOP", f, "TOP", 0, -20)
  help:SetWidth(f:GetWidth() - 40)
  f.help = help

  local button1 = CreateFrame("Button", nil, f, "StaticPopupButtonTemplate")
  button1:SetPoint("BOTTOM", f, "BOTTOM", 0, 15)
  local button2 = CreateFrame("Button", nil, f, "StaticPopupButtonTemplate")
  button2:SetPoint("BOTTOM", button1, "BOTTOM")
  f.button1 = button1
  f.button2 = button2

  local s = CreateFrame("ScrollFrame", "EPGPExportScrollFrame",
                        f, "UIPanelScrollFrameTemplate2")
  s:SetPoint("TOPLEFT", help, "BOTTOMLEFT", 0, -10)
  s:SetPoint("TOPRIGHT", help, "BOTTOMRIGHT", -20, 0)
  s:SetPoint("BOTTOM", button1, "TOP", 0, 10)

  local b = CreateFrame("EditBox", nil, s)
  b:SetPoint("TOPLEFT")
  b:SetWidth(425)
  b:SetHeight(s:GetHeight())
  b:SetMultiLine(true)
  b:SetAutoFocus(false)
  b:SetFontObject(GameFontHighlight)
  b:SetScript("OnEscapePressed", function (self) self:ClearFocus() end)
  s:SetScrollChild(b)
  f.editbox = b

  f:SetScript(
    "OnShow",
    function (self)
      if self.export == false then
        self.help:SetText(L["To restore to an earlier version of the standings, copy and paste the text from: %s"]:format(EPGPWEB))
        self.editbox:SetText(L["Paste import data here"])
        self.button1:Show()
        self.button1:SetText(ACCEPT)
        self.button1:SetPoint("CENTER", self, "CENTER",
                              -self.button1:GetWidth()/2 - 5, 0)
        self.button1:SetScript("OnClick",
                               function (self)
                                 local text = self:GetParent().editbox:GetText()
                                 EPGP:GetModule("log"):Import(text)
                                 self:GetParent():Hide()
                               end)
        self.button2:Show()
        self.button2:SetText(CANCEL)
        self.button2:SetPoint("LEFT", self.button1, "RIGHT", 10, 0)
        self.button2:SetScript("OnClick",
                               function (self) self:GetParent():Hide() end)
        self.editbox:SetScript("OnTextChanged", nil)
      elseif self.exportDetail then
        self.help:SetText(L["EXPORT_DETAIL_DESC"] .. "\n" ..
                          "https://www.wowepgp.com - " .. _G.ZHCN .. " - " .. L["Web & WeChat Mini Program"])
        self.button1:Show()
        self.button1:SetText(CLOSE)
        self.button1:SetPoint("CENTER", self, "CENTER")
        self.button1:SetScript("OnClick",
                               function (self) self:GetParent():Hide() end)
        self.button2:Hide()
        self.editbox:SetText(EPGP:GetModule("log"):ExportDetail())
        self.editbox:HighlightText()
      else
        self.help:SetText(L["To export the current standings, copy the text below and post it to: %s"]:format(EPGPWEB) .. "\n" ..
                          L["You may need to deselect \"Show only members\" on EPGP web after uploading."])
        self.button1:Show()
        self.button1:SetText(CLOSE)
        self.button1:SetPoint("CENTER", self, "CENTER")
        self.button1:SetScript("OnClick",
                               function (self) self:GetParent():Hide() end)
        self.button2:Hide()
        self.editbox:SetText(EPGP:GetModule("log"):Export())
        self.editbox:HighlightText()
        -- self.editbox:SetScript("OnTextChanged",
        --                        function (self)
        --                          local text = EPGP:GetModule("log"):Export()
        --                          self:SetText(text)
        --                        end)
      end
    end)
  f:SetScript(
    "OnHide",
    function (self)
      self.editbox:SetText("")
    end)
end

local function CreateTableHeader(parent)
  local h = CreateFrame("Button", nil, parent)
  h:SetHeight(24)

  local tl = h:CreateTexture(nil, "BACKGROUND")
  tl:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
  tl:SetWidth(5)
  tl:SetHeight(24)
  tl:SetPoint("TOPLEFT")
  tl:SetTexCoord(0, 0.07815, 0, 0.75)

  local tr = h:CreateTexture(nil, "BACKGROUND")
  tr:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
  tr:SetWidth(5)
  tr:SetHeight(24)
  tr:SetPoint("TOPRIGHT")
  tr:SetTexCoord(0.90625, 0.96875, 0, 0.75)

  local tm = h:CreateTexture(nil, "BACKGROUND")
  tm:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
  tm:SetHeight(24)
  tm:SetPoint("LEFT", tl, "RIGHT")
  tm:SetPoint("RIGHT", tr, "LEFT")
  tm:SetTexCoord(0.07815, 0.90625, 0, 0.75)

  h:SetHighlightTexture(
    "Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight", "ADD")

  return h
end

local function CreateTableRow(parent, rowHeight, widths, justifiesH)
  local row = CreateFrame("Button", nil, parent)
  row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  row:SetHeight(rowHeight)
  row:SetPoint("LEFT")
  row:SetPoint("RIGHT")

  row.cells = {}
  for i,w in ipairs(widths) do
    local c = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    c:SetHeight(rowHeight)
    c:SetWidth(w - (2 * ROW_TEXT_PADDING))
    c:SetJustifyH(justifiesH[i])
    if #row.cells == 0 then
      c:SetPoint("LEFT", row, "LEFT", ROW_TEXT_PADDING, 0)
    else
      c:SetPoint("LEFT", row.cells[#row.cells], "RIGHT", 2 * ROW_TEXT_PADDING, 0)
    end
    table.insert(row.cells, c)
    c:SetText(w)
  end

  return row
end

local function CreateTable(parent, texts, widths, justfiesH, rightPadding)
  assert(#texts == #widths and #texts == #justfiesH,
         "All specification tables must be the same size")
  -- Compute widths
  local totalFixedWidths = rightPadding or 0
  local numDynamicWidths = 0
  for i,w in ipairs(widths) do
    if w > 0 then
      totalFixedWidths = totalFixedWidths + w
    else
      numDynamicWidths = numDynamicWidths + 1
    end
  end
  local remainingWidthSpace = parent:GetWidth() - totalFixedWidths
  assert(remainingWidthSpace >= 0, "Widths specified exceed parent width")

  local dynamicWidth = math.floor(remainingWidthSpace / numDynamicWidths)
  local leftoverWidth = remainingWidthSpace % numDynamicWidths
  for i,w in ipairs(widths) do
    if w <= 0 then
      numDynamicWidths = numDynamicWidths - 1
      if numDynamicWidths then
        widths[i] = dynamicWidth
      else
        widths[i] = dynamicWidth + leftoverWidth
      end
    end
  end

  -- Make headers
  parent.headers = {}
  for i=1,#texts do
    local text, width, justifyH = texts[i], widths[i], justfiesH[i]
    local h = CreateTableHeader(parent, text, width)
    h:SetNormalFontObject("GameFontHighlightSmall")
    h:SetText(text)
    h:GetFontString():SetJustifyH(justifyH)
    h:SetWidth(width)
    if #parent.headers == 0 then
      h:SetPoint("TOPLEFT")
    else
      h:SetPoint("TOPLEFT", parent.headers[#parent.headers], "TOPRIGHT")
    end
    table.insert(parent.headers, h)
  end

  -- Make a frame for the rows
  local rowFrame = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate");
  rowFrame:SetPoint("TOP", parent.headers[#parent.headers], "BOTTOM")
  rowFrame:SetPoint("BOTTOMLEFT")
  rowFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -rightPadding, 0)
  parent.rowFrame = rowFrame

  -- Compute number of rows
  local fontHeight = select(2, GameFontNormalSmall:GetFont())
  local rowHeight = fontHeight + 4
  rowFrame.rowHeight = rowHeight
  local numRows = math.floor(rowFrame:GetHeight() / rowHeight)

  -- Make rows
  rowFrame.rows = {}
  for i=1,numRows do
    local r = CreateTableRow(rowFrame, rowHeight, widths, justfiesH)
    if #rowFrame.rows == 0 then
      r:SetPoint("TOP")
    else
      r:SetPoint("TOP", rowFrame.rows[#rowFrame.rows], "BOTTOM")
    end
    table.insert(rowFrame.rows, r)
  end
end

local function CreateEPGPLogFrame()
  local f = CreateFrame("Frame", "EPGPLogFrame", EPGPFrame, BackdropTemplateMixin and "BackdropTemplate");
  table.insert(SIDEFRAMES, f)

  f:SetResizable(true)
  f:SetMinResize(600, 435)
  f:SetMaxResize(1200, 435)

  f:Hide()
  f:SetWidth(600)
  f:SetHeight(435)
  f:SetPoint("TOPLEFT", EPGPFrame, "TOPRIGHT", -37, -6)

  local t = f:CreateTexture(nil, "OVERLAY")
  t:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner")
  t:SetWidth(32)
  t:SetHeight(32)
  t:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -7)

  t = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  t:SetPoint("TOPLEFT", f, "TOPLEFT", 17, -17)
  t:SetText(L["Personal Action Log"])

  f:SetBackdrop(
    {
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 32,
      insets = { left=11, right=12, top=12, bottom=11 }
    })

  local sizer = CreateFrame("Button", nil, f)
  sizer:SetHeight(16)
  sizer:SetWidth(16)
  sizer:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
  sizer:SetScript(
    "OnMouseDown",
    function (self) self:GetParent():StartSizing("BOTTOMRIGHT") end)
  sizer:SetScript(
    "OnMouseUp", function (self) self:GetParent():StopMovingOrSizing() end)

  local line1 = sizer:CreateTexture(nil, "BACKGROUND")
  line1:SetWidth(14)
  line1:SetHeight(14)
  line1:SetPoint("BOTTOMRIGHT", -8, 8)
  line1:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
  local x = 0.1 * 14/17
  line1:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)

  local line2 = sizer:CreateTexture(nil, "BACKGROUND")
  line2:SetWidth(8)
  line2:SetHeight(8)
  line2:SetPoint("BOTTOMRIGHT", -8, 8)
  line2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
  local x = 0.1 * 8/17
  line2:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)

  local cb = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -3)

  local export = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  export:SetNormalFontObject("GameFontNormalSmall")
  export:SetHighlightFontObject("GameFontHighlightSmall")
  export:SetDisabledFontObject("GameFontDisableSmall")
  export:SetHeight(BUTTON_HEIGHT)
  export:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 17, 13)
  export:SetText(L["Export"])
  export:SetWidth(export:GetTextWidth() + BUTTON_TEXT_PADDING)
  export:SetScript(
    "OnClick",
    function(self, button, down)
      EPGPExportImportFrame.export = true
      EPGPExportImportFrame.exportDetail = false
      EPGPExportImportFrame:Hide()
      EPGPExportImportFrame:Show()
    end)

  local exportDetail = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  exportDetail:SetNormalFontObject("GameFontNormalSmall")
  exportDetail:SetHighlightFontObject("GameFontHighlightSmall")
  exportDetail:SetDisabledFontObject("GameFontDisableSmall")
  exportDetail:SetHeight(BUTTON_HEIGHT)
  exportDetail:SetPoint("LEFT", export, "RIGHT")
  exportDetail:SetText(L["Export Detail"])
  exportDetail:SetWidth(exportDetail:GetTextWidth() + BUTTON_TEXT_PADDING)
  exportDetail:SetScript(
    "OnClick",
    function(self, button, down)
      EPGPExportImportFrame.export = true
      EPGPExportImportFrame.exportDetail = true
      EPGPExportImportFrame:Hide()
      EPGPExportImportFrame:Show()
    end)

  local import = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  import:SetNormalFontObject("GameFontNormalSmall")
  import:SetHighlightFontObject("GameFontHighlightSmall")
  import:SetDisabledFontObject("GameFontDisableSmall")
  import:SetHeight(BUTTON_HEIGHT)
  import:SetPoint("LEFT", exportDetail, "RIGHT")
  import:SetText(L["Import"])
  import:SetWidth(import:GetTextWidth() + BUTTON_TEXT_PADDING)
  import:SetScript(
    "OnClick",
    function(self, button, down)
      EPGPExportImportFrame.export = false
      EPGPExportImportFrame:Hide()
      EPGPExportImportFrame:Show()
    end)

  local undo = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  undo:SetNormalFontObject("GameFontNormalSmall")
  undo:SetHighlightFontObject("GameFontHighlightSmall")
  undo:SetDisabledFontObject("GameFontDisableSmall")
  undo:SetHeight(BUTTON_HEIGHT)
  undo:SetText(L["Undo"])
  undo:SetWidth(undo:GetTextWidth() + BUTTON_TEXT_PADDING)
  undo:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -17, 13)
  undo:SetScript(
    "OnClick",
    function (self, value) EPGP:GetModule("log"):UndoLastAction() end)
  undo:SetScript(
    "OnUpdate",
    function (self)
      if EPGP:GetModule("log"):CanUndo() then
        self:Enable()
      else
        self:Disable()
      end
    end)

  local redo = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  redo:SetNormalFontObject("GameFontNormalSmall")
  redo:SetHighlightFontObject("GameFontHighlightSmall")
  redo:SetDisabledFontObject("GameFontDisableSmall")
  redo:SetHeight(BUTTON_HEIGHT)
  redo:SetText(L["Redo"])
  redo:SetWidth(redo:GetTextWidth() + BUTTON_TEXT_PADDING)
  redo:SetPoint("RIGHT", undo, "LEFT")
  redo:SetScript(
    "OnClick",
    function (self, value) EPGP:GetModule("log"):RedoLastUndo() end)
  redo:SetScript(
    "OnUpdate",
    function (self)
      if EPGP:GetModule("log"):CanRedo() then
        self:Enable()
      else
        self:Disable()
      end
    end)

  local scrollParent = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate");
  scrollParent:SetPoint("TOP", t, "TOP", 0, -16)
  scrollParent:SetPoint("BOTTOM", redo, "TOP", 0, 0)
  scrollParent:SetPoint("LEFT", f, "LEFT", 16, 0)
  scrollParent:SetPoint("RIGHT", f, "RIGHT", -16, 0)
  scrollParent:SetBackdrop(
    {
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true,
      tileSize = 16,
      edgeSize = 16,
      insets = { left=5, right=5, top=5, bottom=5 }
    })
  scrollParent:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r,
                                      TOOLTIP_DEFAULT_COLOR.g,
                                      TOOLTIP_DEFAULT_COLOR.b)
  scrollParent:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
                                TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
                                TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)

  local font = "ChatFontSmall"
  local fontHeight = select(2, getglobal(font):GetFont())
  local recordHeight = fontHeight + 2
  local recordWidth = scrollParent:GetWidth() - 35
  local numLogRecordFrames = math.floor(
    (scrollParent:GetHeight() - 3) / recordHeight)
  local record = scrollParent:CreateFontString("EPGPLogRecordFrame1", "OVERLAY", font)
  record:SetHeight(recordHeight)
  record:SetWidth(recordWidth)
  record:SetNonSpaceWrap(false)
  record:SetPoint("TOPLEFT", scrollParent, "TOPLEFT", 5, -3)
  for i=2,numLogRecordFrames do
    record = scrollParent:CreateFontString("EPGPLogRecordFrame"..i, "OVERLAY", font)
    record:SetHeight(recordHeight)
    record:SetWidth(recordWidth)
    record:SetNonSpaceWrap(false)
    record:SetPoint("TOPLEFT", "EPGPLogRecordFrame"..(i-1), "BOTTOMLEFT")
  end

  local scrollBar = CreateFrame("ScrollFrame", "EPGPLogRecordScrollFrame",
                                scrollParent, "FauxScrollFrameTemplateLight")
  scrollBar:SetWidth(scrollParent:GetWidth() - 35)
  scrollBar:SetHeight(scrollParent:GetHeight() - 10)
  scrollBar:SetPoint("TOPRIGHT", scrollParent, "TOPRIGHT", -28, -6)

  function LogChanged()
    if not EPGPLogFrame:IsVisible() then
      return
    end
    local log = EPGP:GetModule("log")
    local offset = FauxScrollFrame_GetOffset(scrollBar)
    local numRecords = log:GetNumRecords()
    local numDisplayedRecords = math.min(numLogRecordFrames, numRecords - offset)
    local recordWidth = scrollParent:GetWidth() - 35
    for i=1,numLogRecordFrames do
      local record = getglobal("EPGPLogRecordFrame"..i)
      record:SetWidth(recordWidth)
      local logIndex = i + offset - 1
      if logIndex < numRecords then
        record:SetText(log:GetLogRecord(logIndex))
        record:SetJustifyH("LEFT")
        record:Show()
      else
        record:Hide()
      end
    end

    FauxScrollFrame_Update(
      scrollBar, numRecords, numDisplayedRecords, recordHeight)
  end

  EPGPLogFrame:SetScript("OnShow", LogChanged)
  EPGPLogFrame:SetScript("OnSizeChanged", LogChanged)
  scrollBar:SetScript(
    "OnVerticalScroll",
    function(self, value)
      FauxScrollFrame_OnVerticalScroll(scrollBar, value, recordHeight, LogChanged)
    end)
  EPGP:GetModule("log"):RegisterCallback("LogChanged", LogChanged)
end

function EPGP:ItemCacheDropDown_SetList(dropDown, extra)
  local list = {}
  for i=1,GP:GetNumRecentItems() do
    tinsert(list, GP:GetRecentItemLink(i))
  end
  if extra then
    for i = 1, #extra do
      table.insert(list, extra[i])
    end
  end
  local empty = #list == 0
  if empty then list[1] = EMPTY end
  dropDown:SetList(list)
  dropDown:SetItemDisabled(1, empty)
  if empty then
    dropDown:SetValue(nil)
  else
    local text = dropDown.text:GetText()
    for i=1,#list do
      if list[i] == text then
        dropDown:SetValue(i)
        break
      end
    end
  end
end

local function AddGPControls(frame)
  local function SetButtonText(button, text, enable)
    button:SetText(text)
    button:SetWidth(button:GetTextWidth() + BUTTON_TEXT_PADDING)
    if enable then
      button:Enable()
    else
      button:Disable()
    end
  end

  local reasonLabel =
    frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  reasonLabel:SetText(L["GP Reason"])
  reasonLabel:SetPoint("TOPLEFT")

  local gp1, c1, gp2, c2, gp3, c3

  local dropDown = GUI:Create("Dropdown")
  dropDown:SetWidth(168)
  dropDown.frame:SetParent(frame)
  dropDown:SetPoint("TOP", reasonLabel, "BOTTOM")
  dropDown:SetPoint("LEFT", frame, "LEFT", 15, 0)
  dropDown.text:SetJustifyH("LEFT")
  dropDown:SetCallback(
    "OnValueChanged",
    function(self, event, ...)
      local parent = self.frame:GetParent()
      local itemLink = self.text:GetText()

      if itemLink == OTHER then
        parent.otherLabel:SetAlpha(1)
        parent.otherEditBox:SetAlpha(1)
        -- parent.otherEditBox:EnableKeyboard(true)
        -- parent.otherEditBox:EnableMouse(true)
        parent.otherEditBox:SetFocus()
        reason = parent.otherEditBox:GetText()
        local last_award = EPGP.db.profile.last_awards[reason]
        if last_award then
          parent.editBox:SetText(last_award)
        end

        return
      end

      parent.otherLabel:SetAlpha(0.25)
      parent.otherEditBox:SetAlpha(0.25)
      -- parent.otherEditBox:EnableKeyboard(false)
      -- parent.otherEditBox:EnableMouse(false)
      parent.otherEditBox:ClearFocus()

      if itemLink and itemLink ~= "" then
        gp1, c1, gp2, c2, gp3, c3 = GP:GetValue(itemLink)
        if gp1 then
          SetButtonText(parent.gpButton1, ("GP1: %d (%s)"):format(gp1, c1), true)
          parent.editBox:SetText(("%d"):format(gp1))
        else
          SetButtonText(parent.gpButton1, "GP1:", false)
          parent.editBox:SetText("")
        end
        if gp2 then
          SetButtonText(parent.gpButton2, ("GP2: %d (%s)"):format(gp2, c2), true)
        else
          SetButtonText(parent.gpButton2, "GP2:", false)
        end
        if gp3 then
          SetButtonText(parent.gpButton3, ("GP3: %d (%s)"):format(gp3, c3), true)
        else
          SetButtonText(parent.gpButton3, "GP3:", false)
        end
        parent.editBox:SetFocus()
        parent.editBox:HighlightText()
      end
    end)

  dropDown.button:HookScript(
    "OnMouseDown",
    function(self)
      if not self.obj.open then EPGP:ItemCacheDropDown_SetList(self.obj, {OTHER}) end
    end)
  dropDown.button:HookScript(
    "OnClick",
    function(self)
      if self.obj.open then self.obj.pullout:SetWidth(285) end
    end)
  dropDown.button_cover:HookScript(
    "OnMouseDown",
    function(self)
      if not self.obj.open then EPGP:ItemCacheDropDown_SetList(self.obj, {OTHER}) end
    end)
  dropDown.button_cover:HookScript(
    "OnClick",
    function(self)
      if self.obj.open then self.obj.pullout:SetWidth(285) end
    end)
  dropDown:SetCallback(
    "OnEnter",
    function(self)
      local itemLink = self.text:GetText()
      if itemLink and itemLink ~= OTHER then
        local anchor = self.open and self.pullout.frame or self.frame:GetParent()
        GameTooltip:SetOwner(anchor, "ANCHOR_RIGHT", 5)
        GameTooltip:SetHyperlink(itemLink)
      end
    end)
  dropDown:SetCallback("OnLeave", function() GameTooltip:Hide() end)

  local otherLabel =
    frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  otherLabel:SetText(OTHER)
  otherLabel:SetPoint("LEFT")
  otherLabel:SetPoint("TOP", dropDown.frame, "BOTTOM", 0, -2)

  local otherEditBox = CreateFrame("EditBox", "$parentEPControlOtherEditBox",
                                   frame, "InputBoxTemplate")
  otherEditBox:SetFontObject("GameFontHighlightSmall")
  otherEditBox:SetHeight(24)
  otherEditBox:SetAutoFocus(false)
  otherEditBox:SetPoint("LEFT", 25, 0)
  otherEditBox:SetPoint("RIGHT", dropDown.frame, "RIGHT")
  otherEditBox:SetPoint("TOP", otherLabel, "BOTTOM")
  otherEditBox:SetScript(
    "OnTextChanged",
    function(self)
      local last_award =
        EPGP.db.profile.last_awards[self:GetText()]
      if last_award then
        frame.editBox:SetText(last_award)
      end
    end)

  local gpButton1 = CreateFrame("Button", "gpButton1", frame, "UIPanelButtonTemplate")
  gpButton1:SetNormalFontObject("GameFontNormalSmall")
  gpButton1:SetHighlightFontObject("GameFontHighlightSmall")
  gpButton1:SetDisabledFontObject("GameFontDisableSmall")
  gpButton1:SetHeight(BUTTON_HEIGHT)
  gpButton1:SetText("GP1:")
  gpButton1:SetWidth(gpButton1:GetTextWidth() + BUTTON_TEXT_PADDING)
  gpButton1:SetPoint("TOP", otherEditBox, "BOTTOM")
  gpButton1:SetPoint("LEFT", 15, 0)
  gpButton1:Disable()

  local gpButton2 = CreateFrame("Button", "gpButton2", frame, "UIPanelButtonTemplate")
  gpButton2:SetNormalFontObject("GameFontNormalSmall")
  gpButton2:SetHighlightFontObject("GameFontHighlightSmall")
  gpButton2:SetDisabledFontObject("GameFontDisableSmall")
  gpButton2:SetHeight(BUTTON_HEIGHT)
  gpButton2:SetText("GP2:")
  gpButton2:SetWidth(gpButton2:GetTextWidth() + BUTTON_TEXT_PADDING)
  gpButton2:SetPoint("TOP", gpButton1, "BOTTOM")
  gpButton2:SetPoint("LEFT", 15, 0)
  gpButton2:Disable()

  local gpButton3 = CreateFrame("Button", "gpButton3", frame, "UIPanelButtonTemplate")
  gpButton3:SetNormalFontObject("GameFontNormalSmall")
  gpButton3:SetHighlightFontObject("GameFontHighlightSmall")
  gpButton3:SetDisabledFontObject("GameFontDisableSmall")
  gpButton3:SetHeight(BUTTON_HEIGHT)
  gpButton3:SetText("GP3:")
  gpButton3:SetWidth(gpButton3:GetTextWidth() + BUTTON_TEXT_PADDING)
  gpButton3:SetPoint("TOP", gpButton2, "BOTTOM")
  gpButton3:SetPoint("LEFT", 15, 0)
  gpButton3:Disable()

  local label =
    frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  label:SetText(L["Value"])
  label:SetPoint("LEFT", reasonLabel)
  label:SetPoint("TOP", gpButton3, "BOTTOM")

  local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  button:SetNormalFontObject("GameFontNormalSmall")
  button:SetHighlightFontObject("GameFontHighlightSmall")
  button:SetDisabledFontObject("GameFontDisableSmall")
  button:SetHeight(BUTTON_HEIGHT)
  button:SetText(L["Credit GP"])
  button:SetWidth(button:GetTextWidth() + BUTTON_TEXT_PADDING)
  button:SetPoint("RIGHT", dropDown.frame, "RIGHT")
  button:SetPoint("TOP", label, "BOTTOM")

  local editBox = CreateFrame("EditBox", "$parentGPControlEditBox",
                              frame, "InputBoxTemplate")
  editBox:SetFontObject("GameFontHighlightSmall")
  editBox:SetHeight(24)
  editBox:SetAutoFocus(false)
  editBox:SetPoint("LEFT", frame, "LEFT", 25, 0)
  editBox:SetPoint("RIGHT", button, "LEFT")
  editBox:SetPoint("TOP", label, "BOTTOM")

  local function EditBotSetText(text)
    editBox:SetText(text)
    editBox:SetFocus()
    editBox:HighlightText()
  end

  gpButton1:SetScript(
    "OnClick",
    function (self)
      EditBotSetText(tostring(gp1))
    end)
  gpButton2:SetScript(
    "OnClick",
    function (self)
      EditBotSetText(tostring(gp2))
    end)
  gpButton3:SetScript(
    "OnClick",
    function (self)
      EditBotSetText(tostring(gp3))
    end)
  button:SetScript(
    "OnUpdate",
    function(self)
      if EPGP:CanIncGPBy(dropDown.text:GetText(), tonumber(editBox:GetText())) then
        self:Enable()
      else
        self:Disable()
      end
    end)

  frame:SetHeight(
    reasonLabel:GetHeight() +
    otherLabel:GetHeight() +
    otherEditBox:GetHeight() +
    gpButton1:GetHeight() * 3 +
    dropDown.frame:GetHeight() +
    label:GetHeight() +
    button:GetHeight())

  frame.reasonLabel = reasonLabel
  frame.dropDown = dropDown
  frame.label = label
  frame.otherLabel = otherLabel
  frame.otherEditBox = otherEditBox
  frame.gpButton1 = gpButton1
  frame.gpButton2 = gpButton2
  frame.gpButton3 = gpButton3
  frame.button = button
  frame.editBox = editBox

  frame.OnShow =
    function(self)
      editBox:SetText("")
      dropDown:SetValue(nil)
      dropDown.frame:Show()
      otherLabel:SetAlpha(0.25)
      otherEditBox:SetAlpha(0.25)
      SetButtonText(gpButton1, "GP1:", false)
      SetButtonText(gpButton2, "GP2:", false)
      SetButtonText(gpButton3, "GP3:", false)
    end
end

local function EPGPSideFrameEPDropDown_SetList(dropDown)
  local list = {}
  local seen = {}

  -- WOW Classic does not have this API
  -- for dungeons in ipairs(C_Calendar.EventGetTextures(0)) do
  --   if dungeons['expansionLevel'] == GetExpansionLevel() and not seen[dungeons['title']] and dungeons['isLfr'] ~= true then
  --     seen[dungeons['title']] = true
  --     tinsert(list, dungeons['title'])
  --   end
  -- end

  tinsert(list, LE["Karazhan"])
  tinsert(list, LE["Magtheridon's Lair"])
  tinsert(list, LE["Gruul's Lair"])
  tinsert(list, LE["Coilfang: Serpentshrine Cavern"])
  tinsert(list, LE["Tempest Keep"])
  tinsert(list, LE["The Battle for Mount Hyjal"])
  tinsert(list, LE["Black Temple"])
  tinsert(list, LE["The Sunwell"])
  tinsert(list, OTHER)

  dropDown:SetList(list)
  local text = dropDown.text:GetText()
  for i=1,#list do
    if list[i] == text then
      dropDown:SetValue(i)
      break
    end
  end
end

local function AddEPControls(frame, withRecurring)
  local reasonLabel =
    frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  reasonLabel:SetText(L["EP Reason"])
  reasonLabel:SetPoint("TOPLEFT")

  local dropDown = GUI:Create("Dropdown")
  dropDown:SetWidth(168)
  dropDown.frame:SetParent(frame)
  dropDown:SetPoint("TOP", reasonLabel, "BOTTOM")
  dropDown:SetPoint("LEFT", 15, 0)
  dropDown.text:SetJustifyH("LEFT")
  dropDown:SetCallback(
    "OnValueChanged",
    function(self, event, ...)
      local parent = self.frame:GetParent()
      local reason = self.text:GetText()
      local other = reason == OTHER
      parent.otherLabel:SetAlpha(other and 1 or 0.25)
      parent.otherEditBox:SetAlpha(other and 1 or 0.25)
      parent.otherEditBox:EnableKeyboard(other)
      parent.otherEditBox:EnableMouse(other)
      if other then
        parent.otherEditBox:SetFocus()
        reason = parent.otherEditBox:GetText()
      else
        parent.otherEditBox:ClearFocus()
      end
      local last_award = EPGP.db.profile.last_awards[reason]
      if last_award then
          parent.editBox:SetText(last_award)
      end
    end)
  dropDown.button:HookScript(
    "OnMouseDown",
    function(self)
      if not self.obj.open then EPGPSideFrameEPDropDown_SetList(self.obj) end
    end)
  dropDown.button:HookScript(
    "OnClick",
    function(self)
      if self.obj.open then self.obj.pullout:SetWidth(285) end
    end)
  dropDown.button_cover:HookScript(
          "OnMouseDown",
          function(self)
            if not self.obj.open then EPGPSideFrameEPDropDown_SetList(self.obj) end
          end)
  dropDown.button_cover:HookScript(
          "OnClick",
          function(self)
            if self.obj.open then self.obj.pullout:SetWidth(285) end
          end)


  local otherLabel =
    frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  otherLabel:SetText(OTHER)
  otherLabel:SetPoint("LEFT")
  otherLabel:SetPoint("TOP", dropDown.frame, "BOTTOM", 0, -2)

  local otherEditBox = CreateFrame("EditBox", "$parentEPControlOtherEditBox",
                                   frame, "InputBoxTemplate")
  otherEditBox:SetFontObject("GameFontHighlightSmall")
  otherEditBox:SetHeight(24)
  otherEditBox:SetAutoFocus(false)
  otherEditBox:SetPoint("LEFT", 25, 0)
  otherEditBox:SetPoint("RIGHT")
  otherEditBox:SetPoint("TOP", otherLabel, "BOTTOM")
  otherEditBox:SetScript(
    "OnTextChanged",
    function(self)
      local last_award =
        EPGP.db.profile.last_awards[self:GetText()]
      if last_award then
        frame.editBox:SetText(last_award)
      end
    end)

  local label = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  label:SetText(L["Value"])
  label:SetPoint("LEFT")
  label:SetPoint("TOP", otherEditBox, "BOTTOM")

  local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  button:SetNormalFontObject("GameFontNormalSmall")
  button:SetHighlightFontObject("GameFontHighlightSmall")
  button:SetDisabledFontObject("GameFontDisableSmall")
  button:SetHeight(BUTTON_HEIGHT)
  button:SetText(L["Award EP"])
  button:SetWidth(button:GetTextWidth() + BUTTON_TEXT_PADDING)
  button:SetPoint("RIGHT")
  button:SetPoint("TOP", label, "BOTTOM")

  local editBox = CreateFrame("EditBox", "$parentEPControlEditBox",
                              frame, "InputBoxTemplate")
  editBox:SetFontObject("GameFontHighlightSmall")
  editBox:SetHeight(24)
  editBox:SetAutoFocus(false)
  editBox:SetPoint("LEFT", 25, 0)
  editBox:SetPoint("RIGHT", button, "LEFT")
  editBox:SetPoint("TOP", label, "BOTTOM")

  local function EnabledStatus(self)
    local reason = dropDown.text:GetText()
    if reason == OTHER then
      reason = otherEditBox:GetText()
    end
    local amount = editBox:GetNumber()
    if (not withRecurring or UnitInRaid("player")) and
       EPGP:CanIncEPBy(reason, amount) then
      self:Enable()
      self:SetAlpha(1)
    else
      self:Disable()
      self:SetAlpha(self.disabledAlpha)
    end
  end
  button.disabledAlpha = 1
  button:SetScript("OnUpdate", EnabledStatus)

  if withRecurring then
    local recurring =
      CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    recurring:SetWidth(20)
    recurring:SetHeight(20)
    recurring:SetPoint("TOP", editBox, "BOTTOM")
    recurring:SetPoint("LEFT")
    recurring.disabledAlpha = 0.5
    recurring:SetScript(
      "OnUpdate",
      function (self)
        if EPGP:RunningRecurringEP() then
          self:Enable()
        else
          EnabledStatus(self)
        end
      end)

    local label =
      frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    label:SetText(L["Recurring"])
    label:SetPoint("LEFT", recurring, "RIGHT")

    local timePeriod =
      frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    timePeriod:SetJustifyH("RIGHT")

    local incButton = CreateFrame("Button", nil, frame)
    incButton:SetNormalTexture(
      "Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Up")
    incButton:SetPushedTexture(
      "Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Down")
    incButton:SetDisabledTexture(
      "Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Disabled")
    incButton:SetWidth(24)
    incButton:SetHeight(24)

    local decButton = CreateFrame("Button", nil, frame)
    decButton:SetNormalTexture(
      "Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Up")
    decButton:SetPushedTexture(
      "Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Down")
    decButton:SetDisabledTexture(
      "Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Disabled")
    decButton:SetWidth(24)
    decButton:SetHeight(24)

    decButton:SetPoint("RIGHT")
    decButton:SetPoint("TOP", recurring, "TOP")
    incButton:SetPoint("RIGHT", decButton, "LEFT", 8, 0)
    timePeriod:SetPoint("RIGHT", incButton, "LEFT")

    function frame:UpdateTimeControls()
      local period_mins = EPGP:RecurringEPPeriodMinutes()
      local fmt, val = SecondsToTimeAbbrev(period_mins * 60)
      timePeriod:SetText(fmt:format(val))
      recurring:SetChecked(EPGP:RunningRecurringEP())
      if period_mins == 1 or EPGP:RunningRecurringEP() then
        decButton:Disable()
      else
        decButton:Enable()
      end
      if EPGP:RunningRecurringEP() then
        incButton:Disable()
      else
        incButton:Enable()
      end
    end

    incButton:SetScript(
      "OnClick",
      function(self)
        local period_mins = EPGP:RecurringEPPeriodMinutes()
        EPGP:RecurringEPPeriodMinutes(period_mins + 1)
        self:GetParent():UpdateTimeControls()
      end)

    decButton:SetScript(
      "OnClick",
      function(self)
        local period_mins = EPGP:RecurringEPPeriodMinutes()
        EPGP:RecurringEPPeriodMinutes(period_mins - 1)
        self:GetParent():UpdateTimeControls()
      end)

    frame.recurring = recurring
    frame.incButton = incButton
    frame.decButton = decButton
  end

  frame:SetHeight(
    reasonLabel:GetHeight() +
    dropDown.frame:GetHeight() +
    otherLabel:GetHeight() +
    otherEditBox:GetHeight() +
    label:GetHeight() +
    button:GetHeight() +
    (withRecurring and frame.recurring:GetHeight() or 0))

  frame.reasonLabel = reasonLabel
  frame.dropDown = dropDown
  frame.otherLabel = otherLabel
  frame.otherEditBox = otherEditBox
  frame.label = label
  frame.editBox = editBox
  frame.button = button

  frame.OnShow =
    function(self)
      self.editBox:SetText("")
      self.dropDown:SetValue(nil)
      self.dropDown.frame:Show()
      self.otherLabel:SetAlpha(0.25)
      self.otherEditBox:SetAlpha(0.25)
      self.otherEditBox:EnableKeyboard(false)
      self.otherEditBox:EnableMouse(false)
      if self.UpdateTimeControls then
        self:UpdateTimeControls()
      end
    end
end

local function AddCustomGuildInfoControls(frame)
  local vars = EPGP.db.profile

  local useCustomOption = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
  useCustomOption:SetWidth(20)
  useCustomOption:SetHeight(20)
  useCustomOption:SetPoint("LEFT")
  useCustomOption:SetPoint("TOP")

  local t = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  t:SetText(L["Use custom global configuration"])
  t:SetPoint("LEFT", useCustomOption, "RIGHT")

  -- OUTSIDERS
  local outsidersLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  outsidersLabel:SetText("OUTSIDERS")
  outsidersLabel:SetHeight(BUTTON_HEIGHT)
  outsidersLabel:SetPoint("LEFT")
  outsidersLabel:SetPoint("TOP", useCustomOption, "BOTTOM")

  local outsidersEditBox = CreateEditBox(nil, frame)

  local outsidersOkayButton = LUI:CreateTextButton(nil, frame, _G.OKAY, true)
  outsidersOkayButton:SetPoint("RIGHT")
  outsidersOkayButton:SetPoint("TOP", useCustomOption, "BOTTOM")
  outsidersOkayButton:SetScript("OnClick",
    function(self)
      EPGP:SetOutdisers(tonumber(outsidersEditBox:GetText()))
      outsidersEditBox:ClearFocus()
      self:Disable()
    end)

  outsidersEditBox:SetPoint("LEFT", outsidersLabel, "RIGHT", 5, 0)
  outsidersEditBox:SetPoint("TOPRIGHT", outsidersOkayButton, "TOPLEFT", 0, 1)
  outsidersEditBox:SetScript("OnTextChanged",
    function(self)
      local v = tonumber(self:GetText())
      if v and v ~= vars.outsiders and EPGP:ValidOutdisers(v) then
        outsidersOkayButton:Enable()
      else
        outsidersOkayButton:Disable()
      end
    end)

  local outsidersTip = LUI:CreateIconButton(nil, frame, 32, 32,
    "Interface\\COMMON\\help-i",
    "Interface\\Calendar\\EventNotificationGlow")
  outsidersTip:SetPoint("LEFT", outsidersOkayButton, "RIGHT", -5, 0)
  outsidersTip:SetScript("OnEnter", function(self)
    LUI:TextTooltipShow(self, L["OUTSIDERS_DESC"])
  end)
  outsidersTip:SetScript("OnLeave", function(self) LUI:TextTooltipHide(self) end)
  -- OUTSIDERS END

  -- DECAY_P
  local decayPLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  decayPLabel:SetText("DECAY_P")
  decayPLabel:SetHeight(BUTTON_HEIGHT)
  decayPLabel:SetPoint("LEFT")
  decayPLabel:SetPoint("TOP", outsidersLabel, "BOTTOM")

  local decayPEditBox = CreateEditBox(nil, frame)

  local decayPOkayButton = LUI:CreateTextButton(nil, frame, _G.OKAY, true)
  decayPOkayButton:SetPoint("RIGHT")
  decayPOkayButton:SetPoint("TOP", outsidersLabel, "BOTTOM")
  decayPOkayButton:SetScript("OnClick",
    function(self)
      EPGP:SetDecayPercent(tonumber(decayPEditBox:GetText()))
      decayPEditBox:ClearFocus()
      self:Disable()
    end)

  decayPEditBox:SetPoint("LEFT", outsidersLabel, "RIGHT", 5, 0)
  decayPEditBox:SetPoint("TOPRIGHT", decayPOkayButton, "TOPLEFT", 0, 1)
  decayPEditBox:SetScript("OnTextChanged",
    function(self)
      local v = tonumber(self:GetText())
      if v and v ~= vars.decay_p and EPGP:ValidDecayPercent(v) then
        decayPOkayButton:Enable()
      else
        decayPOkayButton:Disable()
      end
    end)

  local decayPTip = LUI:CreateIconButton(nil, frame, 32, 32,
    "Interface\\COMMON\\help-i",
    "Interface\\Calendar\\EventNotificationGlow")
  decayPTip:SetPoint("LEFT", decayPOkayButton, "RIGHT", -5, 0)
  decayPTip:SetScript("OnEnter", function(self)
    LUI:TextTooltipShow(self, L["DECAY_P_DESC"])
  end)
  decayPTip:SetScript("OnLeave", function(self) LUI:TextTooltipHide(self) end)
  -- DECAY_P END

  -- BASE_GP
  local baseGpLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  baseGpLabel:SetText("BASE_GP")
  baseGpLabel:SetHeight(BUTTON_HEIGHT)
  baseGpLabel:SetPoint("LEFT")
  baseGpLabel:SetPoint("TOP", decayPLabel, "BOTTOM")

  local baseGpEditBox = CreateEditBox(nil, frame)

  local baseGpOkayButton = LUI:CreateTextButton(nil, frame, _G.OKAY, true)
  baseGpOkayButton:SetPoint("RIGHT")
  baseGpOkayButton:SetPoint("TOP", decayPLabel, "BOTTOM")
  baseGpOkayButton:SetScript("OnClick",
    function(self)
      EPGP:SetBaseGP(tonumber(baseGpEditBox:GetText()))
      baseGpEditBox:ClearFocus()
      self:Disable()
    end)

  baseGpEditBox:SetPoint("LEFT", outsidersLabel, "RIGHT", 5, 0)
  baseGpEditBox:SetPoint("TOPRIGHT", baseGpOkayButton, "TOPLEFT", 0, 1)
  baseGpEditBox:SetScript("OnTextChanged",
    function(self)
      local v = tonumber(self:GetText())
      if v and v ~= vars.base_gp and EPGP:ValidBaseGP(v) then
        baseGpOkayButton:Enable()
      else
        baseGpOkayButton:Disable()
      end
    end)
  -- BASE_GP END

  -- MIN_EP
  local minEpLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  minEpLabel:SetText("MIN_EP")
  minEpLabel:SetHeight(BUTTON_HEIGHT)
  minEpLabel:SetPoint("LEFT")
  minEpLabel:SetPoint("TOP", baseGpLabel, "BOTTOM")

  local minEpEditBox = CreateEditBox(nil, frame)

  local minEpOkayButton = LUI:CreateTextButton(nil, frame, _G.OKAY, true)
  minEpOkayButton:SetPoint("RIGHT")
  minEpOkayButton:SetPoint("TOP", baseGpLabel, "BOTTOM")
  minEpOkayButton:SetScript("OnClick",
    function(self)
      EPGP:SetMinEP(tonumber(minEpEditBox:GetText()))
      minEpEditBox:ClearFocus()
      self:Disable()
    end)

  minEpEditBox:SetPoint("LEFT", outsidersLabel, "RIGHT", 5, 0)
  minEpEditBox:SetPoint("TOPRIGHT", minEpOkayButton, "TOPLEFT", 0, 1)
  minEpEditBox:SetScript("OnTextChanged",
    function(self)
      local v = tonumber(self:GetText())
      if v and v ~= vars.min_ep and EPGP:ValidMinEP(v) then
        minEpOkayButton:Enable()
      else
        minEpOkayButton:Disable()
      end
    end)
  -- MIN_EP END

  -- EXTRAS_P
  local extrasPLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  extrasPLabel:SetText("EXTRAS_P")
  extrasPLabel:SetHeight(BUTTON_HEIGHT)
  extrasPLabel:SetPoint("LEFT")
  extrasPLabel:SetPoint("TOP", minEpLabel, "BOTTOM")

  local extrasPEditBox = CreateEditBox(nil, frame)

  local extrasPOkayButton = LUI:CreateTextButton(nil, frame, _G.OKAY, true)
  extrasPOkayButton:SetPoint("RIGHT")
  extrasPOkayButton:SetPoint("TOP", minEpLabel, "BOTTOM")
  extrasPOkayButton:SetScript("OnClick",
    function(self)
      EPGP:SetExtrasPercent(tonumber(extrasPEditBox:GetText()))
      extrasPEditBox:ClearFocus()
      self:Disable()
    end)

  extrasPEditBox:SetPoint("LEFT", outsidersLabel, "RIGHT", 5, 0)
  extrasPEditBox:SetPoint("TOPRIGHT", extrasPOkayButton, "TOPLEFT", 0, 1)
  extrasPEditBox:SetScript("OnTextChanged",
    function(self)
      local v = tonumber(self:GetText())
      if v and v ~= vars.extras_p and EPGP:ValidExtrasPercent(v) then
        extrasPOkayButton:Enable()
      else
        extrasPOkayButton:Disable()
      end
    end)

  local extrasPTip = LUI:CreateIconButton(nil, frame, 32, 32,
    "Interface\\COMMON\\help-i",
    "Interface\\Calendar\\EventNotificationGlow")
  extrasPTip:SetPoint("LEFT", extrasPOkayButton, "RIGHT", -5, 0)
  extrasPTip:SetScript("OnEnter", function(self)
    LUI:TextTooltipShow(self, L["EXTRAS_P_DESC"])
  end)
  extrasPTip:SetScript("OnLeave", function(self) LUI:TextTooltipHide(self) end)
  -- EXTRAS_P END

  -- DECAY_BASE_GP
  local decayBaseGp = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
  decayBaseGp:SetWidth(20)
  decayBaseGp:SetHeight(20)
  decayBaseGp:SetPoint("LEFT")
  decayBaseGp:SetPoint("TOP", extrasPLabel, "BOTTOM")
  decayBaseGp:SetScript("OnClick",
    function(self)
      EPGP:SetDecayBaseGp(self:GetChecked() and 1 or 0)
    end)

  local decayBaseGpLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  decayBaseGpLabel:SetText(L["DECAY_BASE_GP_TEXT"])
  decayBaseGpLabel:SetHeight(BUTTON_HEIGHT)
  decayBaseGpLabel:SetPoint("LEFT", decayBaseGp, "RIGHT")

  local decayBaseGpTip = LUI:CreateIconButton(nil, frame, 32, 32,
    "Interface\\COMMON\\help-i",
    "Interface\\Calendar\\EventNotificationGlow")
  decayBaseGpTip:SetPoint("RIGHT", 27, 0)
  decayBaseGpTip:SetPoint("CENTER", decayBaseGp, "CENTER")
  decayBaseGpTip:SetScript("OnEnter", function(self)
    LUI:TextTooltipShow(self, L["DECAY_BASE_GP_DESC"])
  end)
  decayBaseGpTip:SetScript("OnLeave", function(self) LUI:TextTooltipHide(self) end)
  -- DECAY_BASE_GP END

  local editGuildInfoButton = LUI:CreateTextButton(nil, frame, L["Write into Guild Info"], true)
  editGuildInfoButton:SetPoint("LEFT")
  editGuildInfoButton:SetPoint("TOP", decayBaseGpLabel, "BOTTOM")
  editGuildInfoButton:SetScript("OnClick",
    function(self)
      EPGP:SetGlobalConfiguration(
        vars.decay_p,
        vars.extras_p,
        vars.base_gp,
        vars.min_ep,
        vars.outsiders,
        vars.decay_base_gp)
      EPGP:Print(L["Guild info has been updated."])
    end)
  editGuildInfoButton.OnShow =
    function(self)
      if vars.useCustomGuildOptions then
        self:Enable()
      else
        self:Disable()
      end
    end

  local function EnableCustomGuildOptions(enable, init)
    if enable then
      outsidersLabel:SetAlpha(1)
      EnableEditBox(outsidersEditBox, vars.outsiders or "")
      decayPLabel:SetAlpha(1)
      EnableEditBox(decayPEditBox, vars.decay_p or "")
      baseGpLabel:SetAlpha(1)
      EnableEditBox(baseGpEditBox, vars.base_gp or "")
      minEpLabel:SetAlpha(1)
      EnableEditBox(minEpEditBox, vars.min_ep or "")
      extrasPLabel:SetAlpha(1)
      EnableEditBox(extrasPEditBox, vars.extras_p or "")
      decayBaseGpLabel:SetAlpha(1)
      EnableSelectBox(decayBaseGp, vars.decay_base_gp == 1)
    else
      outsidersLabel:SetAlpha(0.25)
      outsidersOkayButton:Disable()
      DisableEditBox(outsidersEditBox, vars.outsiders_guild_info or "")
      EPGP:SetOutdisers(vars.outsiders_guild_info)
      decayPLabel:SetAlpha(0.25)
      decayPOkayButton:Disable()
      DisableEditBox(decayPEditBox, vars.decay_p_guild_info or "")
      EPGP:SetDecayPercent(vars.decay_p_guild_info)
      baseGpLabel:SetAlpha(0.25)
      baseGpOkayButton:Disable()
      DisableEditBox(baseGpEditBox, vars.base_gp_guild_info or "")
      EPGP:SetBaseGP(vars.base_gp_guild_info)
      minEpLabel:SetAlpha(0.25)
      minEpOkayButton:Disable()
      DisableEditBox(minEpEditBox, vars.min_ep_guild_info or "")
      EPGP:SetMinEP(vars.min_ep_guild_info)
      extrasPLabel:SetAlpha(0.25)
      extrasPOkayButton:Disable()
      DisableEditBox(extrasPEditBox, vars.extras_p_guild_info or "")
      EPGP:SetExtrasPercent(vars.extras_p_guild_info)
      decayBaseGpLabel:SetAlpha(0.25)
      DisableSelectBox(decayBaseGp, vars.decay_base_gp_guild_info == 1)
      EPGP:SetDecayBaseGp(vars.decay_base_gp_guild_info)
    end
  end

  useCustomOption.OnShow =
    function(self)
      if vars.useCustomGuildOptions then
        self:SetChecked(true)
        EnableCustomGuildOptions(true)
      else
        self:SetChecked(false)
        EnableCustomGuildOptions(false)
      end
    end
  useCustomOption:SetScript(
    "OnClick",
    function(self)
      if self:GetChecked() then
        editGuildInfoButton:Enable()
        vars.useCustomGuildOptions = true
        EnableCustomGuildOptions(true)
      else
        editGuildInfoButton:Disable()
        vars.useCustomGuildOptions = false
        EnableCustomGuildOptions(false)
      end
    end)

  frame:SetHeight(
    useCustomOption:GetHeight() +
    outsidersLabel:GetHeight() * 5 +
    decayBaseGp:GetHeight() +
    editGuildInfoButton:GetHeight())

  frame.OnShow =
    function(self)
      useCustomOption:OnShow()
      editGuildInfoButton:OnShow()
    end
end

local function RankCheckBoxOnClickFunc(self)
  EPGP:SetManageRank(self.index, self:GetChecked())
end

local function AddDecayControls(frame)
  local vars = EPGP.db.profile
  frame.rank = {}

  local selectAllButton = LUI:CreateTextButton(nil, frame, L["Select all"], true)
  selectAllButton:SetPoint("TOPLEFT")
  selectAllButton:SetScript("OnClick",
    function(self)
      EPGP:SetManageRankAll(true)
      for i, v in pairs(frame.rank) do
        v:SetChecked(true)
      end
    end)
  selectAllButton:Enable()

  local decayButton = LUI:CreateTextButton(nil, frame, L["Decay"], true)
  decayButton:SetPoint("LEFT", selectAllButton, "RIGHT")
  decayButton:SetScript(
    "OnClick",
    function(self, button, down)
      DLG:Spawn("EPGP_DECAY_EPGP", EPGP:GetDecayPercent())
    end)
  decayButton:SetScript(
    "OnUpdate",
    function(self)
      if EPGP:CanDecayEPGP() then
        self:Enable()
      else
        self:Disable()
      end
    end)

  for i = 1, GuildControlGetNumRanks() do
    local cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    cb:SetWidth(20)
    cb:SetHeight(20)
    cb:SetPoint("LEFT")
    if i == 1 then
      cb:SetPoint("TOP", selectAllButton, "BOTTOM")
    else
      cb:SetPoint("TOP", frame.rank[i - 1], "BOTTOM")
    end
    cb.index = i
    cb:SetScript("OnClick", RankCheckBoxOnClickFunc)
    table.insert(frame.rank, cb)

    local l = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    l:SetText(GuildControlGetRankName(i))
    l:SetPoint("LEFT", cb, "RIGHT")
  end

  frame:SetHeight(
    selectAllButton:GetHeight() +
    frame.rank[1]:GetHeight() * #frame.rank)

  frame.OnShow =
    function(self)
      local all = vars.manageRankAll
      for i = 1, GuildControlGetNumRanks() do
        if all then
          vars.manageRank[i] = true
        elseif vars.manageRank[i] == nil then
          vars.manageRank[i] = false
        end
        frame.rank[i]:SetChecked(vars.manageRank[i])
      end
    end
end

local function CreateEPGPSideFrame(self)
  local f = CreateFrame("Frame", "EPGPSideFrame", EPGPFrame, BackdropTemplateMixin and "BackdropTemplate");
  table.insert(SIDEFRAMES, f)

  f:Hide()
  f:SetWidth(225)
  f:SetHeight(310)
  f:SetPoint("TOPLEFT", EPGPFrame, "TOPRIGHT", -33, -20)

  local h = f:CreateTexture(nil, "ARTWORK")
  h:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
  h:SetWidth(300)
  h:SetHeight(68)
  h:SetPoint("TOP", -9, 12)

  f.title = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  f.title:SetPoint("TOP", h, "TOP", 0, -15)

  local t = f:CreateTexture(nil, "OVERLAY")
  t:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner")
  t:SetWidth(32)
  t:SetHeight(32)
  t:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -7)

  f:SetBackdrop(
    {
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 32,
      insets = { left=11, right=12, top=12, bottom=11 }
    })

  local cb = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -3)

  local gpFrame = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate");
  gpFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -30)
  gpFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -15, -30)

  local epFrame = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate");
  epFrame:SetPoint("TOPLEFT", gpFrame, "BOTTOMLEFT", 0, -15)
  epFrame:SetPoint("TOPRIGHT", gpFrame, "BOTTOMRIGHT", -15, -15)

  f:SetScript("OnShow", function(self)
    self.title:SetText(EPGP:GetDisplayCharacterName(self.name))
    if not gpFrame.button then
      AddGPControls(gpFrame)
      f:SetHeight(gpFrame:GetHeight() + epFrame:GetHeight() + 60)
      gpFrame.button:SetScript(
        "OnClick",
        function(self)
          local itemLink = gpFrame.dropDown.text:GetText()
          if itemLink == OTHER then
            itemLink = gpFrame.otherEditBox:GetText()
          end
          local amount = gpFrame.editBox:GetNumber()
          EPGP:IncGPBy(f.name, itemLink, amount)
        end)
    end
    if not epFrame.button then
      AddEPControls(epFrame)
      f:SetHeight(gpFrame:GetHeight() + epFrame:GetHeight() + 60)
      epFrame.button:SetScript(
        "OnClick",
        function(self)
          local reason = epFrame.dropDown.text:GetText()
          if reason == OTHER then
            reason = epFrame.otherEditBox:GetText()
          end
          local amount = epFrame.editBox:GetNumber()
          EPGP:IncEPBy(f.name, reason, amount)
        end)
    end
    if gpFrame.OnShow then gpFrame:OnShow() end
    if epFrame.OnShow then epFrame:OnShow() end
  end)
end

local function CreateEPGPSideFrame2()
  local f = CreateFrame("Frame", "EPGPSideFrame2", EPGPFrame, BackdropTemplateMixin and "BackdropTemplate");
  table.insert(SIDEFRAMES, f)

  f:Hide()
  f:SetWidth(225)
  f:SetPoint("TOPLEFT", EPGPFrame, "TOPRIGHT", -33, -6)

  f:SetBackdrop(
    {
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 32,
      insets = { left=11, right=12, top=12, bottom=11 }
    })

  local cb = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -3)

  local epFrame = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate");
  epFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -15)
  epFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -30, -15)

  local customFrame = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate");
  customFrame:SetPoint("TOPLEFT", epFrame, "BOTTOMLEFT", 0, -15)
  customFrame:SetPoint("TOPRIGHT", epFrame, "BOTTOMRIGHT", 0, -15)

  local decayFrame = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate");
  decayFrame:SetPoint("TOPLEFT", customFrame, "BOTTOMLEFT", 0, -15)
  decayFrame:SetPoint("TOPRIGHT", customFrame, "BOTTOMRIGHT", 0, -15)

  f:SetScript("OnShow", function()
    if not epFrame.initiated then
      epFrame.initiated = true
      AddEPControls(epFrame, true)
      epFrame.button:SetScript(
        "OnClick",
        function(self)
          local reason = epFrame.dropDown.text:GetText()
          if reason == OTHER then
            reason = epFrame.otherEditBox:GetText()
          end
          local amount = epFrame.editBox:GetNumber()
          EPGP:IncMassEPBy(reason, amount)
        end)
      epFrame.recurring:SetScript(
        "OnClick",
        function(self)
          if not EPGP:RunningRecurringEP() then
            local reason = epFrame.dropDown.text:GetText()
            if reason == OTHER then
              reason = epFrame.otherEditBox:GetText()
            end
            local amount = epFrame.editBox:GetNumber()
            EPGP:StartRecurringEP(reason, amount)
          else
            EPGP:StopRecurringEP()
          end
          self:GetParent():UpdateTimeControls()
        end)
    end
    if not customFrame.initiated then
      customFrame.initiated = true
      AddCustomGuildInfoControls(customFrame)
    end
    if not decayFrame.initiated then
      decayFrame.initiated = true
      AddDecayControls(decayFrame)
      f:SetHeight(60 +
        epFrame:GetHeight() +
        customFrame:GetHeight() +
        decayFrame:GetHeight())
    end
    if epFrame.OnShow then epFrame:OnShow() end
    if customFrame.OnShow then customFrame:OnShow() end
    if decayFrame.OnShow then decayFrame:OnShow() end
  end)
end

local function CreateEPGPLootFrame()
  local f = CreateFrame("Frame", "EPGPLootFrame", EPGPFrame, BackdropTemplateMixin and "BackdropTemplate");
  table.insert(SIDEFRAMES, f)

  f:Hide()
  f:SetPoint("TOPLEFT", EPGPFrame, "TOPRIGHT", -33, -6)

  local t = f:CreateTexture(nil, "OVERLAY")
  t:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner")
  t:SetWidth(32)
  t:SetHeight(32)
  t:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -7)

  f:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

  local cb = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -3)

  local itemFrame = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate");
  itemFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -15)
  itemFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -15, -15)
  itemFrame:SetScript("OnShow",
    function()
      if not itemFrame.initiated then
        EPGP:GetModule("distribution"):FillFrame(itemFrame)
        f:SetWidth(itemFrame:GetWidth() + 30)
        f:SetHeight(itemFrame:GetHeight() + 30)
      end
      itemFrame.autoPop:OnShow()
    end)
end

local function CreateEPGPOptionsFrame()
  local f = CreateFrame("Frame", "EPGPOptionsFrame", EPGPFrame, BackdropTemplateMixin and "BackdropTemplate");
  table.insert(SIDEFRAMES, f)

  f:Hide()
  f:SetWidth(500)
  f:SetHeight(400)
  f:SetPoint("TOPLEFT", EPGPFrame, "TOPRIGHT", -33, -6)

  local t = f:CreateTexture(nil, "OVERLAY")
  t:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner")
  t:SetWidth(32)
  t:SetHeight(32)
  t:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -7)

  f:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

  local cb = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -3)

  f:SetScript("OnShow",
    function()
      if not f.initiated then
        f.initiated = true
        EPGP:GetModule("options"):FillFrame(f)
      end
      if f.OnShowFunc then f:OnShowFunc() end
    end)
end

local function CreateEPGPFrameStandings()
  -- Make the show everyone checkbox
  local f = CreateFrame("Frame", nil, EPGPFrame, BackdropTemplateMixin and "BackdropTemplate");
  f:SetHeight(28)
  f:SetPoint("TOPRIGHT", EPGPFrame, "TOPRIGHT", -42, -38)

  local tr = f:CreateTexture(nil, "BACKGROUND")
  tr:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-FilterBorder")
  tr:SetWidth(12)
  tr:SetHeight(28)
  tr:SetPoint("TOPRIGHT")
  tr:SetTexCoord(0.90625, 1, 0, 1)

  local tl = f:CreateTexture(nil, "BACKGROUND")
  tl:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-FilterBorder")
  tl:SetWidth(12)
  tl:SetHeight(28)
  tl:SetPoint("TOPLEFT")
  tl:SetTexCoord(0, 0.09375, 0, 1)

  local tm = f:CreateTexture(nil, "BACKGROUND")
  tm:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-FilterBorder")
  tm:SetHeight(28)
  tm:SetPoint("RIGHT", tr, "LEFT")
  tm:SetPoint("LEFT", tl, "RIGHT")
  tm:SetTexCoord(0.09375, 0.90625, 0, 1)

  local cb = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
  cb:SetWidth(20)
  cb:SetHeight(20)
  cb:SetPoint("RIGHT", f, "RIGHT", -8, 0)
  cb:SetScript(
    "OnShow",
    function(self)
      self:SetChecked(EPGP:StandingsShowEveryone())
    end)
  cb:SetScript(
    "OnClick",
    function(self)
      EPGP:StandingsShowEveryone(not not self:GetChecked())
    end)
  table.insert(disableWhileNotInRaidList, cb)

  local t = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  t:SetText(L["Show everyone"])
  t:SetPoint("RIGHT", cb, "LEFT", 0, 2)

  f:SetWidth(t:GetStringWidth() + 4 * tl:GetWidth() + cb:GetWidth())
  f:Show()

  -- Make the log frame
  CreateEPGPLogFrame()

  -- Make the side frame
  CreateEPGPSideFrame()

  -- Make the second side frame
  CreateEPGPSideFrame2()

  -- Make the loot frame
  CreateEPGPLootFrame()

  -- Make the loot frame
  CreateEPGPOptionsFrame()

  -- Make the main frame
  local main = CreateFrame("Frame", nil, EPGPFrame, BackdropTemplateMixin and "BackdropTemplate");
  main:SetWidth(325)
  main:SetHeight(358)
  main:SetPoint("TOPLEFT", EPGPFrame, 19, -72)

  local loot = CreateFrame("Button", nil, main, "UIPanelButtonTemplate")
  loot:SetNormalFontObject("GameFontNormalSmall")
  loot:SetHighlightFontObject("GameFontHighlightSmall")
  loot:SetDisabledFontObject("GameFontDisableSmall")
  loot:SetHeight(BUTTON_HEIGHT)
  loot:SetPoint("BOTTOMLEFT")
  loot:SetText(_G.LOOT)
  loot:SetWidth(loot:GetTextWidth() + BUTTON_TEXT_PADDING)
  loot:SetScript("OnClick", function() ToggleOnlySideFrame(EPGPLootFrame) end)

  local award = CreateFrame("Button", nil, main, "UIPanelButtonTemplate")
  award:SetNormalFontObject("GameFontNormalSmall")
  award:SetHighlightFontObject("GameFontHighlightSmall")
  award:SetDisabledFontObject("GameFontDisableSmall")
  award:SetHeight(BUTTON_HEIGHT)
  award:SetPoint("BOTTOMLEFT", loot, "TOPLEFT")
  award:SetText(L["Mass EP Award"] .. "/" .. L["Decay"])
  award:SetWidth(award:GetTextWidth() + BUTTON_TEXT_PADDING)
  award:SetScript(
    "OnClick",
    function()
      ToggleOnlySideFrame(EPGPSideFrame2)
    end)
  -- table.insert(disableWhileNotInRaidList, award)

  local log = CreateFrame("Button", nil, main, "UIPanelButtonTemplate")
  log:SetNormalFontObject("GameFontNormalSmall")
  log:SetHighlightFontObject("GameFontHighlightSmall")
  log:SetDisabledFontObject("GameFontDisableSmall")
  log:SetHeight(BUTTON_HEIGHT)
  log:SetPoint("BOTTOMRIGHT")
  log:SetText(L["Logs"])
  log:SetWidth(log:GetTextWidth() + BUTTON_TEXT_PADDING)
  log:SetScript(
    "OnClick",
    function(self, button, down)
      ToggleOnlySideFrame(EPGPLogFrame)
    end)

  local option = CreateFrame("Button", nil, main, "UIPanelButtonTemplate")
  option:SetNormalFontObject("GameFontNormalSmall")
  option:SetHighlightFontObject("GameFontHighlightSmall")
  option:SetDisabledFontObject("GameFontDisableSmall")
  option:SetHeight(BUTTON_HEIGHT)
  option:SetPoint("BOTTOMRIGHT", log, "TOPRIGHT")
  option:SetText(_G.SETTINGS)
  option:SetWidth(option:GetTextWidth() + BUTTON_TEXT_PADDING)
  option:SetScript(
    "OnClick",
    function(self, button, down)
      ToggleOnlySideFrame(EPGPOptionsFrame)
    end)

  local fontHeight = select(2, GameFontNormal:GetFont())

  local recurringTime = main:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  recurringTime:SetHeight(fontHeight)
  recurringTime:SetJustifyH("CENTER")
  recurringTime:SetPoint("LEFT", loot, "RIGHT")
  recurringTime:SetPoint("RIGHT", log, "LEFT")
  -- recurringTime:SetPoint("RIGHT", f, "LEFT", -10, 0)
  recurringTime:Hide()
  function recurringTime:StartRecurringAward()
    self:Show()
  end
  function recurringTime:ResumeRecurringAward()
    self:Show()
  end
  function recurringTime:StopRecurringAward()
    self:Hide()
  end
  function recurringTime:RecurringAwardUpdate(
      event_type, reason, amount, time_left)
    local fmt, val = SecondsToTimeAbbrev(time_left)
    self:SetFormattedText(L["Next award in "] .. fmt, val)
  end

  EPGP.RegisterCallback(recurringTime, "StartRecurringAward")
  EPGP.RegisterCallback(recurringTime, "ResumeRecurringAward")
  EPGP.RegisterCallback(recurringTime, "StopRecurringAward")
  EPGP.RegisterCallback(recurringTime, "RecurringAwardUpdate")

  -- Make the status text
  local statusText = main:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  statusText:SetHeight(fontHeight)
  statusText:SetJustifyH("CENTER")
  statusText:SetPoint("BOTTOMLEFT", award, "TOPLEFT")
  statusText:SetPoint("BOTTOMRIGHT", log, "TOPRIGHT")

  function statusText:TextUpdate()
    self:SetFormattedText(
      "Decay=%s%% BaseGP=%s MinEP=%s Extras=%s%%",
      "|cFFFFFFFF"..EPGP:GetDecayPercent().."|r",
      "|cFFFFFFFF"..EPGP:GetBaseGP().."|r",
      "|cFFFFFFFF"..EPGP:GetMinEP().."|r",
      "|cFFFFFFFF"..EPGP:GetExtrasPercent().."|r")
  end
  EPGP.RegisterCallback(statusText, "DecayPercentChanged", "TextUpdate")
  EPGP.RegisterCallback(statusText, "BaseGPChanged", "TextUpdate")
  EPGP.RegisterCallback(statusText, "MinEPChanged", "TextUpdate")
  EPGP.RegisterCallback(statusText, "ExtrasPercentChanged", "TextUpdate")

  -- Make the mode text
  local modeText = main:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  modeText:SetHeight(fontHeight)
  modeText:SetJustifyH("CENTER")
  modeText:SetPoint("BOTTOMLEFT", statusText, "TOPLEFT")
  modeText:SetPoint("BOTTOMRIGHT", statusText, "TOPRIGHT")

  function modeText:TextUpdate()
    local mode
    if UnitInRaid("player") then
      mode = "|cFFFF0000" .. _G.RAID .. "|r"
    else
      mode = "|cFF00FF00" .. _G.GUILD .. "|r"
    end
    self:SetFormattedText("%s (%s)", mode,
                          "|cFFFFFFFF"..EPGP:GetNumMembersInAwardList().."|r")
  end

  -- Make the table frame
  local tabl = CreateFrame("Frame", nil, main, BackdropTemplateMixin and "BackdropTemplate");
  tabl:SetPoint("TOPLEFT")
  tabl:SetPoint("TOPRIGHT")
  tabl:SetPoint("BOTTOM", modeText, "TOP")
  -- Also hook the status texts to update on show
  tabl:SetScript(
    "OnShow",
    function (self)
      statusText:TextUpdate()
      modeText:TextUpdate()
    end)

  -- Populate the table
  CreateTable(tabl,
              {"Name", "EP", "GP", "PR", "B/R"},
              {0, 50, 50, 60, 32},
              {"LEFT", "RIGHT", "RIGHT", "RIGHT", "RIGHT"},
              27)  -- The scrollBarWidth

  -- Make the scrollbar
  local rowFrame = tabl.rowFrame
  rowFrame.needUpdate = true
  local scrollBar = CreateFrame("ScrollFrame", "EPGPScrollFrame",
                                rowFrame, "FauxScrollFrameTemplateLight")
  scrollBar:SetWidth(rowFrame:GetWidth())
  scrollBar:SetPoint("TOPRIGHT", rowFrame, "TOPRIGHT", 0, -2)
  scrollBar:SetPoint("BOTTOMRIGHT")

  -- Make all our rows have a check on them and setup the OnClick
  -- handler for each row.
  for i,r in ipairs(rowFrame.rows) do
    r.check = r:CreateTexture(nil, "BACKGROUND")
    r.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    r.check:SetWidth(r:GetHeight())
    r.check:SetHeight(r:GetHeight())
    r.check:SetPoint("RIGHT", r.cells[1])

    r:RegisterForClicks("LeftButtonDown")
    r:SetScript(
      "OnClick",
      function(self, value)
        if IsModifiedClick("QUESTWATCHTOGGLE") then
          if self.check:IsShown() then
            EPGP:DeSelectMember(self.name)
          else
            EPGP:SelectMember(self.name)
          end
        else
          if EPGPSideFrame.name ~= self.name then
            self:LockHighlight()
            EPGPSideFrame:Hide()
            EPGPSideFrame.name = self.name
          end
          ToggleOnlySideFrame(EPGPSideFrame)
        end
      end)

    r:SetScript(
      "OnEnter",
      function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, self)
        GameTooltip:AddLine(GS:GetRank(self.name))
        if EPGP:GetNumAlts(self.name) > 0 then
          GameTooltip:AddLine("\n"..L["Alts"])
          for i=1,EPGP:GetNumAlts(self.name) do
            local altName = EPGP:GetAlt(self.name, i)

            -- Show short alt name for alts from our server and long for others
            altName = EPGP:GetDisplayCharacterName(altName)
            GameTooltip:AddLine(altName, 1, 1, 1)
          end
        elseif EPGP:GetMain(self.name) ~= self.name then
          -- Show the main name for alts
          GameTooltip:AddLine("\n"..L["Main"])
          GameTooltip:AddLine(EPGP:GetMain(self.name), 1, 1, 1)
        end
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT")
        GameTooltip:Show()
      end)
    r:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end

  -- Hook up the headers
  tabl.headers[1]:SetScript(
    "OnClick", function(self) EPGP:StandingsSort("NAME") end)
  tabl.headers[2]:SetScript(
    "OnClick", function(self) EPGP:StandingsSort("EP") end)
  tabl.headers[3]:SetScript(
    "OnClick", function(self) EPGP:StandingsSort("GP") end)
  tabl.headers[4]:SetScript(
    "OnClick", function(self) EPGP:StandingsSort("PR") end)
  tabl.headers[5]:SetScript(
    "OnClick", function(self) EPGP:StandingsSort("BR") end)

  -- Install the update function on rowFrame.
  local function UpdateStandings()
    if not rowFrame.needUpdate then return end
    modeText:TextUpdate()

    local offset = FauxScrollFrame_GetOffset(EPGPScrollFrame)
    local numMembers = EPGP:GetNumMembers()
    local numDisplayedMembers = math.min(#rowFrame.rows, numMembers - offset)
    local minEP = EPGP:GetMinEP()
    for i=1,#rowFrame.rows do
      local row = rowFrame.rows[i]
      local j = i + offset
      if j <= numMembers then
        local name = EPGP:GetMember(j)
        row.name = name
        row.cells[1]:SetText(Ambiguate(row.name, "short"))
        local c = _G.RAID_CLASS_COLORS[EPGP:GetClass(row.name)]
        row.cells[1]:SetTextColor(c.r, c.g, c.b)
        local ep, gp = EPGP:GetEPGP(row.name)
        row.cells[2]:SetText(ep)
        row.cells[3]:SetText(gp)
        local pr = 0
        if gp then
          pr = ep / math.max(1, gp)
        end
        if pr > 9999 then
          row.cells[4]:SetText(math.floor(pr))
        else
          row.cells[4]:SetFormattedText("%.4g", pr)
        end

        local bid_result, bid_violate = EPGP:GetBidResult(name)
        row.cells[5]:SetText(bid_result)
        if bid_violate then
          row.cells[5]:SetTextColor(1, 0, 0)
        else
          row.cells[5]:SetTextColor(1, 1, 1)
        end

        row.check:Hide()
        if UnitInRaid("player") then -- and EPGP:StandingsShowEveryone()
          local state_ = EPGP:GetMemberAwardState(row.name)
          if state_ == 1 then
            row.check:SetTexture("Interface\\CURSOR\\Attack")
            row.check:Show()
          elseif state_ == 2 then
            row.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            row.check:Show()
          end
        elseif EPGP:IsAnyMemberInExtrasList() then
          if EPGP:IsMemberInAwardList(row.name) then
            row.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            row.check:Show()
          end
        end
        row:SetAlpha(ep < minEP and 0.6 or 1)
        row:Show()
      else
        row:Hide()
      end
      -- Fix the highlighting of the rows
      if row.name == EPGPSideFrame.name then
        row:LockHighlight()
      else
        row:UnlockHighlight()
      end
    end

    FauxScrollFrame_Update(EPGPScrollFrame, numMembers, numDisplayedMembers,
                           rowFrame.rowHeight, nil, nil, nil, nil,
                           nil, nil, true)
    EPGPSideFrame:SetScript(
      "OnHide",
      function(self)
        self.name = nil
        rowFrame.needUpdate = true
        UpdateStandings()
      end)
    rowFrame.needUpdate = nil
  end

  rowFrame:SetScript("OnUpdate", UpdateStandings)
  EPGP.RegisterCallback(rowFrame, "StandingsChanged",
                        function() rowFrame.needUpdate = true end)
  rowFrame:SetScript("OnShow", UpdateStandings)
  scrollBar:SetScript(
    "OnVerticalScroll",
    function(self, value)
      rowFrame.needUpdate = true
      FauxScrollFrame_OnVerticalScroll(
        self, value, rowFrame.rowHeight, UpdateStandings)
    end)
end

function EPGP:ShowDistrubutionFrame()
  if not EPGPFrame then return end
  if not EPGPFrame:IsShown() then
    ShowUIPanel(EPGPFrame)
  end
  ToggleOnlySideFrame(EPGPLootFrame)
end

local function OnEvent(self, event, ...)
  if event == "GROUP_ROSTER_UPDATE" then
    DisableWhileNotInRaid()
  end
end

local function OnShow(self)
  GuildRoster()
  DisableWhileNotInRaid()
end

function mod:OnEnable()
  if not EPGPFrame then
    CreateEPGPFrame()
    CreateEPGPFrameStandings()
    CreateEPGPExportImportFrame()
  end

  HideUIPanel(EPGPFrame)
  EPGPFrame:SetScript("OnShow", OnShow)
  EPGPFrame:SetScript("OnEvent", OnEvent)
  EPGPFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function mod:OnDisable()
end
