clear all
clc
load notch_50_128
load noisy_signal

yf=filter(h,1,yn);
plot([yn yf]), grid on
shg

% store in hexadecimal for keil
h_fixed=fi(h, 1, 16, 8);
sig_fixed=fi(yn, 1, 16, 8);
file1=fopen('Filter Co-efficients from MATLAB.txt', 'w');
for i=1:1:length(h_fixed)
    h=h_fixed(i);
    if i<length(h_fixed)
        fprintf(file1, '0x%s, ', hex(h));
    else
        fprintf(file1, '0x%s', hex(h));
    end
end
fclose(file1);
file2=fopen('Input Signal Data from MATLAB.txt', 'w');
for i=1:length(sig_fixed)
    si=sig_fixed(i);
    if i<length(sig_fixed)
        fprintf(file2, '0x%s, ', hex(si));
    else
        fprintf(file2, '0x%s', hex(si));
    end
end
fclose(file2);
