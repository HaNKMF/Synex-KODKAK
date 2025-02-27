-- โหลด Library
local HttpService = game:GetService("HttpService")
local FluentUrl = ""
local SaveManagerUrl = "https://raw.githubusercontent.com/HaNKMF/Synex-KUB/refs/heads/main/Synex-KUB.lua"
local InterfaceManagerUrl = "https://raw.githubusercontent.com/HaNKMF/Synex-InterfaceManager.lua/refs/heads/main/InterfaceManager.lua"

-- ฟังก์ชันในการโหลดไฟล์จาก URL
local function loadScript(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then
        return result
    else
        warn("Error loading script from: " .. url)
        return nil
    end
end

-- โหลด Library
local Fluent = loadScript(FluentUrl)
local SaveManager = loadScript(SaveManagerUrl)
local InterfaceManager = loadScript(InterfaceManagerUrl)

-- ตรวจสอบว่าโหลด Library ได้หรือไม่
if Fluent == nil or SaveManager == nil or InterfaceManager == nil then
    warn("Failed to load one or more libraries.")
    return
end

-- คำนวณขนาด UI ตามขนาดหน้าจอ
local screenSize = game:GetService("Workspace").CurrentCamera.ViewportSize
local uiWidth = math.clamp(screenSize.X * 0.5, 400, 800)  -- กำหนดขนาด UI ความกว้าง
local uiHeight = math.clamp(screenSize.Y * 0.6, 300, 600)  -- กำหนดขนาด UI ความสูง

-- สร้างหน้าต่าง UI
local Window = Fluent:CreateWindow({
    Title = "Fisch | SynexHUB",
    SubTitle = "By xDorzy",
    TabWidth = 160,
    Size = UDim2.fromOffset(uiWidth, uiHeight),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- ฟังก์ชันการอัพเดตขนาด UI อัตโนมัติ
local function updateUI()
    local newSize = game:GetService("Workspace").CurrentCamera.ViewportSize
    Window:SetSize(UDim2.fromOffset(
        math.clamp(newSize.X * 0.5, 400, 800),  -- คำนวณความกว้างใหม่
        math.clamp(newSize.Y * 0.6, 300, 600)   -- คำนวณความสูงใหม่
    ))
end

-- ใช้ RenderStepped เพื่ออัพเดต UI ทุกครั้งที่ขนาดหน้าจอเปลี่ยนแปลง
game:GetService("RunService").RenderStepped:Connect(updateUI)


-- สร้าง Tabs
local Tabs = {
    Fishing = Window:AddTab({ Title = "Auto Fishing", Icon = "power" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "gem" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "airplay" }),
    Trade = Window:AddTab({ Title = "Trade", Icon = "package-check" }),
    Players = Window:AddTab({ Title = "Players", Icon = "user" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    Miscellaneous = Window:AddTab({ Title = "Miscellaneous", Icon = "database" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- สร้าง Section สำหรับ Fishing
local FishingBotSection = Tabs.Fishing:AddSection("Fishing Bot")

-- เพิ่ม Toggle Auto Equip
local ToggleAutoEquip = FishingBotSection:AddToggle("AutoEquipToggle", {
    Title = "Auto Equip",
    Description = "Automatically equip all rods if you have them",
    Default = false
})

local isAutoEquip = false
local player = game:GetService("Players").LocalPlayer
local backpack = player.Backpack

-- ฟังก์ชันสำหรับการ Equip Rod ทุกตัว
local function equipAllRods()
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:match("Rod") then  -- เช็คว่าเป็นเบ็ดทุกชนิด
            game:GetService("ReplicatedStorage"):WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RE/Backpack/Equip"):FireServer(item)
        end
    end
end

local childAddedConnection
ToggleAutoEquip:OnChanged(function()
    isAutoEquip = ToggleAutoEquip.Value
    if isAutoEquip then
        equipAllRods()  -- เรียกใช้งานให้ติดเบ็ดทุกตัว
        childAddedConnection = backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and child.Name:match("Rod") then  -- เช็คเบ็ดทุกชนิดที่ถูกเพิ่ม
                equipAllRods()
            end
        end)
    else
        if childAddedConnection then childAddedConnection:Disconnect() end
    end
end)




-- เพิ่ม Toggle Auto Farm
local ToggleAutoFish = FishingBotSection:AddToggle("AutoFishToggle", {
    Title = "Auto Farm",
    Description = "Automatically fish",
    Default = false
})

-- ตัวแปรที่ใช้ควบคุมสถานะการทำงานของ AutoFish
local fishingActive = false  -- เริ่มต้นที่ปิดการทำงาน

-- ฟังก์ชัน Auto Fish สำหรับทุกเบ็ด
local function autoFish()
    while fishingActive do  -- ทำงานจนกว่า fishingActive จะเป็น false
        local player = game.Players.LocalPlayer
        local tools = player.Character and player.Character:GetChildren()  -- ค้นหาทุกๆ อุปกรณ์ในตัวผู้เล่น

        -- ค้นหาทุกเบ็ดในอุปกรณ์
        for _, tool in pairs(tools) do
            if tool:IsA("Tool") and tool.Name:match("Rod") then  -- ตรวจสอบว่าเป็น Tool และชื่อของมันมีคำว่า "Rod"
                -- ส่งคำสั่ง cast (เหวี่ยงเบ็ด)
                local castArgs = {
                    [1] = 100,  -- ค่าที่ใช้ในการเหวี่ยงเบ็ด (ปรับได้ตามต้องการ)
                    [2] = 1    -- ค่าที่อาจจะเป็นตัวกำหนดสถานะต่างๆ (สามารถปรับได้)
                }

                local castEvent = tool:FindFirstChild("events") and tool.events:FindFirstChild("cast")
                if castEvent then
                    castEvent:FireServer(unpack(castArgs))
                    print("การเหวี่ยงเบ็ดสำหรับ " .. tool.Name)
                end

                -- รอระยะเวลาเล็กน้อยก่อนที่จะเริ่มดึงเบ็ด
                task.wait(0.5)

                -- ส่งคำสั่ง reelfinished (ดึงเบ็ด)
                local reelArgs = {
                    [1] = 100,  -- ค่าที่ใช้ในการดึงเบ็ด
                    [2] = true  -- สถานะการดึงเบ็ด
                }

                local reelfinishedEvent = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished")
                if reelfinishedEvent then
                    reelfinishedEvent:FireServer(unpack(reelArgs))
                    print("การดึงเบ็ดเสร็จสิ้นสำหรับ " .. tool.Name)
                end
            end
        end

        -- รอ 1 วินาที ก่อนที่จะทำงานอีกครั้ง
        task.wait(0.5)
    end
end

-- เชื่อมโยง Toggle กับฟังก์ชัน
ToggleAutoFish:OnChanged(function(state)
    fishingActive = state  -- ตั้งค่า fishingActive ตามสถานะ Toggle
    if fishingActive then
        print("เริ่มการตกปลาอัตโนมัติ")
        task.spawn(autoFish)  -- เริ่มการตกปลาอัตโนมัติ
    else
        print("หยุดการตกปลาอัตโนมัติ")
    end
end)




-- เพิ่ม Toggle Auto Shake
local ToggleAutoShake = FishingBotSection:AddToggle("AutoShakeToggle", {
    Title = "Auto Shake",
    Description = "Automatically shake when prompted",
    Default = false
})

local shakingFlags = { shaking = false }

local function autoShake()
    local GuiService = game:GetService("GuiService")
    local player = game.Players.LocalPlayer
    
    while shakingFlags.shaking do -- ทำงานเฉพาะตอน Toggle เปิด
        local shakeUI = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("shakeui")
        if shakeUI then
            local safezone = shakeUI:FindFirstChild("safezone")
            if safezone and safezone:FindFirstChild("button") then
                GuiService.SelectedObject = safezone.button
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
        end
        task.wait(0.01) -- ลดโหลด (ทำงานทุก 0.01 วินาที)
    end
end

ToggleAutoShake:OnChanged(function(state)
    shakingFlags.shaking = state

    if state then
        task.spawn(autoShake) -- ใช้ task.spawn() เพื่อลดแล็ค
    end
end)


-- สร้าง Section สำหรับ Fishing
local AutoBaitSection = Tabs.Fishing:AddSection("Auto Buy Create")

-- เพิ่ม Toggle Auto Buy Bait
local ToggleAutoBuy = AutoBaitSection:AddToggle("Auto Buy Bait Create", {
    Title = "Auto Buy Bait Create",
    Description = "Automatically Buy the bait Create",
    Default = false
})






















---FischPositionTab---

local FishngPositionSection = Tabs.Fishing:AddSection("Fishing Position")

-- เพิ่ม Paragraph ก่อน
Tabs.Fishing:AddParagraph({
    Title = "📌Current Fishing Position",
    Content = "Current Fishing Position None"
})








-- เพิ่มระบบบันทึกค่า (SaveManager)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:SetFolder("FluentScriptHub")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

-- เลือกแท็บแรก
Window:SelectTab(1)
