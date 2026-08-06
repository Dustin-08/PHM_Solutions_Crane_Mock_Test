% Decompose long/full fieldnames into their parts
%
% This function decomposes the full structure fieldname into its parts.
% The partial strings are returned in a cell array.
%
% Syntax:  [FieldNameParts] = fieldnames_parts(FieldNameFull)
%
% Input parameters:
%    FieldNameFull - String containing one full structure fieldname
%                    (mostly created by fieldnames_full)
%
% Output parameter:
%    FieldNameParts - cell array of strings containing the parts of the full 
%                     structure fieldnames
%
% Example:
% % Get the partial field names from the full fieldname
% >> FieldNameParts = fieldnames_parts('SecondField.Deeper.Really')
% >> FieldNameParts = 
%     'SecondField'    'Deeper'    'Really'
%
% See also: paraoptset, paraoptsave, paraoptload, fieldnames_full
     
% Author:   Hartmut Pohlheim
% History:  17.02.2002  file created (taken from compdiv)


function [FieldNameParts] = fieldnames_parts(FieldNameFull)

   % Preset output parameter
   FieldNameParts = {};
   
   NameRest = FieldNameFull;
   % Take all parts before '.', one after the other
   while ~(isempty(NameRest)),
      [Part, NameRest] = strtok(NameRest, '.');
      FieldNameParts = {FieldNameParts{:}, Part};
   end


% End of function

