-- DeepRivals v6
-- Base Script by yes.dev

local myScriptCode = [==[
if _G.__deeprivals_v6 then warn("[deeprivals] running.") return end
_G.__deeprivals_v6 = true

local VIM      = game:GetService("VirtualInputManager")
local Players  = game:GetService("Players")
local Run      = game:GetService("RunService")
local UIS      = game:GetService("UserInputService")
local RS       = game:GetService("ReplicatedStorage")
local Tween    = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Http     = game:GetService("HttpService")
local Stats    = game:GetService("Stats")
local Teleport = game:GetService("TeleportService")
local VUser    = game:GetService("VirtualUser")

local Camera = workspace.CurrentCamera
local LP     = Players.LocalPlayer
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local CACHE_FOLDER = "DeepRivals"
local CACHE_FILE   = CACHE_FOLDER .. "/settings.json"

pcall(function()
    if makefolder and isfolder and not isfolder(CACHE_FOLDER) then
        makefolder(CACHE_FOLDER)
    end
end)

local CONNS, DEAD = {}, false

local function track(c)
    if DEAD then pcall(function() c:Disconnect() end) return c end
    table.insert(CONNS, c)
    return c
end

local function disconnectAll()
    for _, c in ipairs(CONNS) do
        pcall(function() c:Disconnect() end)
    end
    CONNS = {}
end

-- colors
local ACCENT   = Color3.fromRGB(120, 200, 255)
local ACCENT_D = Color3.fromRGB(50, 100, 150)
local BG       = Color3.fromRGB(13, 15, 19)
local BG2      = Color3.fromRGB(20, 23, 28)
local ROW      = Color3.fromRGB(27, 31, 37)
local ROW_H    = Color3.fromRGB(36, 41, 49)
local TXT      = Color3.fromRGB(235, 240, 245)
local TXT_D    = Color3.fromRGB(150, 158, 168)
local TXT_F    = Color3.fromRGB(75, 82, 92)
local GREEN    = Color3.fromRGB(90, 230, 140)
local RED      = Color3.fromRGB(235, 90, 90)
local YELLOW   = Color3.fromRGB(240, 200, 80)
local TAG_COLOR = { LOCAL = GREEN, MIX = YELLOW, SRV = RED }

-- settings
local Default = {
    Aimbot_Enabled         = true,
    Aimbot_FOV             = 120,
    Aimbot_Smooth          = 0.35,
    Aimbot_WallCheck       = false,
    Aimbot_AutoShoot       = false,
    Aimbot_Keybind         = "E",
    Aimbot_KeybindMode     = false,
    Aimbot_Priority        = "Nearest",

    Triggerbot_Enabled     = true,
    Triggerbot_Range       = 1000,

    SilentAim_Enabled      = false,
    SilentAim_FOV          = 150,
    SilentAim_Range        = 500,
    SilentAim_WallCheck    = false,
    SilentAim_HitChance    = 100,
    SilentAim_Marker       = true,
    SilentAim_SprayLock    = true,
    SilentAim_Anywhere     = true,   -- ignore FOV / screen
    SilentAim_ComboSpin    = false,

    NoRecoil_Enabled       = false,
    NoSpread_Enabled       = false,
    InfAmmo_Enabled        = false,
    RapidFire_Enabled      = false,
    RapidFire_Rate         = 3,

    ESP_Enabled            = true,
    ESP_Highlight          = true,
    ESP_Name               = true,
    ESP_Distance           = true,
    ESP_Health             = true,
    ESP_Tracer             = false,
    ESP_Box                = false,
    ESP_Skeleton           = false,
    ESP_HeadDot            = false,
    ESP_MaxDist            = 800,
    ESP_Transparency       = 0.5,

    Fullbright_Enabled     = false,
    FOV_Enabled            = false,
    FOV_Value              = 70,
    ThirdPerson_Enabled    = false,
    ThirdPerson_Dist       = 8,
    CustomCrosshair        = false,
    NoFog_Enabled          = false,

    Fly_Enabled            = false,
    Fly_Speed              = 60,
    Fly_Keybind            = "F",
    Noclip_Enabled         = false,
    InfJump_Enabled        = false,
    WalkSpeed_Enabled      = false,
    WalkSpeed_Value        = 16,
    JumpPower_Enabled      = false,
    JumpPower_Value        = 50,
    Sprint_Enabled         = false,
    Sprint_Multiplier      = 2,
    BunnyHop_Enabled       = false,
    FastSwim_Enabled       = false,
    AntiFling_Enabled      = false,
    SlowFall_Enabled       = false,
    TeleportWalk_Enabled   = false,

    Orbit_Enabled          = false,
    Orbit_Radius           = 10,
    Orbit_Speed            = 2,
    Orbit_CrouchHeight     = 2,

    Spin_Enabled           = false,
    Spin_Speed             = 2,
    HitboxExpander_Enabled = false,
    HitboxExpander_Size    = 5,
    AutoExec_Enabled       = false,
    AntiAFK_Enabled        = true,
    RemoveTextures_Enabled = false,
    LowGraphics_Enabled    = false,
    FPSCounter_Enabled     = false,
    PingDisplay_Enabled    = false,
    MemoryDisplay_Enabled  = false,
    PlayerCountDisplay     = false,

    DeviceSpoofer_Active   = nil,
}

local function loadSettings()
    local ok, r = pcall(function()
        if isfile and isfile(CACHE_FILE) then
            local d = Http:JSONDecode(readfile(CACHE_FILE))
            for k, v in pairs(Default) do
                if d[k] == nil then d[k] = v end
            end
            return d
        end
    end)
    if ok and r then return r end
    local t = {}
    for k, v in pairs(Default) do t[k] = v end
    return t
end

local SERIAL = { boolean = true, number = true, string = true }

local function saveSettings()
    if DEAD then return end
    pcall(function()
        if writefile then
            local clean = {}
            for k, v in pairs(Settings) do
                if SERIAL[typeof(v)] or v == nil then clean[k] = v end
            end
            writefile(CACHE_FILE, Http:JSONEncode(clean))
        end
    end)
end

local Settings = loadSettings()

local function clamp(v, mn, mx, fb)
    if typeof(v) ~= "number" or v < mn or v > mx then return fb end
    return v
end

Settings.Aimbot_FOV          = clamp(Settings.Aimbot_FOV, 10, 800, 120)
Settings.Aimbot_Smooth       = clamp(Settings.Aimbot_Smooth, 0, 0.95, 0.35)
Settings.SilentAim_FOV       = clamp(Settings.SilentAim_FOV, 10, 1000, 150)
Settings.SilentAim_Range     = clamp(Settings.SilentAim_Range, 20, 2000, 500)
Settings.SilentAim_HitChance = clamp(Settings.SilentAim_HitChance, 0, 100, 100)
Settings.Fly_Speed           = clamp(Settings.Fly_Speed, 5, 500, 60)
Settings.Spin_Speed          = clamp(Settings.Spin_Speed, 0.25, 10, 2)
Settings.HitboxExpander_Size = clamp(Settings.HitboxExpander_Size, 1, 20, 5)
Settings.WalkSpeed_Value     = clamp(Settings.WalkSpeed_Value, 8, 250, 16)
Settings.JumpPower_Value     = clamp(Settings.JumpPower_Value, 30, 400, 50)
Settings.Sprint_Multiplier   = clamp(Settings.Sprint_Multiplier, 1, 5, 2)
Settings.FOV_Value           = clamp(Settings.FOV_Value, 30, 120, 70)
Settings.ThirdPerson_Dist    = clamp(Settings.ThirdPerson_Dist, 3, 40, 8)
Settings.RapidFire_Rate      = clamp(Settings.RapidFire_Rate, 1, 20, 3)
Settings.Orbit_Radius        = clamp(Settings.Orbit_Radius, 3, 40, 10)
Settings.Orbit_Speed         = clamp(Settings.Orbit_Speed, 0.25, 10, 2)
Settings.Orbit_CrouchHeight  = clamp(Settings.Orbit_CrouchHeight, 0, 6, 2)

if typeof(Settings.Fly_Keybind) ~= "string" or Settings.Fly_Keybind == "" then
    Settings.Fly_Keybind = "F"
end
if typeof(Settings.Aimbot_Keybind) ~= "string" or Settings.Aimbot_Keybind == "" then
    Settings.Aimbot_Keybind = "E"
end

-- team / enemy
local teamCache, teamTime = {}, {}
local TC_TTL = 0.15

local function normTeam(v)
    if v == nil then return nil end
    local t = typeof(v)
    if t == "Instance" then return v end
    if t == "Color3" then return string.format("c:%.3f:%.3f:%.3f", v.R, v.G, v.B) end
    if t == "BrickColor" then return "b:" .. v.Name end
    if t == "string" then return v == "" and nil or ("s:" .. v) end
    if t == "number" then return "n:" .. tostring(v) end
    if t == "boolean" then return "x:" .. tostring(v) end
    return nil
end

local function isTeamName(n)
    if typeof(n) ~= "string" then return false end
    local l = string.gsub(string.lower(n), "[%s_%-]", "")
    return l == "team" or l == "teamid" or l == "teamidentifier"
        or l == "teamindex" or l == "teamcolor" or l == "teamcolour"
        or string.find(l, "teamid", 1, true) ~= nil
end

local function getTeamAttr(c)
    if not c then return nil end
    local ok, a = pcall(function() return c:GetAttributes() end)
    if not ok or not a then return nil end
    for k, v in pairs(a) do
        if isTeamName(k) then
            local n = normTeam(v)
            if n ~= nil then return n end
        end
    end
    return nil
end

local function getTeamVal(c)
    if not c then return nil end
    local ok, ch = pcall(function() return c:GetChildren() end)
    if not ok or not ch then return nil end
    for _, o in ipairs(ch) do
        if isTeamName(o.Name) then
            local n = normTeam(o.Value)
            if n then return n end
        end
    end
    return nil
end

local function teamSig(p)
    if not p then return nil end
    local now = os.clock()
    if teamCache[p] ~= nil and teamTime[p] and now - teamTime[p] < TC_TTL then
        return teamCache[p]
    end
    local s = p.Team or getTeamAttr(p) or getTeamVal(p)
        or (p.Character and getTeamAttr(p.Character))
        or (p.Character and getTeamVal(p.Character))
    if not s then
        local ok, tc = pcall(function() return p.TeamColor end)
        if ok and tc and tc.Name ~= "Medium stone grey" then
            s = "b:" .. tc.Name
        end
    end
    teamCache[p] = s
    teamTime[p]  = now
    return s
end

local function clearTeam(p) teamCache[p], teamTime[p] = nil, nil end

local function isTeammate(p)
    if not p or p == LP then return true end
    local ok1, lt = pcall(function() return LP.Team end)
    local ok2, pt = pcall(function() return p.Team end)
    if ok1 and ok2 and lt and pt then return lt == pt end
    local ls, ts = teamSig(LP), teamSig(p)
    if ls ~= nil and ts ~= nil then
        if typeof(ls) == "Instance" and typeof(ts) == "Instance" then return ls == ts end
        return tostring(ls) == tostring(ts)
    end
    return false
end

local function isEnemy(p) return p and p ~= LP and not isTeammate(p) end

local enemyList, enemyTime = {}, 0
local ENEMY_TTL = 0.05

local function getEnemies()
    if DEAD then return {} end
    local now = os.clock()
    if now - enemyTime < ENEMY_TTL then return enemyList end
    local r = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and isEnemy(p) then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then table.insert(r, p) end
        end
    end
    enemyList, enemyTime = r, now
    return r
end

track(Players.PlayerAdded:Connect(function(p)
    clearTeam(p)
    track(p:GetPropertyChangedSignal("Team"):Connect(function() clearTeam(p) end))
    track(p:GetPropertyChangedSignal("TeamColor"):Connect(function() clearTeam(p) end))
    track(p.CharacterAdded:Connect(function() clearTeam(p) end))
end))

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then
        track(p:GetPropertyChangedSignal("Team"):Connect(function() clearTeam(p) end))
        track(p:GetPropertyChangedSignal("TeamColor"):Connect(function() clearTeam(p) end))
        track(p.CharacterAdded:Connect(function() clearTeam(p) end))
    end
end

track(Players.PlayerRemoving:Connect(function(p) clearTeam(p) end))

-- raycast
local rpParams = RaycastParams.new()
rpParams.FilterType = Enum.RaycastFilterType.Exclude

local function makeRP(target)
    local bl = {}
    if LP.Character then table.insert(bl, LP.Character) end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character ~= target then
            table.insert(bl, p.Character)
        end
    end
    rpParams.FilterDescendantsInstances = bl
    return rpParams
end

local function hasLOS(part)
    if not part or not Camera then return false end
    local par = part.Parent
    if not par then return false end
    local ok, tpos = pcall(function() return part.Position end)
    if not ok then return false end
    local camPos = Camera.CFrame.Position
    local off = tpos - camPos
    local dist = off.Magnitude
    if dist <= 0 then return false end
    local ok2, res = pcall(function()
        return workspace:Raycast(camPos, off.Unit * dist, makeRP(par))
    end)
    if not ok2 then return true end
    if not res or not res.Instance then return true end
    return res.Instance:IsDescendantOf(par)
end

local function crosshair()
    if not Camera then return Vector2.new(0, 0) end
    if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
        local vp = Camera.ViewportSize
        return Vector2.new(vp.X / 2, vp.Y / 2)
    end
    return UIS:GetMouseLocation()
end

local function w2s(pos)
    if not Camera then return nil, false end
    local ok, r = pcall(function() return Camera:WorldToScreenPoint(pos) end)
    if not ok or not r then return nil, false end
    return Vector2.new(r.X, r.Y), r.Z > 0
end

-- ============================================================
-- UI
-- ============================================================

local pg = LP:WaitForChild("PlayerGui")

local SG = Instance.new("ScreenGui")
SG.Name = "DeepRivalsV6"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 999
SG.Parent = pg

local function computeSize()
    local vp = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    return math.clamp(vp.X * 0.62, 560, 860), math.clamp(vp.Y * 0.76, 380, 640)
end

local PW, PH = computeSize()

local Root = Instance.new("Frame")
Root.Name = "Root"
Root.AnchorPoint = Vector2.new(0.5, 0.5)
Root.Position = UDim2.fromScale(0.5, 0.5)
Root.Size = UDim2.fromOffset(PW, PH)
Root.BackgroundColor3 = BG
Root.BorderSizePixel = 0
Root.Visible = false
Root.Active = true
Root.ZIndex = 100
Root.Parent = SG

Instance.new("UICorner", Root).CornerRadius = UDim.new(0, 14)

local RS1 = Instance.new("UIStroke")
RS1.Color = ACCENT_D
RS1.Thickness = 1.5
RS1.Transparency = 0.4
RS1.Parent = Root

local RG = Instance.new("UIGradient")
RG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 29, 36)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 14, 18)),
})
RG.Rotation = 90
RG.Parent = Root

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundTransparency = 1
Header.ZIndex = 101
Header.Parent = Root

local AB = Instance.new("Frame")
AB.Size = UDim2.new(1, -32, 0, 2)
AB.Position = UDim2.new(0, 16, 1, -8)
AB.BackgroundColor3 = ACCENT
AB.BorderSizePixel = 0
AB.BackgroundTransparency = 0.5
AB.ZIndex = 101
AB.Parent = Header

Instance.new("UICorner", AB).CornerRadius = UDim.new(1, 0)

local DOT = Instance.new("Frame")
DOT.Size = UDim2.fromOffset(10, 10)
DOT.Position = UDim2.new(0, 20, 0.5, -5)
DOT.BackgroundColor3 = ACCENT
DOT.BorderSizePixel = 0
DOT.ZIndex = 102
DOT.Parent = Header

Instance.new("UICorner", DOT).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DeepRivals"
Title.TextColor3 = TXT
Title.Font = Enum.Font.GothamBold
Title.TextSize = 19
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 102
Title.Parent = Header

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(0, 140, 1, 0)
Credit.Position = UDim2.new(1, -180, 0, 0)
Credit.BackgroundTransparency = 1
Credit.Text = "Base Script by yes.dev"
Credit.TextColor3 = TXT_F
Credit.Font = Enum.Font.GothamMedium
Credit.TextSize = 10
Credit.TextXAlignment = Enum.TextXAlignment.Right
Credit.ZIndex = 102
Credit.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(28, 28)
Close.Position = UDim2.new(1, -38, 0.5, -14)
Close.BackgroundColor3 = Color3.fromRGB(30, 34, 40)
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 = TXT_D
Close.Font = Enum.Font.GothamBold
Close.TextSize = 16
Close.AutoButtonColor = false
Close.ZIndex = 102
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

Close.MouseEnter:Connect(function()
    Tween:Create(Close, TweenInfo.new(0.1), { BackgroundColor3 = RED, TextColor3 = Color3.new(1, 1, 1) }):Play()
end)
Close.MouseLeave:Connect(function()
    Tween:Create(Close, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(30, 34, 40), TextColor3 = TXT_D }):Play()
end)
Close.MouseButton1Click:Connect(function() Root.Visible = false end)

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -24, 1, -52 - 26)
Body.Position = UDim2.new(0, 12, 0, 52)
Body.BackgroundTransparency = 1
Body.ZIndex = 101
Body.Parent = Root

local RAIL_W = 152

local Rail = Instance.new("Frame")
Rail.Size = UDim2.new(0, RAIL_W, 1, 0)
Rail.BackgroundColor3 = BG2
Rail.BorderSizePixel = 0
Rail.ZIndex = 102
Rail.Parent = Body

Instance.new("UICorner", Rail).CornerRadius = UDim.new(0, 10)

local RailL = Instance.new("UIListLayout")
RailL.Padding = UDim.new(0, 4)
RailL.SortOrder = Enum.SortOrder.LayoutOrder
RailL.HorizontalAlignment = Enum.HorizontalAlignment.Center
RailL.Parent = Rail

local RailPad = Instance.new("UIPadding")
RailPad.PaddingTop = UDim.new(0, 8)
RailPad.PaddingBottom = UDim.new(0, 8)
RailPad.PaddingLeft = UDim.new(0, 6)
RailPad.PaddingRight = UDim.new(0, 6)
RailPad.Parent = Rail

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(1, -RAIL_W - 8, 1, 0)
Panel.Position = UDim2.new(0, RAIL_W + 8, 0, 0)
Panel.BackgroundColor3 = BG2
Panel.BorderSizePixel = 0
Panel.ZIndex = 102
Panel.Parent = Body

Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.fromScale(1, 1)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = ACCENT_D
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ZIndex = 103
Scroll.Parent = Panel

local SPad = Instance.new("UIPadding")
SPad.PaddingTop = UDim.new(0, 12)
SPad.PaddingBottom = UDim.new(0, 12)
SPad.PaddingLeft = UDim.new(0, 12)
SPad.PaddingRight = UDim.new(0, 12)
SPad.Parent = Scroll

local SLayout = Instance.new("UIListLayout")
SLayout.Padding = UDim.new(0, 6)
SLayout.SortOrder = Enum.SortOrder.LayoutOrder
SLayout.Parent = Scroll

local Foot = Instance.new("TextLabel")
Foot.Size = UDim2.new(1, -24, 0, 18)
Foot.Position = UDim2.new(0, 12, 1, -22)
Foot.BackgroundTransparency = 1
Foot.Text = "Base Script by yes.dev"
Foot.TextColor3 = TXT_F
Foot.Font = Enum.Font.GothamMedium
Foot.TextSize = 11
Foot.TextXAlignment = Enum.TextXAlignment.Right
Foot.ZIndex = 102
Foot.Parent = Root

local function mkC(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = p
    return c
end

local catFrames, catButtons = {}, {}
local activeCat

local function setCat(name)
    activeCat = name
    for n, f in pairs(catFrames) do f.Visible = (n == name) end
    for n, b in pairs(catButtons) do
        if n == name then
            Tween:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = ACCENT_D }):Play()
            b.TextColor3 = TXT
        else
            Tween:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = ROW }):Play()
            b.TextColor3 = TXT_D
        end
    end
end

local function createCategory(name, order)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = ROW
    b.BorderSizePixel = 0
    b.Text = name
    b.TextColor3 = TXT_D
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.LayoutOrder = order
    b.ZIndex = 103
    b.Parent = Rail

    mkC(b, 6)

    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, 10)
    p.Parent = b

    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 0)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.Visible = false
    f.ZIndex = 103
    f.Parent = Scroll

    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = f

    catFrames[name] = f
    catButtons[name] = b

    b.MouseButton1Click:Connect(function() setCat(name) end)
    b.MouseEnter:Connect(function()
        if activeCat ~= name then
            Tween:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = ROW_H }):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if activeCat ~= name then
            Tween:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = ROW }):Play()
        end
    end)

    return f
end

local function sectionHeader(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = string.upper(text)
    l.TextColor3 = ACCENT
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 104
    l.Parent = parent

    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, 4)
    p.Parent = l

    return l
end

local function tagPill(parent, tag, pos)
    if not tag then return end
    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(44, 16)
    pill.Position = pos
    pill.BackgroundColor3 = TAG_COLOR[tag] or TXT_F
    pill.BackgroundTransparency = 0.75
    pill.BorderSizePixel = 0
    pill.ZIndex = 105
    pill.Parent = parent

    mkC(pill, 4)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.BackgroundTransparency = 1
    t.Text = tag
    t.TextColor3 = TAG_COLOR[tag] or TXT_F
    t.Font = Enum.Font.GothamBold
    t.TextSize = 9
    t.ZIndex = 106
    t.Parent = pill
end

local function toggle(parent, name, tag, getV, setV)
    local r = Instance.new("TextButton")
    r.Size = UDim2.new(1, 0, 0, 34)
    r.BackgroundColor3 = ROW
    r.BorderSizePixel = 0
    r.Text = ""
    r.AutoButtonColor = false
    r.ZIndex = 104
    r.Parent = parent

    mkC(r, 6)

    tagPill(r, tag, UDim2.new(0, 10, 0.5, -8))

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -110, 1, 0)
    l.Position = UDim2.new(0, 62, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = TXT
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 105
    l.Parent = r

    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(32, 18)
    track.Position = UDim2.new(1, -44, 0.5, -9)
    track.BackgroundColor3 = Color3.fromRGB(50, 55, 62)
    track.BorderSizePixel = 0
    track.ZIndex = 105
    track.Parent = r

    mkC(track, 9)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = TXT_D
    knob.BorderSizePixel = 0
    knob.ZIndex = 106
    knob.Parent = track

    mkC(knob, 7)

    local function refresh(anim)
        local on = getV()
        local tT = on and ACCENT or Color3.fromRGB(50, 55, 62)
        local tK = on and Color3.new(1, 1, 1) or TXT_D
        local tX = on and UDim2.new(0, 16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        if anim then
            Tween:Create(track, TweenInfo.new(0.15), { BackgroundColor3 = tT }):Play()
            Tween:Create(knob, TweenInfo.new(0.15), { Position = tX, BackgroundColor3 = tK }):Play()
        else
            track.BackgroundColor3 = tT
            knob.Position = tX
            knob.BackgroundColor3 = tK
        end
    end

    r.MouseButton1Click:Connect(function()
        setV(not getV())
        refresh(true)
        saveSettings()
    end)
    r.MouseEnter:Connect(function() Tween:Create(r, TweenInfo.new(0.1), { BackgroundColor3 = ROW_H }):Play() end)
    r.MouseLeave:Connect(function() Tween:Create(r, TweenInfo.new(0.1), { BackgroundColor3 = ROW }):Play() end)

    refresh(false)
    return r, refresh
end

local function slider(parent, name, tag, mn, mx, snap, getV, setV, suffix)
    suffix = suffix or ""
    local w = Instance.new("Frame")
    w.Size = UDim2.new(1, 0, 0, 48)
    w.BackgroundColor3 = ROW
    w.BorderSizePixel = 0
    w.ZIndex = 104
    w.Parent = parent

    mkC(w, 6)

    tagPill(w, tag, UDim2.new(0, 10, 0, 6))

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -(tag and 76 or 30), 0, 16)
    l.Position = UDim2.new(0, tag and 62 or 14, 0, 6)
    l.BackgroundTransparency = 1
    l.Text = name .. ": " .. tostring(getV()) .. suffix
    l.TextColor3 = TXT
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 105
    l.Parent = w

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -28, 0, 4)
    line.Position = UDim2.new(0, 14, 0, 30)
    line.BackgroundColor3 = Color3.fromRGB(50, 55, 62)
    line.BorderSizePixel = 0
    line.ZIndex = 105
    line.Parent = w

    mkC(line, 2)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel = 0
    fill.ZIndex = 106
    fill.Parent = line

    mkC(fill, 2)

    local handle = Instance.new("TextButton")
    handle.Size = UDim2.fromOffset(14, 14)
    handle.Position = UDim2.new(0, -7, 0.5, -7)
    handle.BackgroundColor3 = Color3.new(1, 1, 1)
    handle.BorderSizePixel = 0
    handle.Text = ""
    handle.AutoButtonColor = false
    handle.ZIndex = 107
    handle.Parent = line

    mkC(handle, 7)

    local drag = false

    local function upd()
        local a = (getV() - mn) / (mx - mn)
        a = math.clamp(a, 0, 1)
        local lw = line.AbsoluteSize.X
        if lw > 0 then
            handle.Position = UDim2.new(a, -7, 0.5, -7)
            fill.Size = UDim2.new(a, 0, 1, 0)
        end
        l.Text = name .. ": " .. tostring(getV()) .. suffix
    end

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
        end
    end)

    track(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end))

    track(UIS.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local mxp = i.Position.X
            local ls = line.AbsolutePosition.X
            local lw = line.AbsoluteSize.X
            if lw > 0 then
                local rel = math.clamp(mxp - ls, 0, lw)
                local raw = mn + (rel / lw) * (mx - mn)
                local sn = math.floor((raw + snap / 2) / snap) * snap
                setV(math.clamp(sn, mn, mx))
                upd()
                saveSettings()
            end
        end
    end))

    task.defer(function() task.wait(0.1) upd() end)
    return w, upd
end

local function keybind(parent, name, tag, getK, setK)
    local r = Instance.new("TextButton")
    r.Size = UDim2.new(1, 0, 0, 34)
    r.BackgroundColor3 = ROW
    r.BorderSizePixel = 0
    r.Text = ""
    r.AutoButtonColor = false
    r.ZIndex = 104
    r.Parent = parent

    mkC(r, 6)

    tagPill(r, tag, UDim2.new(0, 10, 0.5, -8))

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.6, -76, 1, 0)
    l.Position = UDim2.new(0, 62, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = TXT
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 105
    l.Parent = r

    local kl = Instance.new("TextLabel")
    kl.Size = UDim2.new(0.4, -14, 1, 0)
    kl.Position = UDim2.new(0.6, 0, 0, 0)
    kl.BackgroundTransparency = 1
    kl.Text = "[" .. tostring(getK()) .. "]"
    kl.TextColor3 = ACCENT
    kl.Font = Enum.Font.GothamBold
    kl.TextSize = 12
    kl.TextXAlignment = Enum.TextXAlignment.Right
    kl.ZIndex = 105
    kl.Parent = r

    local listening = false
    local conn

    local function refresh()
        kl.Text = listening and "[ ... ]" or "[" .. tostring(getK()) .. "]"
    end

    local function stop()
        if conn then conn:Disconnect() conn = nil end
        listening = false
        refresh()
    end

    r.MouseButton1Click:Connect(function()
        if listening then stop() return end
        listening = true
        refresh()
        conn = UIS.InputBegan:Connect(function(i)
            if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if i.KeyCode == Enum.KeyCode.Escape then stop() return end
            setK(i.KeyCode.Name)
            saveSettings()
            stop()
        end)
    end)

    refresh()
    return r
end

local function actionButton(parent, name, tag, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = ROW
    b.BorderSizePixel = 0
    b.Text = ""
    b.AutoButtonColor = false
    b.ZIndex = 104
    b.Parent = parent

    mkC(b, 6)

    tagPill(b, tag, UDim2.new(0, 10, 0.5, -8))

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -76, 1, 0)
    l.Position = UDim2.new(0, 62, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = TXT
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 105
    l.Parent = b

    b.MouseEnter:Connect(function() Tween:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = ROW_H }):Play() end)
    b.MouseLeave:Connect(function() Tween:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = ROW }):Play() end)
    b.MouseButton1Click:Connect(function() pcall(callback) end)

    return b
end

-- categories
local catCombat = createCategory("Combat", 1)
sectionHeader(catCombat, "Aimbot")
toggle(catCombat, "Enable Aimbot", "SRV", function() return Settings.Aimbot_Enabled end, function(v) Settings.Aimbot_Enabled = v end)
toggle(catCombat, "Wall Check", "LOCAL", function() return Settings.Aimbot_WallCheck end, function(v) Settings.Aimbot_WallCheck = v end)
toggle(catCombat, "Auto Shoot", "SRV", function() return Settings.Aimbot_AutoShoot end, function(v) Settings.Aimbot_AutoShoot = v end)
toggle(catCombat, "Hold-to-Aim", "LOCAL", function() return Settings.Aimbot_KeybindMode end, function(v) Settings.Aimbot_KeybindMode = v end)
keybind(catCombat, "Aim Keybind", "LOCAL", function() return Settings.Aimbot_Keybind end, function(v) Settings.Aimbot_Keybind = v end)
slider(catCombat, "Aimbot FOV", "LOCAL", 10, 800, 5, function() return Settings.Aimbot_FOV end, function(v) Settings.Aimbot_FOV = v end)
slider(catCombat, "Smoothness", "LOCAL", 0, 0.95, 0.05, function() return math.floor(Settings.Aimbot_Smooth * 100) / 100 end, function(v) Settings.Aimbot_Smooth = v end)

sectionHeader(catCombat, "Triggerbot")
toggle(catCombat, "Enable Triggerbot", "SRV", function() return Settings.Triggerbot_Enabled end, function(v) Settings.Triggerbot_Enabled = v end)
slider(catCombat, "Trigger Range", "LOCAL", 20, 2000, 10, function() return Settings.Triggerbot_Range end, function(v) Settings.Triggerbot_Range = v end)

sectionHeader(catCombat, "Silent Aim")
toggle(catCombat, "Enable Silent Aim", "SRV", function() return Settings.SilentAim_Enabled end, function(v) Settings.SilentAim_Enabled = v end)
toggle(catCombat, "Silent Wall Check", "LOCAL", function() return Settings.SilentAim_WallCheck end, function(v) Settings.SilentAim_WallCheck = v end)
toggle(catCombat, "Visible Marker", "LOCAL", function() return Settings.SilentAim_Marker end, function(v) Settings.SilentAim_Marker = v end)
toggle(catCombat, "Spray Lock", "LOCAL", function() return Settings.SilentAim_SprayLock end, function(v) Settings.SilentAim_SprayLock = v end)
toggle(catCombat, "Anywhere (360)", "LOCAL", function() return Settings.SilentAim_Anywhere end, function(v) Settings.SilentAim_Anywhere = v end)
toggle(catCombat, "Spin + Silent Combo", "LOCAL", function() return Settings.SilentAim_ComboSpin end, function(v) Settings.SilentAim_ComboSpin = v end)
slider(catCombat, "Silent FOV", "LOCAL", 10, 1000, 5, function() return Settings.SilentAim_FOV end, function(v) Settings.SilentAim_FOV = v end)
slider(catCombat, "Silent Range", "LOCAL", 20, 2000, 10, function() return Settings.SilentAim_Range end, function(v) Settings.SilentAim_Range = v end)
slider(catCombat, "Hit Chance", "LOCAL", 0, 100, 5, function() return Settings.SilentAim_HitChance end, function(v) Settings.SilentAim_HitChance = v end, "%")

sectionHeader(catCombat, "Weapon")
toggle(catCombat, "No Recoil", "LOCAL", function() return Settings.NoRecoil_Enabled end, function(v) Settings.NoRecoil_Enabled = v end)
toggle(catCombat, "No Spread", "LOCAL", function() return Settings.NoSpread_Enabled end, function(v) Settings.NoSpread_Enabled = v end)
toggle(catCombat, "Infinite Ammo", "LOCAL", function() return Settings.InfAmmo_Enabled end, function(v) Settings.InfAmmo_Enabled = v end)
toggle(catCombat, "Rapid Fire", "LOCAL", function() return Settings.RapidFire_Enabled end, function(v) Settings.RapidFire_Enabled = v end)
slider(catCombat, "Rapid Fire Rate", "LOCAL", 1, 20, 1, function() return Settings.RapidFire_Rate end, function(v) Settings.RapidFire_Rate = v end, "x")

local catVis = createCategory("Visuals", 2)
sectionHeader(catVis, "ESP")
toggle(catVis, "Enable ESP", "LOCAL", function() return Settings.ESP_Enabled end, function(v) Settings.ESP_Enabled = v end)
toggle(catVis, "Highlight", "LOCAL", function() return Settings.ESP_Highlight end, function(v) Settings.ESP_Highlight = v end)
toggle(catVis, "Name Tags", "LOCAL", function() return Settings.ESP_Name end, function(v) Settings.ESP_Name = v end)
toggle(catVis, "Distance", "LOCAL", function() return Settings.ESP_Distance end, function(v) Settings.ESP_Distance = v end)
toggle(catVis, "Health Bar", "LOCAL", function() return Settings.ESP_Health end, function(v) Settings.ESP_Health = v end)
toggle(catVis, "Tracers", "LOCAL", function() return Settings.ESP_Tracer end, function(v) Settings.ESP_Tracer = v end)
toggle(catVis, "Box ESP", "LOCAL", function() return Settings.ESP_Box end, function(v) Settings.ESP_Box = v end)
toggle(catVis, "Skeleton", "LOCAL", function() return Settings.ESP_Skeleton end, function(v) Settings.ESP_Skeleton = v end)
toggle(catVis, "Head Dot", "LOCAL", function() return Settings.ESP_HeadDot end, function(v) Settings.ESP_HeadDot = v end)
slider(catVis, "Max Distance", "LOCAL", 50, 3000, 25, function() return Settings.ESP_MaxDist end, function(v) Settings.ESP_MaxDist = v end)
slider(catVis, "Transparency", "LOCAL", 0, 1, 0.05, function() return math.floor(Settings.ESP_Transparency * 100) / 100 end, function(v) Settings.ESP_Transparency = v end)

sectionHeader(catVis, "Camera / World")
toggle(catVis, "Fullbright", "LOCAL", function() return Settings.Fullbright_Enabled end, function(v) Settings.Fullbright_Enabled = v end)
toggle(catVis, "FOV Changer", "LOCAL", function() return Settings.FOV_Enabled end, function(v) Settings.FOV_Enabled = v end)
slider(catVis, "FOV", "LOCAL", 30, 120, 5, function() return Settings.FOV_Value end, function(v) Settings.FOV_Value = v end)
toggle(catVis, "Third Person", "MIX", function() return Settings.ThirdPerson_Enabled end, function(v) Settings.ThirdPerson_Enabled = v end)
slider(catVis, "TP Distance", "MIX", 3, 40, 1, function() return Settings.ThirdPerson_Dist end, function(v) Settings.ThirdPerson_Dist = v end)
toggle(catVis, "Custom Crosshair", "LOCAL", function() return Settings.CustomCrosshair end, function(v) Settings.CustomCrosshair = v end)
toggle(catVis, "No Fog", "LOCAL", function() return Settings.NoFog_Enabled end, function(v) Settings.NoFog_Enabled = v end)

local catMove = createCategory("Movement", 3)
sectionHeader(catMove, "Flight")
toggle(catMove, "Fly", "LOCAL", function() return Settings.Fly_Enabled end, function(v) Settings.Fly_Enabled = v end)
slider(catMove, "Fly Speed", "LOCAL", 5, 500, 5, function() return Settings.Fly_Speed end, function(v) Settings.Fly_Speed = v end)
keybind(catMove, "Fly Keybind", "LOCAL", function() return Settings.Fly_Keybind end, function(v) Settings.Fly_Keybind = v end)

sectionHeader(catMove, "Ground")
toggle(catMove, "Noclip", "LOCAL", function() return Settings.Noclip_Enabled end, function(v) Settings.Noclip_Enabled = v end)
toggle(catMove, "Infinite Jump", "LOCAL", function() return Settings.InfJump_Enabled end, function(v) Settings.InfJump_Enabled = v end)
toggle(catMove, "WalkSpeed", "MIX", function() return Settings.WalkSpeed_Enabled end, function(v) Settings.WalkSpeed_Enabled = v end)
slider(catMove, "Speed", "MIX", 8, 250, 1, function() return Settings.WalkSpeed_Value end, function(v) Settings.WalkSpeed_Value = v end)
toggle(catMove, "JumpPower", "MIX", function() return Settings.JumpPower_Enabled end, function(v) Settings.JumpPower_Enabled = v end)
slider(catMove, "Jump", "MIX", 30, 400, 5, function() return Settings.JumpPower_Value end, function(v) Settings.JumpPower_Value = v end)
toggle(catMove, "Sprint", "LOCAL", function() return Settings.Sprint_Enabled end, function(v) Settings.Sprint_Enabled = v end)
slider(catMove, "Sprint Mult", "LOCAL", 1, 5, 0.25, function() return Settings.Sprint_Multiplier end, function(v) Settings.Sprint_Multiplier = v end, "x")
toggle(catMove, "Bunny Hop", "LOCAL", function() return Settings.BunnyHop_Enabled end, function(v) Settings.BunnyHop_Enabled = v end)
toggle(catMove, "Fast Swim", "LOCAL", function() return Settings.FastSwim_Enabled end, function(v) Settings.FastSwim_Enabled = v end)
toggle(catMove, "Anti-Fling", "LOCAL", function() return Settings.AntiFling_Enabled end, function(v) Settings.AntiFling_Enabled = v end)
toggle(catMove, "Slow Fall", "LOCAL", function() return Settings.SlowFall_Enabled end, function(v) Settings.SlowFall_Enabled = v end)
toggle(catMove, "Teleport Walk", "LOCAL", function() return Settings.TeleportWalk_Enabled end, function(v) Settings.TeleportWalk_Enabled = v end)

local catMisc = createCategory("Misc", 4)
sectionHeader(catMisc, "Orbit")
toggle(catMisc, "Orbital Mode", "LOCAL", function() return Settings.Orbit_Enabled end, function(v) Settings.Orbit_Enabled = v end)
slider(catMisc, "Orbit Radius", "LOCAL", 3, 40, 1, function() return Settings.Orbit_Radius end, function(v) Settings.Orbit_Radius = v end)
slider(catMisc, "Orbit Speed", "LOCAL", 0.25, 10, 0.25, function() return Settings.Orbit_Speed end, function(v) Settings.Orbit_Speed = v end, " r/s")
slider(catMisc, "Crouch Height", "LOCAL", 0, 6, 0.5, function() return Settings.Orbit_CrouchHeight end, function(v) Settings.Orbit_CrouchHeight = v end)

sectionHeader(catMisc, "Fun")
toggle(catMisc, "Spin", "LOCAL", function() return Settings.Spin_Enabled end, function(v) Settings.Spin_Enabled = v end)
slider(catMisc, "Spin Speed", "LOCAL", 0.25, 10, 0.25, function() return Settings.Spin_Speed end, function(v) Settings.Spin_Speed = v end, " t/s")
toggle(catMisc, "Hitbox Expander", "LOCAL", function() return Settings.HitboxExpander_Enabled end, function(v) Settings.HitboxExpander_Enabled = v end)
slider(catMisc, "Hitbox Size", "LOCAL", 1, 20, 0.5, function() return Settings.HitboxExpander_Size end, function(v) Settings.HitboxExpander_Size = v end)

sectionHeader(catMisc, "Performance")
toggle(catMisc, "Anti-AFK", "LOCAL", function() return Settings.AntiAFK_Enabled end, function(v) Settings.AntiAFK_Enabled = v end)
toggle(catMisc, "Remove Textures", "LOCAL", function() return Settings.RemoveTextures_Enabled end, function(v) Settings.RemoveTextures_Enabled = v end)
toggle(catMisc, "Low Graphics", "LOCAL", function() return Settings.LowGraphics_Enabled end, function(v) Settings.LowGraphics_Enabled = v end)
toggle(catMisc, "FPS Counter", "LOCAL", function() return Settings.FPSCounter_Enabled end, function(v) Settings.FPSCounter_Enabled = v end)
toggle(catMisc, "Ping Display", "LOCAL", function() return Settings.PingDisplay_Enabled end, function(v) Settings.PingDisplay_Enabled = v end)
toggle(catMisc, "Memory Display", "LOCAL", function() return Settings.MemoryDisplay_Enabled end, function(v) Settings.MemoryDisplay_Enabled = v end)
toggle(catMisc, "Player Count", "LOCAL", function() return Settings.PlayerCountDisplay end, function(v) Settings.PlayerCountDisplay = v end)

sectionHeader(catMisc, "System")
toggle(catMisc, "Auto Execute", "SRV", function() return Settings.AutoExec_Enabled end, function(v) Settings.AutoExec_Enabled = v end)

sectionHeader(catMisc, "Device Spoofer")

local DEVICES = {
    { label = "PC", value = "MouseKeyboard" },
    { label = "Console", value = "Gamepad" },
    { label = "Mobile", value = "Touch" },
    { label = "VR", value = "VR" },
}

local activeDevice = Settings.DeviceSpoofer_Active
local dotUpdaters = {}
local function refreshDots() for _, fn in ipairs(dotUpdaters) do fn() end end

local SetControlsRemote
pcall(function()
    SetControlsRemote = RS:WaitForChild("Remotes", 5):WaitForChild("Replication", 5)
        :WaitForChild("Fighter", 5):WaitForChild("SetControls", 5)
end)

for i, d in ipairs(DEVICES) do
    local r = Instance.new("TextButton")
    r.Size = UDim2.new(1, 0, 0, 32)
    r.BackgroundColor3 = ROW
    r.BorderSizePixel = 0
    r.Text = ""
    r.AutoButtonColor = false
    r.LayoutOrder = 200 + i
    r.ZIndex = 104
    r.Parent = catMisc

    mkC(r, 6)
    tagPill(r, "SRV", UDim2.new(0, 10, 0.5, -8))

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -100, 1, 0)
    l.Position = UDim2.new(0, 62, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = d.label
    l.TextColor3 = TXT
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 105
    l.Parent = r

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(10, 10)
    dot.Position = UDim2.new(1, -24, 0.5, -5)
    dot.BackgroundColor3 = Color3.fromRGB(60, 66, 74)
    dot.BorderSizePixel = 0
    dot.ZIndex = 105
    dot.Parent = r

    mkC(dot, 5)

    local function upd()
        dot.BackgroundColor3 = (activeDevice == d.value) and GREEN or Color3.fromRGB(60, 66, 74)
    end

    r.MouseButton1Click:Connect(function()
        if activeDevice == d.value then
            activeDevice, Settings.DeviceSpoofer_Active = nil, nil
            pcall(function()
                if SetControlsRemote then SetControlsRemote:FireServer("MouseKeyboard") end
            end)
        else
            activeDevice, Settings.DeviceSpoofer_Active = d.value, d.value
            pcall(function()
                if SetControlsRemote then SetControlsRemote:FireServer(d.value) end
            end)
        end
        refreshDots()
        saveSettings()
    end)

    upd()
    table.insert(dotUpdaters, upd)
end

local catTools = createCategory("Tools", 5)
sectionHeader(catTools, "Server")
actionButton(catTools, "Server Hop", "SRV", function()
    local servers = Http:JSONDecode(game:HttpGet(
        "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    if servers and servers.data then
        for _, s in ipairs(servers.data) do
            if s.id ~= game.JobId then
                Teleport:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                return
            end
        end
    end
end)
actionButton(catTools, "Rejoin", "SRV", function() Teleport:Teleport(game.PlaceId, LP) end)

sectionHeader(catTools, "Character")
actionButton(catTools, "Reset Character", "SRV", function()
    local ch = LP.Character
    if ch then
        local h = ch:FindFirstChildOfClass("Humanoid")
        if h then h.Health = 0 end
    end
end)

sectionHeader(catTools, "Script")
actionButton(catTools, "Unload Script", "LOCAL", function()
    DEAD = true
    _G.__deeprivals_v6 = nil

    pcall(function()
        if writefile then
            writefile(CACHE_FOLDER .. "/rivals_main.lua", "-- killed")
            writefile(CACHE_FOLDER .. "/rivals_queue.lua", "-- killed")
            writefile(CACHE_FOLDER .. "/rivals_version.txt", "-- killed")
        end
    end)

    disconnectAll()

    pcall(function()
        if Drawing then
            for _, l in pairs(tracerLines) do l:Remove() end
            for _, b in pairs(boxDrawings) do b:Remove() end
            for _, grp in pairs(skeletonDrawings) do
                for _, s in pairs(grp) do s:Remove() end
            end
            for _, d in pairs(headDots) do d:Remove() end
            if circleDraw then circleDraw:Remove() end
            if silentMark then silentMark:Remove() end
            if customCrosshair then customCrosshair:Remove() end
        end
    end)

    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, n in ipairs({ "DR_Highlight", "DR_Billboard", "DR_HealthOutline", "DR_HealthBG", "DR_HealthBar" }) do
                local o = p.Character:FindFirstChild(n)
                if o then pcall(function() o:Destroy() end) end
            end
        end
    end

    pcall(function() SG:Destroy() end)
    pcall(function()
        local mg = pg:FindFirstChild("DeepRivalsV6Mobile")
        if mg then mg:Destroy() end
    end)

    pcall(function()
        Lighting.Ambient = sL.Ambient
        Lighting.OutdoorAmbient = sL.OutdoorAmbient
        Lighting.Brightness = sL.Brightness
        Lighting.ClockTime = sL.ClockTime
        Lighting.FogEnd = sL.FogEnd
        Lighting.FogStart = sL.FogStart
        Lighting.GlobalShadows = sL.GlobalShadows
    end)

    pcall(function()
        LP.CameraMinZoomDistance = 0.5
        LP.CameraMaxZoomDistance = origCamMax or 128
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end)

    print("[deeprivals] unloaded.")
end)

setCat("Combat")

-- drag
local dragging, dragStart, dragOrig = false, nil, nil

Header.InputBegan:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
    dragging, dragStart, dragOrig = true, i.Position, Root.Position
end)

track(UIS.InputChanged:Connect(function(i)
    if not dragging then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - dragStart
        Root.Position = UDim2.new(
            dragOrig.X.Scale, dragOrig.X.Offset + d.X,
            dragOrig.Y.Scale, dragOrig.Y.Offset + d.Y)
    end
end))

track(UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

track(UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightControl or i.KeyCode == Enum.KeyCode.RightShift then
        Root.Visible = not Root.Visible
    end
end))

-- ============================================================
-- MOUSE UNLOCK - menu gets real cursor even in locked-mouse games
-- ============================================================

track(Run.RenderStepped:Connect(function()
    if DEAD then return end
    if Root.Visible then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
        if not UIS.MouseIconEnabled then
            UIS.MouseIconEnabled = true
        end
    end
end))

-- when menu closes, restore the game's normal mouse mode
local wasMenuOpen = false

track(Run.RenderStepped:Connect(function()
    if DEAD then return end
    if wasMenuOpen and not Root.Visible then
        -- game will re-lock naturally; we don't force it
    end
    wasMenuOpen = Root.Visible
end))

if isMobile then
    local mg = Instance.new("ScreenGui")
    mg.Name = "DeepRivalsV6Mobile"
    mg.ResetOnSpawn = false
    mg.IgnoreGuiInset = true
    mg.DisplayOrder = 1001
    mg.Parent = pg

    local tb = Instance.new("TextButton")
    tb.Size = UDim2.fromOffset(48, 48)
    tb.Position = UDim2.new(1, -64, 1, -64)
    tb.AnchorPoint = Vector2.new(1, 1)
    tb.BackgroundColor3 = BG
    tb.BorderSizePixel = 0
    tb.Text = "DR"
    tb.TextColor3 = ACCENT
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 15
    tb.AutoButtonColor = false
    tb.ZIndex = 200
    tb.Parent = mg

    mkC(tb, 12)

    tb.MouseButton1Click:Connect(function()
        Root.Visible = not Root.Visible
    end)
end

-- status footer
task.spawn(function()
    while not DEAD do
        task.wait(1)
        if DEAD then return end
        local parts = {}
        if Settings.FPSCounter_Enabled then
            table.insert(parts, string.format("FPS %.0f", workspace:GetRealPhysicsFPS()))
        end
        if Settings.PingDisplay_Enabled then
            local s = Stats.Network.ServerStatsItem["Data Ping"]
            if s then table.insert(parts, string.format("Ping %.0f", s:GetValue())) end
        end
        if Settings.MemoryDisplay_Enabled then
            table.insert(parts, string.format("Mem %.0f MB", Stats:GetTotalMemoryUsageMb()))
        end
        if Settings.PlayerCountDisplay then
            table.insert(parts, string.format("%d Players", #Players:GetPlayers()))
        end
        Foot.Text = #parts > 0 and table.concat(parts, "  |  ") or "Base Script by yes.dev"
    end
end)

-- draws
local tracerLines, boxDrawings, skeletonDrawings, headDots = {}, {}, {}, {}
local circleDraw, silentMark, customCrosshair

pcall(function()
    if Drawing then
        circleDraw = Drawing.new("Circle")
        circleDraw.Thickness, circleDraw.Color, circleDraw.Filled, circleDraw.Visible = 2, ACCENT, false, false

        silentMark = Drawing.new("Circle")
        silentMark.Thickness, silentMark.Color, silentMark.Filled, silentMark.Visible = 2, Color3.fromRGB(255, 90, 90), false, false

        customCrosshair = Drawing.new("Line")
        customCrosshair.Thickness, customCrosshair.Color, customCrosshair.Visible = 2, ACCENT, false
    end
end)

local function getLine(p)
    if tracerLines[p] then return tracerLines[p] end
    local ok, r = pcall(function()
        local d = Drawing.new("Line")
        d.Thickness, d.Color, d.Transparency, d.Visible = 1.5, ACCENT, 1, false
        return d
    end)
    if ok and r then tracerLines[p] = r return r end
    return nil
end

local function getBox(p)
    if boxDrawings[p] then return boxDrawings[p] end
    local ok, r = pcall(function()
        local d = Drawing.new("Square")
        d.Thickness, d.Color, d.Filled, d.Transparency, d.Visible = 1.5, ACCENT, false, 1, false
        return d
    end)
    if ok and r then boxDrawings[p] = r return r end
    return nil
end

local function getSkelLine(p, idx)
    skeletonDrawings[p] = skeletonDrawings[p] or {}
    if skeletonDrawings[p][idx] then return skeletonDrawings[p][idx] end
    local ok, r = pcall(function()
        local d = Drawing.new("Line")
        d.Thickness, d.Color, d.Transparency, d.Visible = 1.5, ACCENT, 1, false
        return d
    end)
    if ok and r then skeletonDrawings[p][idx] = r return r end
    return nil
end

local function getHeadDot(p)
    if headDots[p] then return headDots[p] end
    local ok, r = pcall(function()
        local d = Drawing.new("Circle")
        d.Thickness, d.Color, d.Filled, d.Radius, d.Transparency, d.Visible = 2, ACCENT, true, 4, 1, false
        return d
    end)
    if ok and r then headDots[p] = r return r end
    return nil
end

local function hideAllDraws()
    for _, l in pairs(tracerLines) do pcall(function() l.Visible = false end) end
    for _, b in pairs(boxDrawings) do pcall(function() b.Visible = false end) end
    for _, g in pairs(skeletonDrawings) do
        for _, s in pairs(g) do pcall(function() s.Visible = false end) end
    end
    for _, d in pairs(headDots) do pcall(function() d.Visible = false end) end
end

track(Players.PlayerRemoving:Connect(function(p)
    pcall(function()
        if tracerLines[p] then tracerLines[p]:Remove() end
        if boxDrawings[p] then boxDrawings[p]:Remove() end
        if skeletonDrawings[p] then
            for _, s in pairs(skeletonDrawings[p]) do s:Remove() end
        end
        if headDots[p] then headDots[p]:Remove() end
    end)
    tracerLines[p], boxDrawings[p] = nil, nil
    skeletonDrawings[p], headDots[p] = nil, nil
end))

local function removeESP(ch)
    if not ch then return end
    for _, n in ipairs({ "DR_Highlight", "DR_Billboard", "DR_HealthOutline", "DR_HealthBG", "DR_HealthBar" }) do
        local o = ch:FindFirstChild(n)
        if o then pcall(function() o:Destroy() end) end
    end
end

local ESP_W, ESP_H = 220, 60
local HP_W, HP_H = 120, 7

local function buildBB(ch, head)
    local bb = Instance.new("BillboardGui")
    bb.Name = "DR_Billboard"
    bb.Adornee = head
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.MaxDistance = Settings.ESP_MaxDist
    bb.Size = UDim2.fromOffset(ESP_W, ESP_H)
    bb.StudsOffsetWorldSpace = Vector3.new(0, 2.7, 0)
    bb.Parent = ch

    local out = Instance.new("Frame")
    out.Name = "DR_HealthOutline"
    out.Position = UDim2.fromOffset((ESP_W - HP_W) / 2 - 1, 2)
    out.Size = UDim2.fromOffset(HP_W + 2, HP_H + 2)
    out.BackgroundColor3 = Color3.new(0, 0, 0)
    out.BackgroundTransparency = 0.15
    out.BorderSizePixel = 0
    out.ZIndex = 5
    out.Parent = bb
    mkC(out, 4)

    local bg = Instance.new("Frame")
    bg.Name = "DR_HealthBG"
    bg.Position = UDim2.fromOffset(1, 1)
    bg.Size = UDim2.fromOffset(HP_W, HP_H)
    bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    bg.BorderSizePixel = 0
    bg.ZIndex = 6
    bg.Parent = out
    mkC(bg, 3)

    local bar = Instance.new("Frame")
    bar.Name = "DR_HealthBar"
    bar.Position = UDim2.fromOffset(0, 0)
    bar.Size = UDim2.fromOffset(HP_W, HP_H)
    bar.BackgroundColor3 = GREEN
    bar.BorderSizePixel = 0
    bar.ZIndex = 7
    bar.Parent = bg
    mkC(bar, 3)

    local info = Instance.new("TextLabel")
    info.Name = "DR_Info"
    info.Position = UDim2.fromOffset(0, 16)
    info.Size = UDim2.fromOffset(ESP_W, 24)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.GothamBold
    info.TextSize = 14
    info.TextColor3 = TXT
    info.TextStrokeTransparency = 0.4
    info.TextXAlignment = Enum.TextXAlignment.Center
    info.Text = ""
    info.ZIndex = 8
    info.Parent = bb

    return bb
end

local SKEL_PAIRS = {
    { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" }, { "UpperTorso", "RightUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" }, { "RightUpperArm", "RightLowerArm" },
    { "LowerTorso", "LeftUpperLeg" }, { "LowerTorso", "RightUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" }, { "RightUpperLeg", "RightLowerLeg" },
}

local function updateESP()
    if DEAD then return end
    if not Settings.ESP_Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then removeESP(p.Character) end
        end
        hideAllDraws()
        return
    end

    local lc = LP.Character
    local lr = lc and lc:FindFirstChild("HumanoidRootPart")
    if not lr or not Camera then hideAllDraws() return end

    local seen = {}
    local vp = Camera.ViewportSize

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local ch = p.Character
            if ch and isEnemy(p) then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                local root = ch:FindFirstChild("HumanoidRootPart")
                local head = ch:FindFirstChild("Head")
                if hum and hum.Health > 0 and root and head then
                    local ok, rp = pcall(function() return root.Position end)
                    if ok then
                        local dist = (rp - lr.Position).Magnitude
                        if dist <= Settings.ESP_MaxDist then
                            local hl = ch:FindFirstChild("DR_Highlight")
                            if Settings.ESP_Highlight then
                                if not hl then
                                    hl = Instance.new("Highlight")
                                    hl.Name, hl.Adornee = "DR_Highlight", ch
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    hl.Parent = ch
                                end
                                hl.FillColor = ACCENT
                                hl.FillTransparency = Settings.ESP_Transparency
                                hl.OutlineColor = ACCENT
                                hl.OutlineTransparency = 0
                                hl.Enabled = true
                            elseif hl then
                                hl:Destroy()
                            end

                            local bb = ch:FindFirstChild("DR_Billboard")
                            if not bb or not bb:IsA("BillboardGui") then
                                if bb then bb:Destroy() end
                                bb = buildBB(ch, head)
                            end

                            bb.Adornee = head
                            bb.AlwaysOnTop = true
                            bb.MaxDistance = Settings.ESP_MaxDist
                            bb.Enabled = Settings.ESP_Health

                            local out = bb:FindFirstChild("DR_HealthOutline")
                            local hb = out and out:FindFirstChild("DR_HealthBG")
                            local bar = hb and hb:FindFirstChild("DR_HealthBar")
                            if bar then
                                local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                                bar.Size = UDim2.fromOffset(math.max(0, math.floor(HP_W * pct)), HP_H)
                                if pct > 0.6 then bar.BackgroundColor3 = GREEN
                                elseif pct > 0.3 then bar.BackgroundColor3 = YELLOW
                                else bar.BackgroundColor3 = RED end
                            end

                            local info = bb:FindFirstChild("DR_Info")
                            if info then
                                local parts = {}
                                if Settings.ESP_Name then table.insert(parts, p.Name) end
                                if Settings.ESP_Distance then table.insert(parts, string.format("%.0f studs", dist)) end
                                info.Text = #parts > 0 and table.concat(parts, " · ") or ""
                                info.Visible = #parts > 0
                            end

                            if Settings.ESP_Tracer and not Root.Visible then
                                local sp, on = w2s(head.Position)
                                if sp and on then
                                    local line = getLine(p)
                                    if line then
                                        line.From = Vector2.new(vp.X / 2, vp.Y / 2)
                                        line.To = sp
                                        line.Visible = true
                                    end
                                end
                            end

                            if Settings.ESP_Box and not Root.Visible then
                                local sp, on = w2s(root.Position)
                                if sp and on then
                                    local box = getBox(p)
                                    if box then
                                        local sz = 1000 / dist * 1.8
                                        box.Size = Vector2.new(sz, sz * 1.9)
                                        box.Position = Vector2.new(sp.X - sz / 2, sp.Y - sz)
                                        box.Visible = true
                                    end
                                end
                            end

                            if Settings.ESP_Skeleton and not Root.Visible then
                                for i, pair in ipairs(SKEL_PAIRS) do
                                    local a = ch:FindFirstChild(pair[1])
                                    local b = ch:FindFirstChild(pair[2])
                                    if a and b then
                                        local sp1, on1 = w2s(a.Position)
                                        local sp2, on2 = w2s(b.Position)
                                        if sp1 and sp2 and on1 and on2 then
                                            local line = getSkelLine(p, i)
                                            if line then
                                                line.From, line.To, line.Visible = sp1, sp2, true
                                            end
                                        end
                                    end
                                end
                            end

                            if Settings.ESP_HeadDot and not Root.Visible then
                                local sp, on = w2s(head.Position)
                                if sp and on then
                                    local d = getHeadDot(p)
                                    if d then d.Position = sp d.Visible = true end
                                end
                            end

                            seen[p] = true
                        else
                            removeESP(ch)
                        end
                    end
                else
                    removeESP(ch)
                end
            elseif ch then
                removeESP(ch)
            end
        end
    end

    for p, l in pairs(tracerLines) do if not seen[p] then pcall(function() l.Visible = false end) end end
    for p, b in pairs(boxDrawings) do if not seen[p] then pcall(function() b.Visible = false end) end end
    for p, g in pairs(skeletonDrawings) do
        if not seen[p] then for _, s in pairs(g) do pcall(function() s.Visible = false end) end end
    end
    for p, d in pairs(headDots) do if not seen[p] then pcall(function() d.Visible = false end) end end
end

-- targeting
local lockedTarget
local aimKeyDown = false

track(UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if i.KeyCode.Name == Settings.Aimbot_Keybind then aimKeyDown = true end
end))

track(UIS.InputEnded:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if i.KeyCode.Name == Settings.Aimbot_Keybind then aimKeyDown = false end
end))

local function aimbotActive()
    if DEAD then return false end
    if not Settings.Aimbot_Enabled then return false end
    if Settings.Aimbot_KeybindMode and not aimKeyDown then return false end
    return true
end

local function getAimTarget()
    local cx = crosshair()
    local lc = LP.Character
    if not lc then return nil end
    local lr = lc:FindFirstChild("HumanoidRootPart")
    if not lr then return nil end

    if lockedTarget then
        if not isEnemy(lockedTarget) then
            lockedTarget = nil
        else
            local ch = lockedTarget.Character
            local head = ch and ch:FindFirstChild("Head")
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local d = (lr.Position - head.Position).Magnitude
                if d > Settings.Triggerbot_Range then lockedTarget = nil
                elseif Settings.Aimbot_WallCheck and not hasLOS(head) then lockedTarget = nil
                else return head end
            else
                lockedTarget = nil
            end
        end
    end

    local best, bestMetric = nil, math.huge
    for _, p in ipairs(getEnemies()) do
        local ch = p.Character
        if ch then
            local head = ch:FindFirstChild("Head")
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local d3 = (lr.Position - head.Position).Magnitude
                if d3 <= Settings.Triggerbot_Range then
                    local sp, on = w2s(head.Position)
                    if sp and on then
                        local d2 = (sp - cx).Magnitude
                        if d2 <= Settings.Aimbot_FOV then
                            if not Settings.Aimbot_WallCheck or hasLOS(head) then
                                local metric = d2
                                if Settings.Aimbot_Priority == "LowestHP" then metric = hum.Health
                                elseif Settings.Aimbot_Priority == "MostVisible" then
                                    metric = d2 * (hum.Health / hum.MaxHealth)
                                end
                                if metric < bestMetric then
                                    bestMetric = metric
                                    best = p
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if best then
        lockedTarget = best
        return best.Character:FindFirstChild("Head")
    end
    return nil
end

local function aimAt(head)
    if DEAD then return false end
    if not head or not head.Parent or not Camera then return false end
    local lc = LP.Character
    if not lc then return false end
    local root = lc:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local ok, hp = pcall(function() return head.Position end)
    if not ok then return false end

    local cur = Camera.CFrame
    local want = CFrame.lookAt(cur.Position, hp, Vector3.new(0, 1, 0))
    local alpha = 1 - Settings.Aimbot_Smooth
    Camera.CFrame = cur:Lerp(want, alpha)

    local rp = root.Position
    root.CFrame = CFrame.lookAt(rp, Vector3.new(hp.X, rp.Y, hp.Z), Vector3.new(0, 1, 0))
    return true
end

-- ============================================================
-- SILENT AIM
-- FOV removed when Anywhere is on. Spray updates target every frame.
-- Nudge-and-restore within 2 frames (33ms).
-- ============================================================

local sprayHeld, sprayTarget = false, nil
local silentSavedCF = nil
local silentHoldFrames = 0

local function silentTarget()
    if not Settings.SilentAim_Enabled or not Camera then return nil end

    local cx = crosshair()
    local lc = LP.Character
    if not lc then return nil end
    local lr = lc:FindFirstChild("HumanoidRootPart")
    if not lr then return nil end

    local best, bestD = nil, math.huge

    for _, p in ipairs(getEnemies()) do
        local ch = p.Character
        if ch then
            local head = ch:FindFirstChild("Head")
            if head then
                local d3 = (lr.Position - head.Position).Magnitude
                if d3 <= Settings.SilentAim_Range then
                    if not Settings.SilentAim_WallCheck or hasLOS(head) then
                        -- score: world distance if Anywhere, else screen distance
                        local score
                        if Settings.SilentAim_Anywhere then
                            score = d3
                        else
                            local sp, on = w2s(head.Position)
                            if not sp or not on then
                                -- skip
                                score = nil
                            else
                                local d2 = (sp - cx).Magnitude
                                if d2 > Settings.SilentAim_FOV then
                                    score = nil
                                else
                                    score = d2
                                end
                            end
                        end
                        if score and score < bestD then
                            bestD = score
                            best = head
                        end
                    end
                end
            end
        end
    end
    return best
end

-- on click: queue a shot, don't nudge yet
track(UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType ~= Enum.UserInputType.MouseButton1
    and i.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
    if not Settings.SilentAim_Enabled then return end
    if Root.Visible then return end

    sprayHeld = true

    local head = silentTarget()
    if head then
        if math.random() * 100 <= Settings.SilentAim_HitChance then
            sprayTarget = head
            -- nudge immediately
            if not silentSavedCF then
                silentSavedCF = Camera.CFrame
            end
            Camera.CFrame = CFrame.lookAt(silentSavedCF.Position, head.Position, Vector3.new(0, 1, 0))
            silentHoldFrames = 3
            -- dispatch click
            local vp = Camera.ViewportSize
            VIM:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, true, game, 0)
            VIM:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, false, game, 0)
        end
    end
end))

track(UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.MouseButton2 then
        sprayHeld = false
        sprayTarget = nil
    end
end))

-- per-frame silent aim driver
track(Run.RenderStepped:Connect(function()
    if DEAD then return end
    if not Settings.SilentAim_Enabled then
        if silentSavedCF then
            Camera.CFrame = silentSavedCF
            silentSavedCF = nil
        end
        return
    end
    if Root.Visible then
        if silentSavedCF then
            Camera.CFrame = silentSavedCF
            silentSavedCF = nil
        end
        return
    end

    -- spray: refresh target every frame while held
    if sprayHeld and Settings.SilentAim_SprayLock then
        local fresh = silentTarget()
        if fresh then
            sprayTarget = fresh
            if not silentSavedCF then
                silentSavedCF = Camera.CFrame
            end
            -- aim camera at fresh target
            Camera.CFrame = CFrame.lookAt(silentSavedCF.Position, fresh.Position, Vector3.new(0, 1, 0))
            -- re-aim character too so shot direction is consistent
            local lc = LP.Character
            if lc then
                local root = lc:FindFirstChild("HumanoidRootPart")
                if root then
                    local rp = root.Position
                    root.CFrame = CFrame.lookAt(rp, Vector3.new(fresh.Position.X, rp.Y, fresh.Position.Z), Vector3.new(0, 1, 0))
                end
            end
            silentHoldFrames = 2
            return
        end
    end

    if silentHoldFrames > 0 then
        silentHoldFrames = silentHoldFrames - 1
        return
    end

    if silentSavedCF then
        Camera.CFrame = silentSavedCF
        silentSavedCF = nil
    end
end))

-- triggerbot
local HB_PARTS = {
    "Head", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "RightUpperArm",
    "LeftLowerArm", "RightLowerArm",
    "LeftUpperLeg", "RightUpperLeg",
    "LeftLowerLeg", "RightLowerLeg",
}

local function triggerCheck()
    if DEAD then return false end
    if not Camera then return false end

    if Settings.Aimbot_Enabled and Settings.Aimbot_AutoShoot and lockedTarget then
        local ch = lockedTarget.Character
        local head = ch and ch:FindFirstChild("Head")
        if head and hasLOS(head) then return true end
    end

    if not Settings.Triggerbot_Enabled then return false end

    if Settings.Aimbot_Enabled and lockedTarget then
        local ch = lockedTarget.Character
        local head = ch and ch:FindFirstChild("Head")
        if head and hasLOS(head) then return true end
    end

    local cx = crosshair()
    local lc = LP.Character
    if not lc then return false end
    local lr = lc:FindFirstChild("HumanoidRootPart")
    if not lr then return false end

    for _, p in ipairs(getEnemies()) do
        local ch = p.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            local root = ch:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                local d = (root.Position - lr.Position).Magnitude
                if d <= Settings.Triggerbot_Range then
                    for _, pn in ipairs(HB_PARTS) do
                        local part = ch:FindFirstChild(pn)
                        if part and hasLOS(part) then
                            local sp, on = w2s(part.Position)
                            if sp and on then
                                local sz = 50 / math.max(d, 1)
                                if math.abs(sp.X - cx.X) <= sz and math.abs(sp.Y - cx.Y) <= sz then
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

local autoClick = false

task.spawn(function()
    while not DEAD do
        task.wait()
        if DEAD then return end
        if autoClick then
            if not Camera then Camera = workspace.CurrentCamera end
            if Camera then
                local vp = Camera.ViewportSize
                VIM:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, true, game, 0)
                VIM:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, false, game, 0)
            end
        end
    end
end)

-- aimbot render
track(Run.RenderStepped:Connect(function()
    if DEAD then return end
    if not Camera then Camera = workspace.CurrentCamera end
    if not Camera then return end
    if not LP.Character then return end

    if circleDraw then
        if Settings.Aimbot_Enabled and not Root.Visible then
            circleDraw.Position = crosshair()
            circleDraw.Radius = Settings.Aimbot_FOV
            circleDraw.Visible = true
        else
            circleDraw.Visible = false
        end
    end

    if silentMark then
        if Settings.SilentAim_Enabled and Settings.SilentAim_Marker and not Root.Visible then
            local h = silentTarget()
            if h then
                local sp, on = w2s(h.Position)
                if sp and on then
                    silentMark.Position = sp
                    silentMark.Radius = 9
                    silentMark.Visible = true
                else
                    silentMark.Visible = false
                end
            else
                silentMark.Visible = false
            end
        else
            silentMark.Visible = false
        end
    end

    if customCrosshair then
        if Settings.CustomCrosshair and not Root.Visible then
            local vp = Camera.ViewportSize
            customCrosshair.From = Vector2.new(vp.X / 2 - 8, vp.Y / 2)
            customCrosshair.To = Vector2.new(vp.X / 2 + 8, vp.Y / 2)
            customCrosshair.Visible = true
        else
            customCrosshair.Visible = false
        end
    end

    if Root.Visible then return end

    -- skip visible aimbot while silent aim is holding a nudge
    if silentSavedCF and silentHoldFrames > 0 then return end

    if aimbotActive() then
        if lockedTarget then
            local ch = lockedTarget.Character
            local head = ch and ch:FindFirstChild("Head")
            if head and head.Parent then aimAt(head) else lockedTarget = nil end
        else
            local t = getAimTarget()
            if t then aimAt(t) end
        end
    else
        lockedTarget = nil
    end
end))

track(Run.RenderStepped:Connect(function()
    if DEAD then return end
    if Root.Visible then autoClick = false return end
    autoClick = triggerCheck()
end))

-- humanoid hooks
local function applyWalk(hum)
    if not Settings.WalkSpeed_Enabled then return end
    local base = Settings.WalkSpeed_Value
    if Settings.Sprint_Enabled
    and (UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) then
        base = base * Settings.Sprint_Multiplier
    end
    if hum.WalkSpeed ~= base then hum.WalkSpeed = base end
end

local function applyJump(hum)
    if not Settings.JumpPower_Enabled then return end
    if hum.UseJumpPower then
        if hum.JumpPower ~= Settings.JumpPower_Value then hum.JumpPower = Settings.JumpPower_Value end
    else
        local t = Settings.JumpPower_Value / 7.5
        if hum.JumpHeight ~= t then hum.JumpHeight = t end
    end
end

local function watchHumanoid(hum)
    if not hum then return end
    track(hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Settings.WalkSpeed_Enabled and hum.WalkSpeed ~= 0 then
            local base = Settings.WalkSpeed_Value
            if Settings.Sprint_Enabled
            and (UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) then
                base = base * Settings.Sprint_Multiplier
            end
            if hum.WalkSpeed ~= base then hum.WalkSpeed = base end
        end
    end))
    track(hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if Settings.JumpPower_Enabled and hum.UseJumpPower and hum.JumpPower ~= Settings.JumpPower_Value then
            hum.JumpPower = Settings.JumpPower_Value
        end
    end))
    track(hum:GetPropertyChangedSignal("JumpHeight"):Connect(function()
        if Settings.JumpPower_Enabled and not hum.UseJumpPower then
            local t = Settings.JumpPower_Value / 7.5
            if hum.JumpHeight ~= t then hum.JumpHeight = t end
        end
    end))
    applyWalk(hum)
    applyJump(hum)
end

local function onChar(ch)
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if hum then watchHumanoid(hum) end
    track(ch.ChildAdded:Connect(function(c)
        if c:IsA("Humanoid") then watchHumanoid(c) end
    end))
end

if LP.Character then onChar(LP.Character) end
track(LP.CharacterAdded:Connect(onChar))

track(Run.Stepped:Connect(function()
    if DEAD then return end
    local lc = LP.Character
    if not lc then return end
    local hum = lc:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Settings.WalkSpeed_Enabled then applyWalk(hum) end
    if Settings.JumpPower_Enabled then applyJump(hum) end
    if Settings.FastSwim_Enabled and hum:GetState() == Enum.HumanoidStateType.Swimming then
        hum.WalkSpeed = 80
    end
end))

track(Run.Stepped:Connect(function()
    if DEAD then return end
    if not Settings.Noclip_Enabled and not Settings.Orbit_Enabled then return end
    local lc = LP.Character
    if not lc then return end
    for _, p in ipairs(lc:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
    end
end))

track(UIS.JumpRequest:Connect(function()
    if DEAD then return end
    if not Settings.InfJump_Enabled then return end
    local lc = LP.Character
    if not lc then return end
    local hum = lc:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

track(Run.Heartbeat:Connect(function()
    if DEAD then return end
    if not Settings.BunnyHop_Enabled then return end
    local lc = LP.Character
    if not lc then return end
    local hum = lc:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local st = hum:GetState()
    if (st == Enum.HumanoidStateType.Landed or st == Enum.HumanoidStateType.Running)
    and UIS:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

track(Run.Heartbeat:Connect(function()
    if DEAD then return end
    if not Settings.AntiFling_Enabled then return end
    local lc = LP.Character
    if not lc then return end
    local root = lc:FindFirstChild("HumanoidRootPart")
    if root and root.Velocity.Magnitude > 300 then
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
    end
end))

track(Run.Heartbeat:Connect(function()
    if DEAD then return end
    if not Settings.SlowFall_Enabled then return end
    local lc = LP.Character
    if not lc then return end
    local hum = lc:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum:GetState() == Enum.HumanoidStateType.Freefall then
        hum.WalkSpeed = 0
    elseif Settings.WalkSpeed_Enabled then
        hum.WalkSpeed = Settings.WalkSpeed_Value
    else
        hum.WalkSpeed = 16
    end
end))

track(Run.RenderStepped:Connect(function(dt)
    if DEAD then return end
    if not Settings.TeleportWalk_Enabled then return end
    if Root.Visible then return end
    if not UIS:IsKeyDown(Enum.KeyCode.W) then return end
    local lc = LP.Character
    if not lc then return end
    local root = lc:FindFirstChild("HumanoidRootPart")
    if not root or not Camera then return end
    root.CFrame = root.CFrame + Camera.CFrame.LookVector * 80 * dt
end))

-- fly
local flyActive = false

local function flyKey()
    local ok, c = pcall(function() return Enum.KeyCode[Settings.Fly_Keybind] end)
    if ok and c then return c end
    return Enum.KeyCode.F
end

local function setFly(on)
    flyActive = on
    local lc = LP.Character
    if not lc then return end
    local hum = lc:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = on end
end

track(UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if not Settings.Fly_Enabled then
        if flyActive then setFly(false) end
        return
    end
    if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if i.KeyCode == flyKey() then setFly(not flyActive) end
end))

track(Run.RenderStepped:Connect(function(dt)
    if DEAD then return end
    if not Settings.Fly_Enabled then
        if flyActive then setFly(false) end
        return
    end
    if not flyActive or Root.Visible then return end
    local lc = LP.Character
    if not lc then return end
    local root = lc:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if not Camera then Camera = workspace.CurrentCamera end
    if not Camera then return end

    local spd = Settings.Fly_Speed
    local mv = Vector3.zero
    local cf = Camera.CFrame

    if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + cf.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - cf.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + cf.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - cf.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, 1, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift) then
        mv = mv - Vector3.new(0, 1, 0)
    end

    if mv.Magnitude > 0 then mv = mv.Unit * spd * dt end

    local np = root.Position + mv
    root.CFrame = CFrame.new(np) * (root.CFrame - root.CFrame.Position)
    root.Velocity = Vector3.zero
end))

-- ============================================================
-- ORBITAL MODE
-- teleport to nearest enemy, orbit at crouch height, aim at head
-- ============================================================

local orbitAngle = 0

track(Run.RenderStepped:Connect(function(dt)
    if DEAD then return end
    if not Settings.Orbit_Enabled then orbitAngle = 0 return end

    local lc = LP.Character
    if not lc then return end
    local root = lc:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- find nearest enemy (never self)
    local nearest, nearestDist = nil, math.huge
    for _, p in ipairs(getEnemies()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hh = p.Character:FindFirstChild("Humanoid")
            if hrp and hh and hh.Health > 0 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearest = p
                end
            end
        end
    end

    if not nearest then return end

    local enemyRoot = nearest.Character:FindFirstChild("HumanoidRootPart")
    local enemyHead = nearest.Character:FindFirstChild("Head")
    if not enemyRoot or not enemyHead then return end

    orbitAngle = orbitAngle + (Settings.Orbit_Speed * math.pi * 2) * dt
    if orbitAngle > math.pi * 2 then orbitAngle = orbitAngle - math.pi * 2 end

    local radius = Settings.Orbit_Radius
    local crouch = Settings.Orbit_CrouchHeight

    -- place root at orbit position, at crouch height relative to enemy
    local targetY = enemyRoot.Position.Y - (2.5 - crouch)
    local orbitPos = Vector3.new(
        enemyRoot.Position.X + math.sin(orbitAngle) * radius,
        targetY,
        enemyRoot.Position.Z + math.cos(orbitAngle) * radius
    )

    -- face enemy head
    root.CFrame = CFrame.lookAt(
        orbitPos,
        Vector3.new(enemyHead.Position.X, targetY, enemyHead.Position.Z),
        Vector3.new(0, 1, 0)
    )

    -- aim camera at enemy head too
    if Camera then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, enemyHead.Position, Vector3.new(0, 1, 0))
    end
end))

-- weapon hooks
track(Run.Heartbeat:Connect(function()
    if DEAD then return end
    local lc = LP.Character
    if not lc then return end
    local tool = lc:FindFirstChildOfClass("Tool")
    if not tool then return end

    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            local n = string.lower(v.Name)
            if Settings.NoSpread_Enabled and (n == "spread" or n == "spreadvalue" or n == "spreadangle") then
                pcall(function() v.Value = 0 end)
            end
            if Settings.InfAmmo_Enabled and (n == "ammo" or n == "currentammo" or n == "ammocount"
            or n == "mag" or n == "magazine" or n == "clip") then
                local mx = tool:FindFirstChild("MaxAmmo") or tool:FindFirstChild("MaxMag")
                local cap = (mx and typeof(mx.Value) == "number") and mx.Value or 999
                pcall(function() v.Value = cap end)
            end
            if Settings.RapidFire_Enabled and (n == "firerate" or n == "firedelay"
            or n == "cooldown" or n == "firecooldown") then
                pcall(function() v.Value = math.max(v.Value / Settings.RapidFire_Rate, 0.01) end)
            end
        end
    end
end))

local lastNRC
track(Run.RenderStepped:Connect(function()
    if DEAD then return end
    if not Camera then return end
    if Settings.NoRecoil_Enabled then
        local cur = Camera.CFrame
        if lastNRC then
            local cr = cur - cur.Position
            local lr = lastNRC - lastNRC.Position
            Camera.CFrame = CFrame.new(cur.Position) * cr:Lerp(lr, 0.45)
        end
        lastNRC = Camera.CFrame
    else
        lastNRC = nil
    end
end))

-- world / camera
local sL = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
}

track(Run.Heartbeat:Connect(function()
    if DEAD then return end
    if Settings.Fullbright_Enabled then
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
    elseif Lighting.Ambient ~= sL.Ambient then
        Lighting.Ambient = sL.Ambient
        Lighting.OutdoorAmbient = sL.OutdoorAmbient
        Lighting.Brightness = sL.Brightness
        Lighting.ClockTime = sL.ClockTime
        Lighting.FogEnd = sL.FogEnd
    end
    if Settings.NoFog_Enabled then
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 1e6
    end
    if Settings.LowGraphics_Enabled then
        Lighting.GlobalShadows = false
    elseif Lighting.GlobalShadows ~= sL.GlobalShadows then
        Lighting.GlobalShadows = sL.GlobalShadows
    end
end))

local origCamMax

track(Run.RenderStepped:Connect(function()
    if DEAD then return end
    if not Camera then Camera = workspace.CurrentCamera end
    if not Camera then return end

    if Settings.FOV_Enabled and Camera.FieldOfView ~= Settings.FOV_Value then
        Camera.FieldOfView = Settings.FOV_Value
    end

    if origCamMax == nil then origCamMax = LP.CameraMaxZoomDistance end

    if Settings.ThirdPerson_Enabled then
        local dist = Settings.ThirdPerson_Dist
        if LP.CameraMode ~= Enum.CameraMode.Classic then LP.CameraMode = Enum.CameraMode.Classic end
        if LP.CameraMinZoomDistance ~= dist then LP.CameraMinZoomDistance = dist end
        if LP.CameraMaxZoomDistance ~= dist then LP.CameraMaxZoomDistance = dist end
    else
        if LP.CameraMinZoomDistance ~= 0.5 then LP.CameraMinZoomDistance = 0.5 end
        local mx = origCamMax or 128
        if LP.CameraMaxZoomDistance ~= mx then LP.CameraMaxZoomDistance = mx end
    end
end))

track(Run.Heartbeat:Connect(function()
    if DEAD then return end
    if not Settings.RemoveTextures_Enabled then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if obj.Transparency ~= 1 then obj.Transparency = 1 end
        end
    end
end))

task.spawn(function()
    while not DEAD do
        task.wait(60)
        if DEAD then return end
        if Settings.AntiAFK_Enabled then
            pcall(function()
                VUser:CaptureController()
                VUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- spin (coexists with silent aim)
local spinAngle = 0

track(Run.RenderStepped:Connect(function(dt)
    if DEAD then return end
    if not Settings.Spin_Enabled then spinAngle = 0 return end
    if Root.Visible then return end
    -- only stop for visible aimbot, not silent aim
    if Settings.Aimbot_Enabled and lockedTarget
    and not Settings.SilentAim_ComboSpin then return end

    local lc = LP.Character
    if not lc then return end
    local root = lc:FindFirstChild("HumanoidRootPart")
    if not root then return end

    spinAngle = spinAngle + (Settings.Spin_Speed * math.pi * 2) * dt
    if spinAngle > math.pi * 2 then spinAngle = spinAngle - math.pi * 2 end

    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, spinAngle, 0)
end))

-- hitbox expander
local origSizes = {}

track(Run.Heartbeat:Connect(function()
    if DEAD then return end
    if not Settings.HitboxExpander_Enabled then
        if next(origSizes) then
            for p, d in pairs(origSizes) do
                if p.Character then
                    for part, sz in pairs(d) do
                        if part.Parent then pcall(function() part.Size = sz end) end
                    end
                end
            end
            origSizes = {}
        end
        return
    end
    for _, p in ipairs(getEnemies()) do
        local ch = p.Character
        if ch then
            if not origSizes[p] then origSizes[p] = {} end
            for _, part in ipairs(ch:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    if not origSizes[p][part] then origSizes[p][part] = part.Size end
                    local o = origSizes[p][part]
                    local s = Settings.HitboxExpander_Size
                    local ns = Vector3.new(o.X * s, o.Y * s, o.Z * s)
                    if part.Size ~= ns then pcall(function() part.Size = ns end) end
                end
            end
        end
    end
end))

track(Players.PlayerRemoving:Connect(function(p) origSizes[p] = nil end))

task.spawn(function()
    while not DEAD do
        task.wait(0.15)
        if DEAD then return end
        pcall(updateESP)
    end
end)

task.spawn(function()
    while not DEAD do
        task.wait(2)
        if DEAD then return end
        if Settings.AutoExec_Enabled then
            pcall(function()
                local qf = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
                if qf and isfile and isfile(CACHE_FOLDER .. "/rivals_queue.lua") then
                    local q = readfile(CACHE_FOLDER .. "/rivals_queue.lua")
                    if q and q ~= "-- killed" then qf(q) end
                end
            end)
        end
    end
end)

track(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local w, h = computeSize()
    Root.Size = UDim2.fromOffset(w, h)
end))

print("[deeprivals] v6 loaded. RCTRL/RSHIFT toggles.")
]==]

local CACHE_FOLDER = "DeepRivals"
local SCRIPT_FILE = CACHE_FOLDER .. "/rivals_main.lua"
local QUEUE_FILE = CACHE_FOLDER .. "/rivals_queue.lua"
local VERSION_FILE = CACHE_FOLDER .. "/rivals_version.txt"
local QUEUE_VER = "deeprivals_v6"

pcall(function()
    if makefolder and isfolder and not isfolder(CACHE_FOLDER) then
        makefolder(CACHE_FOLDER)
    end
end)

local function staleWrite()
    local need = true
    pcall(function()
        if isfile and isfile(VERSION_FILE) and readfile(VERSION_FILE) == QUEUE_VER then
            need = false
        end
    end)
    if not need then return end
    pcall(function()
        if writefile then
            writefile(SCRIPT_FILE, myScriptCode)
            writefile(VERSION_FILE, QUEUE_VER)
        end
    end)
end

staleWrite()

local fn, ce = loadstring(myScriptCode)

if not fn then
    warn("[deeprivals] compile: " .. tostring(ce))
    pcall(function()
        if writefile then
            writefile(SCRIPT_FILE, "-- killed")
            writefile(QUEUE_FILE, "-- killed")
            writefile(VERSION_FILE, "-- killed")
        end
    end)
else
    local ok, e = pcall(fn)
    if not ok then warn("[deeprivals] runtime: " .. tostring(e)) end
end

local queuePayload = [==[
task.wait(2)
local CACHE_FOLDER = "DeepRivals"
local SCRIPT_FILE = CACHE_FOLDER .. "/rivals_main.lua"
local QUEUE_FILE = CACHE_FOLDER .. "/rivals_queue.lua"
local VERSION_FILE = CACHE_FOLDER .. "/rivals_version.txt"
local QUEUE_VER = "deeprivals_v6"

pcall(function()
    if makefolder and isfolder and not isfolder(CACHE_FOLDER) then
        makefolder(CACHE_FOLDER)
    end
end)

local function qf()
    return queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
end

local function read(path)
    local r
    pcall(function()
        if isfile and isfile(path) then r = readfile(path) end
    end)
    if typeof(r) ~= "string" or r == "" then return nil end
    return r
end

local function poison(why)
    warn("[deeprivals/q] " .. tostring(why))
    pcall(function()
        if writefile then
            writefile(SCRIPT_FILE, "-- killed")
            writefile(QUEUE_FILE, "-- killed")
            writefile(VERSION_FILE, "-- killed")
        end
    end)
end

if read(VERSION_FILE) ~= QUEUE_VER then poison("version") return end

local code = read(SCRIPT_FILE)
if not code or code == "-- killed" then poison("no main") return end

if loadstring then
    local fn, ce = loadstring(code)
    if not fn then
        poison("compile: " .. tostring(ce))
    else
        local ok, e = pcall(fn)
        if not ok then poison("runtime: " .. tostring(e))
        else print("[deeprivals] cached loaded.") end
    end
end

local f = qf()
if f then
    local qc = read(QUEUE_FILE)
    if qc and qc ~= "-- killed" then
        pcall(function() f(qc) end)
        print("[deeprivals] re-queued.")
    end
end
]==]

pcall(function()
    if writefile then
        writefile(QUEUE_FILE, queuePayload)
        writefile(VERSION_FILE, QUEUE_VER)
    end
end)

local qfunc = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

if qfunc then
    pcall(function() qfunc(queuePayload) end)
    print("[deeprivals] queued.")
else
    print("[deeprivals] no queue support.")
end