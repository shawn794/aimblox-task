-- Compiled with roblox-ts v1.2.2
--[[
	*
	* Scale a Model and all descendants uniformly
	* @param model The Model to scale
	* @param scale The amount to scale.  > 1 is bigger, < 1 is smaller
]]
local _scaleDescendants
local function scaleModel(model, scale)
	if scale == 1 then
		return nil
	end
	local pPart = model.PrimaryPart
	local _origin = pPart
	if _origin ~= nil then
		_origin = _origin.Position
	end
	local origin = _origin
	if not pPart or not origin then
		print("Unable to scale model, no PrimaryPart has been defined")
		return nil
	end
	_scaleDescendants(model:GetDescendants(), scale, origin)
end
--[[
	*
	* Scale a Part and all descendants uniformly
	* @param part The Part to scale
	* @param scale The amount to scale.  > 1 is bigger, < 1 is smaller
	* @param center (Optional) The point about which to scale.  Default: the Part's Position
]]
local function scalePart(part, scale, center)
	if scale == 1 then
		return nil
	end
	local origin = center or part.Position
	part.Position = origin:Lerp(part.Position, scale)
	part.Size = part.Size * scale
	_scaleDescendants(part:GetDescendants(), scale, origin)
end
function _scaleDescendants(descendants, scale, origin)
	local _arg0 = function(p)
		return p:IsA("BasePart")
	end
	-- ▼ ReadonlyArray.filter ▼
	local _newValue = {}
	local _length = 0
	for _k, _v in ipairs(descendants) do
		if _arg0(_v, _k - 1, descendants) == true then
			_length += 1
			_newValue[_length] = _v
		end
	end
	-- ▲ ReadonlyArray.filter ▲
	local parts = _newValue
	local _arg0_1 = function(part)
		part.Position = origin:Lerp(part.Position, scale)
		part.Size = part.Size * scale
	end
	-- ▼ ReadonlyArray.forEach ▼
	for _k, _v in ipairs(parts) do
		_arg0_1(_v, _k - 1, parts)
	end
	-- ▲ ReadonlyArray.forEach ▲
end
return {
	scaleModel = scaleModel,
	scalePart = scalePart,
}
