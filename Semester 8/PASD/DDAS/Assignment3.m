%% System Parameters
clear all;
clc;
R=2.4;
Tp=20;
Kp=120;
Tt=0.30;
Tg=0.08;
T=0.005;    % Sampling time
simTime = 4000;

%% Part 1: Determining optimal Ki by minimizing cost J

% Continuous System State Space
A = [-1/Tp  Kp/Tp   0;
        0   -1/Tt   1/Tt;
     -1/(R*Tg) 0    -1/Tg];
B = [0; 0; 1/Tg];
Gamma= [-Kp/Tp; 0; 0];

% Discrete System State Space
phi = expm(A*T);
psi = (expm(A*T)-eye(size(A)))*(A\B);
gamma = (expm(A*T)-eye(size(A)))*(A\Gamma);

J_hist = [];                % Store cost J for each Ki
Kvals = -0.05:-0.001:-0.7;   % Range of Ki

p = 0.01;       % Perturbation

for Ki = Kvals
    X = zeros(3, 1);    % Initialize state
    U = 0;              % Initialize control input
    u2 = 0;             % Initialize integral input
    J = 0;              % Cost
    d = 0;              % Previous X(1,1) for differential input
    kp = 0;             % Proportional gain
    Kd = 0;             % Differential gain
    for i=1:simTime
        X = phi*X + psi*U + gamma*p;
        u1 = kp*X(1,1);
        u2 = u2 + T*Ki*X(1,1);
        u3 = Kd*(X(1,1)-d)/T;
        d = X(1,1);
        U = u1+u2+u3;
        J = J + T*X(1,1)*X(1,1);
    end
    J_hist = [J_hist; J];
end
[Jmin, minidx] = min(J_hist);
disp("Min J:")
disp(Jmin)
disp("Optimum Ki by minimizing cost J for Kp'=0,Kd=0:")
Ki = Kvals(minidx) 

figure(1)
yyaxis left;
plot(Kvals', J_hist, 'LineWidth',2.0)
ylabel("Cost J")
yyaxis right;
plot(Kvals', log(J_hist), 'LineWidth',2.0)
ylabel("log(Cost J)")
xlabel("Ki")
title("Cost J vs Ki for Kp'=0, Kd=0")

%% Simulation with optimum Ki

X = zeros(3, 1);    % Initialize state
U = 0;              % Initialize control input
u2 = 0;             % Initialize integral input
d = 0;              % Previous X(1,1) for differential input
kp = 0;             % Proportional gain
Kd = 0;             % Differential gain
X_hist = [X'];
for i=1:simTime
    X = phi*X + psi*U + gamma*p;
    u1 = kp*X(1,1);
    u2 = u2 + T*Ki*X(1,1);
    u3 = Kd*(X(1,1)-d)/T;
    d = X(1,1);
    U = u1+u2+u3;
    X_hist = [X_hist; X'];
end

Tvals = 0:T:(simTime*T);

% Run Simulink Simulation and obtain signal values
SimData = sim('sim_assignment2');
Tvals_sim = SimData.ScopeData.time;
x1_sim=SimData.ScopeData.signals(1).values;
x2_sim=SimData.ScopeData.signals(2).values;
x3_sim=SimData.ScopeData.signals(3).values;

figure(2)
hold on;
plot(Tvals', X_hist, 'LineWidth',2.0);
plot(Tvals_sim, x1_sim, '--', Tvals_sim, x2_sim, '--', Tvals_sim, x3_sim, '--', 'LineWidth',2.0)
xlabel("Time (s)");
ylabel("X");
title("Comparison of Simulation in MATLAB and Simulink (kp=Kd=0, Ki optimized)");
legend("X1","X2","X3","X1 simulink","X2 simulink","X3 simulink");
hold off;

%% Part 2: Determining optimum Ki, Kd by minimizing the maximum Eigen value of A
kp = 0;
Kd = 0;
Eig_hist = [];
Kvals = -1:0.001:1;
for Ki = Kvals
    A = [-1/Tp              Kp/Tp                                       0               0;
         0                  -1/Tt                                       1/Tt            0;
         -1/(R*Tg)          0                                           -1/Tg           1/Tg;
         (-kp/Tp+Ki+Kd/Tp^2) (kp*Kp/Tp - Kd*Kp/Tp^2 - Kd*Kp/(Tp*Tt))   Kd*Kp/(Tp*Tt)     0];
    Eig = max(real(eig(A)));
    Eig_hist = [Eig_hist; Eig];
end
[Eigmin, minidx] = min(Eig_hist);

figure(3)
plot(Kvals', Eig_hist, 'LineWidth',2.0);
xlabel("Ki");
ylabel("Maximum Eigen Value of A");
title("Maximum Eigen value vs Ki");

disp("Optimum Ki obtained via minimization of maximum Eigen Value of A:")
Ki = Kvals(minidx)

Eig_hist = [];
Kvals = -0.5:0.001:0.5;
for Kd = Kvals
    A = [-1/Tp              Kp/Tp                                       0               0;
         0                  -1/Tt                                       1/Tt            0;
         -1/(R*Tg)          0                                           -1/Tg           1/Tg;
         (-kp/Tp+Ki+Kd/Tp^2) (kp*Kp/Tp - Kd*Kp/Tp^2 - Kd*Kp/(Tp*Tt))   Kd*Kp/(Tp*Tt)   0];
    Eig = max(real(eig(A)));
    Eig_hist = [Eig_hist; Eig];
end

[Eigmin, minidx] = min(Eig_hist);

figure(4)
plot(Kvals', Eig_hist, 'LineWidth',2.0);
xlabel("Kd");
ylabel("Maximum Eigen Value of A");
title("Maximum Eigen value vs Kd");

disp("Optimum Kd obtained via minimization of maximum Eigen Value of A:")
Kdmin = Kvals(minidx);

%% Simulate with only optimum Ki

Kd = 0;
X = zeros(3, 1);    % Initialize state
U = 0;              % Initialize control input
u2 = 0;             % Initialize integral input
d = 0;              % Previous X(1,1) for differential input
kp = 0;             % Proportional gain
X_hist = [X'];
for i=1:simTime
    X = phi*X + psi*U + gamma*p;
    u1 = kp*X(1,1);
    u2 = u2 + T*Ki*X(1,1);
    u3 = Kd*(X(1,1)-d)/T;
    d = X(1,1);
    U = u1+u2+u3;
    X_hist = [X_hist; X'];
end

Tvals = 0:T:(simTime*T);

% Run Simulink Simulation and obtain signal values
SimData = sim('sim_assignment2');
Tvals_sim = SimData.ScopeData.time;
x1_sim=SimData.ScopeData.signals(1).values;
x2_sim=SimData.ScopeData.signals(2).values;
x3_sim=SimData.ScopeData.signals(3).values;

figure(5)
hold on;
plot(Tvals', X_hist, 'LineWidth',2.0);
plot(Tvals_sim, x1_sim, '--', Tvals_sim, x2_sim, '--', Tvals_sim, x3_sim, '--', 'LineWidth',2.0)
xlabel("Time (s)");
ylabel("X");
title("Comparison of Simulation in MATLAB and Simulink (kp=Kd=0, Ki optimized using Eigen Value Method))");
legend("X1","X2","X3","X1 simulink","X2 simulink","X3 simulink");
hold off;

%% Simulate with optimum Ki and Kd

Kd = Kdmin
X = zeros(3, 1);    % Initialize state
U = 0;              % Initialize control input
u2 = 0;             % Initialize integral input
d = 0;              % Previous X(1,1) for differential input
kp = 0;             % Proportional gain
X_hist = [X'];
for i=1:simTime
    X = phi*X + psi*U + gamma*p;
    u1 = kp*X(1,1);
    u2 = u2 + T*Ki*X(1,1);
    u3 = Kd*(X(1,1)-d)/T;
    d = X(1,1);
    U = u1+u2+u3;
    X_hist = [X_hist; X'];
end

Tvals = 0:T:(simTime*T);

% Run Simulink Simulation and obtain signal values
SimData = sim('sim_assignment2');
Tvals_sim = SimData.ScopeData.time;
x1_sim=SimData.ScopeData.signals(1).values;
x2_sim=SimData.ScopeData.signals(2).values;
x3_sim=SimData.ScopeData.signals(3).values;

figure(6)
hold on;
plot(Tvals', X_hist, 'LineWidth',2.0);
plot(Tvals_sim, x1_sim, '--', Tvals_sim, x2_sim, '--', Tvals_sim, x3_sim, '--', 'LineWidth',2.0)
xlabel("Time (s)");
ylabel("X");
title("Comparison of Simulation in MATLAB and Simulink (kp=0, Ki&Kd optimized using Eigen Value Method)");
legend("X1","X2","X3","X1 simulink","X2 simulink","X3 simulink");
hold off;