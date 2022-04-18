close all;
clear all;
clc;

%% Data generation

A = 0.5;    % Amplitude of random process
f0 = 0.05;  % Frequency
w = 2*pi*f0;     % Angular Frequency

n_arr = 1:200;      % Indices over which realization is recorded
N = numel(n_arr);

y = rand_proc(A, w, n_arr); % Desired signal

figure(1)
hold on;
plot(y)
title('Random process with uniformly distributed phase')
ylabel('Amplitude')
xlabel('Index')
hold off;

%% Add noise

var = 0.5;      % Noise variance

v = sqrt(var)*randn(1, N);  % Gaussian noise

x = y + v;  % Signal + Noise

figure(2)
hold on;
plot(x)
title('Random process + AWGN')
ylabel('Amplitude')
xlabel('Index')
hold off;

err = rms(x - y)^2;
disp("Initial mean squared error = "+num2str(err));

%% Weiner-Hopf Filter

filter_orders = [10 15 20 40];

err_mem = [];

for M = filter_orders
    
    w0 = wiener_filter(A, var, w, M, M);    % Obtain optimum weights (function defined below)
    
    % Convolution with filter coefficients
    y_hat = zeros(1, N);
    for n=1:N
        if n < M
            x_w = [zeros(1, M-n), x(1:n)].'; % Window of x
        else
            x_w = x(n-M+1:n).'; % Window of x
        end
        y_hat(n) = conj(w0)'*flipud(x_w);   % y_hat(n) = sum over k(wH(k) * x(n-k))
    end
    
    % Compute error signal
    err_sig = y - y_hat;
  
    error = rms(y(M:N)-y_hat(M:N))^2;
    err_mem = [err_mem; error];
    disp("Mean squared error with filter order "+num2str(M)+" = "+num2str(error));

    figure
    hold on;
    plot(y_hat);
    title("Filter Output for Filter Order = "+num2str(M));
    ylabel('Amplitude');
    xlabel('Index');
    hold off;
    
    figure
    hold on;
    plot(err_sig);
    title("Predicted Error for Filter Order = "+num2str(M));
    ylabel('Amplitude');
    xlabel('Index');
    hold off;
    
end

figure
hold on
plot(filter_orders, err_mem, 'ro-', 'LineWidth', 2)
title('Mean Squared Error vs Filter Order')
xlabel('Filter Order')
ylabel('Mean Squared Error')
hold off

%% Functions

function y = rand_proc(A, w0, n_arr)
    % Generate random process
    N = numel(n_arr);
    phi = 2*pi*rand();      % Uniformly distributed phase
    y = A*cos(n_arr.*w0+ones(1,N).*phi);
end

function w = wiener_filter(A, var, w, M, N)
    % Generate optimum Wiener filter weights by solving Wiener-Hopf matrix equation
    
    % Obtain the theoretical autocorrelation
    auto = [0.5*(abs(A)^2) + var, zeros(1, N-1)];    
    for i=2:N
        auto(1, i) = 0.5*cos((i-1)*w)*(abs(A)^2);
    end
    
    % Obtain the theoretical crosscorrelation
    cross = [0.5*(abs(A)^2), zeros(1, N-1)];
    for i=2:N
        cross(1, i) = 0.5*cos((1-i)*w)*(abs(A)^2);
    end

    p = cross(N-(M-1):N);   % Obtain top M values of crosscorrelation
    toeplitz_row = auto(N-(M-1):N);     % Obtain top M values of autocorrelation
    
    R = toeplitz(toeplitz_row);     % Generate toeplitz matrix
    
    w = R\p.';   % Obtain optimum Weiner-Hopf filter
end




