clear all;
Fs = 16000;
fcomb = [[1500 1550 1600 1650 ],[1500 1550 1600 1650 ]+500,[1500 1550 1600 1650 ]+1000,[1500 1550 1600 1650 ]+1500];
mags = [[1 0 1],[0 1],[0 1],[0 1]];
dev = [[0.5 0.1 0.5],[0.1 0.1],[0.1 0.1],[0.1 0.1]];
[n,Wn,beta,ftype] = kaiserord(fcomb,mags,dev,Fs);
hh = fir1(128,Wn,ftype,kaiser(128+1,beta),'noscale');
h_fixed=fi(hh,1,16,8);
file1=fopen('Filter Co-efficients from MATLAB.txt', 'w');
for i=1:1:length(h_fixed)
    h=h_fixed(i);
    if i<length(h_fixed)
        fprintf(file1, '0x%s, ', hex(h));
    else
        fprintf(file1, '0x%s', hex(h));
    end
end
figure(1)
freqz(hh, 1, 2^20, Fs)
hold on
sig = audioread('Mixed.wav');

sig_fixed=fi(sig, 1, 16, 8);
file2=fopen('Input Signal Data from MATLAB.txt', 'w');
for i=30000:30500
    si=sig_fixed(i);
    if i<30500
        fprintf(file2, '0x%s, ', hex(si));
    else
        fprintf(file2, '0x%s', hex(si));
    end
end
fclose(file2);

figure(2);
plot(sig)
ot = filter(hh, [1], sig);
hold on 
plot(ot)
legend(["original" "filtered"])

save mixed.mat sig
save filtered.mat ot
sound(ot,16000)