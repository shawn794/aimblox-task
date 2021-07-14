local Scaler = require(script.Parent.Scaler)

return {
	Scale = Scaler.scaleModel,

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