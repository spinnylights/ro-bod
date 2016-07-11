<CsoundSynthesizer>
<CsOptions>
-odac
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

  #define MIDI_MAX_VEL #127#
  
  ; kick params
  ikickdur          = .20
  ikickbasefreq     = 45  ; 20-60ish conventional
  ikicknoiseamt     = .05
  ikickcolor        = 14.2  ; low values conventional, high values strange
  ikickpitchreduct  = .7  ; <1 conventional, 0 illegal
  ikickdecmethod    = 0   ; 0 = linear, 1 = exponential
  
  ; snare params
  isnaredur         = .3
  isnarebasefreq    = 180
  isnarecolor       = 1
  isnaresnares      = 2.25
  isnaresnarecutoff = 9000

  ; woodblock params
  iwoodbcolor = 700
  
  ivel    = p5
  iamp    = ivel / $MIDI_MAX_VEL ; convert midi velocity to 0-1 scale

  imidi_n = p4

  if     (imidi_n == $KICK_MIDI_N) then
    event_i "i", "RoBod_Kick", 0, ikickdur, iamp, ikickbasefreq, ikicknoiseamt, ikickdecmethod, ikickcolor, ikickpitchreduct
  elseif (imidi_n == $SNARE_MIDI_N) then
    event_i "i", "RoBod_Snare", 0, isnaredur, iamp, isnarebasefreq, isnarecolor, isnaresnares, isnaresnarecutoff
  elseif (imidi_n == $WOODBLOCK_MIDI_N) then
    event_i "i", "RoBod_Woodblock", 0, iamp, iwoodbcolor
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

  outs apostsig, apostsig
endin

instr RoBod_Snare
  idur         = p3
  iamp         = p4
  ibasefreq    = p5
  icolor       = p6
  isnares      = p7
  isnarecutoff = p8

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

  outs apostsig, apostsig
endin

instr RoBod_Woodblock
  idur       = .2
  iamp       = p3
  ibeaterbf  = (((p4 - 1) * 1180) / 999) + 20 ; convert 1-1000 scale to 20-1200
  iblockbf   = 449
  ibeaterpnum = 2 ; quantity of beater partials modeled
  iblockpnum  = 4 ; quantity of block partials modeled

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

  outs apostsig, apostsig
endin

</CsInstruments>
; ==============================================
<CsScore>
;i            s          d       n   v
i "RoBod"     0.0000     0.7479  41  60
i "RoBod"     0.7500     0.1229  38  80
i "RoBod"     0.8750     0.1229  38  80
i "RoBod"     1.0000     0.4979  37  90
i "RoBod"     1.5000     0.4979  38  80
i "RoBod"     2.0000     0.7479  41  60
i "RoBod"     2.7500     0.1229  38  80
i "RoBod"     2.8750     0.1229  38  80
i "RoBod"     3.0000     0.4979  37  90
i "RoBod"     3.5000     0.2479  37  90
i "RoBod"     3.7500     0.2479  37  80
e
</CsScore>
</CsoundSynthesizer>

