-- โหลด OrionLib จาก GitHub
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- สร้างหน้าต่าง UI ด้วยชื่อ "SANG HUB"
local Window = OrionLib:MakeWindow({
    Name = "SANG HUB",
    SaveConfig = true,
    ConfigFolder ="SangConfig"
})

-- สร้างแท็บหลัก (Tag) ใน OrionLib
local MainTab = Window:MakeTab({
    Name = "Main",
})

-- สร้างกลุ่ม Power (ในแท็บเดียว)
local PowerSection = MainTab:AddSection({
    Name = "Power",  -- ชื่อกลุ่ม Power
})

-- ฟังก์ชันตั้งค่าความเร็ว
PowerSection:AddTextbox({
    Name = "Set WalkSpeed",
    Default = "100", -- ค่าเริ่มต้นของความเร็วการเดิน
    TextDisappear = true,
    Callback = function(value)
        local walkSpeed = tonumber(value)
        if walkSpeed then
            -- ตรวจสอบว่า Character มีอยู่หรือไม่
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()  -- รอให้ตัวละครโหลด
            local humanoid = character:WaitForChild("Humanoid")  -- รอให้ Humanoid พร้อม
            
            -- ตั้งค่าความเร็วการเดิน
            humanoid.WalkSpeed = walkSpeed -- ปรับค่า WalkSpeed
        else
            warn("กรุณาป้อนตัวเลขที่ถูกต้องสำหรับ WalkSpeed")
        end
    end
})

-- ฟังก์ชันตั้งค่าความสูงกระโดด
PowerSection:AddTextbox({
    Name = "Set JumpPower",
    Default = "100", -- ค่าเริ่มต้นสำหรับ JumpPower
    TextDisappear = true,
    Callback = function(value)
        local jumpPower = tonumber(value)
        if jumpPower then
            -- ตรวจสอบว่า Character มีอยู่หรือไม่
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()  -- รอให้ตัวละครโหลด
            local humanoid = character:WaitForChild("Humanoid")  -- รอให้ Humanoid พร้อม

            -- ตั้งค่าความสูงของการกระโดด
            humanoid.JumpPower = jumpPower -- ปรับค่า JumpPower ตามค่าที่กรอก

            -- ตรวจสอบเมื่อผู้เล่นกระโดด
            humanoid.Jumping:Connect(function()
                print("Player is jumping!")
            end)
        else
            warn("กรุณาป้อนตัวเลขที่ถูกต้องสำหรับ JumpPower")
        end
    end
})

-- ฟังก์ชันตั้งค่าความแรงของแรงดึงดูด (Gravity)
PowerSection:AddTextbox({
    Name = "Set Gravity",
    Default = "100", -- ค่าเริ่มต้นของ Gravity (ค่ามาตรฐาน 196)
    TextDisappear = true,
    Callback = function(value)
        local gravity = tonumber(value)
        if gravity then
            -- ตั้งค่าค่าของแรงดึงดูด
            game.Workspace.Gravity = gravity -- ปรับค่า Gravity ของเกม
        else
            warn("กรุณาป้อนตัวเลขที่ถูกต้องสำหรับ Gravity")
        end
    end
})

-- สร้างกลุ่ม Player ในแท็กเดิม
local PlayerSection = MainTab:AddSection({
    Name = "Player",  -- ชื่อกลุ่ม Player
})

-- ตัวแปรสำหรับจัดการการเปิด/ปิด Noclip
local noclipEnabled = false
local connection

-- เพิ่มฟังก์ชัน Noclip เปิด/ปิดในกลุ่ม Player
PlayerSection:AddToggle({
    Name = "Noclip",  -- ชื่อปุ่ม Toggle
    Default = false,  -- ค่าเริ่มต้น (ปิด Noclip)
    TextDisappear = true,
    Callback = function(state)
        noclipEnabled = state
        
        if noclipEnabled then
            -- ฟังก์ชัน Noclip ที่ทำงานเมื่อเปิด
            local player = game.Players.LocalPlayer
            local runService = game:GetService("RunService")

            local function getCharacter()
                local character = player.Character or player.CharacterAdded:Wait()
                return character
            end

            local function enableNoclip()
                connection = runService.Stepped:Connect(function()
                    local character = getCharacter()
                    local rootPart = character:FindFirstChild("HumanoidRootPart")

                    if character and rootPart then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false  -- ทำให้ทะลุวัตถุ
                                part.Anchored = false    -- ป้องกันตัวละครติดอยู่กับที่
                            end
                        end
                    end
                end)
            end

            enableNoclip()  -- เรียกใช้ฟังก์ชัน Noclip
        else
            -- เมื่อปิด Noclip (คืนค่าการชนกลับ) และหยุดการเชื่อมต่อ
            if connection then
                connection:Disconnect()  -- หยุดการทำงานของฟังก์ชัน Noclip
            end
            
            -- คืนค่าการชนกลับสำหรับทุกส่วนของตัวละคร
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()

            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true  -- เปิดการชนอีกครั้ง
                end
            end
        end
    end
})

-- เพิ่ม Toggle สำหรับเปิด/ปิด ESP Player ในกลุ่ม Player
PlayerSection:AddToggle({
    Name = "ESP Player",  -- ชื่อปุ่ม Toggle
    Default = false,  -- ค่าเริ่มต้น (ปิด ESP)
    TextDisappear = true,
    Callback = function(state)
        -- ฟังก์ชัน ESP ที่จะแสดงชื่อและระยะของผู้เล่นทุกคนบนแผนที่
        local function createESP()
            local player = game.Players.LocalPlayer
            local runService = game:GetService("RunService")
            local players = game.Players:GetPlayers()

            -- ฟังก์ชันคำนวณระยะห่างจากผู้เล่น
            local function getDistance(character)
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    return (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                end
                return 0
            end

            -- สร้างกล่อง ESP ที่จะแสดงชื่อและระยะ
            local function createESPBox(character)
                local espBox = Instance.new("BillboardGui")
                espBox.Adornee = character:WaitForChild("Head")
                espBox.Parent = character
                espBox.Size = UDim2.new(0, 200, 0, 50)
                espBox.StudsOffset = Vector3.new(0, 2, 0)
                espBox.AlwaysOnTop = true

                local textLabel = Instance.new("TextLabel")
                textLabel.Parent = espBox
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextStrokeTransparency = 0.5
                textLabel.TextSize = 16

                -- แสดงชื่อและระยะห่างของผู้เล่น
                local function updateESP()
                    local distance = getDistance(character)
                    textLabel.Text = character.Name .. " - " .. math.floor(distance) .. "m"
                end

                -- อัพเดต ESP ทุกๆ เฟรม
                runService.RenderStepped:Connect(function()
                    if character and character.Parent then
                        updateESP()
                    else
                        espBox:Destroy() -- ถ้าผู้เล่นหายไปหรือโดนทำลาย ให้ลบ ESP
                    end
                end)
            end

            -- สร้าง ESP ให้กับผู้เล่นทั้งหมด
            for _, p in pairs(players) do
                if p ~= player then
                    p.CharacterAdded:Connect(function(character)
                        createESPBox(character)
                    end)
                end
            end

            -- ตรวจสอบตัวละครที่มีอยู่แล้ว
            for _, p in pairs(players) do
                if p ~= player and p.Character then
                    createESPBox(p.Character)
                end
            end
        end

        -- เปิด/ปิด ESP เมื่อมีการ Toggle
        if state then
            createESP()  -- เรียกใช้ฟังก์ชัน ESP เมื่อเปิด
        else
            -- ลบ ESP เมื่อปิด
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BillboardGui") and v.Parent:IsA("Model") and v.Parent:FindFirstChild("Humanoid") then
                    v:Destroy()  -- ลบกล่อง ESP
                end
            end
        end
    end
})

-- สร้างกลุ่มใหม่ในแท็กหลัก
local TeleportSection = MainTab:AddSection({
    Name = "Teleport",  -- ชื่อกลุ่ม Teleport
})

-- ฟังก์ชันสำหรับเทเลพ็อตไปยังผู้เล่นที่กรอกชื่อ
local function teleportToPlayer(playerName)
    local player = game.Players.LocalPlayer
    local targetPlayer = game.Players:FindFirstChild(playerName)

    -- เทเลพ็อตไปหาผู้เล่น
    if targetPlayer then
        local character = targetPlayer.Character
        local myCharacter = player.Character

        -- ตรวจสอบว่ามีทั้งตัวละครของผู้เล่นเป้าหมายและตัวละครของเรา
        if character and myCharacter then
            -- รอให้ `HumanoidRootPart` โหลดให้ครบ
            local targetRootPart = character:WaitForChild("HumanoidRootPart")
            local myRootPart = myCharacter:WaitForChild("HumanoidRootPart")
                
            -- เทเลพ็อตไปยังตำแหน่งของ `HumanoidRootPart`
            myRootPart.CFrame = CFrame.new(targetRootPart.Position)  -- เทเลพ็อต
        end
    else
        warn("ไม่พบผู้เล่นที่ชื่อ " .. playerName)
    end
end

-- เพิ่มฟังก์ชันเข้าในกลุ่ม Teleport
TeleportSection:AddTextbox({
    Name = "Warp to player",  -- ชื่อกล่องข้อความ
    Default = "Enter Player Name",  -- ค่าเริ่มต้น (ข้อความบอกให้กรอกชื่อผู้เล่น)
    TextDisappear = true,
    Callback = function(playerName)
        teleportToPlayer(playerName)  -- เรียกฟังก์ชันเมื่อกรอกชื่อ
    end
})

-- ตัวแปรควบคุมสถานะ
local showCoordinates = false
local connection
local coordinatesGui
local textLabel

-- ฟังก์ชันสร้าง GUI
local function createCoordinatesGui()
    -- ลบ GUI เดิมถ้ามีอยู่
    if coordinatesGui then
        coordinatesGui:Destroy()
    end

    -- สร้าง GUI ใหม่
    coordinatesGui = Instance.new("ScreenGui")
    coordinatesGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    textLabel = Instance.new("TextLabel")
    textLabel.Parent = coordinatesGui
    textLabel.Size = UDim2.new(0, 400, 0, 50)
    textLabel.Position = UDim2.new(0.5, -200, 0, 10)
    textLabel.BackgroundTransparency = 1
    textLabel.TextScaled = true
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = "X:0   Y:0   Z:0"

    return textLabel
end

-- ฟังก์ชันอัปเดตพิกัด
local function updateCoordinates()
    -- ตรวจสอบว่ามีการเชื่อมต่ออยู่หรือไม่
    if connection then
        connection:Disconnect()
        connection = nil
    end

    -- ถ้าเปิดใช้งาน
    if showCoordinates then
        local player = game.Players.LocalPlayer
        local runService = game:GetService("RunService")

        -- สร้าง GUI ใหม่
        if not coordinatesGui then
            textLabel = createCoordinatesGui()
        end

        -- อัปเดตพิกัดตามตำแหน่งของผู้เล่น
        connection = runService.RenderStepped:Connect(function()
            if showCoordinates and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local pos = player.Character.HumanoidRootPart.Position
                textLabel.Text = string.format("X:%.1f   Y:%.1f   Z:%.1f", pos.X, pos.Y, pos.Z)
            end
        end)
    else
        -- ถ้าปิดใช้งานให้ลบ GUI ออก
        if coordinatesGui then
            coordinatesGui:Destroy()
            coordinatesGui = nil
        end
        -- ตัดการเชื่อมต่อเพื่อหยุดอัปเดต
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end

-- เพิ่มปุ่ม Toggle เข้า UI กลุ่ม Player
PlayerSection:AddToggle({
    Name = "Show Coordinates",
    Default = false,
    Callback = function(state)
        showCoordinates = state
        updateCoordinates()
    end
})


OrionLib:Init()