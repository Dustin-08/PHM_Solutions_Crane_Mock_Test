% Create cell array with all full fieldnames of given structure
%
% This function collects the complete/full fieldnames of a given 
% structure up to arbitrary levels and returnes them in a cell array.
% This function calls itself recursively to get the fieldnames of 
% the lower levels.
%
% Syntax:  [FieldNamesFull] = fieldnames_full(StructFull)
%
% Input parameters:
%    StructFull - Structure of any form
%
% Output parameter:
%    FieldNamesFull - cell array of strings containing the complete 
%                     fieldnames of the input structure
%
% Example:
% % Get the complete/full fieldnames of the structure
% >> ExplStruct.First = 24;
% >> ExplStruct.SecondField.Higher = 'no';
% >> ExplStruct.SecondField.Deeper.Really = 38;
% >> FullFieldNames = fieldnames_full(ExplStruct)
%    FullFieldNames = 
%      { 'First'
%        'SecondField.Higher'
%        'SecondField.Deeper.Really'
%      }
%
% See also: paraoptset, paraoptsave, paraoptload, fieldnames_parts
     
% Author:   Hartmut Pohlheim
% History:  17.02.2002  file created (taken from compdiv)
%           09.06.2002  call of strcat replaced by direct implementation
%                          (produced an error in very special compiled version) 


function [FieldNamesFull] = fieldnames_full(StructFull)

   % Check for empty input or no-structure input, return with empty cell array
   if any([isempty(StructFull), ~(isstruct(StructFull))]), return; end

   % Preset output parameter
   FieldNamesFull = {};
   
   % Get fieldnames of first level in structure
   FieldNamesCurrent = fieldnames(StructFull);
   FieldNamesFull = {};

   for ifull = 1:size(FieldNamesCurrent, 1),
      StructLevel2 = getfield(StructFull, FieldNamesCurrent{ifull});
      if isstruct(StructLevel2),
         FieldNamesInt = fieldnames_full(StructLevel2);
         % disp(sprintf('Current: %s       Int: %s', prprintf(FieldNamesCurrent{ifull}), prprintf(FieldNamesInt)))
         % FieldNamesNew = strcat(FieldNamesCurrent{ifull}, '.', FieldNamesInt);
         % Workaround for above compile broken line
         [FNIntR, FNIntC] = size(FieldNamesInt);
         FieldNamesNew = cell(FNIntR,1);
         for icat = 1:FNIntR, FieldNamesNew{icat} = [FieldNamesCurrent{ifull}, '.', FieldNamesInt{icat}]; end
         %FieldNamesNew = strcat(FieldNamesNew1, FieldNamesInt)
      else FieldNamesNew = FieldNamesCurrent(ifull); end
      FieldNamesFull = [FieldNamesFull; FieldNamesNew];
   end


% End of function

