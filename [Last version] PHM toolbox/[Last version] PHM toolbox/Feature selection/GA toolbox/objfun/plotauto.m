% PLOTing of AUTO lateral control results 
%
% This function plots some of the results during computation
% of the lateral control system.
%
% Syntax:  [ObjVal, t, y] = plotauto(OBJ_F, chrom, gen, vargin)
%
% Input parameters:
%    OBJ_F     - Vector containing the (name of the) objective function
%    chrom     - Matrix/Vector containing the population/individual for 
%                simulation
%    gen       - Scalar containing the number of the current generation
%    vargin    - additional parameters, see objauto2
%
% Output parameter:
%    ObjVal    - Vector/Scalar containing the objective value of first 
%                individual in chrom
%    t         - Vector containing the time from answer of objauto
%    y         - Matrix containing the states from answer of objauto
%
% See also: demoauto1, objauto2

% Author:   Hartmut Pohlheim
% History:  10.05.1999  file created
%           11.02.2003  lines for zero added, colors of lines different
%                       two plots above each other


function [ObjVal, t, y, ModAll] = plotauto(OBJ_F, chrom, gen, varargin)


% Compute states of first individual in chrom
   AddPara = {};
   AddPara = varargin;
   NAIN = length(AddPara);
   v =  20; Noise = 0;
   % Check additional parameters
   if NAIN > 1, if ~(isempty(AddPara{2})), v = AddPara{2}; end, end     
   if NAIN > 3, if ~(isempty(AddPara{4})), Noise = AddPara{4}; end, end
   AddPara{2} = v;
   AddPara{4} = Noise;

   % Calculate objective function
   Ind = chrom(1,:);
   [ObjVal, t, y, ModAll] = feval(OBJ_F, Ind, AddPara{:});



% look for figure, set Name
   FigUserName = 'geatbxfigstateplot_plotauto1';
   figplotauto = findobj('UserData', FigUserName);
   if isempty(figplotauto),
      figplotauto = figure('UserData', FigUserName, 'NumberTitle', 'Off');
   end
   set(figplotauto,'Name', ...
       sprintf('Simulation results of %s in gen %g', OBJ_F, gen));
   set(figplotauto, 'defaultaxesfontsize', 8);
   set(0, 'Currentfigure', figplotauto);
   set(figplotauto, 'PaperPosition', [0.5 2.5 4 6]);
   plotstd(figplotauto); delete(get(figplotauto, 'Children'));


% Get size of individual and states
   [Nind, Nvar] = size(Ind);

% Define language for labels
   Lan = 'g';

% plot of y - y(:,1) - output 1
   subplot(2,1,1), plot(t, y(:,[1]), 'r-');
   StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
   line(get(gca,'XLim'), [0; 0],'Color', 'k', 'LineStyle', ':');
   set(gca, 'NextPlot', StoreNextPlot);
   if Lan == 'g',
      title(sprintf('Abweichung von Fahrbahn (v: %g m/s)', v));
      xlabel('Zeit [s]'), ylabel('Abweichung [m]');
   else
   end

% plot of u - y(:,2) - output 2
   subplot(2,1,2), plot(t, y(:,[2]), 'b:');
   StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
   line(get(gca,'XLim'), [0; 0],'Color', 'k', 'LineStyle', ':');
   set(gca, 'NextPlot', StoreNextPlot);
   if Lan == 'g',
      title(sprintf('Lenkänderung  (Noise: %2g)', Noise));
      xlabel('Zeit [s]'), ylabel('Lenkung [rad]');
   else
   end
   drawnow

   % no second plot
   return;
   
   
% look for figure, set Name
   FigUserName = 'geatbxfigstateplot_plotauto2';
   figplotauto = findobj('UserData', FigUserName);
   if isempty(figplotauto),
      figplotauto = figure('UserData', FigUserName, 'NumberTitle', 'Off');
   end
   set(figplotauto,'Name', ...
       sprintf('Simulation results of %s in gen %g', OBJ_F, gen));
   set(figplotauto, 'defaultaxesfontsize', 8);
   set(0, 'Currentfigure', figplotauto);
   set(figplotauto, 'PaperPosition', [0.5 2.5 5 4]);
   plotstd(figplotauto); delete(get(figplotauto, 'Children'));

% plot of pole zero map of model
   % subplot(2,2,4);
   rlocus(ModAll);
   if Lan == 'g',
      title(['Pol/Nullstellen Gesamtsystem']);
      xlabel('reelle Achse'), ylabel('imaginäre Achse');
   else
   end
   drawnow;


% End of function

