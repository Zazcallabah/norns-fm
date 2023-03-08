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
parameter_table = {
  [0]={p="ratio_t",min=0,max=100},
  [1]={p="ratio_n",min=1,max=100},
  [2]={p="detune",min=0.8,max=1.2},
  [3]={p="amp",min=0,max=10},
  [4]={p="attack",min=0,max=5},
  [5]={p="decay",min=0,max=5},
  [6]={p="sustain",min=0,max=1},
  [7]={p="release",min=0,max=5}
}

m = midi.connect() -- if no argument is provided, we default to port 1
m2 = midi.connect(2) -- sequencer
m2.event = function(data)
	local d = midi.to_msg(data)
  lastmessage = msg_to_str(d)
  if d.type=="note_off" then
    engine.noteOff()
  end
  if d.type=="note_on" then
    engine.noteOn(midi_to_hz(d.note))
  end
  redraw()
end
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

function set_param(p,op,min,max,val)
  local v = util.linlin(0,127,min,max,val)
  params:set("Pfm_" .. op .. p, v)
  infomessage = "op" .. op .. " ".. p ..": " .. params:get("Pfm_" .. op .. p)
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
      -- carrier amplitude is locked to 0.4 for safety reasons
      params:set("Pfm_" .. op .. "amp", 0.4)

              if routing[op][ix]  then
                infomessage = "sending op " .. op .. " to out"
              else
                infomessage = "muting op " .. op
              end
    else
      engine.toggleRoute(op,ix + 1)
            if routing[op][ix]  then
              infomessage =  "sending op ".. op .. " to " .. (ix+1)
            else
              infomessage = "not sending op ".. op .. " to " .. (ix+1)
            end
    end
  end

  if d.type == "cc" then
    -- cc 32-47 4x ratio detune amp one row for each op
    -- cc 48-63 4x adsr same
    local cc = d.cc - 32
    local ix = cc % 4
    local para = parameter_table[ix]
    if cc > 15 then para = parameter_table[ix+4] end
    local op = (math.floor( cc / 4) % 4) + 1
    if para.p == "amp" and routing[op][4] then
      infomessage = "amp locked for carrier"
    else
      set_param(para.p,op,para.min,para.max,d.val)
    end
  end
  redraw()
end

function init()

  pfm.add_params()
  mults = s{ 0, 7, 2, 7, 0, 7, 2, 7, -2, 4, 1, 4, -2, 4, 1, 4 }
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

