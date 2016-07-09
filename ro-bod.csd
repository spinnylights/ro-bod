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
  #define KICK_MIDI_N      #41# ; Assign midi note numbers to drums here
  #define SNARE_MIDI_N     #38#
  #define WOODBLOCK_MIDI_N #37#

  #define MIDI_MAX_VEL #127#
  
  ikickdur      = .1 ; unfortunately drum note durations must be defined here
  isnaredur     = .1
  iwoodblockdur = .1

  ivel    = p5
  iamp    = ivel / $MIDI_MAX_VEL ; convert midi velocity to 0-1 scale

  imidi_n = p4

  if     (imidi_n == $KICK_MIDI_N) then
    event_i "i", "RoBod_Kick", 0, ikickdur, iamp
  elseif (imidi_n == $SNARE_MIDI_N) then
    event_i "i", "RoBod_Snare", 0, isnaredur, iamp
  elseif (imidi_n == $WOODBLOCK_MIDI_N) then
    event_i "i", "RoBod_Woodblock", 0, iwoodblockdur, iamp
  else
    prints "WARNING: midi note number %d does not correspond to a drum instrument\n", imidi_n
  endif
endin

instr RoBod_Kick
  iamp = p4

  asig oscil iamp, 300
  outs asig, asig
endin

instr RoBod_Snare
  iamp = p4

  asig oscil iamp, 400
  outs asig, asig
endin

instr RoBod_Woodblock
  iamp = p4

  asig oscil iamp, 500
  outs asig, asig
endin

</CsInstruments>
; ==============================================
<CsScore>
;i            s          d       n   v
i "RoBod"     0.0000     0.7479  41  80
i "RoBod"     0.7500     0.1229  38  80
i "RoBod"     0.8750     0.1229  38  80
i "RoBod"     1.0000     0.4979  37  80
i "RoBod"     1.5000     0.4979  38  80
i "RoBod"     2.0000     0.7479  41  80
i "RoBod"     2.7500     0.1229  38  80
i "RoBod"     2.8750     0.1229  38  80
i "RoBod"     3.0000     0.4979  37  80
i "RoBod"     3.5000     0.2479  37  80
i "RoBod"     3.7500     0.2479  37  80
e
</CsScore>
</CsoundSynthesizer>

