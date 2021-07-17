-- Compiled with roblox-ts v1.2.3
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
local _scaleNumberSequence
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
	local _arg0_2 = function(p)
		return p:IsA("Attachment")
	end
	-- ▼ ReadonlyArray.filter ▼
	local _newValue_1 = {}
	local _length_1 = 0
	for _k, _v in ipairs(descendants) do
		if _arg0_2(_v, _k - 1, descendants) == true then
			_length_1 += 1
			_newValue_1[_length_1] = _v
		end
	end
	-- ▲ ReadonlyArray.filter ▲
	local atts = _newValue_1
	local _arg0_3 = function(att)
		local parent = att.Parent
		att.WorldPosition = parent.Position:Lerp(att.WorldPosition, scale)
	end
	-- ▼ ReadonlyArray.forEach ▼
	for _k, _v in ipairs(atts) do
		_arg0_3(_v, _k - 1, atts)
	end
	-- ▲ ReadonlyArray.forEach ▲
	local _arg0_4 = function(p)
		return p:IsA("SpecialMesh")
	end
	-- ▼ ReadonlyArray.filter ▼
	local _newValue_2 = {}
	local _length_2 = 0
	for _k, _v in ipairs(descendants) do
		if _arg0_4(_v, _k - 1, descendants) == true then
			_length_2 += 1
			_newValue_2[_length_2] = _v
		end
	end
	-- ▲ ReadonlyArray.filter ▲
	local specials = _newValue_2
	local _arg0_5 = function(special)
		special.Scale = special.Scale * scale
	end
	-- ▼ ReadonlyArray.forEach ▼
	for _k, _v in ipairs(specials) do
		_arg0_5(_v, _k - 1, specials)
	end
	-- ▲ ReadonlyArray.forEach ▲
	local _arg0_6 = function(p)
		return p:IsA("Fire")
	end
	-- ▼ ReadonlyArray.filter ▼
	local _newValue_3 = {}
	local _length_3 = 0
	for _k, _v in ipairs(descendants) do
		if _arg0_6(_v, _k - 1, descendants) == true then
			_length_3 += 1
			_newValue_3[_length_3] = _v
		end
	end
	-- ▲ ReadonlyArray.filter ▲
	local fires = _newValue_3
	local _arg0_7 = function(fire)
		fire.Size = math.floor(fire.Size * scale)
	end
	-- ▼ ReadonlyArray.forEach ▼
	for _k, _v in ipairs(fires) do
		_arg0_7(_v, _k - 1, fires)
	end
	-- ▲ ReadonlyArray.forEach ▲
	local _arg0_8 = function(p)
		return p:IsA("ParticleEmitter")
	end
	-- ▼ ReadonlyArray.filter ▼
	local _newValue_4 = {}
	local _length_4 = 0
	for _k, _v in ipairs(descendants) do
		if _arg0_8(_v, _k - 1, descendants) == true then
			_length_4 += 1
			_newValue_4[_length_4] = _v
		end
	end
	-- ▲ ReadonlyArray.filter ▲
	local particles = _newValue_4
	local _arg0_9 = function(particle)
		particle.Size = _scaleNumberSequence(particle.Size, scale)
		return particle.Size
	end
	-- ▼ ReadonlyArray.forEach ▼
	for _k, _v in ipairs(particles) do
		_arg0_9(_v, _k - 1, particles)
	end
	-- ▲ ReadonlyArray.forEach ▲
end
function _scaleNumberSequence(sequence, scale)
	local _keypoints = sequence.Keypoints
	local _arg0 = function(kp)
		return NumberSequenceKeypoint.new(kp.Time, kp.Value * scale, kp.Envelope * scale)
	end
	-- ▼ ReadonlyArray.map ▼
	local _newValue = table.create(#_keypoints)
	for _k, _v in ipairs(_keypoints) do
		_newValue[_k] = _arg0(_v, _k - 1, _keypoints)
	end
	-- ▲ ReadonlyArray.map ▲
	return NumberSequence.new(_newValue)
end
return {
	scaleModel = scaleModel,
	scalePart = scalePart,
}
