--
-- MIDI keyboard
-- into custom sc
--

engine.name = 'S4' -- assign the engine to this script's run
s4 = include('s4/lib/s4_engine')

m = midi.connect() -- if no argument is provided, we default to port 1
seq = midi.connect(2) -- sequencer
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

seq.event = function(data)
	local d = midi.to_msg(data)
	if d.type == "note_on" then
		s4.trig(midi_to_hz(d.note))
	end
end

m.event = function(data)
  local d = midi.to_msg(data)
  scrollback_active = (scrollback_active + 1) % 10
  scrollback[scrollback_active] = msg_to_str(d)
  if d.type == "cc" then
	if d.cc == 32 then
		engine.attack(util.linlin(0,127,0,1,d.val))
	end
	if d.cc == 33 then
		engine.release(util.linlin(0,127,0,1,d.val))
	end
	if d.cc == 34 then
		engine.amp(util.linlin(0,127,0,2,d.val))
	end
	if d.cc == 35 then
		engine.ratio(util.linlin(0,127,0,2,d.val))
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
	s4.add_params()
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

