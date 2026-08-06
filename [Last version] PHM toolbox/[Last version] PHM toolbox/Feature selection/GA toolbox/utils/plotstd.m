% change appearance of PLOT in a STanDard way
%
% Set special ColorOrder, white background color for plots.
% Define a FontSize for all AxesText and set InvertHardCopy
% to 'off'. Additionally the aspect ratio of the screen
% figure is adjusted to the PaperPosition.
%
% Input parameters:
%    figno     - (optional) scalar containing handle to figure
%                if omitted the current figure (gcf) is used
%    LineHdl   - (optional) vector containing handles to lines
%                if submitted, the style of the lines is changed
%
% See also:

% Author:   Hartmut Pohlheim
% History:  28.11.1996  file created
%           24.01.1997  drawnow('discard') added, prevents update of
%                       figure on screen, thus saving time
%           08.09.2001  standard axes font smaller now (9 point)
%           26.01.2002  better handling of figure size and position, is 
%                       now always on screen 


function plotstd(figno, LineHdl);

% Get handle for figure to work on
   if nargin < 1,
      figno = gcf;
   end

% Make figure the active one (not really necesary)
   % set(0, 'CurrentFigure', figno);
   
% Set white background and some other stuff
   % whitebg(figno, 'white');
   set(figno,'color',[1.0 1.0 1.0])

% Collect a set of good colors for printing and viewing on white
   DefaultColors = [1   0   0;   % Red
                    0   0   1;   % Blue
                    0   0.5 0;   % Green (Dark)
                    0.5 0.5 0;   % Olive
                    0.5 0   0.5; % Purple
                    0   0.5 0.5; % Darkcyan / Teal
                    0.5 0   0;   % Darkred
                    0.1 0.5 0.1; % Forestgreen
                    1   0   1;   % Fuchsia
                    0   1   1;   % Aqua
                    0.7 0.5 0;   % Darkgoldenrod
                    0.7 0.7 0.7; % Silver
                   ];
   set(figno, 'DefaultAxesColorOrder', DefaultColors);
   set(figno, 'DefaultAxesFontSize', 9);
   set(figno, 'InvertHardcopy', 'off');
  
% Maintain same AspectRatio in print and screen picture
% PaperPosition is the main thing,
% the height of the screen figure is adjusted
   ScreenIs = get(0, 'ScreenSize');
   % Adjust upper value of screen size for figure menu and title bar
   ScreenIs(4) = ScreenIs(4)-3*18;
   PaperPos = get(figno, 'PaperPosition');
   WinPos = get(figno, 'Position');
   % Calculate the relative height of the figure window
   WindowHeightRel = min(0.9*ScreenIs(4), WinPos(3)/PaperPos(3)*PaperPos(4));
   % Check, if the resulting figure position is partly outside the screen and 
   % reset accordingly (change lower corner)
   if (max(0,WinPos(2))+WindowHeightRel) > ScreenIs(4), WinPos(2) = (ScreenIs(4)-WindowHeightRel)/2; end
   % Set the newly calculated figure position
   set(figno, 'Position', [WinPos(1:3), WindowHeightRel]);
   % NewPos = [max([0, ceil(Pos(3)/PaperPos(3)*PaperPos(4))])];
   % set(figno, 'Position', [Pos(1) Pos(2)+Pos(4)-NewPos Pos(3) NewPos]);

% If second input argument set LineWidth to thick lines and style to solid
   if nargin > 1,
      set(LineHdl, 'LineWidth', 4 * get(gca, 'LineWidth'), 'LineStyle', '-');
   end

% Update data, however, do not show them on screen (saves a lot of time)
   drawnow('discard');

% End of function
