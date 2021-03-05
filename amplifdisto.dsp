import("stdfaust.lib");

freq = hslider("freq1",1,0.1,3,0.001);

disto = ef.cubicnl_nodc(drive:si.smoo,offset:si.smoo) :> _
        with{
	        drive = hslider("[1] Drive [tooltip: Amount of distortion]",
		0.5, 0, 1, 0.01);
	        offset = hslider("[2] Offset [tooltip: Brings in even harmonics]",
		0.6, 0, 1, 0.01);
};


//2ch random generator
noise = no.multinoise(2) : ba.latch(os.oscrs(freq)),ba.latch(os.oscrs(freq)) : fi.lowpass(1,freq),fi.lowpass(1,freq) : +(1),+(1) : *(0.5),*(0.5);

// select one of the two output channels of p
channel1(p) = p : _,!;
channel2(p) = p : !,_;

//filters with noise as input
process = disto <: fi.resonbp(channel1(noise)*2000+6000,10, 1),fi.resonbp(channel2(noise)*2000+6000,10, 1) :> _ <: _,_;