# Ro-bod

Ro-bod is a synth-based drum machine that provides a wide range of textures while keeping a classic synth drum sound. You might like it if you want synth drums but are getting tired of the 808 and 909.

## Parameters
### Kick
  * __ikickdur:__ The duration of the kick sound. Values around .1-.3 will give conventional results; longer values can be used for strange effects.
  * __ikickbasefreq:__ The base frequency of the drum in hz. 20-60 or so will give conventional results.
  * __ikicknoiseamt:__ The amount of noise mixed into the signal. .01-.06 or so will give conventional results.
  * __ikickcolor:__ The amount of frequency shift applied to the main drum sound in hz. Can change the "color" of the drum from dark to bright to bizarre. Values below 20 or so will give conventional results, though higher values won't necessarily sound weird. The effect of this parameter on the sound depends heavily on the other parameters, particularly the base frequency.
  * __ikickpitchreduct:__ The amount by which the pitch of the drum falls for the duration of the sound. Values below 1 will give conventional results; values above 1 will cause an _increase_ in the pitch which can be used for some fun weirdness.
  * __ikickdecmethod:__ 0 for linear decay, 1 for exponential. Exponential decay often sounds more conventional; linear decay can give a "bigger" kick sound more like an orchestral bass drum.
