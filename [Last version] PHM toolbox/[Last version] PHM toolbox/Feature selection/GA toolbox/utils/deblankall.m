% Remove leading and trailing Spaces from string or cell array of strings
%
% This function removes spaces in front and at the end of a string
% or cell array of strings. The removed spaces are taken from the 
% definition of isspace.
%
% Syntax:  OutString = deblankall(InString)
%
% Input parameter:
%   InString   - String or cell array of strings
%
% Output parameter:
%   OutString  - same format as InString without leading and trailing spaces
%
% See also: deblank

% Author:   Hartmut Pohlheim
% History:  17.06.2001  file created


function OutString = deblankall(InString)

   if ~iscell(InString),
      OutString = deblank_string(InString);
   % Special handling of cell arrays, each string is despaced separately
   else
      OutString=cell(size(InString));
      for ideb = prod(size(InString)):-1:1,
         OutString{ideb} = deblank_string(InString{ideb});
      end
   end



   function StringDeblank = deblank_string(StringwithSpaces)
   
      StringDeblank = StringwithSpaces;
      if ~(isempty(StringwithSpaces)),
         [r,c] = find(~(isspace(StringwithSpaces)) & StringwithSpaces ~= 0);
         if isempty(c), StringDeblank = StringwithSpaces([]);
         else StringDeblank = StringwithSpaces(:,min(c):max(c)); end
      end


% End of function
