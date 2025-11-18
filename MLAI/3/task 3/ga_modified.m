% Define the search range
lb = -15 * ones(1, 10);  % Lower bounds for each decision variable
ub = 30 * ones(1, 10);   % Upper bounds for each decision variable

% Use the ga function for optimization
options = optimoptions(@ga, 'Display', 'iter', 'MaxGenerations', 200, 'PopulationSize', 100, 'PlotFcn', @gaplotbestf);
% Setting up options for the Genetic Algorithm optimization:
% 'Display', 'iter': Display information at each iteration.
% 'MaxGenerations', 200: Maximum number of generations for the algorithm.
% 'PopulationSize', 100: Size of the population in each generation.

[x_optimal, fval_optimal] = ga(@ackley, 10, [], [], [], [], lb, ub, [], options);
% Calling the Genetic Algorithm (ga) function for optimization:
% @ackley: Objective function to minimize (Ackley function).
% 10: Number of decision variables in the optimization problem.
% [], [], [], []: No linear/nonlinear equalities or inequalities.
% lb and ub: Lower and upper bounds for decision variables.
% options: Configuration options for the Genetic Algorithm.

% Display the results
fprintf('The Value of Optimal Decision Variables are:\n');
disp(x_optimal);

fprintf('The Value of Optimal Ackley Function is:\n');
disp(fval_optimal);
% Displaying the optimal decision variables and the optimal objective function value.
