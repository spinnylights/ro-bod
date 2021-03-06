# Ro-bod

Ro-bod is a synth-based drum machine that provides a wide range of textures while keeping a classic synth drum sound. You might like it if you want synth drums but are getting tired of the 808 and 909.

## Parameters
### Kick
  * __ikickdur:__ The duration of the kick sound. Values around .1–.3 will give conventional results; longer values can be used for strange effects.
  * __ikickbasefreq:__ The base frequency of the drum in hz. 20–60 or so will give conventional results.
  * __ikicknoiseamt:__ The amount of noise mixed into the signal. .01–.06 or so will give conventional results.
  * __ikickcolor:__ The amount of frequency shift applied to the main drum sound in hz. Can change the "color" of the drum from dark to bright to bizarre. Values below 20 or so will give conventional results, though higher values won't necessarily sound weird. The effect of this parameter on the sound depends heavily on the other parameters, particularly the base frequency.
  * __ikickpitchreduct:__ The amount by which the pitch of the drum falls for the duration of the sound. Values below 1 will give conventional results; values above 1 will cause an _increase_ in the pitch which can be used for some fun weirdness.
  * __ikickdecmethod:__ 0 for linear decay, 1 for exponential. Exponential decay often sounds more conventional; linear decay can give a "bigger" kick sound, more like an orchestral bass drum.
  * __ikickpan:__ Panning. 1 is hard left; 0 is hard right; .5 is center.

### Snare
  * __isnaredur:__ The duration of the snare sound. Values around .1–.5 will give conventional results. Longer values will mainly elongate the sound of the snares.
  * __isnarebasefreq:__ The base frequency of the drum in hz. 100–200 or so will give conventional results.
  * __isnarecolor:__ A constant that all the partials of the drum above the base frequency are multiplied by, allowing you to spread or tighten their distribution. Lower values give a darker snare, higher values give a brighter one. Values from .8–1.3 will give conventional results.
  * __isnaresnares:__ The volume of the noise burst used to simulate the sound of the drum snares. Conventional-sounding values will vary depending on the value of `isnaredur`, `isnarensares`, and `isnaresnarecutoff`, but tend to fall in the range of .8–4 or so at most. At long durations, values above ~1.2 or so may sound overly noisy.
  * __isnaresnarecutoff:__ The cutoff frequency for the lowpass filter applied to the noise burst, in hz. Anything from ~2000–~20000 can produce conventional results; lower values give softer snares, higher values give brighter ones. A higher value will result in louder snares, so you may want to adjust `isnaresnares` to compensate.
  * __isnarepan:__ Panning. 1 is hard left; 0 is hard right; .5 is center.

### Hi-hat
  * __ihihatpedal:__ The foot pedal control. .18 is fully closed; 7.8 is fully open.
  * __ihihatcolor:__ .8 is darkest; 3 is brightest.
  * __ihihatpan:__ Panning. 1 is hard left; 0 is hard right; .5 is center.

### Ride
  * __iridedur:__ The duration of the ride sound. 6 to 7.3 gives conventional results. It may be helpful to increase the duration with higher values of `iridecolor` and decrease it with lower values.
  * __iridecolor:__ Dark to bright. 1.8 to 2.6 gives conventional results.
  * __iridepan:__ Panning. 1 is hard left; 0 is hard right; .5 is center.

### Crash
  * __icrashdur:__ The duration of the crash sound. 5 to 6.5 gives conventional results.
  * __icrashcolor1:__ Controls the frequency spread. .7 to .77, dark to bright.
  * __icrashcolor2:__ Controls the modulation index. 1.8 to 3, dark to bright.
  * __icrashpan:__ Panning. 1 is hard left; 0 is hard right; .5 is center.

### Woodblock
  * __iwoodbcolor:__ A number from 1–1000. Controls the "material" of the simulated beater. Low values give a sound like felt; middle values give a sound like wood; high values give a sound like metal.
  * __iwoodbpan:__ Panning. 1 is hard left; 0 is hard right; .5 is center.
