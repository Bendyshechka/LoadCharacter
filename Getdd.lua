

return function(c)
	local Players = game:GetService("Players")
	local HttpService = game:GetService("HttpService")

	local function prelcframe(cf)
		local function smartRound(num)
			if math.abs(num) < 1e-10 then
				return 0
			elseif math.abs(num - math.floor(num + 0.5)) < 1e-10 then
				return math.floor(num + 0.5)
			else
				return math.floor(num * 1000000 + 0.5) / 1000000
			end
		end

		local rx, ry, rz = cf:ToOrientation()
		local degX, degY, degZ = math.deg(rx), math.deg(ry), math.deg(rz)

		return "CFrame.new(" .. smartRound(cf.X) .. ", " .. smartRound(cf.Y) .. ", " .. smartRound(cf.Z) .. ") * CFrame.Angles(math.rad(" .. smartRound(degX) .. "), math.rad(" .. smartRound(degY) .. "), math.rad(" .. smartRound(degZ) .. "))"
	end

	local function prelcolor(color)
		return "Color3.fromRGB(" .. math.floor(color.R * 255) .. "," .. math.floor(color.G * 255) .. "," .. math.floor(color.B * 255) .. ")"
	end

	local function prelvector3(vec)
		local function smartRound(num)
			if math.abs(num) < 1e-10 then
				return 0
			elseif math.abs(num - math.floor(num + 0.5)) < 1e-10 then
				return math.floor(num + 0.5)
			else
				return math.floor(num * 1000000 + 0.5) / 1000000
			end
		end

		return string.format("Vector3.new(%s, %s, %s)", 
			smartRound(vec.X), smartRound(vec.Y), smartRound(vec.Z))
	end

	local function prelacctype(type1)
		-- используется для аксессуаров (AccessoryType) — вернёт кусочек строки
		local newstring = string.sub(type1, 20)
		return newstring
	end
	

	local character = c
	if not character:IsA("Model") then
		print("Выберите модель, а не отдельную часть!")
		return nil
	end

	local skindata = {
		["BodyColors"] = {
			ALL = prelcolor(Color3.fromRGB(0,1488,0)),
			HeadColor3 = prelcolor(Color3.new(1,1,1)),
			LeftArmColor3 = prelcolor(Color3.new(1,1,1)),
			LeftLegColor3 = prelcolor(Color3.new(1,1,1)),
			RightArmColor3 = prelcolor(Color3.new(1,1,1)),
			RightLegColor3 = prelcolor(Color3.new(1,1,1)),
			TorsoColor3 = prelcolor(Color3.new(1,1,1)),
		},
		Pants = {
			Color3 = prelcolor(Color3.new(1,1,1)),
			PantsTemplate = ""
		},
		Shirt = {
			Color3 = prelcolor(Color3.new(1,1,1)),
			ShirtTemplate = ""
		},
		ShirtGrapics = {},
		Head = {
			Face = {
				Color3 = prelcolor(Color3.fromRGB(1,1,1)),
				Texture = "rbxasset://textures/face.png"
			},
			Mesh = {
				MeshId = "",
				MeshType = "Enum.MeshType.Head",
				Scale = prelvector3(Vector3.new(1,1,1)),
				TextureId = "",
				DataMesh = {}
			}
		},
		CharMesh = false, -- теперь либо false, либо таблица с CharacterMesh-ами
		Acc = {}
	}

	-- Body Colors
	local bodyColors = character:FindFirstChild("Body Colors")
	if bodyColors then
		local colors = bodyColors
		skindata.BodyColors.HeadColor3 = prelcolor(colors.HeadColor3)
		skindata.BodyColors.LeftArmColor3 = prelcolor(colors.LeftArmColor3)
		skindata.BodyColors.LeftLegColor3 = prelcolor(colors.LeftLegColor3)
		skindata.BodyColors.RightArmColor3 = prelcolor(colors.RightArmColor3)
		skindata.BodyColors.RightLegColor3 = prelcolor(colors.RightLegColor3)
		skindata.BodyColors.TorsoColor3 = prelcolor(colors.TorsoColor3)

		-- Проверка одинаковых цветов (упрощённо)
		local allSame = true
		local firstColor = colors.HeadColor3
		if colors.LeftArmColor3 ~= firstColor or colors.LeftLegColor3 ~= firstColor or
			colors.RightArmColor3 ~= firstColor or colors.RightLegColor3 ~= firstColor or
			colors.TorsoColor3 ~= firstColor then
			allSame = false
		end

		if allSame then
			skindata.BodyColors.ALL = prelcolor(firstColor)
		end
	end

	-- Pants and Shirt
	local pants = character:FindFirstChild("Pants")
	if pants then
		skindata.Pants.Color3 = prelcolor(pants.Color3)
		skindata.Pants.PantsTemplate = pants.PantsTemplate
	end

	local shirt = character:FindFirstChild("Shirt")
	if shirt then
		skindata.Shirt.Color3 = prelcolor(shirt.Color3)
		skindata.Shirt.ShirtTemplate = shirt.ShirtTemplate
	end

	-- Head
	local head = character:FindFirstChild("Head")
	if head then
		local face = head:FindFirstChild("face")
		if face then
			skindata.Head.Face.Color3 = prelcolor(face.Color3)
			skindata.Head.Face.Texture = face.Texture
		end

		local mesh = head:FindFirstChild("Mesh")
		if mesh then
			skindata.Head.Mesh.MeshId = mesh.MeshId
			skindata.Head.Mesh.MeshType = tostring(mesh.MeshType)
			skindata.Head.Mesh.Scale = prelvector3(mesh.Scale)
			skindata.Head.Mesh.TextureId = mesh.TextureId

			for _, obj in pairs(head:GetDescendants()) do
				if obj:IsA("Vector3Value") and skindata.Head.Mesh.DataMesh[obj.Name] == nil then
					skindata.Head.Mesh.DataMesh[obj.Name] = prelvector3(obj.Value)
				end
			end
		end
	end

	-- CharacterMesh (теперь сохраняем все CharacterMesh-ы в дереве)
	for _, cm in pairs(character:GetDescendants()) do
		if cm:IsA("CharacterMesh") then
			if typeof(skindata.CharMesh) == "boolean" then
				skindata.CharMesh = {}
			end
			local entry = {
				MeshId = cm.MeshId or "",
				OverlayTextureId = cm.OverlayTextureId or "",
				BodyPart = tostring(cm.BodyPart or ""),


				DataMesh = {}
			}
			for _, child in pairs(cm:GetChildren()) do
				if child:IsA("Vector3Value") then
					entry.DataMesh[child.Name] = prelvector3(child.Value)
				end
			end
			skindata.CharMesh[cm.Name .. math.random(1, 10000000)] = entry
		end
	end

	-- ShirtGraphics
	local shirtGraphicsIndex = 1
	for _, obj in pairs(character:GetChildren()) do
		if obj:IsA("ShirtGraphic") then
			skindata.ShirtGrapics[shirtGraphicsIndex] = {
				Color3 = prelcolor(obj.Color3),
				Graphic = obj.Graphic
			}
			shirtGraphicsIndex += 1
		end
	end

	-- Accessories
	for _, accessory in pairs(character:GetChildren()) do
		if accessory:IsA("Accessory") then
			local handle = accessory:FindFirstChild("Handle")
			if handle then
				local accData = {
					Type = "Accessory",
					AccessoryType = prelacctype(tostring(accessory.AccessoryType)),
					AttachmentPoint = prelcframe(accessory.AttachmentPoint),
					Childrens = {
						Handle = {
							Type = "Part",
							Color = prelcolor(handle.Color),
							Size = prelvector3(handle.Size),
							Childrens = {}
						}
					}
				}

				for _, child in pairs(handle:GetChildren()) do
					if child:IsA("Attachment") then
						accData.Childrens.Handle.Childrens[child.Name] = {
							Type = "Attachment",
							CFrame = prelcframe(child.CFrame),
							Axis = prelvector3(child.Axis),
							SecondaryAxis = prelvector3(child.SecondaryAxis)
						}
					elseif child:IsA("SpecialMesh") then
						accData.Childrens.Handle.Childrens[child.Name] = {
							Type = "SpecialMesh",
							MeshId = child.MeshId,
							Offset = prelvector3(child.Offset),
							Scale = prelvector3(child.Scale),
							TextureId = child.TextureId
						}
					elseif child:IsA("Weld") or child:IsA("WeldConstraint") then
						local part1Name = "Head"
						if child.Part1 then
							part1Name = child.Part1.Name
						end
						accData.Childrens.Handle.Childrens[child.Name] = {
							Type = "Weld",
							C0 = prelcframe(child.C0),
							C1 = prelcframe(child.C1),
							Part0 = "Handle",
							Part1 = part1Name
						}
					end
				end

				skindata.Acc[accessory.Name] = accData
			end
		end
	end

	return HttpService:JSONEncode(skindata)
end

