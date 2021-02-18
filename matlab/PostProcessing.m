% File Name: PostProcessing.m -------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% Description:  --------------------------+
% -----------------------------------------------------------------------------+

% MAIN ------------------------------------------------------------------------+

function PostProcessing(fe,ps,runs,gens,Best,Evolution,EvolutionPosition,...
        EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,...
        BestPenalty,BestEval,run_timer,total_time)
    
    [Evolution,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,...
        BestEval,WorstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,...
        Success,mean_run_timer,Evol_X,Evol_G,gen] = post(runs,gens,Best,Evolution,EvolutionPosition,...
        EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,...
        BestPenalty,BestEval,run_timer);
   
   	write(gen,fe,ps,runs,Evolution,EvolutionPenalty,BestPosition,BestCost,...
        BestConstraint,BestPenalty,BestEval,WorstCost,mean_BestCost,mean_BestEval,...
        std_BestCost,std_BestEval,Success,mean_run_timer,total_time,Evol_X,Evol_G);
    
    visual(BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,WorstCost,...
        mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,Success,Evolution,...
        EvolutionPenalty,Evol_X,Evol_G,mean_run_timer,total_time,gen,fe);
    
end

% POST-PROCESSING -------------------------------------------------------------+
function [Evolution,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,...
        BestEval,WorstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,...
        Success,mean_run_timer,Evol_X,Evol_G,gen] = post(runs,gens,Best,Evolution,EvolutionPosition,...
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
    % Success Rate
	s = 0;
	for j = 1:length(BestCost)
		if BestCost(j) <= Best
			s = s + 1;
        end
    end
	Success = 100*(s/runs);
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
    Evol_X1 = zeros(runs, gen);
	Evol_X2 = zeros(runs, gen);
	Evol_X3 = zeros(runs, gen);
	Evol_X4 = zeros(runs, gen);
	Evol_X5 = zeros(runs, gen);
	Evol_X6 = zeros(runs, gen);
	Evol_X7 = zeros(runs, gen);
    for i = 1:runs
        for j = 1:gen
            Evol_X1(i,j) = EvolutionPosition{i}(j,1);
            Evol_X2(i,j) = EvolutionPosition{i}(j,2);
            Evol_X3(i,j) = EvolutionPosition{i}(j,3);
            Evol_X4(i,j) = EvolutionPosition{i}(j,4);
            Evol_X5(i,j) = EvolutionPosition{i}(j,5);
            Evol_X6(i,j) = EvolutionPosition{i}(j,6);
            Evol_X7(i,j) = EvolutionPosition{i}(j,7);
        end        
    end
    Evol_X1 = mean(Evol_X1,1);
	Evol_X2 = mean(Evol_X2,1);
	Evol_X3 = mean(Evol_X3,1);
	Evol_X4 = mean(Evol_X4,1);
	Evol_X5 = mean(Evol_X5,1);
	Evol_X6 = mean(Evol_X6,1);
	Evol_X7 = mean(Evol_X7,1);
    Evol_X = [Evol_X1;Evol_X2;Evol_X3;Evol_X4;Evol_X5;Evol_X6;Evol_X7];
    % Evolution of Constraints
    Evol_G1 = zeros(runs, gen);
	Evol_G2 = zeros(runs, gen);
	Evol_G3 = zeros(runs, gen);
	Evol_G4 = zeros(runs, gen);
	Evol_G5 = zeros(runs, gen);
	Evol_G6 = zeros(runs, gen);
	Evol_G7 = zeros(runs, gen);
    Evol_G8 = zeros(runs, gen);
    Evol_G9 = zeros(runs, gen);
    Evol_G10 = zeros(runs, gen);
    Evol_G11 = zeros(runs, gen);
    for i = 1:runs
        for j = 1:gen
            Evol_G1(i,j) = EvolutionConstraints{i}(j,1);
            Evol_G2(i,j) = EvolutionConstraints{i}(j,2);
            Evol_G3(i,j) = EvolutionConstraints{i}(j,3);
            Evol_G4(i,j) = EvolutionConstraints{i}(j,4);
            Evol_G5(i,j) = EvolutionConstraints{i}(j,5);
            Evol_G6(i,j) = EvolutionConstraints{i}(j,6);
            Evol_G7(i,j) = EvolutionConstraints{i}(j,7);
            Evol_G8(i,j) = EvolutionConstraints{i}(j,8);
            Evol_G9(i,j) = EvolutionConstraints{i}(j,9);
            Evol_G10(i,j) = EvolutionConstraints{i}(j,10);
            Evol_G11(i,j) = EvolutionConstraints{i}(j,11);
        end        
    end
    Evol_G1 = mean(Evol_G1,1);
	Evol_G2 = mean(Evol_G2,1);
	Evol_G3 = mean(Evol_G3,1);
	Evol_G4 = mean(Evol_G4,1);
	Evol_G5 = mean(Evol_G5,1);
	Evol_G6 = mean(Evol_G6,1);
	Evol_G7 = mean(Evol_G7,1);
    Evol_G8 = mean(Evol_G8,1);
    Evol_G9 = mean(Evol_G9,1);
    Evol_G10 = mean(Evol_G10,1);
    Evol_G11 = mean(Evol_G11,1);
    Evol_G = [Evol_G1;Evol_G2;Evol_G3;Evol_G4;Evol_G5;Evol_G6;Evol_G7;Evol_G8;Evol_G9;Evol_G10;Evol_G11];
    % Evolution Penalty Mean for X Runs
	EvolutionPenalty = mean(EvolutionPenalty,1);
	% Mean Time of Run
	mean_run_timer = mean(run_timer);
   
end

% WRITE TO FILES --------------------------------------------------------------+
function write(gen,fe,ps,runs,Evolution,EvolutionPenalty,BestPosition,BestCost,...
        BestConstraint,BestPenalty,BestEval,WorstCost,mean_BestCost,mean_BestEval,...
        std_BestCost,std_BestEval,Success,mean_run_timer,total_time,Evol_X,Evol_G)
    
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
    fprintf(file,['\n','+++ DESIGN VARIABLES EVOLUTION +++','\n']);
    dlmwrite('Results.txt',Evol_X,'delimiter','\t','precision','%.6f','-append');
    fprintf(file,['\n','+++ CONSTRAINTS EVOLUTION +++','\n']);
    dlmwrite('Results.txt',Evol_G,'delimiter','\t','precision','%.6f','-append');
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
    fprintf(file,['Success Rate: ',num2str(Success),'\n']);
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
        mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,Success,Evolution,...
        EvolutionPenalty,Evol_X,Evol_G,mean_run_timer,total_time,gen,fe)
    
    fprintf('\n + --------- FINAL RESULTS --------- + \n')
	fprintf(['Best Position: [',num2str(round(BestPosition,6)),']\n']);
	fprintf(['Best Cost: ',sprintf('%.6f',BestCost),'\n']);
	fprintf(['Constraints: [',num2str(round(BestConstraint,6)),']\n']);
	fprintf(['Penalty: ', sprintf('%.6f',BestPenalty),'\n']);
	fprintf(['Worst Cost: ',sprintf('%.6f',WorstCost),'\n']);
	fprintf(['Mean Best Cost: ',sprintf('%.6f',mean_BestCost),'\n']);
	fprintf(['Std. Best Cost: ' sprintf('%.6f',std_BestCost),'\n']);
	fprintf(['Success Rate: ',num2str(Success),'\n']);
    fprintf(['Evaluations: ',num2str(BestEval),'\n']);
    fprintf(['Mean Evaluations: ',num2str(mean_BestEval),'\n']);
    fprintf(['Std. Evaluations: ',num2str(std_BestEval),'\n']);
	fprintf(['Mean Run Time: ',num2str(mean_run_timer,10),' sec\n']);
	fprintf(['Total Time: ',num2str(total_time,10),' sec\n']);
	fprintf('\nOptimization Complete! See Results :) \n');
    
%     f1 = figure('visible','off');
%     Evals = linspace(1,fe,gen);
%     plot(Evals,Evolution);
%     title('Speed Reducer')
%     xlabel('Function Evaluations')
%     ylabel('Cost')
%     xlim([1 fe])
%     grid on
%     FileName = fullfile('Results','R_Cost.png');
%     saveas(f1,FileName);
%     
%     lines = {'s','*','+','p','h','x','.'};
%     f2 = figure('visible','off');
%     for i = 1:7
%         plot(Evals,Evol_X(i,:),['-',lines{i}],'MarkerSize',2);
%         hold on
%     end
%     title('Speed Reducer')
%     xlabel('Function Evaluations')
%     ylabel('Design Variable')
%     axis([1 fe 0 28])
%     legend('X1','X2','X3','X4','X5','X6','X7','Location','East');
%     grid on
%     FileName = fullfile('Results','R_Variables.png');
%     saveas(f2,FileName);
%    
%     lines = {'s','*','+','p','h','x','.','p','h','x','.','p','h','x','.'};
%     f3 = figure('visible','off');
%     for i = 1:11
%         plot(Evals,Evol_G(i,:),['-',lines{i}],'MarkerSize',2);
%         hold on
%     end
%     title('Speed Reducer')
%     xlabel('Function Evaluations')
%     ylabel('Constraints')
%     axis([1 fe -1 0.2])
%     legend('G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','Location','East');
%     grid on
%     FileName = fullfile('Results','R_Constraints.png');
%     saveas(f3,FileName);
%     
%     f4 = figure('visible','off');
%     plot(Evals,EvolutionPenalty);
%     title('Speed Reducer')
%     xlabel('Function Evaluations')
%     ylabel('Penalty')
%     xlim([1 fe])
%     grid on
%     FileName = fullfile('Results','R_Penalty.png');
%     saveas(f4,FileName);
end

% END -------------------------------------------------------------------------+
