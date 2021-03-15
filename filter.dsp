import("stdfaust.lib");

freq = hslider("frequency",1,0.1,3,0.001);
drywet = hslider("dry/wet",-1,-1,1,0.001) : si.smoo;
drive = hslider("[1] Drive [tooltip: Amount of distortion]",0.5, 0, 1, 0.01);
offset = hslider("[2] Offset [tooltip: Brings in even harmonics]",0.6, 0, 1, 0.01);


dry_wet(x,y) = *(wet) + dry*x, *(wet) + dry*y with {
	wet = 0.5*(drywet+1.0);
	dry = 1.0-wet;
};


disto = ef.cubicnl_nodc(drive:si.smoo,offset:si.smoo) :> _;


//2ch random generator
noise = no.multinoise(2) : ba.latch(os.oscrs(freq)),ba.latch(os.oscrs(freq)) : fi.lowpass(1,freq),fi.lowpass(1,freq);

// select one of the two output channels of p
channel1(p) = p : _,!;
channel2(p) = p : !,_;

ampdisto(channel) = disto : fi.resonbp(channel(noise)*2000+4000,10, 1);

//filters with noise as input
process = no.noise <: _,_,ampdisto(channel1), ampdisto(channel2) : dry_wet :> _;

//process = noise;