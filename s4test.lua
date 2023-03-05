--
-- MIDI keyboard
-- into custom sc
-- scrollback 10

engine.name = 'S4' -- assign the engine to this script's run
s4 = include('s4/lib/s4_engine')

m = midi.connect() -- if no argument is provided, we default to port 1

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
  scrollback_active = (scrollback_active + 1) % 10
  scrollback[scrollback_active] = msg_to_str(d)
  if d.type == "note_on" then
    --engine.amp(d.vel / 127)
  --  engine.hz(midi_to_hz(d.note))
    s4.trig(midi_to_hz(d.note))
  end
  if d.type == "cc" then

	if d.cc == 32 then
		engine.cutoff(util.linexp(0,127,300,12000,d.val))
	end
	if d.cc == 33 then
		engine.noise_level(util.linlin(0,127,0,1,d.val))
	end
	if d.cc == 34 then
		engine.resonance(util.linlin(0,127,1,6,d.val))
	end
	if d.cc == 35 then
		engine.sub_div(util.linlin(0,127,0,5,d.val))
	end
	if d.cc == 36 then
		engine.attack(util.linlin(0,127,0,1,d.val))
	end
	if d.cc == 37 then
		engine.release(util.linlin(0,127,0,1,d.val))
	end
	if d.cc == 38 then
		local tmp = util.linlin(0,127,0,1,d.val)
		scrollback[scrollback_active] = "pha > " .. tmp
		engine.amp(tmp)
	end
	if d.cc == 39 then
		local tmp = util.linlin(0,127,0,1,d.val)
		scrollback[scrollback_active] = "pan > " .. tmp
		engine.pan(tmp)
	end
  end
  redraw()
end
scrollback = {}
scrollback_active = 0

function init()
	for i = 0,10 do
		scrollback[i] = "line "..i
	end
	s4.add_params() -- the script adds params via the `.add params()` function
end


function redraw()
	screen.clear()
	screen.level(15)
	line = 1
	local ll = #scrollback

	for i=(scrollback_active - 5),scrollback_active do
	  screen.move(0,(line)*10)
	  screen.text(scrollback[i%10])
--	  screen.move(127,line*10)
--	  screen.text_right(value)
		line = line + 1
	end
	screen.update()
end

