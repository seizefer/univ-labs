% Set the lower and upper bounds
lb = -15*ones(1,10);
ub = 30*ones(1,10);

% Set the optimization options
options = optimoptions('ga');
options.MaxGenerations = 100; % Maximum number of generations
options.PopulationSize = 100; % Population size
options.CrossoverFraction = 0.8; % Crossover probability
options.MutationFcn = {@mutationgaussian, 0.1, 0.5}; % Mutation function and parameters

% Call the ga function
[x,fval] = ga(@ackley,10,[],[],[],[],lb,ub,[],options);

% Display the optimal solution
disp('The optimal decision variables are:')
disp(x)
disp('The optimal objective function value is:')
disp(fval)

% Plot the objective function value versus generation
figure
plot(options.OutputFcnArgs{1}.score)
xlabel('Generation')
ylabel('Objective function value')
title('Optimization of Ackley function using ga')