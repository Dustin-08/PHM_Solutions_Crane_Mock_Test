% MAIN function for Genetic and Evolutionary Algorithm toolbox for matlab
%
% This function is the main driver for the GEA Toolbox.
% Here all the parameters are resolved and the appropriate
% functions are called. Additionally, results are collected
% and plot functions are called.
%
% Syntax:  [xnew, GEAOpt] = geamain2(OBJ_F, GEAOpt, VLUB, PopInit, varargin)
%
% Input parameter:
%    OBJ_F     - Name of m-file containing the objective function or
%                matlab-expression of objective function
%                The function 'OBJ_F' should return the values of the
%                objectives, ObjV.  ObjV = OBJ_F(X).
%    GEAOpt    - Structure with parameters,
%                see geaoptset for details or documentation
%    VLUB      - Matrix with 2 rows containing lower (first row) and
%                upper (second row) bounds of domain of variables
%    PopInit   - (optional) matrix containing initial population,
%                   may contain one or multiple individuals,
%                   more or less individuals than population size
%    varargin  - (optional) cell array/multiple parameter containing
%                 additional parameters, passed through to OBJ_F and
%                 all special function (initialization, stateplot)
%
% Output parameter:
%    xnew      - Matrix containing population of last generation sorted
%                by objective value (best individual first).
%                The first individual of the return population is the
%                overall best individual found. Thus, the first individual
%                could be from an earlier generation.
%    GEAOpt    - Structure with parameters, some may contain results
%                see geaoptset for details or documentation
%
% See also: compdiv

% Author:   Hartmut Pohlheim
% History:  29.10.1998  file created
%           04.11.1998  rewriting at the end, tests start
%           27.01.1999  including default values for OBJ_F and VLUB
%           17.05.1999  conversion of objective function expression
%                          into inline function
%                       use feval (instead of eval) for calling the
%                          objective function
%                       use of savebindata or loadsave possible
%           14.10.1999  included initpop for all population initialization
%                          (except special init function)
%           05.11.1999  special termination functionality inside objective
%                          function added
%           06.12.1999  parameter handling of Gui added
%           07.12.1999  special initialization (plot of figure, parameter
%                          printing) added
%           14.12.1999  moved status string creation to function gearunstatus
%           06.04.2000  collection of good individuals included
%           15.08.2000  moved GUI stuff to subfunction (necessary for compilation)
%                       moved input parameter checking to subfunction (compilation)
%           04.05.2002  moved build VLUB to subfunction (compilation)
%           05.05.2002  inclusion of ranking calls necessary for mo stuff
%                       return of best individuals / population reworked (because
%                          of collect best and mo stuff)
%           05.10.2002  test implementation of Var2ObjV feature
%           26.02.2005  calculation of position of subpopulations directly done
%                          before competition (thus twice in each generation)
%           24.04.2005  transfered some lines in separate subfunctions
%                          (geamain_calcshareoptsigma and geamain_optendresult)
%                          necessary for compilation of function


function [xnew,GEAOpt, bestObjVal] = geamain2(OBJ_F, GEAOpt, VLUB, PopInit, varargin)

% Check input variables
NAIN = nargin;
if NAIN < 4, PopInit = []; end
if isnan(PopInit), PopInit = []; end
if NAIN < 3, VLUB = []; end, if isnan(VLUB), VLUB = []; end
if NAIN < 2, GEAOpt = []; end
if NAIN < 1, OBJ_F = []; end, if isnan(OBJ_F), OBJ_F = []; end
InputAddPara = varargin;

% Put some values into the geaopt structure and check the input parameters
[OBJ_F, GEAOpt, VLUB] = geamain_defvalues(OBJ_F, GEAOpt, VLUB, InputAddPara);

% Check, if OBJ_F contains inline expression or function name,
% convert inline expression to inline function
if any(OBJ_F < 48), OBJ_Fin = fcnchk(OBJ_F, length(varargin), 'vectorized');
else OBJ_Fin = OBJ_F; end

% Variables for indicating, if text output header was already written
OutputTextHeader = [0, 0];    % OutputTextHeader = 0; OutputSaveTextHeader = 0;

% Build matrix with boundaries of objective values for binary/integer coding
% afterwards the "true" length of the individuals is known (when converting real/integer into binary)
[VLUBbint, NVarAll] = geamain_buildVLUB(GEAOpt.VariableFormat, VLUB);

% Set mutation rate depending on true length of individuals
if GEAOpt.Mutation.Rate > (10 / NVarAll), GEAOpt.Mutation.Rate = GEAOpt.Mutation.Rate / NVarAll; end

% Create new population by calling the appropriate initialization function
% or do special initialization
Chrom = [];
% special initialization
if all([GEAOpt.Special.InitDo >= 1, ~(isempty(deblank(GEAOpt.Special.InitFunction)))]),
    % Call special initialization function
    [Chrom, VLUB] = feval(GEAOpt.Special.InitFunction, sum(GEAOpt.NumberIndividuals), VLUB, GEAOpt.System.ObjFunAddPara{:});
    NVAR = size(VLUB, 2); NVarAll = NVAR;
    if size(Chrom, 2) ~= NVarAll,
        error('Number of variables of specially initialized individuals disagree with number of defined boundaries!');
    end
    % Set VLUB for binary represented variables new
    VLUBbint([2,3],:) = VLUB;
end

% Check, if population was already initialized by special method
% if Chrom is empty or not large enough, start innoculation / standard initialization
if size(Chrom, 1) ~= sum(GEAOpt.NumberIndividuals),
    % Concatenate initial individuals and specially initialized individuals
    PopInit = [PopInit; Chrom];
    % With preinitialized population PopInit ~= empty do innoculation, otherwise random initialization
    % all done with the same function
    InitOpt = [GEAOpt.VariableFormat, GEAOpt.Special.InitPresetRand, GEAOpt.Special.InitPresetKeep, GEAOpt.Special.InitUniformCreate];
    Chrom = initpop(PopInit, [sum(GEAOpt.NumberIndividuals) NVarAll], VLUB, InitOpt);
    % Set Special.InitDo to 0.5 to show the print routine the special initialization
    % if all([~(isempty(PopInit)), GEAOpt.Special.InitDo == 0]) GEAOpt.Special.InitDo = 0.5; end
    % Plot a figure representing the initialized population
    %comptime%
    %comptime% if all([~(isempty(PopInit)), GEAOpt.Special.InitDo > 10]), compplot('plot_init_pop', Chrom, sprintf(' (%s)', OBJ_F)); end
end

% Create step size matrices for evolutionary strategies (mutes*)
if strmatch('mutes', GEAOpt.Mutation.Name),
    MutChrom = 1e-2 * ones(sum(GEAOpt.NumberIndividuals), NVarAll);
    if strmatch('mutes1', GEAOpt.Mutation.Name), % MutChrom = MutChrom;
    elseif strmatch('mutes2', GEAOpt.Mutation.Name),
        MutChrom = [MutChrom, zeros(sum(GEAOpt.NumberIndividuals), NVarAll)];
    end
    Chrom = [Chrom MutChrom];
end

% Start count variables
GEAOpt.Run.Generation = 1;
GEAOpt.Run.DoTerminate = 0;

% Create some strings with used parameters, get pretty printed options
StartTime = now;     % can't be compiled: StartCPUTime = cputime;
StartCPUTime = clock; StartGenCPUTime = StartCPUTime;
if any([GEAOpt.Output.TextInterval > 0, GEAOpt.Output.SaveTextInterval > 0]),
    [GeaOptParaScreen, GeaOptParaFile] = geaoptprint(GEAOpt);
end

% Display output on screen (parameters)
if all([GEAOpt.Output.TextInterval > 0, GEAOpt.Run.Generation == 1, GEAOpt.Output.TextExcludeHead == 0]),
    disp(GeaOptParaScreen);
end

% Save output/results to file (parameters)
if all([GEAOpt.Output.SaveTextInterval > 0, GEAOpt.Run.Generation == 1]),
    [fidgen, error_message] = fopen(GEAOpt.Output.SaveTextFilename, 'at');
    if fidgen == -1, disp(sprintf('error during fopen of result file (%s): %s', GEAOpt.Output.SaveTextFilename, error_message));
    else
        if GEAOpt.Output.SaveTextExcludeHead == 0, fprintf(fidgen, '\n%s\n', GeaOptParaFile); end
        fclose(fidgen);
    end
end

% Calculate objective function for initial population
x = bindecod(Chrom(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
ObjV = feval(OBJ_Fin, x, GEAOpt.System.ObjFunAddPara{:});
% Check for DPGEA no longer supported
% if GEAOpt.Special.DPGEA == 0, ObjV = feval(OBJ_Fin, x, GEAOpt.System.ObjFunAddPara{:});
% else ObjV = dpgeamain('master', OBJ_Fin, x, GEAOpt.System.ObjFunAddPara{:}); end

% Check for the number of objective values returned
% special termination inside objective function (1 objective value with 2 NaN inside)
% Check, if objective values returned as column vector
NumIndObjv = size(ObjV, 1); NumIndChrom = size(Chrom, 1);
if all([NumIndObjv == 1, length(ObjV) == 2, all(isnan(ObjV))]),
    GEAOpt.Run.DoTerminate = 1;
    error('Optimization was terminated (special termination inside objective function), before any results were calculated!');
elseif NumIndChrom ~= NumIndObjv,
    disp(sprintf('%s: Objective values should be returned as a column vector.\n   %s  returned a row vector. Please change it appropriate!', mfilename, OBJ_Fin));
    error(sprintf('The objective function  %s  returned not the same number of objective values (%g) as individuals (%g)!', OBJ_Fin, NumIndObjv, NumIndChrom));
end

% Calculate sharing options SigmaObj (sharing sigma in objective space)and
% SigmaChrom (sharing sigma in search space)
ShareOpt = geamain_calcshareoptsigma(GEAOpt, ObjV, NVarAll, VLUB);

% Count number of objective function evaluations
GEAOpt.Run.CountObjFun = size(Chrom, 1);

% Set some matrices for collecting results
ObjVBestAll = [];
IndBestAll = [];
ObjVAllAll = []; IndAllAll = [];
NINDAllGen = []; GenAll = [];
PosSubPopFiltAct = []; PosSubPopFilt = []; PosSubPopAll = [];
CollectedBestInd = [];

% Iterate subpopulations till termination
while GEAOpt.Run.DoTerminate == 0,
    
    % Calculate order of individuals in population (work with a panmictic population)
    % Put all the ranking options into one array for later use
    RankOpt = [GEAOpt.Selection.Pressure; GEAOpt.Selection.RankingMethod; GEAOpt.Selection.RankingMultiobj]';
    
    % Get the best individual in current population
    if any(GEAOpt.Selection.RankingMultiobj >= 1),
        ShowChrom = bindecod(Chrom(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
        % Handle population as one panmictic population (NumSubPop [3rd para] is set to 1)
        [FitnV, RankMOV] = ranking(ObjV, RankOpt, 1, GEAOpt.System.ObjFunGoals);  % , ShowChrom, ShareOpt
        % Best individual has largest fitness value
        [dummy, ixbest] = max(FitnV);
        % when MO ranking // kann spaeter raus, wenn plotmop woanders laeuft
        % Plot some of the information about MO, may be switched on and off by GEAOpt.Selection.RankingMultiobj(1) >= 11
        %comptime%
        if GEAOpt.Selection.RankingMultiobj(1) > 10,
            if any([rem(GEAOpt.Run.Generation, GEAOpt.Selection.RankingMultiobj(1)-10) == 0, GEAOpt.Run.DoTerminate == 1]),
                plotmop(ShowChrom, ObjV, RankMOV, sprintf('%s (gen: %g)', GEAOpt.System.ObjFunFilename, GEAOpt.Run.Generation));
            end
        end
        
    else [dummy, ixbest] = min(ObjV(:,1)); end
    
    
    % Compute order of subpopulations
    if any(GEAOpt.Selection.RankingMultiobj >= 1), ObjVPossubpop = -FitnV; else ObjVPossubpop = ObjV(:,1); end
    [PosSubPopAct, Dummy, PosSubPopFiltActSave] = compdiv('possubpop', ObjVPossubpop, GEAOpt.NumberIndividuals, PosSubPopFiltAct);
    PosSubPopAll = [PosSubPopAll; PosSubPopAct];
    PosSubPopFilt = [PosSubPopFilt; PosSubPopFiltActSave];
    
    % Collect results: best objective value(s), best individual(s) and subpopulation size
    ObjVBestAll = [ObjVBestAll; ObjV(ixbest,:)];
    IndBestAll = [IndBestAll; bindecod(Chrom(ixbest,1:NVarAll), VLUBbint, GEAOpt.VariableFormat)];
    % SUBPOPAll = [SUBPOPAll; SUBPOP'];
    NINDAllGen = [NINDAllGen; GEAOpt.NumberIndividuals];
    ObjVAllAll = [ObjVAllAll; ObjV];
    
    % Check for termination
    TERMPARAALL = [GEAOpt.Termination.MaxGenerations, GEAOpt.Termination.MaxTime, GEAOpt.Termination.Diff2Optimum, ...
        GEAOpt.Termination.RunningMean, GEAOpt.Termination.StdObjV, GEAOpt.Termination.GoodWorstObjV, ...
        GEAOpt.Termination.Phi, GEAOpt.Termination.Kappa, GEAOpt.Termination.Cluster];
    % can't be compiled: CalcTime = (cputime - StartCPUTime) / 60;
    CalcTime = etime(clock, StartCPUTime) / 60;
    % When kappa convergence or cluster analysis, the decoded individuals are needed
    if any([GEAOpt.Termination.Method == 8, GEAOpt.Termination.Method == 9]),
        TermChrom = bindecod(Chrom(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
    else TermChrom = []; end
    [GEAOpt.Run.DoTerminate, WhatTerm] = terminat(GEAOpt.Termination.Method, [TERMPARAALL], GEAOpt.Run.Generation, CalcTime, ...
        GEAOpt.System.ObjFunMinimum, ObjVBestAll, ObjV, TermChrom, VLUB);
    
    % Create result strings
    if any([GEAOpt.Output.TextInterval > 0, GEAOpt.Output.SaveTextInterval > 0]),
        % time results
        GenTime = now - StartTime; GenCPUTime = etime(clock, StartGenCPUTime) / 60; StartGenCPUTime = clock;
        StatusTimes = {GenCPUTime, GenTime};
        OutputTextHeader = gearunstatus(GEAOpt, ObjVBestAll, IndBestAll, PosSubPopAct, WhatTerm, StatusTimes, OutputTextHeader);
    end
    
    % Call plot function with all necessary parameters
    %comptime%
    if GEAOpt.Output.GrafikInterval > 0,
        if any([rem(GEAOpt.Run.Generation, GEAOpt.Output.GrafikInterval) == 0, GEAOpt.Run.DoTerminate == 1]),
            % define new name for plot figure
            FigName = ['GEATbx[' OBJ_F ' - ' int2str(length(GEAOpt.NumberSubpopulation)) ...
                '] in Generation ' int2str(GEAOpt.Run.Generation)];
            % translate internal binary into external integer/real representation or do nothing
            ShowChrom = bindecod(Chrom(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
            % call the plot function
            %comptime%
            resplot(FigName, [GEAOpt.Run.Generation, ...
                GEAOpt.Run.Generation-max([40, 4*GEAOpt.Output.GrafikInterval]), ...
                GEAOpt.Output.GrafikMethod, GEAOpt.Output.GrafikStyle, GEAOpt.Selection.LocalDimension(1)],...
                ShowChrom, VLUB, IndBestAll, ObjV, ObjVBestAll, ObjVAllAll, NINDAllGen, PosSubPopFilt);
        end
    end
    
    % Call function to save data to mat file
    % include both savebindata functions for compilation
    %#function savebindata2 savebindatasp
    if GEAOpt.Output.SaveBinDataInterval > 0,
        if any([rem(GEAOpt.Run.Generation, GEAOpt.Output.SaveBinDataInterval) == 0, GEAOpt.Run.DoTerminate == 1]),
            % translate internal binary into external integer/real representation or do nothing
            ShowChrom = bindecod(Chrom(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
            % Set the save bin data function (standard or additional secure protokoll)
            SaveBinDataFcn = 'savebindatasp';
            % Save variables to mat-file
            Genstr = int2str(GEAOpt.Run.Generation); GenAll = [GenAll; GEAOpt.Run.Generation];
            feval(SaveBinDataFcn, GEAOpt.Output.SaveBinDataFilename, 'OBJ_F', OBJ_F, 'GenAll', GenAll, ...
                ['ShowChrom' Genstr], ShowChrom, 'VLUB', VLUB, 'ShowIndAll', IndBestAll, ...
                ['ObjV' Genstr], ObjV, 'ObjVBestAll', ObjVBestAll, 'ObjVAllAll', ObjVAllAll, ...
                'SUBPOPAll', NINDAllGen, 'PosSubPopFilt', PosSubPopFilt);
        end
    end
    
    % call the problem specific plot function (state plot function)
    %comptime%
    if GEAOpt.Output.StatePlotInterval > 0,
        if any([rem(GEAOpt.Run.Generation, GEAOpt.Output.StatePlotInterval) == 0, GEAOpt.Run.DoTerminate == 1]),
            % translate internal binary into external integer/real representation or do nothing
            ShowChrom = bindecod(Chrom(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
            feval(GEAOpt.Output.StatePlotFunction, GEAOpt.System.ObjFunFilename, ...
                ... % ShowChrom, ...
                IndBestAll(GEAOpt.Run.Generation,:), ...
                GEAOpt.Run.Generation, GEAOpt.System.ObjFunAddPara{:});
        end
    end
    
    % collect good individuals
    if GEAOpt.Special.CollectBest.Interval > 0,
        if any([rem(GEAOpt.Run.Generation, GEAOpt.Special.CollectBest.Interval) == 0, GEAOpt.Run.DoTerminate == 1]),
            ShowChrom = bindecod(Chrom(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
            % Get the ranking values by ranking all objective values, sharing not necessary
            % Handle population as one panmictic population
            FitnVColBest = ranking(ObjV, RankOpt, 1, GEAOpt.System.ObjFunGoals);
            % Call the collection function
            ColBestOpt = {GEAOpt.Special.CollectBest.Rate, GEAOpt.Special.CollectBest.Compare, ...
                GEAOpt.Special.CollectBest.WriteFile, GEAOpt.Special.CollectBest.FileName};
            CollectedBestInd = colbestind(ColBestOpt, CollectedBestInd, ShowChrom, ObjV, FitnVColBest);
        end
    end
    
    % Check geaopt paras from GUI, call private subfunction for handling GUI stuff
    %comptime%
    if GEAOpt.Gui.Use == 1, GEAOpt = geamain_gui(GEAOpt); end
    
    % Start evolutionary process only if termination not reached
    if GEAOpt.Run.DoTerminate == 0,
        % Increment generation counter
        GEAOpt.Run.Generation = GEAOpt.Run.Generation + 1;
        
        % Begin Var2ObjV changes
        LoopVar2ObjV = 1;
        if ~(isempty(GEAOpt.System.ObjFunVar2ObjV)),
            LoopVar2ObjV = size(GEAOpt.System.ObjFunVar2ObjV, 1);
            % Test for any decoding stuff and reset
            TestChrom = bindecod(Chrom(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
            if TestChrom ~= Chrom, LoopVar2ObjV = 1; end
            if LoopVar2ObjV > 1,
                VLUB_main = VLUB; VLUBbint_main = VLUBbint; Chrom_main = Chrom; ObjV_main = ObjV;
            end
        end
        
        for ivar2objv = 1:LoopVar2ObjV,
            if LoopVar2ObjV > 1,
                % Calculate LookupIx
                Var2ObjVIx = GEAOpt.System.ObjFunVar2ObjV{ivar2objv,1};
                VLUB = VLUB_main(:,Var2ObjVIx); VLUBbint = VLUBbint_main(:,Var2ObjVIx);
                Chrom = Chrom_main(:,Var2ObjVIx);
                ObjV = ObjV_main(:,GEAOpt.System.ObjFunVar2ObjV{ivar2objv,2});
            end
            
            % Fitness assignment to whole population, internally separate for each subpopulation
            % Call the single and multi objective (MO) ranking function
            if LoopVar2ObjV == 1, ShowChrom = bindecod(Chrom(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
            else ShowChrom = Chrom; end
            FitnV = ranking(ObjV, RankOpt, GEAOpt.NumberIndividuals, GEAOpt.System.ObjFunGoals, ShowChrom, ShareOpt);
            
            % Select individuals from population
            SelOpt = [GEAOpt.Selection.LocalDimension; GEAOpt.Selection.LocalTopology; GEAOpt.Selection.LocalDistance];
            [SelCh, SUBPOPSel, SelIx] = selection(char(GEAOpt.Selection.Name), Chrom, FitnV, GEAOpt.Selection.GenerationGap, GEAOpt.NumberIndividuals, SelOpt');
            
            % Recombine selected individuals
            RecOpt = [GEAOpt.Recombination.Rate]';
            SelCh = recombin(char(GEAOpt.Recombination.Name), SelCh, RecOpt, VLUB, SUBPOPSel);
            
            % Mutate offspring
            MutOpt = [GEAOpt.Mutation.Rate; GEAOpt.Mutation.Range; GEAOpt.Mutation.Precision]';
            [SelCh, SUBPOPSel] = mutate(char(GEAOpt.Mutation.Name), SelCh, MutOpt, VLUB, SUBPOPSel);
            
            % Copy the newly created variables into a main array for storing till all variables are created
            if LoopVar2ObjV > 1,
                % When the first variables are copied from SelCh, the SelCh_main must be preinitialized
                % Otherwise we get an implicit resizing after the first generation and
                % generation gap smaller 1, which is not possible
                if ivar2objv == 1, SelCh_main = ones(size(SelCh,1), size(Chrom,2)); end
                SelCh_main(:, Var2ObjVIx) = SelCh;
            end
            
        end
        
        if LoopVar2ObjV > 1,
            SelCh = SelCh_main;
            Chrom = Chrom_main; ObjV = ObjV_main;
            VLUB = VLUB_main; VLUBbint = VLUBbint_main;
        end
        % End Var2ObjV changes
        
        
        % Check violation of boundaries of variables
        % makes only sense for direct encoding, thus, no check bounds for binary coding
        if any([GEAOpt.VariableFormat == [0, 2, 4, 5]]),
            ChkOpt = 0;
            SelCh = chkbound(SelCh, ChkOpt, VLUB, GEAOpt.System.ObjFunVarBoundOut);
        end
        
        % Calculate objective function for offsprings
        x = bindecod(SelCh(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
        ObjVOff = feval(OBJ_Fin, x, GEAOpt.System.ObjFunAddPara{:});
        % Check for DPGEA, no longer supported
        % if GEAOpt.Special.DPGEA == 0, ObjVOff = feval(OBJ_Fin, x, GEAOpt.System.ObjFunAddPara{:});
        % else ObjVOff = dpgeamain('master', OBJ_Fin, x, GEAOpt.System.ObjFunAddPara{:}); end
        
        % Check for the number of objective values returned
        % special termination inside objective function (1 objective value with 2 NaN inside)
        NumOffObjv = size(ObjVOff, 1); NumOffChrom = size(SelCh, 1);
        if all([NumOffObjv == 1, length(ObjVOff) == 2, all(isnan(ObjVOff))]),
            GEAOpt.Run.DoTerminate = 1; WhatTerm = [WhatTerm, 1];
        elseif NumOffChrom ~= NumOffObjv,
            error(sprintf('The objective function  %s  returned not the same number of objective values (%g) as individuals (%g)!', OBJ_Fin, NumOffObjv, NumOffChrom));
        end
        
        if GEAOpt.Run.DoTerminate == 0;
            % Increase the number of objective function calls by the number of offspring
            GEAOpt.Run.CountObjFun = GEAOpt.Run.CountObjFun + size(SelCh,1);
            
            % Insert offspring in population replacing parents
            ReinsOpt = [GEAOpt.Selection.ReinsertionMethod; GEAOpt.Selection.ReinsertionRate; ...
                repmat(NaN, [2, GEAOpt.NumberSubpopulation]); SelOpt]';
            ReinsOpt = ReinsOpt(1,:);  % Just at the moment
            % Fitness assignment to offspring
            ShowChrom = bindecod(SelCh(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
            FitnVOff = ranking(ObjVOff, RankOpt, SUBPOPSel, GEAOpt.System.ObjFunGoals, ShowChrom, ShareOpt);
            % The first reins is only usable for the single objective case
            % [Chrom, ObjV] = reins(Chrom, SelCh, GEAOpt.NumberIndividuals, SUBPOPSel, ReinsOpt, ObjV, ObjVOff, [], [], SelIx, zeros(1, GEAOpt.NumberSubpopulation)); % FIX IT: GOPTIONS(5,:) as last parameter
            [Chrom, ObjV] = reins(Chrom, SelCh, GEAOpt.NumberIndividuals, SUBPOPSel, ReinsOpt, ObjV, ObjVOff, FitnV, FitnVOff, SelIx, zeros(1, GEAOpt.NumberSubpopulation)); % FIX IT: GOPTIONS(5,:) as last parameter
            % disp(sprintf('ObjV: %s', sprintf(' %5.3g ', ObjV)));
            
            % Migrate individuals between subpopulations
            if GEAOpt.Migration.Do > 0,
                if all([rem(GEAOpt.Run.Generation, GEAOpt.Migration.Interval) == 0]),
                    FitnV = [];
                    % In the MO case, we must perform ranking to obtain the fitness values, sharing is not necessary
                    if any(GEAOpt.Selection.RankingMultiobj >= 1),
                        FitnV = ranking(ObjV, RankOpt, GEAOpt.NumberIndividuals, GEAOpt.System.ObjFunGoals);
                    end
                    MigOpt = [GEAOpt.Migration.Rate, GEAOpt.Migration.Selection, GEAOpt.Migration.Topology];
                    [Chrom, ObjV] = migrate(Chrom, GEAOpt.NumberIndividuals, MigOpt, ObjV, FitnV);
                end
            end
            
            % Competition between subpopulations
            if GEAOpt.Competition.Do > 0,
                if all([rem(GEAOpt.Run.Generation, GEAOpt.Competition.Interval) == 0]),
                    FitnV = [];
                    % In the MO case, we must perform ranking to obtain the fitness values, sharing is not necessary
                    if any(GEAOpt.Selection.RankingMultiobj >= 1),
                        FitnV = ranking(ObjV, RankOpt, GEAOpt.NumberIndividuals, GEAOpt.System.ObjFunGoals);
                        ObjVPossubpop = -FitnV;
                    else ObjVPossubpop = ObjV(:,1); end
                    % Calculate the position of the subpopulations anew for the current individuals (offsprings reinserted and migrated)
                    [Dummy1, Dummy2, PosSubPopFiltAct] = compdiv('possubpop', ObjVPossubpop, GEAOpt.NumberIndividuals, PosSubPopFiltAct);
                    % Set the options for competition
                    CompOpt = [GEAOpt.Competition.Rate, 1, GEAOpt.Competition.SubpopMinimum(1)];
                    [Chrom, ObjV, GEAOpt.NumberIndividuals, CompQuality] = compete(Chrom, GEAOpt.NumberIndividuals, PosSubPopFiltAct, CompOpt, ObjV, FitnV);
                end
            end
        end
    end
end

% Create a "Super" population, containing the best overall individuals

% What to return as best population:
%   when collect best individuals used, return always pop created from the collected individuals.
%   Otherwise add only the last population to the best indivduals per generation
%   and create a population from part of the best per generation and the last population
if GEAOpt.Special.CollectBest.Interval > 0,
    IndBestAll = [IndBestAll; CollectedBestInd{1}];
    ObjVBestAll = [ObjVBestAll; CollectedBestInd{2}];
else
    IndBestAll = [IndBestAll; bindecod(Chrom(:,1:NVarAll), VLUBbint, GEAOpt.VariableFormat)];
    ObjVBestAll = [ObjVBestAll; ObjV];
end

if any([GEAOpt.Selection.RankingMultiobj >= 1]),
    % Handle population (of all collected best objv) as one panmictic population, no sharing
    FitnV = ranking(ObjVBestAll, RankOpt, 1, GEAOpt.System.ObjFunGoals);
else FitnV = -ObjVBestAll(:,1); end

% Find Nind best individuals and sort them according to fitness
[IndBest, ObjVBest, posbest] = compdiv('get_nbestind', IndBestAll, ObjVBestAll, FitnV, sum(GEAOpt.NumberIndividuals));
% size(IndBest), size(IndBestAll), NVarAll, VLUBint
% plot(posbest)
% Assign the "best" objective value (first by chance) to the options structure for output
GEAOpt.Run.BestObjectiveValue = ObjVBest(1,:);
xnew = IndBest;
% xnew = bindecod(IndBest(:, 1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
onew = ObjVBest;
if any([GEAOpt.Selection.RankingMultiobj >= 1]),
    % Handle population (of return pop best objv) as one panmictic population, no sharing
    FitnVBest = ranking(ObjVBest, RankOpt, 1, GEAOpt.System.ObjFunGoals);
    % Find greatest fitness value and find all other individuals with this value too
    FitnVBestMax = repmat(max(FitnVBest), [length(FitnVBest) 1]);
    % Posbest contains the indizes of all dominating individuals
    IndNonDomIx = find(FitnVBest == FitnVBestMax);
else IndNonDomIx = []; end
% Reset the generation number of best found individual to the maximum possible generation
posbest(1) = min(GEAOpt.Run.Generation, posbest(1));

% Otherwise add only the last population to the best indivduals per generation
% and create a population from part of the best per generation and the last population
% This stuff will be excluded soon.
%       0  = last population incl. best individual
%  [>0, 1] = percentage (pop size) of overall best individuals reinserted in last population
%comptime%
%comptime% ReturnPopMethod = 0;
%comptime% if 0,
%comptime%    % In the MO case, we must perform ranking to obtain the fitness values, sharing is not necessary
%comptime%    if any([GEAOpt.Selection.RankingMultiobj >= 1]),
%comptime%       % Handle population (of all collected best objv) as one panmictic population, no sharing
%comptime%       FitnVBestAll = ranking(ObjVBestAll, RankOpt, 1, GEAOpt.System.ObjFunGoals)
%comptime%    else FitnVBestAll = -ObjVBestAll(:,1); end
%comptime%    % Get the best overall individual
%comptime%    [dummy, posbest] = max(FitnVBestAll);
%comptime%    GEAOpt.Run.BestObjectiveValue = ObjVBestAll(posbest(1),:);
%comptime%    % In the MO case, we must perform ranking to obtain the fitness values, sharing is not necessary
%comptime%    if any([GEAOpt.Selection.RankingMultiobj >= 1]),
%comptime%       % Handle population (of all collected best objv) as one panmictic population, no sharing
%comptime%       FitnV = ranking(ObjV, RankOpt, 1, GEAOpt.System.ObjFunGoals);
%comptime%    else FitnV = -ObjV(:,1); end
%comptime%
%comptime%    if ReturnPopMethod == 0,
%comptime%       [Dummy, SortIx] = sort(-FitnV);
%comptime%       % Return whole population sorted by fitness (best individual first)
%comptime%       xnew = bindecod(Chrom(SortIx, 1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
%comptime%       onew = ObjV(SortIx,:);
%comptime%       % Check, if best individual is in last generation
%comptime%       % Return population is sorted population of last generation
%comptime%       if posbest(1) ~= size(IndBestAll, 1),
%comptime%          % Return population is best overall individual and sorted individuals
%comptime%          % of last generation without the worst individual (to maintain size of population)
%comptime%          xnew = [IndBestAll(posbest(1), :); xnew(1:end-1,:)];
%comptime%          onew = [ObjVBestAll(posbest(1),:); onew(1:end-1,:)];
%comptime%       end
%comptime%    else
%comptime%       % Ensure the percentage is not larger than 1
%comptime%       ReturnPopMethod = min(1, ReturnPopMethod);
%comptime%       % Special reins options for creation of return population
%comptime%       % [GEAOpt.Selection.ReinsertionMethod=2 (for fitness-based); GEAOpt.Selection.ReinsertionRate=ReturnPopMethod]
%comptime%       ReturnPopReinsOpt = [ 2; ReturnPopMethod];
%comptime%       [IndBest, ObjVBest] = reins(Chrom, IndBestAll, 1, 1, ReturnPopReinsOpt, ObjV, ObjVBestAll, FitnV, FitnVBestAll);
%comptime%       % In the MO case, we must perform ranking to obtain the fitness values, sharing is not necessary
%comptime%       if any([GEAOpt.Selection.RankingMultiobj >= 1]),
%comptime%          % Handle population (of all collected best objv) as one panmictic population, no sharing
%comptime%          FitnVBest = ranking(ObjVBest, RankOpt, 1, GEAOpt.System.ObjFunGoals);
%comptime%       else FitnVBest = -ObjVBest(:,1); end
%comptime%       % Sort the newly created population by fitness
%comptime%       [Dummy, SortIx] = sort(-FitnVBest);
%comptime%       % Return population is sorted population of last generation
%comptime%       xnew = bindecod(IndBest(SortIx, 1:NVarAll), VLUBbint, GEAOpt.VariableFormat);
%comptime%       onew = ObjVBest(SortIx,:);
%comptime%    end
%comptime% end
bestObjVal=onew;
% Display/Save output/results to file
if any([GEAOpt.Output.TextInterval > 0, GEAOpt.Output.SaveTextInterval > 0]),
    out1 = geamain_optendresult(GEAOpt, WhatTerm, StartCPUTime, StartTime, onew,  posbest, xnew, IndNonDomIx);
    
    
    % Put the created string on screen and/or file
    if GEAOpt.Output.TextInterval > 0, disp(out1); end
    if GEAOpt.Output.SaveTextInterval > 0,
        % Open output file and write data to file
        [fidgen, error_message] = fopen(GEAOpt.Output.SaveTextFilename, 'at');
        if fidgen == -1,
            disp(sprintf('error during fopen of result file (%s): %s', ...
                GEAOpt.Output.SaveTextFilename, error_message));
        else fprintf(fidgen, '%s\n\n', out1); fclose(fidgen); end
    end
end

% Switch off the Stop button on GUI
%comptime%
if GEAOpt.Gui.Use == 1,
    HandleButtonStartStop = findobj('Type', 'uicontrol', 'Tag', 'StartStopbutton');
    if ~(isempty(HandleButtonStartStop)),
        set(HandleButtonStartStop, 'Value', 0); GEAOpt = feval(GEAOpt.Gui.Name, 'startstop');
    end
end


% End of function




% private subfunction for setting/checking input parameters


function [OBJ_F, GEAOpt, VLUB] = geamain_defvalues(OBJ_F, GEAOpt, VLUB, InputAddPara),

% Check given GEA options structure GEAOpt
if isempty(GEAOpt), GEAOpt = geaoptset; end
GEAOpt = geaoptset(GEAOpt);

% Put some values into the geaopt structure
if isempty(deblank(OBJ_F)),
    if isempty(deblank(GEAOpt.System.ObjFunFilename)),
        warning('No objective function defined! Using demo objective function objfun1!');
        GEAOpt.System.ObjFunFilename = 'objfun1';
        % Set variable OBJ_F to objective function defined in GEAOpt
    else OBJ_F = GEAOpt.System.ObjFunFilename; end
end
% Set objective function in GEAOpt to variable OBJ_F
GEAOpt.System.ObjFunFilename = OBJ_F;

% Put additional parameters into GEAOpt structure
if ~(isempty(InputAddPara)), GEAOpt.System.ObjFunAddPara = InputAddPara;
else
    if ~(iscell(GEAOpt.System.ObjFunAddPara)),
        GEAOpt.System.ObjFunAddPara = {GEAOpt.System.ObjFunAddPara};
    end
end

% Check definition of variable boundaries
if isempty(VLUB),
    if isempty(GEAOpt.System.ObjFunVarBounds),
        % When no boundaries defined, get them from the objective function, two methods are possible
        warning('No variable boundaries defined! Trying to get them from objective function.');
        GEAOpt.System.ObjFunVarBounds = geaobjpara(GEAOpt.System.ObjFunFilename, 1, GEAOpt.System.ObjFunAddPara{:});
        VLUB = GEAOpt.System.ObjFunVarBounds;
    else VLUB = GEAOpt.System.ObjFunVarBounds; end
else GEAOpt.System.ObjFunVarBounds = VLUB; end

% Check the boundaries of VLUB (lower boundary must be smaller or equal to upper boundary)
DiffVLUB = (VLUB(1,:)-VLUB(2,:));
if any(DiffVLUB > 0),
    % Find the indices of the wrong defined boundaries
    IxDiffVLUB = find(DiffVLUB > 0);
    % Issue an descriptive error message
    error(sprintf('At least one lower variable boundary is larger than the corresponding upper boundary! \n   (%s)', ...
        sprintf(' %d. var: [%g, %g]  ', [IxDiffVLUB; VLUB(1, IxDiffVLUB); VLUB(2, IxDiffVLUB)])));
end


% End of subfunction



% private subfunction for building the boundaries matrix for inmteger/binary coding inside geamainX


% Build matrix with boundaries of objective values for binary/integer coding

function [VLUBbint, NVarAll] = geamain_buildVLUB(VariableFormat, VLUB)

% Get number of variables of the individuals from boundary array
NVAR = size(VLUB, 2);

% Depending on the variable format, preset the boundaries matrix with additional values
switch VariableFormat,
    % Precision of binary representation
    case 1, PrecLength = repmat(20, [1, NVAR]);
        % Precision of integer in binary representation, use as many binary values as needed
        % Example: 512 < VLUB(2,:)-VLUB(1,:) <= 1024 => use 10 binary values; because 2^10=1024
    case 3, PrecLength = ceil(log2(abs(VLUB(2,:)-VLUB(1,:))+1));
        % any([GEAOpt.VariableFormat == [0, 2, 4, 5]]), Dummy, not really used
    otherwise, PrecLength = repmat(1, [1, NVAR]);
end
% Create decoding information matrix
% [1; 0; 1; 1]: gray coding, arithmetic scaling, include lower bound,
%               include upper bound, see bindecod for parameters
VLUBbint = [PrecLength; VLUB; repmat([1; 0; 1 ;1], [1, NVAR])];
% Calculate number of variables in representation used by EA
NVarAll = sum(VLUBbint(1,:));

% End of subfunction



% private subfunction for handling GUI stuff inside geamainX


function GEAOpt = geamain_gui(GEAOpt),

GEAOptnew = feval(GEAOpt.Gui.Name, 'get_geaopt');
Para2Use = {'Gui', 'Selection', 'Recombination', 'Mutation', 'Migration', 'Competition', 'Termination', 'Output'};
% Check the run status
while any(GEAOptnew.Gui.RunStopPause == [0, 2]),   % paused
    TagFigName = GEAOpt.Gui.FigureTag;
    % If the GUI figure handle is not visible, we must set ShowHiddenHandles on
    %comptime%
    SHHoldStatus = get(0, 'ShowHiddenHandles');
    set(0, 'ShowHiddenHandles', 'on');
    waitfor(findobj(0, 'Type', 'figure', 'Tag', TagFigName), 'UserData');
    set(0, 'ShowHiddenHandles', SHHoldStatus);
    %comptime%
    GEAOptnew = feval(GEAOpt.Gui.Name, 'get_geaopt');
    % disp(sprintf('RSP after waiting get: %g', GEAOpt.Gui.RunStopPause));
end
if GEAOptnew.Gui.ChangedPara ~= 0,
    for ipara = 1:length(Para2Use),
        Para2UseHere = Para2Use(ipara);
        GEAOpt = setfield(GEAOpt, Para2UseHere{:}, getfield(GEAOptnew, Para2UseHere{:}));
    end
end
% do nothing for: if any(GEAOpt.Gui.RunStopPause == [0, 1, 4])  % don't know, started, stepped % do proceed
if GEAOpt.Gui.RunStopPause == 3, GEAOpt.Run.DoTerminate = 1; end % stopped
% disp(sprintf('geamain2: GEAOpt: %d    -      %d', GEAOpt.Gui.RunStopPause, GEAOpt.Output.TextInterval));


% End of subfunction



% private subfunction for creating the termination reason string inside geamainX


function out1 = geamain_optendresult(GEAOpt, WhatTerm, StartCPUTime, StartTime, onew,  posbest, xnew, IndNonDomIx),

% Define the possible reason strings for termination
TERMREASONSTRING = {'max. generations', 'max. comp. time',  'diff to optimum', ...
    'running mean',     'std. deviation',   'good worst indiv.', ...
    'phi convergence',  'kappa convergence', 'cluster analysis', ...
    'special objfun termination'};

% Check/find the termination option which terminated the optimization
if isempty(WhatTerm), TermIx = 1; else [dummy, TermIx] = sort(-(WhatTerm)); TermIx = TermIx(1); end

% Create the output string for termination
out1 = sprintf('\nEnd of optimization: %s (%g generations; %.2f cpu minutes / %.2f time minutes)\n', ...
    TERMREASONSTRING{TermIx}, GEAOpt.Run.Generation, ...
    etime(clock, StartCPUTime)/60, etime(datevec(now), datevec(StartTime))/60);

% Create the output string for best objective value
out1 = [out1, sprintf('Best Objective value: %s  in Generation %.0d\n', sprintf(' %12.5g ', ...
    onew(1,:)), posbest(1))];

% Create the output string for best individual
out1 = [out1, sprintf('Best Individual:      %s \n', sprintf(' %12.5g', xnew(1,:)))];

% Create the output string for number of non-dominated individuals
if ~(isempty(IndNonDomIx)),
    out1 = [out1, sprintf('Non-dominated individuals: %g  (of  %g  individuals in return population)\n', ...
        length(IndNonDomIx), sum(GEAOpt.NumberIndividuals))];
end


% End of subfunction


% private subfunction for creating the termination reason string inside geamainX

function ShareOpt = geamain_calcshareoptsigma(GEAOpt, ObjV, NVarAll, VLUB),

% Calculate SigmaObj (sharing sigma in objective space), diagonale of the hypercube
% spanned from the largest objective value to the smallest objective value
% (value 5 in  5*sum(G...)  performs good)
SigmaObj = 0;
if any(GEAOpt.Selection.RankingMultiobj >= 1),
    SigmaObj = norm(max(ObjV, [], 1) - min(ObjV, [], 1)) / (5*sum(GEAOpt.NumberIndividuals)^(1/NVarAll));
    if SigmaObj == 0, SigmaObj = 1000*eps; end
end
% Calculate the SigmaChrom (normed size of the space spanned by the boundaries of the individuals)
% used for MO ranking/sharing
SigmaChrom = norm(VLUB(2,:) - VLUB(1,:)) / (100*sum(GEAOpt.NumberIndividuals)^(1/NVarAll));
% Concatenate the various sharing options; ShareAlpha = [1; 1]; ShareBeta = [1; 1];
ShareOpt = [[SigmaChrom; SigmaObj], [1; 1], [1; 1]];


% End of subfunction
