# Pfm

Pfm is a 4-op phase modulated fm synthesizer engine for supercollider (and subsequently, norns).

Each operator takes 8 parameters - two ratio parameters, an amplitude parameter, a detune parameter, plus an asdr envelope.

The two ratio parameters are somewhat non-intuitive to use at first, basically, one is divided by the other to get the ratio used before the phase shift. Amplitude is applied after phase shift.

You will need something midi-ish to play notes for you, and then you need enough midi control to handle a 4x4 routing matrix, plus these 8 parameters x4 (one set for each operator)

I personally solve this using some Grid-16 modules, but I'm working on a grids-128 or maybe a grids-64 example script.
