clear all;

% Zd = readmatrix('Z_histd.txt');
% Zcapd = readmatrix('Zcap_histd.txt');
% Zu = readmatrix('Z_histu.txt');
% Zcapu = readmatrix('Zcap_histu.txt');
% Zr = readmatrix('Z_hist.txt');
% Zcapr = readmatrix('Zcap_hist.txt');
% Zw = readmatrix('Z_histw.txt');
% Zcapw = readmatrix('Zcap_histw.txt');

zcap = readmatrix('Filtered_Data_down1');
z = readmatrix('Raw_Data_down');
t = 0:0.04:20;

a = [];
ae = [];

for i=1:size(zcap, 1)
    a(i, 1) = norm(z(i,:), 2);
    ae(i, 1) = norm(zcap(i,:), 2);
end

t = t(1:size(a,1));

figure
hold on
plot(t, a);
plot(t, ae);
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
title('Kalman Filter Tracking');
legend('Raw Acceleration', 'Kalman Filtered Acceleration', 'FontSize', 12);

% figure
% hold on;
% plot(ad);
% plot(au);
% legend('Magnitude acceleration going down', 'Magnitude acceleration going up');
% hold off;

% mean(a)
% mean(ad)
% mean(au)
% 
% t = 1:0.05:2000;
% t2 = 1:0.02:200;
% residuesd = [];
% residuesu = [];
% residuesr = [];
% for i=1:size(Zd, 1)
%     residuesd = [residuesd; norm(abs(Zd(i,:) - Zcapd(i,:)), 1)];
%     residuesu = [residuesu; norm(abs(Zu(i,:) - Zcapu(i,:)), 1)];
% end
% for i=1:size(Zr, 1)
%     residuesr = [residuesr; norm(abs(Zr(i,:) - Zcapr(i,:)), 1)];
% end
% 
% t = t(1:length(residuesd));
% t2 = t2(1:length(residuesr));

% figure
% plot(t, [Zd(:, 3) Zcapd(:, 3)]);
% legend('Measured down', 'Estimated down');
% 
% figure
% plot(t, [Zu(:, 3) Zcapu(:, 3)]);
% legend('Measured up', 'Estimated u');
% 
% figure
% plot(t2, [Zr(:, 3) Zcapr(:, 3)]);
% legend('Measured run', 'Estimated run');

% figure
% plot(t, residuesd);
% legend('Down');
% 
% figure
% plot(t, residuesu);
% legend('Up');
% 
% figure
% plot(t2, residuesr);
% legend('Running');