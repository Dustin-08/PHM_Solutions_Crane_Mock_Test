% COMPute PLOT things of GEA Toolbox
%
% This function computes diverse special things used during plotting.
%
% Syntax:  [OP1, OP2, OP3, OP4, OP5] = compplot(WhatTask, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10)
%
% Input parameters:
%    WhatTask  - String containing the name of the needed computation
%    P1 - P10  - Parameters needed for the specific computations
%
% Output parameter:
%    OP1 - OP5 - Output parameters, specific for every computation
%
% Possible functions:
%    WhatTask == 'set_linestyle'
%       Set style of lines using default styles or using the supplied (P2) styles
%       P1     - Vector containing handles of lines
%       P2     - (optional) Vector or matrix of line styles to use
%       no output (result is contained in the changed properties of the handles)
%
%    WhatTask == 'set_linewidth'
%       Set width of lines using default width or using the supplied (P2) widths
%       P1     - Vector containing handles of lines
%       P2     - (optional) Vector or matrix of line widths to use
%       no output (result is contained in the changed properties of the handles)
%
%    WhatTask == 'set_axespositions'
%       Compute positions of subaxes in a given area
%       P1     - Vector with 2 scalars defining the number of subplots
%                in both dimensions
%       P2     - Vector with position data (similar to grafic handle position)
%       OP1    - Matrix with each line containing position of sub-axes
%
%    WhatTask == 'scale_variables'
%       Scale variables according to boundary matrix
%       P1     - Matrix with variables
%       P2     - Matrix with boundaries of variables
%       OP1    - Matrix with scaled variables, in area [0, 1]
%
%    WhatTask == 'plot_init_pop'
%       Plot a simple graphic of the distribution of the start population (special initialization)
%       P1     - Matrix with variables of (initial) population
%       P2     - (optional) String with extended info for figure name/title of axes
%
% See also: resplot

%  Author:  Hartmut Pohlheim
%  History: 17.04.97    file created
%           19.06.97    line styles changed and extended, difference
%                          between Matlab4 and Matlab5, later uses Marker
%           20.04.98    added scaling of variables ('scale_variables')
%           06.05.98    added computing of special min, max and diff ('get_min_max_diff')
%           24.09.98    support in 'get_min_max_diff' for all values Inf or NaN or 
%                          a mix of both, even minValue and maxValue may be zero
%           07.12.99    added plot_init_pop


function [OP1, OP2, OP3, OP4, OP5] = compplot(WhatTask, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10);

% Check input parameters
   if nargin < 1, WhatTask = []; end 
   if isempty(WhatTask), error('Parameter WHAT undefined! Do you know what you want?'); end


% Set styles of lines using default styles or using the supplied (P2) styles
   if strcmp(lower(WhatTask), 'set_linestyle'),
      if nargin < 2, error('One input parameter for line style setting necessary !'); end
      LineHandles = P1;

      vers = version;
      Marker4 = ['x '; 'o '; '+ '; '* '];
      Marker5 = [Marker4; 's '; 'd '; 'p '; 'h ']; 
      if nargin < 3, 
         LineStyles = ['- '; ': '; '-.'; '--'];
         if vers(1) <= '4', LineStyles = [LineStyles ; Marker4]; end
      else LineStyles = P2; end
      
      if size(LineStyles, 1) == 1, set(LineHandles, 'LineStyle', strtok(LineStyles));
      else
         for ilh = 1:length(LineHandles),
            LSHere = strtok(LineStyles(rem(ilh-1, size(LineStyles, 1))+1,:));
            if vers(1) <= '4', set(LineHandles(ilh), 'LineStyle', LSHere); 
            elseif vers(1) >= '5',
               if ilh <= size(LineStyles, 1), set(LineHandles(ilh), 'LineStyle', LSHere); 
               else 
                  MarkerHere = strtok(Marker5(rem(ilh-size(LineStyles, 1)-1, size(Marker5, 1))+1,:));
                  set(LineHandles(ilh), 'LineStyle', LSHere, 'Marker', MarkerHere, 'MarkerSize', 5); 
               end
            end
         end
      end

      OP1 = LineHandles;      % Output parameter not used


% Set width of lines using default width or using the supplied (P2) width
   elseif strcmp(lower(WhatTask), 'set_linewidth'),
      if nargin < 2, error('One input parameter for line width setting necessary !'); end
      LineHandles = P1;
      if nargin < 3, LineWidths = 2;
      else LineWidths = P2; end

      if length(LineWidths) == 1, set(LineHandles, 'LineWidth', LineWidths);
      else
         for ilw = 1:length(LineHandles),
            LWHere = LineWidths(rem(ilw, size(LineWidths, 1)),:);
            set(LineHandles(ilh), 'LineWidth', LWHere);
         end
      end

      OP1 = LineHandles;      % Output parameter not used

% Compute positions of subaxes in a given area
   elseif strcmp(lower(WhatTask), 'set_axespositions'),
      if nargin < 2, error('One input parameter for axes position calculation necessary !'); end
      if nargin < 3, AxesArea = [0 0 1 1];
      else AxesArea = P2; end
      if length(P1) == 1,
         MoreLeftRight = 1;
         if MoreLeftRight == 1,
            AxesUD = floor(sqrt(P1));
            AxesLR = ceil(P1 / AxesUD);
         else
            AxesLR = floor(sqrt(P1));
            AxesUD = ceil(P1 / AxesLR);
         end
      else AxesUD = P1(1); AxesLR = P1(2); end

      AxesLeft = AxesArea(1); AxesDown = AxesArea(2); AxesWidth = AxesArea(3); AxesHeight = AxesArea(4);
      % AxesSpaceWidth =  (0.10*AxesWidth)/max(2, min([AxesLR, AxesUD]));
      AxesSpaceWidth =  (0.10*AxesWidth)/max(2, ((AxesLR+AxesUD)/2));
      AxesSpaceHeight = AxesSpaceWidth;     % (0.10*AxesHeight)/max(2, AxesUD);
      AxesWidthSmall  = (AxesWidth  - AxesLR*2*AxesSpaceWidth)/AxesLR;
      AxesHeightSmall = (AxesHeight - AxesUD*2*AxesSpaceHeight)/AxesUD;
      
      AxesAllPos = [];
      for irunUD = 1:AxesUD,
         for irunLR = 1:AxesLR,
            AxesAllPos = [AxesAllPos; ...
                          AxesLeft+2*AxesSpaceWidth+(irunLR-1)*(AxesWidthSmall+2*AxesSpaceWidth) ...     % left side position of axes
                          AxesDown+AxesSpaceHeight+(AxesUD-irunUD)*(AxesHeightSmall+2*AxesSpaceHeight) ... % down side position of axes
                          AxesWidthSmall  AxesHeightSmall
                         ];
         end
      end
      OP1 = AxesAllPos;


% Scale variables according to boundary matrix
   elseif strcmp(lower(WhatTask), 'scale_variables'),
      % Check number of input variables, if not enough provided, return variables unscaled
      if nargin > 1, Chrom = P1; OP1 = Chrom; else OP1 = []; end
      if nargin > 2, 
         VLUB = P2;
         [Nind, Nvar] = size(Chrom);
         % Check the number of columns in variable matrix and in boundary matrix (must be equal)
         if Nvar ~= size(VLUB, 2), 
            warning('The number of columns of the individual matrix and the boundary matrix is not equal (scaling of variables) !');

         % When everything with inputs is ok, start the scaling process
         else
            % Calculate difference between upper and lower boundaries
            VarDiff = VLUB(2, :) - VLUB(1,:);
            % Check for zero diff
            IxDiffZero = find(VarDiff == 0);
            % Set scaling value for zero diff to 1
            if length(IxDiffZero) > 0, VarDiff(IxDiffZero) = ones(1, length(IxDiffZero)); end
            % Scale the variables
            VarMin = VLUB(1,:);
            ScaledChrom = (Chrom - repmat(VarMin, [Nind, 1])) ./ repmat(VarDiff, [Nind, 1]);
            % Assign scaled variables to output variable
            OP1 = ScaledChrom;
         end
      else
         % When not enough input parameter provided, issue a warning
         warning('Two input parameter for scaling of variables necessary (second parameter VLUB is missing)! Proceeding with unscaled variables.'); 
      end
      



% Let the current axes rotate with some special things
   elseif strcmp(lower(WhatTask), 'rotate_axes'),
      if nargin < 2, error('At least one input parameter needed'); end 

      % P2: view values for view
      if nargin < 3, P2 = []; end
      if isempty(P2), P2 = get(gca, 'View'); end      % get the defalult for 3D 
      
      % P1: action to do
      WhatToDo = P1;

      % Set some value
      RotateAZStepOne = 36;      % how many degree per step
      RotateELStepOne = 24;      % how many degree per step
      RotateAZStepAll = RotateAZStepOne:RotateAZStepOne:360;        % steps in degree for one full AZ rotation
      RotateELStepAll = RotateELStepOne:RotateELStepOne:360;        % steps in degree for one full EL rotation
      PauseRotate = 2;           % Pause for rotating stuff
      
      [ViewAZ, ViewEL] = view;
      ViewAZint = ViewAZ; , ViewELint = ViewEL;
      axis vis3d;
      if strcmp(lower(WhatToDo), 'r'),
         ViewAZint = ViewAZint - RotateAZStepOne;
      
      elseif strcmp(lower(WhatToDo), 'l'),
         ViewAZint = ViewAZint + RotateAZStepOne;

      elseif strcmp(lower(WhatToDo), 'u'),
         ViewELint = ViewELint + RotateELStepOne;

      elseif strcmp(lower(WhatToDo), 'd'),
         ViewELint = ViewELint - RotateELStepOne;

      elseif strcmp(lower(WhatToDo), 'lf'),
         for irot = RotateAZStepAll, compplot('rotate_axes', 'l'); pause(PauseRotate); end
         
      elseif strcmp(lower(WhatToDo), 'rf'),
         for irot = RotateAZStepAll, compplot('rotate_axes', 'r'); pause(PauseRotate); end

      elseif strcmp(lower(WhatToDo), 'uf'),
         for irot = RotateELStepAll, compplot('rotate_axes', 'u'); pause(PauseRotate); end

      elseif strcmp(lower(WhatToDo), 'df'),
         for irot = RotateELStepAll, compplot('rotate_axes', 'd'); pause(PauseRotate); end

      else
         disp(sprintf('compplot.m (''rotate_axes''): Unknown option for action! (%s)', WhatToDo));
      end
      
      view(ViewAZint, ViewELint);
      drawnow;

      [ViewAZ, ViewEL] = view; ViewCoord = [ViewAZ, ViewEL]; CoordChanged = 0;
      for icoord = 1:2;
         if abs(ViewCoord(icoord)) > 360, ViewCoord(icoord) = rem(ViewCoord(icoord), 360); CoordChanged = 1; end
         if abs(ViewCoord(icoord)) > 180, ViewCoord(icoord) = ViewCoord(icoord) - sign(ViewCoord(icoord)) * 360; CoordChanged = 1; end
      end
      if CoordChanged == 1, view(ViewCoord); end
      
      [ViewAZ, ViewEL] = view;
      OP1 = [ViewAZ, ViewEL];


% Plot a simple graphic of the distribution of the start population (special initialization)
   elseif strcmp(lower(WhatTask), 'plot_init_pop'),
      % P1: Initial population
      if nargin < 2, error('At least one input parameter needed'); end, Chrom = P1;
      % P2: Extra string in figure/axes title - name of objective function (optional)
      if nargin < 3, P2 = []; end, if isempty(P2), P2 = ''; end
      FigName = sprintf('Distribution of initial population%s', P2);

      TagFigNameInit = 'figgeatbxinit1'; HandlefigInit = findobj(0, 'Type', 'figure', 'Tag', TagFigNameInit);
      if isempty(HandlefigInit), 
         HandlefigInit = figure('Tag', TagFigNameInit, 'NumberTitle', 'Off');
      end
      % Set PaperPosition for saving of figure
      PaperPos = [0.5, 2.5, 5, 3]; set(HandlefigInit, 'PaperPosition', PaperPos, 'Name', FigName);
      % Set all standard settings defined in plotstd
      plotstd(HandlefigInit);
      % Clear all objects in figure and make figure the current one (by keeping in background)
      delete(get(HandlefigInit,'Children')); set(0, 'CurrentFigure', HandlefigInit);
      % Simple plot of initial population
      plot(Chrom'); xlabel('index of variable'); ylabel('value of variable'); title(FigName);
      
      
% If unknown option, issue an error message
   else
      disp(sprintf('compplot.m: Unknown option for action! (%s)', WhatTask));
   end


% End of function

