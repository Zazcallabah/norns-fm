-- PFM

engine.name = 'Pfm'
pfm = include('lib/pfm_engine')


s = require 'sequins'

lastmessage = ""
infomessage = ""
routing = {
  {false,false,false,false},
  {false,false,false,false},
  {false,false,false,false},
  {false,false,false,false}
}


m = midi.connect() -- if no argument is provided, we default to port 1
--seq = midi.connect(2) -- sequencer
-- seq.event = function(data)
-- 	local d = midi.to_msg(data)
-- 	if d.type == "note_on" then
-- 		s4.trig(midi_to_hz(d.note))
-- 	end
-- end
function midi_to_hz(note)
  local hz = (440 / 32) * (2 ^ ((note - 9) / 12))
  return hz
end


function msg_to_str(msg)
	local s = "c".. (msg.ch or 0) .. ": " ..( msg.type or "-" )
	if msg.note then
		s = s .." n: " .. msg.note
	end
	if msg.cc then
		s = s .. " cc: " .. msg.cc
	end
	if msg.val  then
		s =s .. " v: " .. msg.val
	end
	if msg.vel  then
		s = s .. " /." .. msg.vel
	end
	return s
end

m.event = function(data)
  local d = midi.to_msg(data)
  lastmessage = msg_to_str(d)
  if d.type == "note_on" then
    local startN = 32
    local note = d.note - startN
    local op = math.floor(note / 4) + 1
    local ix = (note % 4) + 1

    routing[op][ix] = not routing[op][ix]

    if ix == 4 then
      engine.toggleListen(op)
    else
      engine.toggleRoute(op,ix + 1)
    end
 	end

  -- ["amp"]     = controlspec.new(0, 2,     "lin", 0.01,       1, ""),
  -- ["ratio"]   = controlspec.new(0, 4,     "lin", 0.1,       1, ""),
  -- ["detune"]  = controlspec.new(0.8, 1.2, "lin", 0.001,   1, ""),
  -- ["attack"]  = controlspec.new(0.01, 8,  "exp", 0.01,    1, "s"),
  -- ["release"] = controlspec.new(0.01, 8,  "exp", 0.01,    1, "s"),
  -- ["sustain"] = controlspec.new(0.01, 1,  "lin", 0.01,    1, ""),
  -- ["decay"]   = controlspec.new(0.01, 1,  "lin", 0.01,    0.01, "s"),
  -- ["curve"]   = controlspec.new(-5, 5,    "lin", 0.1,     -4, ""),



  local startCC = 32 -- my midi controller topleft knob cc
  if d.type == "cc" then
    local cc = d.cc - startCC
    local op = math.floor(cc / 4) + 1
    local ix = cc % 4
    if ix == 0 then
      local val = util.linlin(0,127,0,4,d.val)
      infomessage = "op" .. op .. " ratio: " .. val
      params:set("Pfm_"..op.."ratio", val )
    end
    if ix == 1 then
      local val = util.linlin(0,127,0.8,1.2,d.val)
      infomessage = "op" .. op .. " detune: " .. val
      params:set("Pfm_"..op.."detune", val)
    end
    if ix == 2 then
      local val = util.linlin(0,127,0,2,d.val)
      infomessage = "op" .. op .. " amp: " .. val
      params:set("Pfm_"..op.."amp", val)
    end
    if ix == 3 then
      local val =  util.linlin(0,127,0,8,d.val)
      infomessage = "op" .. op .. " rel: " .. val
      params:set("Pfm_"..op.."release",val)
    end
  end
  redraw()
end

function init()

  pfm.add_params()



  mults = s{0, 7, s{0, 3, 7, 3, 3, 3} }
  playing = false
  sequence = clock.run(
    function()
      on = false
      while true do
        clock.sync(1/2)
        if playing then
            if on then
              engine.noteOff()
            else
              engine.noteOn(midi_to_hz(64 + mults()))
            end
            on = not on
        end
      end
    end
  )

end

function key(n,z)
  if n == 3 and z == 1 then
    playing = not playing
    if not playing then
        engine.free_all_notes()
      end
    redraw()
  end
end

function redraw()
  screen.clear()
  for x = 1,4 do
    for y = 1,4 do
      if routing[y][x] then
        screen.level(15)
      else
        screen.level(1)
      end
      screen.circle(10+(x*5), 32+(y*5), 1)
      screen.fill()
    end
  end


	screen.level(15)
  screen.move(10,10)
  screen.text(lastmessage)
  screen.move(10,20)
  screen.text(infomessage)
  screen.move(64,32)
  screen.text(playing and "K3: turn off" or "K3: turn on")
  screen.update()
end

-- see  https://monome.org/docs/norns/engine-study-2/#part-2 for more

-- https://github.com/supercollider/sc3-plugins prereq for dx7
-- https://github.com/everythingwillbetakenaway/DX7-Supercollider

