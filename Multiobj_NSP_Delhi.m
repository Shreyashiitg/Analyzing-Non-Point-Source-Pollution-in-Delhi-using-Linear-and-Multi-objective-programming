clear;
clc;
Data_NSP_Delhi;

% Decision variables: X (land-use areas) and slack variables (S_lb, S_ub)
n = length(BT); % Number of land-use types
num_vars = 3 * n; % Total variables: X + S_lb + S_ub

% Objective function for gamultiobj
objFun = @(V) [
    -sum(BT .* V(1:n)) + lambda * sum(V(n+1:2*n) + V(2*n+1:3*n)); % Economic benefit (negated + slack penalty)
    sum(EC_N .* V(1:n))+sum(EC_P .* V(1:n))                       % Total TN load plus total TP load                                        % Total TP load
];

% Constraints
% Lower bounds: X + S_lb >= LB  -> -X - S_lb <= -LB
A_lb = [-eye(n), -eye(n), zeros(n)];
b_lb = -LB';

% Upper bounds: X - S_ub <= UB
A_ub = [eye(n), zeros(n), -eye(n)];
b_ub = UB';

% Total area constraint 
Area_Cons=[ones(1, n), zeros(1, 2 * n)]; % X variables only
b_Area = TA;

% Combine inequality constraints
A = [Area_Cons;A_lb; A_ub];
b = [b_Area;b_lb; b_ub];

%Equality Constraints
Aeq=[];
beq=[];

% Bounds for decision variables
lb = [zeros(1, n), zeros(1, 2 * n)]; % All variables >= 0
ub = [inf(1, n), inf(1, 2 * n)]; % No explicit upper bounds

%Initial Solution
V_init=[505.28 5093.44 10 120 1000 0 0 0 0 0 0 0 0 0 0];

%Initial Population Matrix
P=repmat(V_init,10,1);
% Solve using gamultiobj
options = optimoptions('gamultiobj', ...
    'PopulationSize', 100, ...
    'InitialPopulationMatrix', P, ...
    'Display', 'iter', ...
    'PlotFcn', {@gaplotpareto}); % Show Pareto front during optimization

% Solve multi-objective optimization
rng(1,"twister");
[X_opt, fval, exitflag, output] = gamultiobj(objFun, num_vars, A, b, Aeq, beq, lb, ub, [], options);

% Extract results
X = X_opt(:, 1:n); % Land-use areas
S_lb = X_opt(:, n+1:2*n); % Slack for lower bounds
S_ub = X_opt(:, 2*n+1:3*n); % Slack for upper bounds

% Display results
disp('Optimal land-use allocations (Pareto front solutions):');
disp(X);

disp('Slack variables for lower bounds (Pareto front solutions):');
disp(S_lb);

disp('Slack variables for upper bounds (Pareto front solutions):');
disp(S_ub);

disp('Objective function values for Pareto front:');
disp(fval);

% Plot Pareto Front
figure;
scatter(fval(:,1), fval(:,2), 'filled');
xlabel('Economic Benefit (negative + slack penalties)');
ylabel('Total TN Load');
zlabel('Total TP Load');
title('Pareto Front with Slack Variables');
grid on;

[valMin,indMin]=min(fval(:,2));
[valMax,indMax]=min(fval(:,1));
disp('Optimal Solution for maximum Economic Benefit and the corresponding values');
disp(X_opt(indMax,:));
disp(-fval(indMax,1));
disp(fval(indMax,2));

disp('Optimal Solution for minimum Pollution Load and the corresponding values');
disp(X_opt(indMin,:));
disp(fval(indMin,1));
disp(fval(indMin,2));

