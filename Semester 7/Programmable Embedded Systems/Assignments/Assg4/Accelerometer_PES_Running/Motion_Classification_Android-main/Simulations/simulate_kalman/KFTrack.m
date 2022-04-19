% Demo for KF to track motion of a subject

clear all;
close all;
clc;
load walking;
clear m;
N = length(t);

Q = 100*eye(9); % Process noise covariance
% For higher process noise - better tracking (tracks jerks)
% For lower process noise - worse tracking (assumes constant acceleration)
% Process noise is the tolerance level between expected process (eg - const acceleration) and actual process (eg - jerks), Higher noise means more ability to track unexpected process variations

R = 0.1*eye(3);     % Measurement noise covariance
% Increasing measurement noise makes velocity smoother

P = 5*eye(9);   % Initial guess of error covariance matrix
x = randn(9, 1); % Initial values of the states
% positions, velocities, accelerations in x, y, z directions

% Define null matrices to capture the estimates
X = []; 
KK = [];  % Kalman gain
a_m = []; % Acceleration measured 
a_e = []; % Acceleration estimated

tme(1) = t(1);  %time
for n=2:N
    tme(n) = t(n);
    h = tme(n) - tme(n-1); h2 = h^2/2;
    Ph = [1 0 0 h 0 0 h2 0 0
          0 1 0 0 h 0 0 h2 0
          0 0 1 0 0 h 0 0 h2
          0 0 0 1 0 0 h 0 0
          0 0 0 0 1 0 0 h 0
          0 0 0 0 0 1 0 0 h
          0 0 0 0 0 0 1 0 0
          0 0 0 0 0 0 0 1 0
          0 0 0 0 0 0 0 0 1 ];
    H = [0 0 0 0 0 0 1 0 0
         0 0 0 0 0 0 0 1 0
         0 0 0 0 0 0 0 0 1];
     
    % Get the noisy measurements from the sensor
    z = a(n,:)'; % a represents the sensor
    a_m = [a_m; z'];
  
    % Step 1 : Compute Kalman Gain
    K = P*H'*inv(H*P*H' + R);
    KK = [KK; K(:)'];
    
    % Step 2 : Update the estimates
    z_cap = H*x;
    x = x + K*(z-z_cap);    % Update estimate
    a_e = [a_e; z_cap'];    % Estimated acceleration or measurements
    
    X = [X; x(:)'];     % Capture the estimates in X
    
    % Step 3 : Compute the posterior error covariance
    P = (eye(9) - K*H)*P;
    
    % Step 4 : Project ahead
    x = Ph*x;
    P = Ph*P*Ph' + Q;
    
%     plot([a_m(:,1) a_e(:,1)]); shg
%     legend('measurement','estimated')
    
end

figure
plot([a_m(:,2) a_e(:,2)]); shg
legend('measurement','estimated')

residues = abs(a_m(:,2) - a_e(:,2));

figure
plot(residues);

% figure
% plot(X(:,1:3))  % Plot X, Y, Z
% grid on;
% 
% figure
% plot(X(:,4:6));  % Plot velocities
% grid on;



















