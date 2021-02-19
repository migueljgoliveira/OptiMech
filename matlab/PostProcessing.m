% File Name: postprocessing.m -------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% -----------------------------------------------------------------------------+

% MAIN ------------------------------------------------------------------------+

function postprocessing(D,G,fe,ps,runs,gens,Evolution,EvolutionPosition,...
        EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,...
        BestPenalty,BestEval,run_timer,total_time)
    
    [Evolution,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,...
        BestEval,WorstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,...
        mean_run_timer,Evol_X,Evol_G,gen] = post(D,G,runs,gens,Evolution,EvolutionPosition,...
        EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,...
        BestPenalty,BestEval,run_timer);
   
   	write(gen,fe,ps,runs,Evolution,EvolutionPenalty,BestPosition,BestCost,...
        BestConstraint,BestPenalty,BestEval,WorstCost,mean_BestCost,mean_BestEval,...
        std_BestCost,std_BestEval,mean_run_timer,total_time,Evol_X,Evol_G);
    
    visual(BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,WorstCost,...
        mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,Evolution,...
        Evol_X,mean_run_timer,total_time,D,gen,fe);
    
end

% POST-PROCESSING -------------------------------------------------------------+
function [Evolution,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,...
        BestEval,WorstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,...
        mean_run_timer,Evol_X,Evol_G,gen] = post(D,G,runs,gens,Evolution,EvolutionPosition,...
        EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,...
        BestPenalty,BestEval,run_timer)
    
    % Run in which Best Cost was found
    [~,BestCost_i] = min(BestCost);
    % Mean Evaluations to Best Solutions
    mean_BestEval = 0;
    count = 0;
    snapBestEval = [];
    for j = 1:runs
        if BestEval(j) > 0
            mean_BestEval = mean_BestEval + BestEval(j);
            snapBestEval(end+1) = BestEval(j);
            count = count + 1;
        end
    end
    if mean_BestEval > 0 
        mean_BestEval = mean_BestEval/count;
        % Standard Deviation of Best Solutions Evaluations
        std_BestEval = std(snapBestEval);
        % Evaluations in which Best Solution
        BestEval = min(snapBestEval);
    else
        mean_BestEval = 0;
        std_BestEval = 0;
        BestEval = 0;
    end
	% Best Position for Best Cost
	BestPosition = BestPosition(BestCost_i,:);
	% Constraints for Best Cost
	BestConstraint = BestConstraint(BestCost_i,:);
    % Penalty for Best Cost
	BestPenalty = BestPenalty(BestCost_i);
    % Mean of Best Cost of all runs
	mean_BestCost = mean(BestCost);
    % Standard Deviation of Best Cost of all runs
	std_BestCost = std(BestCost);
	% Worst Cost of all runs
	WorstCost = max(BestCost);
	% Best Cost of all runs
	BestCost = min(BestCost);
    % Maximum Generations
    gen = max(gens);
	% Evolution Mean for X Runs
	Evolution = mean(Evolution,1);
    % Evolution of Design Variables
    Evol_X = zeros(runs, gen, D);
    for i = 1:runs
        for j = 1:gen
            for k = 1:D
                Evol_X(i,j,k) = EvolutionPosition{i}(j,k);
            end
        end        
    end
    Evol_X = mean(Evol_X,1);
    pEvol_X = zeros(gen,D);
    for i = 1:D
        pEvol_X(:,i) = Evol_X(:,:,i);
    end
    Evol_X = pEvol_X';
    % Evolution of Constraints
    Evol_G = zeros(runs, gen, G);
    for i = 1:runs
        for j = 1:gen
            for k = 1:G
                Evol_G(i,j,k) = EvolutionConstraints{i}(j,k);
            end
        end        
    end
    Evol_G = mean(Evol_G,1);
    pEvol_G = zeros(gen,G);
    for i = 1:G
        pEvol_G(:,i) = Evol_G(:,:,i);
    end
    Evol_G = pEvol_G';
    % Evolution Penalty Mean for X Runs
	EvolutionPenalty = mean(EvolutionPenalty,1);
	% Mean Time of Run
	mean_run_timer = mean(run_timer);
   
end

% WRITE TO FILES --------------------------------------------------------------+
function write(gen,fe,ps,runs,Evolution,EvolutionPenalty,BestPosition,BestCost,...
        BestConstraint,BestPenalty,BestEval,WorstCost,mean_BestCost,mean_BestEval,...
        std_BestCost,std_BestEval,mean_run_timer,total_time,Evol_X,Evol_G)
    
    today = datetime('now');
   
    Evol_X = Evol_X';
    Evol_G = Evol_G';
    file = fopen('Results.txt','w'); 
    fprintf(file,['\n','Date: ',datestr(today),'\n']);
    fprintf(file,['\n','+++ PARAMETERS +++','\n\n']);
    fprintf(file,['Runs: ',num2str(runs),'\n']);
    fprintf(file,['Generations: ',num2str(gen),'\n']);
    fprintf(file,['Function Evaluations: ',num2str(fe),'\n']);
    fprintf(file,['Population Size: ',num2str(ps),'\n']);
    fprintf(file,['\n','+++ COST EVOLUTION +++','\n\n']);
    for i = 1:gen
        fprintf(file,[sprintf('%.6f',Evolution(i)),'\n']);
    end
%     fprintf(file,['\n','+++ DESIGN VARIABLES EVOLUTION +++','\n']);
%     dlmwrite('Results.txt',Evol_X,'delimiter','\t','precision','%.6f','-append')
%     fprintf(file,['\n','+++ CONSTRAINTS EVOLUTION +++','\n']);
%     dlmwrite('Results.txt',Evol_G,'delimiter','\t','precision','%.6f','-append');
    fprintf(file,['\n','+++ PENALTY EVOLUTION +++','\n\n']);
    for i = 1:gen
        fprintf(file,[sprintf('%.6f',EvolutionPenalty(i)),'\n']);
    end
    fprintf(file,['\n','+++ FINAL RESULTS +++','\n\n']);
    fprintf(file,['Best Position: [',num2str(round(BestPosition,6)),']\n']);
	fprintf(file,['Best Cost: ',sprintf('%.6f',BestCost),'\n']);
	fprintf(file,['Constraints: [',num2str(round(BestConstraint,6)),']\n']);
	fprintf(file,['Penalty: ', sprintf('%.6f',BestPenalty),'\n']);
	fprintf(file,['Worst Cost: ',sprintf('%.6f',WorstCost),'\n']);
	fprintf(file,['Mean Best Cost: ',sprintf('%.6f',mean_BestCost),'\n']);
	fprintf(file,['Std. Best Cost: ' sprintf('%.6f',std_BestCost),'\n']);
    fprintf(file,['Evaluations: ',num2str(BestEval),'\n']);
    fprintf(file,['Mean Evaluations: ',num2str(mean_BestEval),'\n']);
    fprintf(file,['Std. Evaluations: ',num2str(std_BestEval),'\n']);
    fprintf(file,['Mean Run Time: ',num2str(mean_run_timer,10),' sec\n']);
	fprintf(file,['Total Time: ',num2str(total_time,10),' sec\n']);
    fprintf(file,['\n','+++++++++++++++++++++++++++++++++++++++++++','\n']);
    
    fclose(file);
    
end

% VISUALISATION ---------------------------------------------------------------+
function visual(BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,WorstCost,...
        mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,Evolution,...
        Evol_X,mean_run_timer,total_time,D,gen,fe)
    
    fprintf('\n + --------- FINAL RESULTS --------- + \n')
	fprintf(['Best Position: [',num2str(round(BestPosition,6)),']\n']);
	fprintf(['Best Cost: ',sprintf('%.6f',BestCost),'\n']);
	fprintf(['Constraints: [',num2str(round(BestConstraint,6)),']\n']);
	fprintf(['Penalty: ', sprintf('%.6f',BestPenalty),'\n']);
	fprintf(['Worst Cost: ',sprintf('%.6f',WorstCost),'\n']);
	fprintf(['Mean Best Cost: ',sprintf('%.6f',mean_BestCost),'\n']);
	fprintf(['Std. Best Cost: ' sprintf('%.6f',std_BestCost),'\n']);
    fprintf(['Evaluations: ',num2str(BestEval),'\n']);
    fprintf(['Mean Evaluations: ',num2str(mean_BestEval),'\n']);
    fprintf(['Std. Evaluations: ',num2str(std_BestEval),'\n']);
	fprintf(['Mean Run Time: ',num2str(mean_run_timer,10),' sec\n']);
	fprintf(['Total Time: ',num2str(total_time,10),' sec\n']);
	fprintf('\nOptimization Complete! See Results :) \n');
    
    f1 = figure('visible','off');
    Evals = linspace(1,fe,gen);
    plot(Evals,Evolution);
    xlabel('Function Evaluations')
    ylabel('Cost')
    xlim([1 fe])
    grid on
    saveas(f1,'Cost.png');
    f2 = figure('visible','off');
    for i = 1:D
        plot(Evals,Evol_X(i,:),'-','MarkerSize',2);
        hold on
    end
    xlabel('Function Evaluations')
    ylabel('Design Variable')
    xlim([1 fe])
    grid on
    saveas(f2,'Variables.png');

end

% END -------------------------------------------------------------------------+
