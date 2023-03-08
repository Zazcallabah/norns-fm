Engine_Pfm : CroneEngine {
	var kernel;
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		kernel = Pfm.new(Crone.server);

		this.addCommand(\noteOn, "f", { arg msg;
			var freq = msg[1].asFloat;
			kernel.noteOn(freq);
		});
		this.addCommand(\noteOff, "", {
			kernel.noteOff();
		});

		this.addCommand(\toggleRoute, "ss", { arg msg;
			kernel.toggleRoute(msg[1].asSymbol,msg[2].asSymbol);
		});
		this.addCommand(\toggleListen, "s", { arg msg;
			kernel.toggleListen(msg[1].asSymbol);
		});
		kernel.globalParams.keysValuesDo({ arg paramKey;
			this.addCommand(paramKey, "sf", {arg msg;
				kernel.setParam(msg[1].asSymbol,paramKey.asSymbol,msg[2].asFloat);
			});
		});
		this.addCommand(\getParam, "ss", { arg msg;
			kernel.getParam(msg[1].asSymbol,msg[2].asSymbol)
		});
		this.addCommand(\free_all_notes, "", {
			kernel.freeAllNotes();
		});
	}

	free {
		kernel.freeAllNotes;
		kernel.free;
	}
}
