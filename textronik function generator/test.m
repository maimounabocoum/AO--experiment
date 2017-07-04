% test file

time = 0:1/1e3:2;
waveform = chirp(time,100,1,50,'quadratic');
figure;
plot(time,waveform)