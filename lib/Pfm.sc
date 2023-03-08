
Pfm {
	classvar <voiceKeys;
	var <globalParams;
	var <voiceParams;
	var <voiceGroup;
	var <singleVoices;
	var <inputBuses;
	var <outputBuses;
	var <nullBus;

	*initClass {
		voiceKeys = [ \1, \2, \3, \4 ];
		StartUp.add {
			var s = Server.default;

			s.waitForBoot {
				SynthDef("Pfm", {
					arg outBusA,
					outBusB,
					outBusC,
					outBusD,
					inBus,
					freq,
					ratio = 1,
					detune = 1,
					stopGate = 1,
					attack = 0.1,
					decay = 0.1,
					sustain = 1,
					release = 2,
					curve = -4,
					amp = 0.2;

					var envelope = EnvGen.kr(
						envelope: Env.adsr(attackTime: attack, decayTime: decay, sustainLevel: sustain, releaseTime: release, curve: curve),
						gate: stopGate,
						doneAction: 2
					);

					var mod = InFeedback.ar(inBus,1);
					var car = SinOsc.ar( freq * ratio * detune, mod.mod(8pi) ) * envelope;
					var signal = car * amp;
					Out.ar(outBusA, signal);
					Out.ar(outBusB, signal);
					Out.ar(outBusC, signal);
					Out.ar(outBusD, signal);
				}).add;
			}
		}
	}

	*new {
		^super.new.init;
	}

	init {

		var s = Server.default;

		voiceGroup = Group.new(s);
		nullBus = Bus.audio(s,1);

		globalParams = Dictionary.newFrom([
			\freq, 400,
			\attack, 1,
			\decay, 1,
			\sustain, 1,
			\release, 1,
			\curve, -4,
			\amp, 1,
			\detune, 1,
			\ratio, 1;
		]);

		singleVoices = Dictionary.new;
		voiceParams = Dictionary.new;
		inputBuses = Dictionary.new;
		outputBuses = Dictionary.new;

		voiceKeys.do({ arg voiceKey;
			singleVoices[voiceKey] = Group.new(voiceGroup);
			voiceParams[voiceKey] = Dictionary.newFrom(globalParams);
			outputBuses[voiceKey] = List[nullBus.index, nullBus.index, nullBus.index, nullBus.index, nullBus.index, nullBus.index];
			inputBuses[voiceKey] = Bus.audio(s,1);
		});
	}

	playVoice { arg voiceKey, freq;
		singleVoices[voiceKey].set(\stopGate, -1.05);
		voiceParams[voiceKey][\freq] = freq;
		Synth.new("Pfm", [
			\freq, freq,
			\inBus, inputBuses[voiceKey].index,
			\stopGate, 1,
			\outBusA, outputBuses[voiceKey].at(0),
			\outBusB, outputBuses[voiceKey].at(2),
			\outBusC, outputBuses[voiceKey].at(3),
			\outBusD, outputBuses[voiceKey].at(4)
		] ++ voiceParams[voiceKey].getPairs, singleVoices[voiceKey]);
	}

	trigger { arg voiceKey, freq;
		if( voiceKey == 'all',{
			voiceKeys.do({ arg vK;
				this.playVoice(vK, freq);
			});
		},
		{
			this.playVoice(voiceKey, freq);
		});
	}

	adjustVoice { arg voiceKey, paramKey, paramValue;
		singleVoices[voiceKey].set(paramKey, paramValue);
		voiceParams[voiceKey][paramKey] = paramValue
	}

	setParam { arg voiceKey, paramKey, paramValue;
		if( voiceKey == 'all',{
			voiceKeys.do({ arg vK;
				this.adjustVoice(vK, paramKey, paramValue);
			});
		},
		{
			this.adjustVoice(voiceKey, paramKey, paramValue);
		});
	}

	noteOn {
		arg freq;
		voiceKeys.do({ arg vK;
			this.playVoice(vK, freq);
		});
	}

	noteOff {
		voiceGroup.set(\stopGate, 0);
	}

	toggleListen { arg op;
		var bus = outputBuses[op];
		if( bus.at(0) == 0, { bus.put(0,nullBus.index); }, { bus.put(0,0); });
	}

	toggleRoute { arg op, ix;
		var bus = outputBuses[op];
		var toggle = inputBuses[ix].index;
		var int = ix.asInteger;

		if(bus.at(int) == toggle, { bus.put(int, nullBus.index); }, { bus.put(int,toggle); });
	}

	freeAllNotes {
		voiceGroup.set(\stopGate, -1.05);
	}

	free {
		nullBus.free;
		voiceKeys.do({ arg vK;
			inputBuses[vK].free;
		});
		voiceGroup.free;
	}

}
