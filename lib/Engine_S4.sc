Engine_S4 : CroneEngine {

	var params;
// need an "in bus" or nil for op A i suppose?
// inbus a, b, c, d --- a is silence?
// outbus x, b, c, d, default  ---- x is /dev/null, default is audio out
// use in bus as phase modulator for sin osc?
// output to
	alloc {
		SynthDef("S4", {
			arg outBus = 0,
			inBus,
			freq, ratio, amp,
			attack, release;

			var env = EnvGen.kr(
				Env.perc(attack,release),
				doneAction:2
			);

			var mod = In.ar(inBus,1);
			var car = SinOsc.ar( freq * ratio + mod ) * env * amp;
			Out.ar(outBus,car);
		}).add;

  // We don't need to sync with the server in this example,
  //   because were not actually doing anything that depends on the SynthDef being available,
  //   so let's leave this commented:
  // Server.default.sync;

  // let's create an Dictionary (an unordered associative collection)
  //   to store parameter values, initialized to defaults.
		params = Dictionary.newFrom([
			\outBus, 0,
			\inBus, 0,
			\ratio, 1,
			\attack, 0.01,
			\release, 0.4,
			\amp, 1;
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