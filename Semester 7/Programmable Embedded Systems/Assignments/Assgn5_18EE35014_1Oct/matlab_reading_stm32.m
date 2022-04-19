iplen = 500;
hlen = 33;
oplen = 500;
fileID = fopen('input_keil.bin', 'r');
mat1 = fread(fileID);
fclose(fileID);

signalin = zeros(1, iplen);

for i=1:iplen
    if mat1(2*i) > 127
        signalin(1, i) = mat1(2*i)-256;
        signalin(1, i) = signalin(1, i) + mat1(2*i-1)/256;
    else
        signalin(1, i) = mat1(2*i);
        signalin(1, i) = signalin(1, i) + mat1(2*i-1)/256;
    end
end

fileID = fopen('output.bin', 'r');
mat3 = fread(fileID);
fclose(fileID);


signal = zeros(1, oplen);

for i=1:oplen
    if mat3(2*i) > 127
        signal(1, i) = mat3(2*i)-256;
        signal(1, i) = signal(1, i) + mat3(2*i-1)/256;
    else
        signal(1, i) = mat3(2*i);
        signal(1, i) = signal(1, i) + mat3(2*i-1)/256;
    end
end

figure(1)
hold on;
plot(signalin);
title('Input signal');
hold off;


figure(2)
hold on;
plot(signal);
title('Output signal');
hold off;
