clc;
clear all;

axyzr = readmatrix('Filtered_Data_run.txt');
axyzr2 = readmatrix('Filtered_Data_run2.txt');

axyzw = readmatrix('Filtered_Data_walk.txt');
axyzw2 = readmatrix('Filtered_Data_walk2.txt');

axyzs = readmatrix('Filtered_Data_still.txt');

axyzd = readmatrix('Filtered_Data_down1.txt');
axyzd2 = readmatrix('Filtered_Data_down2.txt');
axyzd3 = readmatrix('Filtered_Data_down3.txt');

axyzu = readmatrix('Filtered_Data_up1.txt');
axyzu2 = readmatrix('Filtered_Data_up2.txt');
axyzu3 = readmatrix('Filtered_Data_up3.txt');

ar = [];
aw = [];
as = [];
ad = [];
au = [];

for i=1:size(axyzr, 1)
    ar = [ar; norm(axyzr(i,:), 2)];
    aw = [aw; norm(axyzw(i,:), 2)];
    as = [as; norm(axyzs(i,:), 2)];
end
for i=1:size(axyzr2, 1)
    ar = [ar; norm(axyzr2(i,:), 2)];
    aw = [aw; norm(axyzw2(i,:), 2)];
end
for i=1:size(axyzd, 1)
    ad = [ad; norm(axyzd(i,:), 2)];
    au = [au; norm(axyzu(i,:), 2)];
end
for i=1:size(axyzd2, 1)
    ad = [ad; norm(axyzd2(i,:), 2)];
    au = [au; norm(axyzu2(i,:), 2)];
end
for i=1:size(axyzd3, 1)
    ad = [ad; norm(axyzd3(i,:), 2)];
    au = [au; norm(axyzu3(i,:), 2)];
end

% ar = ar - mean(ar);
% aw = aw - mean(aw);
% as = as - mean(as);
% ad = ad - mean(ad);
% au = au - mean(au);

XIr = 0:40/100:40;
size(XIr)
[Fr, XIr] = ksdensity(ar, XIr);
[Fw, XIw] = ksdensity(aw, XIr);
[Fs, XIs] = ksdensity(as, XIr);
[Fd, XId] = ksdensity(ad, XIr);
[Fu, XIu] = ksdensity(au, XIr);

Fr = Fr.*(1/sum(Fr));
Fw = Fw.*(1/sum(Fw));
Fs = Fs.*(1/sum(Fs));
Fd = Fd.*(1/sum(Fd));
Fu = Fu.*(1/sum(Fu));

for i=1:size(XIr, 2);
   Fr(i) = Fr(i)+eps;
   Fw(i) = Fw(i)+eps;
   Fs(i) = Fs(i)+eps;
   Fd(i) = Fd(i)+eps;
   Fu(i) = Fu(i)+eps;
   if Fr(i) == 0 | Fw(i) == 0 | Fs(i) == 0 | Fd(i) == 0 | Fu(i) == 0
       disp("Warning");
   end
end

markersize = 10;
linewidth = 1;
fontsize = 18;

figure(1)
hold on
plot(XIr, Fr, 'LineWidth', linewidth ,'MarkerSize',markersize)
plot(XIw, Fw, 'LineWidth', linewidth ,'MarkerSize',markersize)
plot(XIs, Fs, 'LineWidth', linewidth ,'MarkerSize',markersize)
plot(XId, Fd, 'LineWidth', linewidth ,'MarkerSize',markersize)
plot(XIu, Fu, 'LineWidth', linewidth ,'MarkerSize',markersize)
legend('Running', 'Walking', 'Still', 'Going down', 'Going up', 'FontSize', fontsize);
xlabel('Acceleration m/s^2')
ylabel('Probability')
title('Standard Probability Distributions')
hold off

fileID = fopen('ExtractedPDF\Run.txt', 'w');
 for i=1:length(Fr)
     fp = Fr(i);
     fprintf(fileID, "%e, ", fp);
 end
fclose(fileID);

fileID = fopen('ExtractedPDF\Walk.txt', 'w');
 for i=1:length(Fw)
     fp = Fw(i);
     fprintf(fileID, "%e, ", fp);
 end
fclose(fileID);

fileID = fopen('ExtractedPDF\Still.txt', 'w');
 for i=1:length(Fs)
     fp = Fs(i);
     fprintf(fileID, "%e, ", fp);
 end
fclose(fileID);

fileID = fopen('ExtractedPDF\Up.txt', 'w');
 for i=1:length(Fu)
     fp = Fu(i);
     fprintf(fileID, "%e, ", fp);
 end
fclose(fileID);

fileID = fopen('ExtractedPDF\Down.txt', 'w');
 for i=1:length(Fd)
     fp = Fd(i);
     fprintf(fileID, "%e, ", fp);
 end
fclose(fileID);
