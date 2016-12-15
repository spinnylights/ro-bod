<CsoundSynthesizer>
<CsOptions>
;-odac
-o ro-bod_crash_demo.wav --format=wav
;-o /dev/null
</CsOptions>
; ==============================================
<CsInstruments>

sr = 44100
ksmps = 1
nchnls = 2
0dbfs = 1

instr RoBod
  #define KICK_MIDI_N      #41# ; assign midi note numbers to drums here
  #define SNARE_MIDI_N     #38#
  #define WOODBLOCK_MIDI_N #37#
  #define HIHAT_MIDI_N #36#
  #define RIDE_MIDI_N #35#
  #define CRASH_MIDI_N #34#

  #define MIDI_MAX_VEL #127#
  
  ; kick params
  ikickdur          = .35
  ikickbasefreq     = 60  ; 20-60ish conventional
  ikicknoiseamt     = .02
  ikickcolor        = 7.2  ; low values conventional, high values strange
  ikickpitchreduct  = .7  ; <1 conventional, 0 illegal
  ikickdecmethod    = 0   ; 0 = linear, 1 = exponential
  ikickpan          = .5
  
  ; snare params
  isnaredur         = .3
  isnarebasefreq    = 180
  isnarecolor       = 1
  isnaresnares      = 2.25
  isnaresnarecutoff = 9000
  isnarepan          = .32

  ; woodblock params
  iwoodbcolor = 700
  iwoodbpan   = .61

  ; hi-hat params
  ihihatpedal = 7.8 ; .18 to 7.8; closed to open
  ihihatcolor = 1.9; .8 to 3, dark to bright
  ihihatpan = .5

  ; ride params
  iridedur = 6 ; 6 to 7.3
  iridecolor = 2.4; 1.8 to 2.6, dark to bright
  iridepan = .5

  ; crash params
  icrashdur = 6.2; 5 to 6.5
  icrashcolor1 = .7; .7 to .77, dark to bright
  icrashcolor2 = 1.8; 1.8 to 3, dark to bright
  icrashpan = .5

  ivel    = p5
  iamp    = ivel / $MIDI_MAX_VEL ; convert midi velocity to 0-1 scale

  imidi_n = p4

  if     (imidi_n == $KICK_MIDI_N) then
    event_i "i", "RoBod_Kick", 0, ikickdur, iamp, ikickbasefreq, ikicknoiseamt, ikickdecmethod, ikickcolor, ikickpitchreduct, ikickpan
  elseif (imidi_n == $SNARE_MIDI_N) then
    event_i "i", "RoBod_Snare", 0, isnaredur, iamp, isnarebasefreq, isnarecolor, isnaresnares, isnaresnarecutoff, isnarepan
  elseif (imidi_n == $WOODBLOCK_MIDI_N) then
    event_i "i", "RoBod_Woodblock", 0, iamp, iwoodbcolor, iwoodbpan
  elseif (imidi_n == $HIHAT_MIDI_N) then
    event_i "i", "RoBod_HiHat", 0, ihihatpedal, iamp, ihihatcolor, ihihatpan
  elseif (imidi_n == $RIDE_MIDI_N) then
    event_i "i", "RoBod_Ride", 0, iridedur, iamp, iridecolor, iridepan
  elseif (imidi_n == $CRASH_MIDI_N) then
    event_i "i", "RoBod_Crash", 0, icrashdur, iamp, icrashcolor1, icrashcolor2, icrashpan
  else
    prints "WARNING: midi note number %d does not correspond to a drum instrument\n", imidi_n
  endif
endin

instr RoBod_Kick
  idur       = p3
  iamp       = p4
  ibasefreq  = p5
  inoiseamt  = p6
  idecmethod = p7
  imodfreq   = p8
  ipitchred  = p9
  ipan       = p10
  isq2       = 1.0 / sqrt(2.0)

  ifsine ftgenonce 0, 0, 65536, 10, 1
  ifsaw  ftgenonce 0, 0, 16384, 10, 1, 0.5, 0.3, 0.25, 0.2, 0.167, 0.14, 0.125, .111 

  if (idecmethod == 0) then
    kenv linseg iamp, idur, 0
  elseif (idecmethod == 1) then
    kenv expon  iamp, idur, .001
  else
    prints "ERROR: %d is not a valid value for idecmethod", idecmethod
  endif

  ; freq-shifted oscil

  apitchenv    expon ibasefreq, idur, ibasefreq * ipitchred
  aosc         oscil kenv, apitchenv, ifsaw
  areal, aimag hilbert aosc

  asin oscili 1, imodfreq, ifsine 
  acos oscili 1, imodfreq, ifsine, .25

  amod1 = areal * acos
  amod2 = aimag * asin

  aocalc = isq2*(amod1 - amod2)

  aosig balance aocalc, aosc

  ; bp-filtered noise

  afosc rand .5

  ifhpf = 250
  iflpf  = 1000
  iflpfceil = 4000
  iflpenvleng = .3

  afhp butterhp afosc, ifhpf

  aflpenv linseg iflpfceil, idur*iflpenvleng, iflpf
  aflp butterlp afhp, aflpenv

  afsig balance aflp, afosc

  ; mix

  asig = aosig + afsig*kenv*inoiseamt
  apostsig clip asig, 1, iamp

  outs apostsig*ipan, apostsig*(1-ipan)
endin

instr RoBod_Snare
  idur         = p3
  iamp         = p4
  ibasefreq    = p5
  icolor       = p6
  isnares      = p7
  isnarecutoff = p8
  ipan         = p9

  ; additive synth
  ip1 = ibasefreq     ;180  ; partial frequencies
  ip2 = ibasefreq*1.5777*icolor
  ip3 = ibasefreq*1.7833*icolor
  ip4 = ibasefreq*1.8444*icolor
  ip5 = ibasefreq*2.2500*icolor
  ip6 = ibasefreq*2.4055*icolor
  ip7 = ibasefreq*2.8722*icolor
  ip8 = ibasefreq*3.1000*icolor
  ip9 = ibasefreq*3.4888*icolor
  ioscnum = 9

  kenv1 expon iamp/ioscnum, idur, .001
  kenv2 expon iamp/ioscnum, idur/3, .001
  kenv3 expon iamp/ioscnum, idur/5, .001

  aosc1 oscil kenv3, ip1
  aosc2 oscil kenv1, ip2
  aosc3 oscil kenv3, ip3
  aosc4 oscil kenv2, ip4
  aosc5 oscil kenv3, ip5
  aosc6 oscil kenv3, ip6
  aosc7 oscil kenv3, ip7
  aosc8 oscil kenv3, ip8
  aosc9 oscil kenv3, ip9

  ; lp-filtered noise
  anoise rand 0.5
  anlp   tone  anoise, isnarecutoff

  ; mix

  asig = (aosc1 + aosc2 + aosc3 + aosc4 + aosc5 + aosc6 + aosc7 + aosc8 + aosc9) + (anlp*isnares)*kenv1  
  apostsig clip asig, 1, iamp

  outs apostsig*ipan, apostsig*(1-ipan)
endin

instr RoBod_Woodblock
  idur       = .2
  iamp       = p3
  ibeaterbf  = (((p4 - 1) * 1180) / 999) + 20 ; convert 1-1000 scale to 20-1200
  iblockbf   = 449
  ibeaterpnum = 2 ; quantity of beater partials modeled
  iblockpnum  = 4 ; quantity of block partials modeled
  ipan        = p5

  ; additive beater synth
  ibeaterp1 = ibeaterbf
  ibeaterp2 = ibeaterbf*3

  kbeaterp1env expon iamp/ibeaterpnum, idur/2, .001
  kbeaterp2env expon iamp/ibeaterpnum, idur/3, .001
 
  abeaterp1osc oscil kbeaterp1env, ibeaterp1
  abeaterp2osc oscil kbeaterp2env, ibeaterp2

  abeatersig = (abeaterp1osc + abeaterp2osc) / ibeaterpnum

  ; additive block synth
  iblockp1 = iblockbf
  iblockp2 = iblockbf*1.42
  iblockp3 = iblockbf*2.11
  iblockp4 = iblockbf*2.47

  kblockp1env expon iamp/iblockpnum, idur, .001
  kblockp2env expon iamp/iblockpnum, idur/2, .001
  kblockp3env expon iamp/iblockpnum, idur/2, .001
  kblockp4env expon iamp/iblockpnum, idur/3, .001

  ablockp1osc oscil kblockp1env, iblockp1
  ablockp2osc oscil kblockp2env, iblockp2
  ablockp3osc oscil kblockp3env, iblockp3
  ablockp4osc oscil kblockp4env, iblockp4

  ablocksig = (ablockp1osc + ablockp2osc + ablockp3osc + ablockp4osc) / iblockpnum

  ; mix

  ibeatersigampfac = (((p4 - 1) * (-.7)) / 999) + 1.2 ; convert 1-1000 scale to 1.2-.5
  asig = abeatersig*ibeatersigampfac + ablocksig*3
  apostsig clip asig, 1, iamp

  outs apostsig*ipan, apostsig*(1-ipan)
endin

instr RoBod_HiHat
  idur = p3
  iamp = p4
  ispread = p5 ; from .8 to 3—dark to bright
  ipan = p6
  ienvdur = idur*5.2
  imodindex = (((ispread - .8) * (3 - 5)) / (3 - .8)) + 5 ; varies from 5 at minimum to 3 at maximum with ispread
  imodfreq1 = 1047*ispread
  icarfreq1 = 1481*ispread
  imodamp1  = imodfreq1 * imodindex
  imodfreq2 = 1109*ispread
  icarfreq2 = 1049*ispread
  imodamp2  = imodfreq2 * imodindex
  imodfreq3 = 1175*ispread
  icarfreq3 = 1480*ispread
  imodamp3  = imodfreq3 * imodindex
  ipingdur = ienvdur * .045
  ipingbase = 1000
  irhpbase = 2628

  ; fm signals
  ;   sig1
  amod1 vco2 imodamp1, imodfreq1, 2, .65
  kmod1 downsamp amod1
  acarposc1 oscil imodamp1, icarfreq1 + amod1
  kcarposc1 downsamp acarposc1
  aosc1 vco2 iamp, kcarposc1 + kmod1, 10
  ;   sig2
  amod2 vco2 imodamp2, imodfreq2, 2, .65
  kmod2 downsamp amod2
  acarposc2 oscil imodamp2, icarfreq2 + amod2
  kcarposc2 downsamp acarposc2
  aosc2 vco2 iamp, kcarposc2 + kmod2, 10
  ;   sig3
  amod3 vco2 imodamp3, imodfreq3, 2, .65
  kmod3 downsamp amod3
  acarposc3 oscil imodamp3, icarfreq3 + amod3
  kcarposc3 downsamp acarposc3
  aosc3 vco2 iamp, kcarposc3 + kmod3, 10
  ;   combination
  aosc = (aosc1 + aosc2 + aosc3) / 3

  ; initial cymbal 'ping' filter
  apingdec expseg 20000-ipingbase, ipingdur, 0.0001
  aping butterbp aosc, ipingbase, apingdec 

  ; rest of cymbal filter
  arestenv expseg irhpbase, ipingdur, 20000, ienvdur - (ipingdur), irhpbase
  arest butterhp aosc, arestenv

  asig = (aping * .45) + (arest * .55)
  apostsig clip asig, 1, iamp

  ; overall env
  aoverenv expseg iamp, idur, .0001

  outs (apostsig*ipan)*aoverenv, (apostsig*(1-ipan))*aoverenv
endin

instr RoBod_Ride
  idur = p3
  iamp = p4
  ispread = p5 ; from .8 to 3—dark to bright
  ipan = p6
  ienvdur = idur*5
  imodindex = 6
  imodfreq1 = 505*ispread
  icarfreq1 = 834*ispread
  imodamp1  = imodfreq1 * imodindex
  imodfreq2 = 452*ispread
  icarfreq2 = 649*ispread
  imodamp2  = imodfreq2 * imodindex
  imodfreq3 = 568*ispread
  icarfreq3 = 894*ispread
  imodamp3  = imodfreq3 * imodindex
  ipingdur = ienvdur * .05
  ipingbase = 2000
  irhpbase = 4000

  ; fm signals
  ;   sig1
  amod1 vco2 imodamp1, imodfreq1, 2, .65
  kmod1 downsamp amod1
  acarposc1 oscil imodamp1, icarfreq1 + amod1
  kcarposc1 downsamp acarposc1
  aosc1 vco2 iamp, kcarposc1 + kmod1, 10
  ;   sig2
  amod2 vco2 imodamp2, imodfreq2, 2, .65
  kmod2 downsamp amod2
  acarposc2 oscil imodamp2, icarfreq2 + amod2
  kcarposc2 downsamp acarposc2
  aosc2 vco2 iamp, kcarposc2 + kmod2, 10
  ;   sig3
  amod3 vco2 imodamp3, imodfreq3, 2, .65
  kmod3 downsamp amod3
  acarposc3 oscil imodamp3, icarfreq3 + amod3
  kcarposc3 downsamp acarposc3
  aosc3 vco2 iamp, kcarposc3 + kmod3, 10
  ;   combination
  aosc = (aosc1 + aosc2 + aosc3) / 3

  ; initial cymbal 'ping' filter
  apingdec expseg 20000-ipingbase, ipingdur, 0.0001
  aping butterbp aosc, ipingbase, apingdec 

  ; rest of cymbal filter
  arestenv expseg irhpbase, ipingdur, 20000, ienvdur - (ipingdur), irhpbase
  arest butterhp aosc, arestenv

  asig = (aping * .33) + (arest * .66)
  apostsig clip asig, 1, iamp

  ; overall env
  aoverenv expseg iamp, idur, .0001

  outs (apostsig*ipan)*aoverenv, (apostsig*(1-ipan))*aoverenv
endin

instr RoBod_Crash
  idur = p3
  iamp = p4
  ispread = p5 ; from .8 to 3—dark to bright
  imodindex = p6
  ipan = p7
  ienvdur = idur*8
;  imodindex = (((ispread - .8) * (3 - 5)) / (3 - .8)) + 5 ; varies from 5 at minimum to 3 at maximum with ispread
  imodfreq1 = 1347*ispread
  icarfreq1 = 1681*ispread
  imodamp1  = imodfreq1 * imodindex
  imodfreq2 = 1309*ispread
  icarfreq2 = 1349*ispread
  imodamp2  = imodfreq2 * imodindex
  imodfreq3 = 1375*ispread
  icarfreq3 = 1780*ispread
  imodamp3  = imodfreq3 * imodindex
  imodfreq4 = 828*ispread
  icarfreq4 = 980*ispread
  imodamp4  = imodfreq4 * imodindex
  ipingdur = ienvdur * .09
  ipingbase = 4500*ispread
  irhpbase = 1828*ispread

  ; fm signals
  ;   sig1
  amod1 vco2 imodamp1, imodfreq1, 2, .65
  kmod1 downsamp amod1
  acarposc1 oscil imodamp1, icarfreq1 + amod1
  kcarposc1 downsamp acarposc1
  aosc1 vco2 iamp, kcarposc1 + kmod1, 10
  ;   sig2
  amod2 vco2 imodamp2, imodfreq2, 2, .65
  kmod2 downsamp amod2
  acarposc2 oscil imodamp2, icarfreq2 + amod2
  kcarposc2 downsamp acarposc2
  aosc2 vco2 iamp, kcarposc2 + kmod2, 10
  ;   sig3
  amod3 vco2 imodamp3, imodfreq3, 2, .65
  kmod3 downsamp amod3
  acarposc3 oscil imodamp3, icarfreq3 + amod3
  kcarposc3 downsamp acarposc3
  aosc3 vco2 iamp, kcarposc3 + kmod3, 10
  ;   sig4
  amod4 vco2 imodamp4, imodfreq4, 2, .65
  kmod4 downsamp amod4
  acarposc4 oscil imodamp4, icarfreq4 + amod4
  kcarposc4 downsamp acarposc4
  aosc4 vco2 iamp, kcarposc4 + kmod4, 10
  ;   combination
  aosc = (aosc1 + aosc2 + aosc3 + aosc4) / 4

  ; initial cymbal 'ping' filter
  apingdec expseg 20000-ipingbase+2000, ipingdur, 0.0001
  aping butterbp aosc, ipingbase, apingdec 

  ; rest of cymbal filter
  arestenv expseg irhpbase, ipingdur, 20000, .1, 10000, ienvdur - (ipingdur), irhpbase
  arest butterhp aosc, arestenv

  asig = (aping * .25) + (arest * .55) + (aosc * .3)
  apostsig clip asig, 1, iamp

  ; overall env
  aoverenv expseg iamp, idur, .0001

  outs (apostsig*ipan)*aoverenv, (apostsig*(1-ipan))*aoverenv
endin

</CsInstruments>
; ==============================================
<CsScore>
t 0 130
i "RoBod_Crash" 0     12.5 .8 .7  1.8 .5
i "RoBod_Crash" 8     12.5 .8 .77 1.8 .5
i "RoBod_Crash" 16    12.5 .8 .7  3   .5
i "RoBod_Crash" 24    12.5 .8 .77 3   .5
;i "RoBod" 0     1 34 50
;i "RoBod" 2     1 34 50
;i "RoBod" 3     1 34 50
e
</CsScore>
</CsoundSynthesizer>

