local function scaleDescendants(descendants, scale, origin)
	for _, part in ipairs(descendants) do
		if part:IsA("BasePart") == true then
			part.Position = origin:Lerp(part.Position, scale)
			part.Size = part.Size * scale
		end
	end
end

-- Scales a model uniformily, positioning it correctly as well
local function scaleModel(model, scale)
	if scale == 1 then return nil end

	local primaryPart = model.PrimaryPart
	if primaryPart == nil then print("Primary Part not set!") return end

	local primaryPartOrigin = primaryPart.Position
	scaleDescendants(model:GetDescendants(), scale, primaryPartOrigin)
end

return {
	ScaleModel = scaleModel,
}
