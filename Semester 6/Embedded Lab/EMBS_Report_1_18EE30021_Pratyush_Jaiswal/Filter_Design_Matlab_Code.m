clear;
fs = 48000;
T = 0.01;
ts = 1/fs;
t = 0:ts:T;
f1 = 500;
f2 = 18000;
% Input Signal
x = 1*sin(2*pi*f1*t)+0.1*sin(2*pi*f2*t);
newx=normalize(x,'range',[0,1]);
newx2 = ceil(127*newx);
figure(1);
plot(t(1:50),newx2(1:50));
hold
% Filter Output with fixed point filter arithmetic coefficients
quant_coeffs = [0.0234375000000000,0.101562500000000,0.226562500000000,0.289062500000000,0.226562500000000,0.101562500000000,0.0234375000000000];
y = filter(quant_coeffs,1,newx2);
plot(t(1:50),y(1:50),"r");
title("Original Output");
% y1 = ["01", "08","17","2b","3c","45","4a","4e","52","55","59","5c","5f","62","65","68","6a","6d","6f","71","72","74","75","76","77","78","78","78","78","78","77","77","75","74","73","71","6f","6c","6a","68","65","62","5f","5c","58","55","51","4e","4a","46"];
% output = hex2dec(y1);
% Filtered Output from the Serial Communication with Filter Code
output= [43, 60, 69, 74, 78, 82, 85, 89, 92, 95, 98, 101, 104, 106, 109, 111, 113, 114, 116, 117, 118, 119, 120, 120, 120, 120, 120, 119, 119, 117, 116, 115, 113, 111, 108, 106, 104, 101, 98, 95, 92, 88, 85, 82, 78, 73, 68, 62];
figure(2);
plot(t(1:50),newx2(1:50));
hold
plot(t(3:50),output);
title("Atmel Generated Output");