t = 0 : 79999;
x1 = 0.2*sin(2*pi*t/10);
sound(x1,16000);
audiowrite('Noise.wav',x1,16000);
%Reading sound file
[y, Fs]=audioread('Noise.wav');
%For hearing your audio file
%sound(y,Fs);
%Getting info for plotting
info = audioinfo('Noise.wav');
t = 0:seconds(1/Fs):seconds(info.Duration);
t = t(1:end-1);
%Plotting the audio signal
plot(t,y)
xlabel('Time')
ylabel('Noise Signal')