local Pfm = {}

local specs = {
-- controlspec.new(min, max, warp, step, default, units, quantum, wrap)
  ["amp"]     = controlspec.new(0.01, 10, "exp", 0.01,   0.2, ""),
  ["ratio_t"]   = controlspec.new(0, 100,  "lin", 1,       4, ""),
  ["ratio_n"]   = controlspec.new(1, 100,  "lin", 1,       4, ""),
  ["detune"]  = controlspec.new(0.8, 1.2, "lin", 0.001,   1, ""),
  ["attack"]  = controlspec.new(0.01, 8,  "exp", 0.05,    0.1, "s"),
  ["release"] = controlspec.new(0.01, 8,  "exp", 0.05,    1, "s"),
  ["sustain"] = controlspec.new(0.01, 1,  "lin", 0.01,    1, ""),
  ["decay"]   = controlspec.new(0.01, 3,  "lin", 0.05,    0.01, "s"),
  ["curve"]   = controlspec.new(-5, 5,    "lin", 0.1,     -4, ""),
}

-- this table establishes an order for parameter initialization:
local param_names = {"amp","ratio_t","ratio_n","detune","attack","release","sustain","decay","curve"}

-- initialize parameters:
function Pfm.add_params()
  params:add_group("Pfm",#param_names)

  for op = 1,4 do
    for i = 1,#param_names do
      local p_name = param_names[i]
      params:add{
        type = "control",
        id = "Pfm_".. op .. p_name,
        name = op .. p_name,
        controlspec = specs[p_name],
        action = function(x) engine[p_name](op,x) end
      }

    end
  end

  params:bang()
end

function Pfm.toggleRoute(op,out)
  engine.toggleRoute(op,out)
end
function Pfm.toggleListen(op)
  engine.toggleListen(op)
end
function Pfm.noteOn(hz)
  if hz ~= nil then
    engine.noteOn(hz)
  end
end
function Pfm.noteOff()
  engine.noteOff()
end

return Pfm
