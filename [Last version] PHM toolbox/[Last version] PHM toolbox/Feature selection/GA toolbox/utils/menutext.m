% Generate a text menu of choices for user input (no graphical menu)
%
% Presents a text menu in the command window. The menu-items will be 
% presented as a numbered list in the command window.
% The functionality is nearly identical to menu. However, no graphical 
% menu is presented.
%
% Syntax:  answer = menutext(HeaderText, varargin)
%
% Input parameter:
%    HeaderText- String containing the header / descriptive question for the text menu
%    varargin  - multiple strings or cell array of strings containing the mnu options
%
% Output parameter:
%    answer    - Scalar containing thenumber of the selected menu option
%
% Example:
% >> choice = menutext('Select function', 'objfun1', 'objfun2', 'objfun6')
% >>
%     ----- Select function -----
%        1) objfun1
%        2) objfun1
%        3) objfun1
%     Select a menu number:
%
%   The number entered by the user in response to the prompt is
%   returned as choice (i.e. choice = 2 implies that the user selected objfun2).
%
% See also: menu

% Author:   Hartmut Pohlheim
% History:  26.05.1999  file created


function answer = menutext(HeaderText, varargin);

   % Check input
   if nargin < 2,
       disp(sprintf('%s: No menu items to chose from.', mfilename))
       answer = 0; return;
   % Check for cell array input
   elseif nargin==2 & iscell(varargin{1}), ArgsIn = varargin{1};
   % All further input parameters are used as menu options
   else, ArgsIn = varargin; end
   
   % Calculate the number of items in the menu
   numItems = length(ArgsIn);
   
   % Continuous loop to redisplay menu until the user makes a valid choice
   while 1,
      % Display the header
      disp(sprintf('\n--- %s ----\n', HeaderText))
      % Display items in a numbered list
      for n = 1:numItems, disp(sprintf('      %2d)  %s', n, ArgsIn{n})); end
      % Prompt for user input
      answer = input('Select a menu number: ');
      % Check input:
      % 1) make sure k has a value
      if isempty(answer), answer = 1; end;
      % 2) make sure the value of answer is valid
      if any([(answer < 1), (answer > numItems), ~(strcmp(class(answer),'double')), ...
              ~(isreal(answer)), isnan(answer), isinf(answer)]),
         % Failed a key test. Ask question again
         disp(' '); disp('Selection out of range. Try again.');
      else  % Passed all tests, exit loop and return k
        return
      end
   end


% End of function
