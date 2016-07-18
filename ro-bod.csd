<CsoundSynthesizer>
<CsOptions>
;-odac
-o ro-bod_demo.wav --format=wav
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
  
  ivel    = p5
  iamp    = ivel / $MIDI_MAX_VEL ; convert midi velocity to 0-1 scale

  imidi_n = p4

  if     (imidi_n == $KICK_MIDI_N) then
    event_i "i", "RoBod_Kick", 0, ikickdur, iamp, ikickbasefreq, ikicknoiseamt, ikickdecmethod, ikickcolor, ikickpitchreduct, ikickpan
  elseif (imidi_n == $SNARE_MIDI_N) then
    event_i "i", "RoBod_Snare", 0, isnaredur, iamp, isnarebasefreq, isnarecolor, isnaresnares, isnaresnarecutoff, isnarepan
  elseif (imidi_n == $WOODBLOCK_MIDI_N) then
    event_i "i", "RoBod_Woodblock", 0, iamp, iwoodbcolor, iwoodbpan
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

</CsInstruments>
; ==============================================
<CsScore>
t 0 120
;i            s          d       n   v
i "RoBod"     0.0000     0.7479  41  62
i "RoBod"     0.7500     0.1229  38  79
i "RoBod"     0.8750     0.1229  38  78
i "RoBod"     1.0000     0.4979  37  91
i "RoBod"     1.5000     0.4979  38  81
i "RoBod"     2.0000     0.7479  41  62
i "RoBod"     2.7500     0.1229  38  79
i "RoBod"     2.8750     0.1229  38  78
i "RoBod"     3.0000     0.2479  37  89
i "RoBod"     3.2500     0.2479  38  79
i "RoBod"     3.5000     0.2479  38  80
i "RoBod"     3.7500     0.2479  37  89
i "RoBod"     4.0000     0.7479  41  61
i "RoBod"     4.7500     0.1229  38  78
i "RoBod"     4.8750     0.1229  38  78
i "RoBod"     5.0000     0.2479  37  89
i "RoBod"     5.7500     0.2479  37  89
i "RoBod"     6.0000     0.7479  41  62
i "RoBod"     7.0000     0.2479  37  90
i "RoBod"     7.2500     0.1229  38  88
i "RoBod"     7.3750     0.1229  38  88
i "RoBod"     7.5000     0.2479  38  89
i "RoBod"     7.7500     0.2479  38  89
i "RoBod"     8.0000     0.7479  41  62
i "RoBod"     8.7500     0.1229  38  78
i "RoBod"     8.8750     0.1229  38  78
i "RoBod"     9.0000     0.4979  37  92
i "RoBod"     9.5000     0.4979  38  81
i "RoBod"    10.0000     0.7479  41  61
i "RoBod"    10.7500     0.1229  38  78
i "RoBod"    10.8750     0.1229  38  78
i "RoBod"    11.0000     0.2479  37  91
i "RoBod"    11.2500     0.2479  38  79
i "RoBod"    11.5000     0.2479  38  81
i "RoBod"    11.7500     0.2479  37  89
i "RoBod"    12.0000     0.7479  41  62
i "RoBod"    12.7500     0.1229  38  79
i "RoBod"    12.8750     0.1229  38  78
i "RoBod"    13.0000     0.2479  37  89
i "RoBod"    13.2500     0.1229  37  88
i "RoBod"    13.3750     0.1229  37  88
i "RoBod"    13.5000     0.1229  38  79
i "RoBod"    13.7500     0.1229  37  88
i "RoBod"    13.8750     0.1229  37  88
i "RoBod"    14.0000     0.7479  41  61
i "RoBod"    14.7500     0.1229  38  79
i "RoBod"    14.8750     0.1229  38  78
i "RoBod"    15.0000     0.4979  37  90
i "RoBod"    15.5000     0.1229  38  79
i "RoBod"    15.7500     0.1229  38  78
i "RoBod"    15.8750     0.1229  37  88
i "RoBod"    16.0000     0.7479  41  63
i "RoBod"    16.7500     0.1229  38  78
i "RoBod"    16.8750     0.1229  38  78
i "RoBod"    17.0000     0.4979  37  90
i "RoBod"    17.5000     0.4979  38  80
i "RoBod"    18.0000     0.7479  41  62
i "RoBod"    18.7500     0.1229  38  78
i "RoBod"    18.8750     0.1229  38  78
i "RoBod"    19.0000     0.4979  37  90
i "RoBod"    19.5000     0.4979  38  80
i "RoBod"    20.0000     0.7479  41  62
i "RoBod"    20.7500     0.1229  38  78
i "RoBod"    20.8750     0.1229  38  78
i "RoBod"    21.0000     0.4979  37  90
i "RoBod"    21.5000     0.4979  38  80
i "RoBod"    22.0000     0.7479  41  62
i "RoBod"    23.0000     0.4979  37  90
i "RoBod"    23.5000     0.2479  38  79
i "RoBod"    23.7500     0.2479  38  79
i "RoBod"    24.0000     0.7479  41  62
i "RoBod"    24.7500     0.1229  38  78
i "RoBod"    24.8750     0.1229  38  78
i "RoBod"    25.0000     0.4979  37  90
i "RoBod"    25.5000     0.4979  38  80
i "RoBod"    26.0000     0.7479  41  62
i "RoBod"    26.7500     0.1229  38  78
i "RoBod"    26.8750     0.1229  38  78
i "RoBod"    27.0000     0.4979  37  90
i "RoBod"    27.5000     0.4979  38  80
i "RoBod"    28.0000     0.7479  41  62
i "RoBod"    28.7500     0.1229  38  78
i "RoBod"    28.8750     0.1229  38  78
i "RoBod"    29.0000     0.4979  37  90
i "RoBod"    29.5000     0.4979  38  80
i "RoBod"    30.0000     0.7479  41  62
i "RoBod"    31.0000     0.4979  37  90
i "RoBod"    31.5000     0.2479  38  79
i "RoBod"    31.7500     0.2479  38  79
i "RoBod"    32.0000     0.7479  41  62
i "RoBod"    32.7500     0.1229  38  78
i "RoBod"    32.8750     0.1229  38  78
i "RoBod"    33.0000     0.4979  37  90
i "RoBod"    33.5000     0.4979  38  80
i "RoBod"    34.0000     0.7479  41  62
i "RoBod"    34.7500     0.1229  38  78
i "RoBod"    34.8750     0.1229  38  78
i "RoBod"    35.0000     0.4979  37  90
i "RoBod"    35.5000     0.4979  38  80
i "RoBod"    36.0000     0.7479  41  62
i "RoBod"    36.7500     0.1229  38  78
i "RoBod"    36.8750     0.1229  38  78
i "RoBod"    37.0000     0.4979  37  90
i "RoBod"    37.5000     0.4979  38  80
i "RoBod"    38.0000     0.7479  41  62
i "RoBod"    39.0000     0.4979  37  90
i "RoBod"    39.5000     0.2479  38  79
i "RoBod"    39.7500     0.2479  38  79
i "RoBod"    40.0000     0.7479  41  62
i "RoBod"    40.7500     0.1229  38  78
i "RoBod"    40.8750     0.1229  38  78
i "RoBod"    41.0000     0.4979  37  90
i "RoBod"    41.5000     0.4979  38  80
i "RoBod"    42.0000     0.7479  41  62
i "RoBod"    42.7500     0.1229  38  78
i "RoBod"    42.8750     0.1229  38  78
i "RoBod"    43.0000     0.4979  37  90
i "RoBod"    43.5000     0.4979  38  80
i "RoBod"    44.0000     0.7479  41  62
i "RoBod"    44.7500     0.1229  38  78
i "RoBod"    44.8750     0.1229  38  78
i "RoBod"    45.0000     0.4979  37  90
i "RoBod"    45.5000     0.4979  38  80
i "RoBod"    46.0000     0.7479  41  62
i "RoBod"    47.0000     0.4979  37  90
i "RoBod"    47.5000     0.2479  38  79
i "RoBod"    47.7500     0.2479  38  79
i "RoBod"    48.0000     0.7479  41  62
i "RoBod"    48.7500     0.1229  38  78
i "RoBod"    48.8750     0.1229  38  78
i "RoBod"    49.0000     0.4979  37  90
i "RoBod"    49.5000     0.4979  38  80
i "RoBod"    50.0000     0.7479  41  62
i "RoBod"    50.7500     0.1229  38  78
i "RoBod"    50.8750     0.1229  38  78
i "RoBod"    51.0000     0.4979  37  90
i "RoBod"    51.5000     0.4979  38  80
i "RoBod"    52.0000     0.7479  41  62
i "RoBod"    52.7500     0.1229  38  78
i "RoBod"    52.8750     0.1229  38  78
i "RoBod"    53.0000     0.4979  37  90
i "RoBod"    53.5000     0.4979  38  80
i "RoBod"    54.0000     0.7479  41  62
i "RoBod"    55.0000     0.4979  37  90
i "RoBod"    55.5000     0.2479  38  79
i "RoBod"    55.7500     0.2479  38  79
i "RoBod"    56.0000     0.7479  41  62
i "RoBod"    56.7500     0.1229  38  78
i "RoBod"    56.8750     0.1229  38  78
i "RoBod"    57.0000     0.4979  37  90
i "RoBod"    57.5000     0.4979  38  80
i "RoBod"    58.0000     0.7479  41  62
i "RoBod"    58.7500     0.1229  38  78
i "RoBod"    58.8750     0.1229  38  78
i "RoBod"    59.0000     0.4979  37  90
i "RoBod"    59.5000     0.4979  38  80
i "RoBod"    60.0000     0.7479  41  62
i "RoBod"    60.7500     0.1229  38  78
i "RoBod"    60.8750     0.1229  38  78
i "RoBod"    61.0000     0.4979  37  90
i "RoBod"    61.5000     0.4979  38  80
i "RoBod"    62.0000     0.7479  37  82
e
</CsScore>
</CsoundSynthesizer>

