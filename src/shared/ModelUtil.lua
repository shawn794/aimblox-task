local function scaleDescendants(descendants, scale, origin)
	local function basePart(p)
		return p:IsA("BasePart")
	end

	local parts = {}
	for _, part in ipairs(descendants) do
		if basePart(part) then
			table.insert(parts, part)
		end
	end

	local function resize(part)
		part.Position = origin:Lerp(part.Position, scale)
		part.Size = part.Size * scale
	end
	for _, part in pairs(parts) do
		resize(part)
	end
end

local function scaleModel(model: Model, scale: number)
	if scale == 1 then return end
	local primaryPart = model.PrimaryPart
	local origin = primaryPart.Position
	if not primaryPart or not origin then
		error("Unable to scale model")
		return
	end
	scaleDescendants(model:GetDescendants(), scale, origin)
end

return {
	Scale = scaleModel,

	Unweld = function(model: Model)
		for _, thing in pairs(model:GetDescendants()) do
			if thing:IsA("Weld") or thing:IsA("WeldConstraint") then
				thing.Part0.Anchored = true
				thing.Part1.Anchored = true
				thing:Destroy()
			end
		end
	end,

	Reweld = function(model: Model)
		if model.PrimaryPart == nil then error("No primary part") end
		for _, part in pairs(model:GetChildren()) do
			if part:IsA("BasePart") then
				if part ~= model.PrimaryPart then
					local w = Instance.new("Weld")
					w.Part0 = model.PrimaryPart
					w.Part1 = part
					w.Parent = model.PrimaryPart
					part.Anchored = false
				end
			end
		end
		model.PrimaryPart.Anchored = false
	end
}