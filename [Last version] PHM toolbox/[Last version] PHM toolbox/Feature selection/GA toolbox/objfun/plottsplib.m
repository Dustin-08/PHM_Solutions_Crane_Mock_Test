% PLOTing of results of TSP optimization (TSPLIB examples)
%
% This function plots some of the results during computation
% of the TSPLIB examples.
%
% Syntax:  plottsplib(OBJ_F, chrom, gen, TSPLibFunName)
%
% Input parameters:
%    OBJ_F     - Vector containing the (name of the) objective function
%    chrom     - Vector containing the individual for simulation
%    gen       - Scalar containing the number of the current generation
%    TSPLibFunName - additional parameter, string with name of TSPLib problem 
%                    see objtsplib for more info
%
% Output parameter:
%    x         - Matrix containing the results from objtsplib
%
% See also: objtsplib, demotsplib, tsp_readlib

% Author:   Hartmut Pohlheim
% History:  10.09.1998  file created
%           28.05.2005  added labels for points


function x = plottsplib(OBJ_F, chrom, gen, TSPLibFunName);

   % Define global variables
   global TSPLIB_FILENAME;
   global TSPLIB_NAME;
   global TSPLIB_COMMENT;
   global TSPLIB_DIMENSION;
   global TSPLIB_GLOBALOPT;
   global TSPLIB_BESTTOUR;
   global TSPLIB_DISPLAYDATA;
   global TSPLIB_EDGEWEIGHT;

   % Check input parameters
   if nargin <= 3, TSPLibFunName = []; end
   if nargin <= 2, gen = []; end
   if isempty(gen), gen = 1; end


   % Build objective function and compute states of individual x
   CalcInd = chrom(1:(min([5, size(chrom,1)])),:);
   [objval] = feval(OBJ_F, CalcInd, TSPLibFunName);
   
   % Create title string
   NameTour = geaobjpara(OBJ_F, 2, TSPLibFunName);
   TitleStr = sprintf(' %s  in gen %g', NameTour, gen);

   % look for figure, set Name
   FigUserName = 'geatbxfigstateplot_plottsplib';
   figplottsp = findobj('UserData', FigUserName);
   if isempty(figplottsp),
      figplottsp = figure('UserData', FigUserName, 'NumberTitle', 'Off');
   end
   set(figplottsp,'Name', ...
       sprintf('Simulation results of %s: %s', OBJ_F, TitleStr));
   set(figplottsp, 'defaultaxesfontsize', 8)
   figure(figplottsp);
   set(figplottsp, 'PaperPosition', [0.5 2.5 10 10]);
   plotstd(figplottsp); delete(get(figplottsp, 'Children'));

   % Get size of individual and states
   [Nind, Nvar] = size(CalcInd);

   % plot of best tours
   for iplot = 1:Nind,
      PointsX(:,iplot) = TSPLIB_DISPLAYDATA(CalcInd(iplot,:),1);
      PointsY(:,iplot) = TSPLIB_DISPLAYDATA(CalcInd(iplot,:),2);
   end
   LineHandlesPlot = plot(PointsX, PointsY, '.-');
   
   % Create and plot the labels for the points
   FormatString = sprintf('%%%gg', fix(log10(size(CalcInd,2)+1)));
   Labels = num2str([CalcInd(iplot,:)]', FormatString);
   [LimX] = get(gca, 'XLim'); DiffLimX = 0.02 * (LimX(2) - LimX(1));
   text(PointsX(:,1), PointsY(:,1), Labels, 'FontSize', 9, 'FontUnits', 'points', 'Interpreter', 'none');

   % Plot the best route with a thick line
   StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
   % AxesColorOrder = get(gca, 'ColorOrder');
   % LineHandle = plot(BestChrom); 
   set(LineHandlesPlot(1), 'LineWidth', 4 * get(gca, 'LineWidth'));
   set(gca, 'NextPlot', StoreNextPlot);


   % Create legend string and place legend
   LegString = [];
   for irunleg = 1:Nind,
      LegString = strvcat(LegString, sprintf('%2g  (%g) ', irunleg, objval(irunleg,1)));
   end
   legend(LegString);

   title(sprintf('Best %g tour(s): %s', Nind, TitleStr));
   xlabel('x-coord'), ylabel('y-coord');

   drawnow;


% End of function
