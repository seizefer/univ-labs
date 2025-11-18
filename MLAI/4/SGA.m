clear;

% Define parameters
NIND   = 600;           % Number of individuals in the population
MAXGEN = 200;           % Maximum number of iterations
GGAP   = 1;             % Proportion of new individuals generated, typically set to 1
NVAR   = 7;             % Number of decision variables
PRECI  = 20;            % Precision of binary representation
RecOpt = 0.7;           % Crossover probability

Lind = NVAR * PRECI;    % Total length of an individual's genes
Pm = 0.7 / Lind;        % Mutation probability

MUT_OP = 'mut';         % Mutation operator
SEL_OP = 'sus';         % Selection operator
XOV_OP = 'xovsh';       % Crossover operator
OBJ_F  = 'PrG9c';        % Objective function

% Definition of FieldD, assuming the same settings for each variable
FieldD = repmat([PRECI, -10, 10, 1, 0, 1, 1]', [1, NVAR]);

% Storage for the minimum value of each generation
One_Best = zeros(MAXGEN, 1);
All_Best = zeros(MAXGEN, 20); 
    
% Run the algorithm 20 times

% Perform the optimization algorithm 20 times
for run = 1:20
    
    % Initialize the population of chromosomes
    Chrom = crtbp(NIND, Lind);
    gen = 1;

    % Main loop for the genetic algorithm
    while gen <= MAXGEN

        % Decode binary chromosomes to real values
        x = bs2rv(Chrom, FieldD);

        % Evaluate the objective function for each individual in the population
        for i = 1:NIND
            ObjV(i,:) = PrG9c(x(i,:));
        end

        % Rank individuals based on their objective function values
        FitnV = ranking(ObjV);

        % Select individuals for crossover
        SelCh = select(SEL_OP, Chrom, FitnV, GGAP, 1);

        % Generate new individuals through crossover
        NewChrom = recombin(XOV_OP, SelCh, RecOpt);

        % Introduce mutation to the new individuals
        NewChrom = mutate(MUT_OP, SelCh, [], Pm);

        % Evaluate the objective function for the mutated individuals
        ObjVChild = ObjV;
        Phen = bs2rv(NewChrom, FieldD);
        for i = 1:NIND
            ObjV(i,:) = PrG9c(Phen(i,:));
        end

        % Select the best individuals for the next generation
        ObjVSel = ObjV;
        One_Best(gen, :) = min(min(ObjV));

        % Perform elitist selection to ensure the best individuals survive
        [Selch, ObjVChild] = reins(Chrom, NewChrom, 1, 1, ObjVChild, ObjVSel);

        % Update the current population
        Chrom = NewChrom;

        % Move to the next generation
        gen = gen + 1;

    end

    % Store the best values for each generation in each run
    All_Best(:, run) = One_Best;

end

% Transpose the matrix for easier analysis
All_Best = All_Best';

% Calculate global statistics for each generation
Globalbest = zeros(1, MAXGEN);
Globalworst = zeros(1, MAXGEN);
Globalmean = zeros(1, MAXGEN);
Globalmedian = zeros(1, MAXGEN);

for gen = 1:MAXGEN
    Globalbest(:,gen) = min(All_Best(:,gen));
    Globalworst(:,gen) = max(All_Best(:,gen));
    Globalmean(:,gen) = mean(All_Best(:,gen));
    Globalmedian(:,gen) = median(All_Best(:,gen));
end


% Output statistics
disp(['Min Best Fitness: ', num2str(Globalbest)]);
disp(['Max Best Fitness: ', num2str(Globalworst)]);
disp(['Avg Best Fitness: ', num2str(Globalmean)]);
disp(['Median Best Fitness: ', num2str(Globalmedian)]);

% Plot the figure
figure;
plot(Globalmedian,'r');
hold on;
plot(Globalbest, 'g');
plot(Globalworst, 'b');
plot(Globalmean, 'c');
legend('median value','best value','worst value','mean value')
xlabel('generation');
ylabel('f(x)');
title('Convergence Trend');

