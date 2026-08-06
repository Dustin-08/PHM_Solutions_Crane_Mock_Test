% PLOTing of OBJective FUNction data during optimization
%
% This function plots some of the results during computation of an 
% objective function to visualize the search in the first 2 dimensions.
%
% Syntax:  [ObjVal, t, y] = plotobjfun(OBJ_F, chrom, gen, varargin)
%
% Input parameters:
%    OBJ_F     - Vector containing the (name of the) objective function
%    chrom     - Matrix/Vector containing the population/individual for 
%                simulation
%    gen       - Scalar containing the number of the current generation
%    varargin  - additional parameters, see the respective objfun
%
% Output parameter:
%    ObjVal    - Vector/Scalar containing the objective value of 
%                individuals in chrom
%
% See also: demogeatbx, objfun1, objfun2, objfunx

% Author:   Hartmut Pohlheim
% History:  29.05.2005  file created


function [ObjVal] = plotobjfun(OBJ_F, chrom, gen, varargin)


   % Compute states of first individual in chrom
   AddPara = {};
   if nargin < 4, AddPara = {}; else AddPara = varargin; end
   if length(AddPara) == 1, AddPara = AddPara{1}; end

   % Calculate objective function
   Ind = chrom(:,:);
   [ObjVal] = feval(OBJ_F, Ind(:,[1,2]), AddPara{:});

   % look for figure, set Name
   FigUserName = 'geatbxfigstateplot_plotobjfun1';
   figplotauto = findobj('UserData', FigUserName);
   if isempty(figplotauto),
      figplotauto = figure('UserData', FigUserName, 'NumberTitle', 'Off');
   end
   FigTitle = sprintf('Simulation results of %s in gen %g', OBJ_F, gen);
   set(figplotauto,'Name', FigTitle);
   set(figplotauto, 'defaultaxesfontsize', 8);
   set(0, 'Currentfigure', figplotauto);
   set(figplotauto, 'PaperPosition', [0.5 2.5 4 6]);
   plotstd(figplotauto); delete(get(figplotauto, 'Children'));


   % Get size of individuals
   [Nind, Nvar] = size(Ind);

   % Define language for labels
   Lan = 'g';

   % Get area of the individuals (first 2 dimensions)
   [xmin, xmax, xdiff] = visuminmaxdiff(Ind(:,1), [1, 2]);
   [ymin, ymax, ydiff] = visuminmaxdiff(Ind(:,2), [1, 2]);

   % generate a mesh plot for search space visualization
   % plotmesh(OBJ_F, [xmin-xdiff, ymin-ydiff; xmax+xdiff, ymax+ydiff], [50, 50; NaN, NaN]);
   plotmesh(OBJ_F, [-10, -10; 10, 10], [50, 50; NaN, NaN]);
   view([-30, 70])

   % subplot(2,1,1), plot(t, y(:,[1]), 'r-');
   StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
   plot3(Ind(:,1), Ind(:,2), ObjVal, 'k*')
   % line(get(gca,'XLim'), [0; 0],'Color', 'k', 'LineStyle', ':');
   set(gca, 'NextPlot', StoreNextPlot);
   
   % Create title and labels
   if Lan == 'g',
      title(FigTitle);
      xlabel('Variable 1'), ylabel('Variable 2');
   else
   end

   drawnow



% End of function

