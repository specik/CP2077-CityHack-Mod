CityHack = { 
    description = "",
    rootPath =  "cityhack."
}

for k, _ in pairs(package.loaded) do
    if string.match(k, CityHack.rootPath .. ".*") then
        package.loaded[k] = nil
    end
end

function CityHack:new()

    setmetatable(CityHack, self)
    self.__index = self 

    CityHack.Util = require(CityHack.rootPath.."utility.utility")
    
    CityHack.Util.Log("Loaded! Press F2 to toggle the UI.")

    CityHack.Door = require(CityHack.rootPath.."door.door")
    CityHack.Device = require(CityHack.rootPath.."device.device")
    CityHack.Car = require(CityHack.rootPath.."car.car")
    CityHack.NPC = require(CityHack.rootPath.."npc.npc")
    CityHack.Elevator = require(CityHack.rootPath.."elevator.elevator")


    --------------------------------------- START localVars ---------------------------------------

    local CarLightState = 0


    --------------------------------------- START ImGui ---------------------------------------
    registerForEvent("onInit", function()

    end)
      
    registerForEvent("onUpdate", function(deltaTime)
        if (ImGui.IsKeyPressed(0x71, false)) then 
          drawWindow = not drawWindow
        end
    end)

    registerForEvent("onConsoleOpen", function()
        drawWindow = true
      end)
      
    registerForEvent("onConsoleClose", function()
        drawWindow = false
    end)

    registerForEvent("onDraw", function()
        ImGui.SetNextWindowPos(500, 500, ImGuiCond.FirstUseEver)
        ImGui.SetNextWindowSize(265, 250, ImGuiCond.Appearing)

        if drawWindow then

            ImGui.PushStyleColor(ImGuiCol.Border, 0.56, 0.06, 0.03, 1)
            ImGui.PushStyleColor(ImGuiCol.TitleBg, 0.56, 0.06, 0.03, 0.5)
            ImGui.PushStyleColor(ImGuiCol.TitleBgActive, 0.56, 0.06, 0.03, 0.75)
            ImGui.PushStyleColor(ImGuiCol.TitleBgCollapsed, 0.56, 0.06, 0.03, 0.25)
            ImGui.PushStyleColor(ImGuiCol.Tab, 1, 0.2, 0.2, 0.5)
            ImGui.PushStyleColor(ImGuiCol.TabHovered, 1, 0.2, 0.2, 0.85)
            ImGui.PushStyleColor(ImGuiCol.TabActive, 1, 0.2, 0.2, 1)
            ImGui.PushStyleColor(ImGuiCol.Button, 0.56, 0.06, 0.03, 0.50)
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.56, 0.06, 0.03, 0.75)
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.56, 0.06, 0.03, 1)
            ImGui.PushStyleColor(ImGuiCol.ResizeGrip, 0.56, 0.06, 0.03, 0.6)
            ImGui.PushStyleColor(ImGuiCol.ResizeGripHovered, 0.56, 0.06, 0.03, 0.75)
            ImGui.PushStyleColor(ImGuiCol.ResizeGripActive, 0.56, 0.06, 0.03, 1)
            ImGui.PushStyleColor(ImGuiCol.Separator, 0.56, 0.06, 0.03, 0.6)
            -- ImGui.PushStyleColor(ImGuiCol.PopupBg, 0, 0, 0, 1) -- does not work 
            

            if ImGui.Begin("CITY H4CK") then
                
                local style = {
                    buttonWidth = -1,
                    buttonHeight = 20,
                    halfButtonWidth = ((ImGui.GetWindowContentRegionWidth() / 2) - 4.3)
                }

                if ImGui.BeginTabBar("CITYH4CKTABS") then
                    ---------------- DOORS TAB ---------------- 
                    if ImGui.BeginTabItem("Doors") then
                        ImGui.SetWindowSize(265, 240)

                        ---------------- BASIC ---------------- 
                        ImGui.Columns(2, "DoorsBasic", false)

                        ImGui.Spacing()
                        ImGui.Text("Basic")
                        ImGui.Spacing()

                        if ImGui.Button("Open", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Door.Toggle("open") then
                                CityHack.Util.Response("door", "open", true, false)
                            else
                                CityHack.Util.Response("door", "open", false, false)
                            end
                        end
                        
                        if ImGui.IsItemHovered() then
                            ImGui.SetTooltip("This will automatically unseal and unlock any door and make it open.\r\nFor fake doors, it will delete them but be warned you'll probably fall through the map.")
                        end

                        if ImGui.Button("Close", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Door.Toggle("close") then
                                CityHack.Util.Response("door", "close", true, false)
                            else
                                CityHack.Util.Response("door", "close", false, false)
                            end
                        end

                        if ImGui.Button("Reset", style.buttonWidth, style.buttonHeight) then
                            if not CityHack.Door.Reset() then
                                CityHack.Util.Response("door", "reset", false, false)
                            end
                        end

                        ImGui.Spacing()
                        ImGui.NextColumn()

      
                        ImGui.Columns(2, "ElevatorOther", false)
                        
                        ---------------- ELEVATOR GROUP ---------------- 
                        ImGui.Spacing()
                        ImGui.Text("Elevators")
                        ImGui.Spacing()

                        if ImGui.Button("Restore Access", style.buttonWidth, style.buttonHeight) then
                            CityHack.Elevator.RestoreAccess()
                        end

                        if ImGui.IsItemHovered() then
                            ImGui.SetTooltip("Look at elevator call panel to use this. Will restore access to any\r\nelevator that shows OFF on the call panel.\r\nUseful for exploring mission areas after mission is over.")
                        end

                        ImGui.Spacing()
                        ImGui.NextColumn()

                        ImGui.Separator()
                        ImGui.Spacing()

                        ---------------- OTHER BUTTONS ---------------- 
                        ImGui.Text("Other")
                        ImGui.Spacing()

                        if ImGui.Button("Set Auto", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Door.SetType(2) then
                                CityHack.Util.Response("door", "auto", true, false)
                            else
                                CityHack.Util.Response("door", "auto", false, false)
                            end
                        end

                        if ImGui.IsItemHovered() then
                            ImGui.SetTooltip("Set a door to auto, meaning it will automatically open when you approach.")
                        end

                        if ImGui.Button("Set Manual", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Door.SetType(1) then
                                CityHack.Util.Response("door", "manual", true, false)
                            else
                                CityHack.Util.Response("door", "manual", false, false)
                            end
                        end

                        if ImGui.IsItemHovered() then
                            ImGui.SetTooltip("Sets door back to manual so interaction is required to open door.")
                        end

                        ImGui.Columns(1)
   
                    ImGui.EndTabItem()
                    end

                    
                    ---------------- DEVICES TAB ---------------- 
                    if ImGui.BeginTabItem("Devices") then
                        ImGui.SetWindowSize(265, 185)
                        ImGui.Spacing()

                        if ImGui.Button("Turn On", style.buttonWidth, style.buttonHeight) then
                            CityHack.Device.On()
                        end

                        if ImGui.Button("Turn Off", style.buttonWidth, style.buttonHeight) then
                            CityHack.Device.Off()
                        end

                        if ImGui.Button("Activate", style.buttonWidth, style.buttonHeight) then
                            CityHack.Device.Activate()
                        end

                        if ImGui.Button("Deactivate", style.buttonWidth, style.buttonHeight) then
                            CityHack.Device.Deactivate()
                        end

                        if ImGui.Button("Cut Power", style.buttonWidth, style.buttonHeight) then
                            CityHack.Device.CutPower()
                        end
                    ImGui.EndTabItem()
                    end

                    ---------------- CARS TAB ---------------- 
                    if ImGui.BeginTabItem("Cars") then
                        ImGui.SetWindowSize(265, 400)
                        ImGui.Spacing()

                        ---------------- CAR DOORS ---------------- 
                        ImGui.Text("Doors")
                        ImGui.Spacing()

                        ImGui.Columns(2, "CarDoors", false)
                        if ImGui.Button("Open All", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.Doors("open") then 
                                CityHack.Util.Response("car doors", "open", true, false)
                            else 
                                CityHack.Util.Response("car doors", "open", false, false)
                            end
                        end

                        if ImGui.Button("Close All", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.Doors("close") then 
                                CityHack.Util.Response("car doors", "close", true, false)
                            else 
                                CityHack.Util.Response("car doors", "close", false, false)
                            end
                        end

                        ImGui.NextColumn()

                        if ImGui.Button("Lock All", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.Doors("lock") then 
                                CityHack.Util.Response("car doors", "lock", true, false)
                            else 
                                CityHack.Util.Response("car doors", "lock", false, false)
                            end
                        end

                        if ImGui.Button("Unlock All", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.Doors("lock") then 
                                CityHack.Util.Response("car doors", "unlock", true, false)
                            else 
                                CityHack.Util.Response("car doors", "unlock", false, false)
                            end
                        end
                        ImGui.Columns(1)

                        ImGui.Spacing()
                        ImGui.Separator()
                        ImGui.Spacing()

                        ---------------- CAR WINDOWS ---------------- 
                        ImGui.Columns(2, "CarWindows", false)

                        ImGui.Text("Windows")
                        ImGui.Spacing()

                        ImGui.PushID("CarWindowOpenAll")
                        if ImGui.Button("Open All", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.Windows("open") then 
                                CityHack.Util.Response("car windows", "open", true, false)
                            else 
                                CityHack.Util.Response("car windows", "open", false, false)
                            end
                        end
                        ImGui.PopID()

                        ImGui.PushID("CarWindowCloseAll")
                        if ImGui.Button("Close All", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.Windows("close") then 
                                CityHack.Util.Response("car windows", "close", true, false)
                            else 
                                CityHack.Util.Response("car windows", "close", false, false)
                            end
                        end
                        ImGui.PopID()
                        ImGui.Spacing()

                        ImGui.NextColumn()

                        ---------------- CAR LIGHTS ---------------- 
                        ImGui.Text("Car Lights")
                        ImGui.Spacing()

                        local lightStates = {"Off", "Normal", "High Beams\0"}
                        local lights = table.concat(lightStates, "\0")

                        ImGui.PushItemWidth(style.buttonWidth)
                        CarLightState = ImGui.Combo("##Car Light State", CarLightState, lights)
                        ImGui.PopItemWidth()

                        if ImGui.Button("Set Lights", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.Lights(CarLightState) then
                                CityHack.Util.Response("car lights", "set", true, false)
                            else
                                CityHack.Util.Response("car lights", "set", false, false)
                            end
                        end

                        ImGui.Spacing()
                        ImGui.Separator()
                        ImGui.Spacing()
                        ImGui.Columns(1)

                        ---------------- CAR ENGINE ---------------- 
                        ImGui.Columns(2, "CarEngine", false)
                        ImGui.Text("Engine")
                        ImGui.Spacing()

                            
                        if ImGui.Button("Turn On", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.Engine("on") then
                                CityHack.Util.Response("car engine", "on", true, false)
                            else
                                CityHack.Util.Response("car engine", "on", false, false)
                            end
                        end

                        if ImGui.Button("Turn Off", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.Engine("off") then
                                CityHack.Util.Response("car engine", "off", true, false)
                            else
                                CityHack.Util.Response("car engine", "off", false, false)
                            end
                        end

                        ImGui.NextColumn()
                        ImGui.Text("Utility")
                        ImGui.Spacing()

                        if ImGui.Button("Repair Car", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.Repair() then
                                CityHack.Util.Response("car", "repair", true, false)
                            else
                                CityHack.Util.Response("car", "repair", false, false)
                            end
                        end

                        if ImGui.IsItemHovered() then
                            ImGui.SetTooltip("This will visually repair the vehicle but will\r\nnot re-attach missing parts or fix broken lights.")
                        end

                        if ImGui.Button("Honk & Flash", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.HonkFlash() then
                                CityHack.Util.Response("car", "honk & flash", true, false)
                            else
                                CityHack.Util.Response("car", "honk & flash", false, false)
                            end
                        end

                        if ImGui.Button("Set Immortal", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.SetGod() then
                                CityHack.Util.Response("car", "set immortal", true, false)
                            else
                                CityHack.Util.Response("car", "set immortal", false, false)
                            end
                        end

                        if ImGui.IsItemHovered() then
                            ImGui.SetTooltip("Sets car to immortality meaning it can't be fully destroyed.\r\nWill still take visual damage.")
                        end

                        ImGui.Columns(1)
                        ImGui.Spacing()
                        ImGui.Separator()
                        ImGui.Spacing()


                        ---------------- CAR MAYHEM ---------------- 
                        ImGui.Text("Mayhem")
                        ImGui.Spacing()

                        if ImGui.Button("Detach All Parts", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.DetachAll() then
                                CityHack.Util.Response("car", "detach all", true, false)
                            else
                                CityHack.Util.Response("car", "detach all", false, false)
                            end
                        end

                        if ImGui.Button("Destroy Car", style.buttonWidth, style.buttonHeight) then
                            if CityHack.Car.Destroy() then
                                CityHack.Util.Response("car", "destroy", true, false)
                            else
                                CityHack.Util.Response("car", "destroy", false, false)
                            end
                        end

                        if ImGui.IsItemHovered() then
                            ImGui.SetTooltip("WARNING: Stand back! The explosion may kill you!")
                        end

                    ImGui.EndTabItem()
                    end

                    ---------------- NPC TAB ---------------- 
                    if ImGui.BeginTabItem("NPC") then
                        ImGui.SetWindowSize(265, 120)
                        ImGui.Spacing()

                        ImGui.PushTextWrapPos()
                        ImGui.Text("You will get police heat by using this!")
                        ImGui.PopTextWrapPos()

                        ImGui.Spacing()

                        if ImGui.Button("Kill", style.buttonWidth, style.buttonHeight) then
                            CityHack.NPC.Kill()
                        end

                    ImGui.EndTabItem()
                    end

                    ---------------- UTIL TAB ---------------- 
                    if ImGui.BeginTabItem("Util") then
                        ImGui.SetWindowSize(265, 200)
                        ImGui.Spacing()

                        ImGui.PushTextWrapPos()
                        ImGui.Text("These are debug utilites to dump different types of data into console. They have no effect in the game.")
                        ImGui.PopTextWrapPos()

                        ImGui.Spacing()

                        if ImGui.Button("Dump", style.buttonWidth, style.buttonHeight) then
                            CityHack.Util.Dump()
                        end
    
                        if ImGui.Button("Dump Device PS", style.buttonWidth, style.buttonHeight) then
                            CityHack.Util.DumpPS()
                        end

                        if ImGui.Button("Dump Vehicle PS", style.buttonWidth, style.buttonHeight) then
                            CityHack.Car.DumpPS()
                        end
                    ImGui.EndTabItem()
                    end

                end
                ImGui.EndTabBar()
                
            end
            ImGui.PopStyleColor(14)
            ImGui.End()
        end
    end)    
      

	return CityHack
end

return CityHack:new()