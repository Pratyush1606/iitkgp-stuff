%Adding two wav files
%Reading two files
s1  = audioread('voice.wav');
s2  = audioread('Noise.wav');
%len = max(size(s1, 1), size(s2, 1));
len=80000;
%Mixing the two waves with audio more intense than noise
alpha=0.8;
s12 = alpha*s1(1:len, :) + (1-alpha)*s2(1:len, :);
m   = max(abs(s12(:)));
%Normalize the signals
s12 = s12 / m;
%Writing back at 16 KHz
audiowrite('Mixed.wav',s12,16000);
%Reading the audio back again
[y, Fs]=audioread('Mixed.wav');
save audio.mat y
sound(y,Fs)