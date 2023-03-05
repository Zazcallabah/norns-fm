local S4 = {}
local Formatters = require 'formatters'

-- first, we'll collect all of our commands into norns-friendly ranges
local specs = {
  ["amp"] = controlspec.new(0, 2, "lin", 0, 1, ""),
  ["ratio"] = controlspec.new(0, 2, "lin", 0, 1, ""),
  ["attack"] = controlspec.new(0.003, 8, "exp", 0, 0, "s"),
  ["release"] = controlspec.new(0.003, 8, "exp", 0, 1, "s"),
}

-- this table establishes an order for parameter initialization:
local param_names = {"amp","ratio","attack","release"}

-- initialize parameters:
function S4.add_params()
  params:add_group("S4",#param_names)

  for i = 1,#param_names do
    local p_name = param_names[i]
    params:add{
      type = "control",
      id = "S4_"..p_name,
      name = p_name,
      controlspec = specs[p_name],
      formatter = p_name == "pan" and Formatters.bipolar_as_pan_widget or nil,
      -- every time a parameter changes, we'll send it to the SuperCollider engine:
      action = function(x) engine[p_name](x) end
    }
  end

  params:bang()
end

-- a single-purpose triggering command fire a note
function S4.trig(hz)
  if hz ~= nil then
    engine.hz(hz)
  end
end

 -- we return these engine-specific Lua functions back to the host script:
return S4
