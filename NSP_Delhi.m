clear;
clc;
Data_NSP_Delhi;

% Decision variables: X (land-use areas) and slack variables (S_lb, S_ub)
n = length(BT); % Number of land-use types
num_vars = 3 * n; % Total variables (X, S_lb, S_ub)

% Objective function
% Maximize Z = sum(BT .* X) => Minimize -sum(BT .* X) + lambda * sum(S_lb + S_ub)
f = [-BT, lambda * ones(1, 2 * n)]; % Include penalties for slack variables

% Inequality constraints: A * X <= b
% Pollution constraints (TN and TP)
A = [EC_N, zeros(1, 2 * n); % TN constraint
     EC_P, zeros(1, 2 * n)]; % TP constraint
b = [SD_N; SD_P];

% Lower and upper bound constraints using slack variables
% X + S_lb >= LB  -> -X - S_lb <= -LB
A_lb = [-eye(n), -eye(n), zeros(n)]; % Coefficients for X and S_lb
b_lb = -LB';

% X - S_ub <= UB
A_ub = [eye(n), zeros(n), -eye(n)]; % Coefficients for X and S_ub
b_ub = UB';

%Total area Constraint i.e. sum(X)<=TA
Area_Cons = [ones(1, n), zeros(1, 2 * n)]; % X variables only
b_Area = TA;

% Combine inequality constraints
A = [Area_Cons; A_lb; A_ub];
b = [b_Area; b_lb; b_ub];

% Bounds for decision variables
lb = [zeros(1, n), zeros(1, 2 * n)]; % All variables >= 0
ub = [inf(1, n), inf(1, 2 * n)]; % No explicit upper bound

%Equality Constraints
Aeq=[];
beq=[];



% Solve using linprog
options = optimoptions('linprog', 'Display', 'iter'); % Show iteration details
[X_opt, fval, exitflag, output] = linprog(f, A, b,Aeq, beq, lb, ub, options);

% Extract results
X = X_opt(1:n); % Land-use areas
S_lb = X_opt(n+1:2*n); % Slack for lower bounds
S_ub = X_opt(2*n+1:3*n); % Slack for upper bounds

% Display results
disp('Optimal land-use areas (km²):');
disp(X);

disp('Slack variables for lower bounds (km²):');
disp(S_lb);

disp('Slack variables for upper bounds (km²):');
disp(S_ub);

disp('Maximum economic benefit (10^6 yuan):');
disp(-fval); % Negate the minimized value to get the maximized benefit