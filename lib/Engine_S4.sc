Engine_S4 : CroneEngine {

	var params;

	alloc {
		SynthDef("S4", {
			arg out = 0,
			freq, sub_div, noise_level,
			cutoff, resonance,
			attack, release,
			amp, pan;

			var s1 = SinOsc.ar(freq: freq);
			var s2 = SinOsc.ar(freq: freq, phase: amp*2pi);

			var envelope = EnvGen.kr(envelope:Env.perc(attackTime: attack, releaseTime: release), doneAction: 2);

			Out.ar(out,[s1*envelope*multl,s2*envelope*multr]);

		}).add;

  // We don't need to sync with the server in this example,
  //   because were not actually doing anything that depends on the SynthDef being available,
  //   so let's leave this commented:
  // Server.default.sync;

  // let's create an Dictionary (an unordered associative collection)
  //   to store parameter values, initialized to defaults.
		params = Dictionary.newFrom([
			\sub_div, 2,
			\noise_level, 0.1,
			\cutoff, 8000,
			\resonance, 3,
			\attack, 0,
			\release, 0.4,
			\amp, 0.5,
			\pan, 0.5;
		]);

  // "Commands" are how the Lua interpreter controls the engine.
  // The format string is analogous to an OSC message format string,
  //   and the 'msg' argument contains data.

  // We'll just loop over the keys of the dictionary,
  //   and add a command for each one, which updates corresponding value:
		params.keysDo({ arg key;
			this.addCommand(key, "f", { arg msg;
				params[key] = msg[1];
			});
		});

  // The "hz" command, however, requires a new syntax!
  // ".getPairs" flattens the dictionary to alternating key,value array
  //   and "++" concatenates it:
		this.addCommand("hz", "f", { arg msg;
			Synth.new("S4", [\freq, msg[1]] ++ params.getPairs)
		});

	}

}