# Ambisonic Audio

Thanks to PyDub, the script take an audio source (mono or stereo), split the audio in several parts (each part has a duration of 0.2 sec) then put in overlay the same audio track, but with an inverse phase.

Then we can merge the parts in a single audio tracks by panning each part of 5 degree angle (this make the 360 effects).