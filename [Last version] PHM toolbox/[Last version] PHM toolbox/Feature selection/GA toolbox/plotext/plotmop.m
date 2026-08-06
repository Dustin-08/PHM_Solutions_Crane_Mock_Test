% PLOT properties of MultiObjective functions
%
% This function takes the individuals in Chrom and separetes dominated 
% and non-dominated solutions according to RankV. If RankV is omitted, pareto 
% ranking is done.
% Graphics visualize the dominated and non-dominated objective values, ObjV,
% and variable values, Chrom. Depending on the dimension of the MO function 
% 2-D or 3-D graphics are employed.
%
% Syntax:  Out = plotmop(Chrom, ObjV, RankV, MopOpt)
%
% Input parameters:
%    Chrom     - Matrix containing individuals to visualize
%    ObjV      - Matrix containing objective values for individuals in 
%                   Chrom,.every row contains the objective values of 
%                   the corresponding  individual in Chrom
%    RankV     - Column vector containing rank values of individuals,
%                   non-dominated individuals have the rank 0
%    MopOpt    - (optional) Options for display
%                MopOpt(1): DescrOBJ_F - String containing the descriptive 
%                                        name of objective function
%
% Output parameters:
%    no output parameters
%
% See also: ranking, mobjfonseca1, mobj*, moptest

% Author:   Hartmut Pohlheim
% History:  22.04.1999  file created
%                       plot of 3-D graphics for higher dimensions
%                       labels and titles added to graphics
%           04.05.2002  labels and legend reworked
%           23.04.2006  adjustement of the used visualization styles


function Out = plotmop(ChromAll, ObjVAll, RankVAll, MopOpt, LegLabels)

   % Check input parameter
   if nargin < 2, error('At least 2 input parameters are needed!'); end

   % Check for rank values
   if nargin < 3, RankVAll = []; end
   % if isnan(RankV), RankV = []; end
   if isempty(RankVAll), RankVAll = ranking(ObjVAll, [NaN, NaN, 1]); end

   % Check for name of function to visualize
   if nargin < 4, MopOpt = []; end
   if iscell(MopOpt), DescrOBJ_F = MopOpt{1,:}; else, DescrOBJ_F = MopOpt; end
   if isnan(DescrOBJ_F), DescrOBJ_F = ''; end
   if isempty(DescrOBJ_F), DescrOBJ_F = 'MO fun'; end

   % Check for provided legend labels
   if nargin < 5, LegLabels = ''; end

   NDLineStyles = {'b:', 'b--', 'b-.', 'b-', 'r-', 'r--', 'r-.', 'r:'};
   % NDLineStyles = {'b-', 'b--', 'b-.', 'b:', 'r-', 'r--', 'r-.', 'r:'};
   % NDLineStyles = {'k-', 'k--', 'k-.', 'k:', 'k:s', 'k:o', 'k:*', 'k:d'};

   if iscell(ChromAll), 
      RunPlotLoop = prod(size(ChromAll))
      if RunPlotLoop == 1,
         Chrom = ChromAll{1};
         if iscell(ObjVAll), ObjV = ObjVAll{1}; end
         if iscell(RankVAll), RankV = RankVAll{1}; end
      end
   else, 
      RunPlotLoop = 1; 
      Chrom = ChromAll;
      ObjV = ObjVAll;
      RankV = RankVAll;
   end

   if ~(isempty(LegLabels)), 
      LegendTextLabels = LegLabels(1:RunPlotLoop);
   else, LegendTextLabels = repmat({'run'}, [RunPlotLoop,1]); end

   if RunPlotLoop > 1, PlotDomInd = 0; else, PlotDomInd = 1; end

   for iloop = 1:RunPlotLoop,
      if RunPlotLoop > 1,
         Chrom = ChromAll{iloop};
         if iscell(ObjVAll), ObjV = ObjVAll{iloop}; end
         if iscell(RankVAll), RankV = RankVAll{iloop}; end
      end
      % Get non-dominated ObjV and Chrom
      IxNonDom = find(RankV == 0);
      ChromNonDom = Chrom(IxNonDom,:); ChromDom = Chrom; ChromDom(IxNonDom,:) = [];
      ObjVNonDom = sortrows(ObjV(IxNonDom,:),1);   ObjVDom = ObjV;   ObjVDom(IxNonDom,:) = [];
      RankVNonDom = RankV(IxNonDom,:); RankVDom = RankV; RankVDom(IxNonDom,:) = [];
      NumNonDom = length(IxNonDom); NumDom = size(ChromDom,1); NumInd = size(Chrom,1);
   
      % Check for 2-D or 3-D plot
      if size(ObjVNonDom, 2) == 2, Do2DObjV = 1; else Do2DObjV = 0; end
      if size(ChromNonDom, 2) == 2, Do2DChrom = 1; else Do2DChrom = 0; end
      
      % Defaults for figure creation
      TagFigName = 'geatbx_stateplotfunction_plotmop';
      Handlefigplot = findobj(0, 'Type', 'figure', 'Tag', TagFigName);
      if isempty(Handlefigplot), Handlefigplot = figure('NumberTitle', 'Off', 'Tag', TagFigName); end
      set(Handlefigplot, 'Name', sprintf('Multiobjective plotting %s', DescrOBJ_F));
      set(Handlefigplot, 'PaperPosition', [0.5, 2.5, 22, 10]); plotstd(Handlefigplot);
      set(0, 'CurrentFigure', Handlefigplot);
         
      % Plot of objective values
      PlotTypeNonDom = 'b*'; PlotTypeDom = 'r.';
      TextNonDom = {sprintf('non-dom (%g/%g)', NumNonDom, NumInd)};
      TextDom = {sprintf('dom (%g/%g)', NumDom, NumInd)};
      if PlotDomInd == 1, subplot(1,2,1); end
      if Do2DObjV,
         [XXND, YYND] = stairs(ObjVNonDom(:,1), ObjVNonDom(:,2));
         if iloop > 1, hold on; end
         % Plot for paper publication with multiple pareto fronts
         % plot(XXND, YYND, NDLineStyles{iloop},'LineWidth', 2);
         % if PlotDomInd == 1, hold on; plot(ObjVDom(:,1), ObjVDom(:,2), PlotTypeDom); hold off; end
         % Same with log style
         % semilogy(XXND, YYND, NDLineStyles{iloop},'LineWidth', 2);
         % Plot style for stars and lines for a single pareto front
         plot(ObjVNonDom(:,1), ObjVNonDom(:,2), PlotTypeNonDom, ObjVDom(:,1), ObjVDom(:,2), PlotTypeDom, XXND, YYND, NDLineStyles{iloop});
         if iloop > 1, hold off; end
      else
         plot3(ObjVNonDom(:,1), ObjVNonDom(:,2), ObjVNonDom(:,3), PlotTypeNonDom, ...
               ObjVDom(:,1), ObjVDom(:,2), ObjVDom(:,3), PlotTypeDom);
      end
      title(sprintf('solution space: %s', DescrOBJ_F));
      xlabel('objective value 1');
      ylabel('objective value 2');
      if ~Do2DObjV, zlabel('objective value 3'); end
      % grid('on');
      % LegendTextLabels = 
      if RunPlotLoop > 1,
         legend(LegendTextLabels{:}, 0);
      else
         legend(TextNonDom{:}, TextDom{:}, 0);
      end
   
      if PlotDomInd == 1,
         subplot(1,2,2);
         if Do2DChrom,
            Do2DChromVariant = 1;
            if Do2DChromVariant == 1,
               % 2-D plot of 2-D data (variables)
               plot(ChromNonDom(:,1), ChromNonDom(:,2), PlotTypeNonDom, ...
                    ChromDom(:,1), ChromDom(:,2), PlotTypeDom);
            else
               % 3-D plot of 2-D data (variables) and the corresponding rank values
               plot3(ChromNonDom(:,1), ChromNonDom(:,2), -RankVNonDom, PlotTypeNonDom, ...
                     ChromDom(:,1), ChromDom(:,2), -RankVDom, PlotTypeDom);
               zlabel('(negative) rank value')
            end
         else
            % 3-D plot of 3-D data (variables)
            plot3(ChromNonDom(:,1), ChromNonDom(:,2), ChromNonDom(:,3), PlotTypeNonDom, ...
                  ChromDom(:,1), ChromDom(:,2), ChromDom(:,3), PlotTypeDom);
         end
         grid('on');
         title(sprintf('search space: %s', DescrOBJ_F));
         xlabel('variable 1');
         ylabel('variable 2');
         if ~Do2DChrom, zlabel('variable 3'); end
      end

   end
   
   drawnow;


% End of function