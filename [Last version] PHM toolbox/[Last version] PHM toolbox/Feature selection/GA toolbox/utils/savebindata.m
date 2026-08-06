% SAVing BINary DATA to a file by appending variables
%
% The even input variables in varargin ({1}, {3}, ...) are assigned 
% to variables. The names of these variables are given in the odd input 
% variables in varargin ({2}, {4}, ...). Thus, the name can be defined 
% freely in the calling function.
% Then all variables are saved to the data mat-file defined in FileLS.
% However, the new variables are appended to the mat file, variables of 
% the same name are replaced.
%
% This function is written for Matlab >=5.x.
% For Matlab 4.x please use loadsave with a similar functionality.
%
% Syntax:  savebindata(FileLS, varargin)
%
% Input parameters:
%    FileLS    - String containing the name of the mat-file
%                   if the file doesn't exist, it will be created
%    P1-Pxx    - (optional) input variables (all in varargin)
%                   even numbers: string containing name of next variable
%                   odd  numbers: variable
%                   example: P1 contains the name of the variable in P2
%                            P3 the name of the variable in P4 and so on
%
% Output parameter:
%    no output parameter
%
% Example:
%  % mat-file 'filename.mat' doesn't exist
%  >>savebindata('FileName', 'var2', var2, 'var3', var3)
%  % now mat-file 'filename.mat' contains 2 variables with name var2 and var3
%
%  >>savebindata('FileName', 'hell5', hell5, 'blurr2', blurr2)
%  % now mat-file 'filename.mat' contains 4 variables: var2, var3, hell5, blurr2
%
% See also: geamain

%  Author:  Hartmut Pohlheim
%  History: 17.05.97    file created


function savebindata(FileLS, varargin)

   % Get the data stuff
      sbdData = varargin;

   % check for MAT-file and load it 
      sbdFileAppend = '-append';
      if exist([FileLS '.mat']) == 2,
      elseif exist([FileLS]) == 2,
      else sbdFileAppend = '';
      end

   % worse version, but much quicker than the save -append
      sbdvariant = 1;
      if sbdvariant == 1,
         if ~(isempty(sbdFileAppend)), load(FileLS); end
      end

   % Assign values of variables to correctly named variables 
      % length(Data)
      for irun = 1:2:length(sbdData)-1,
         % DataName = sbdData{irun};
         % DataValues = sbdData{irun+1};
         % [DataName ' = DataValues;']
         % eval([DataName ' = DataValues;'])
         eval([sbdData{irun} ' = sbdData{irun+1};'])
      end

   % Save/append all variables
      if sbdvariant == 1,  % looks worse, but is quicker
         clear varargin sbdData irun sbdvariant sbdFileAppend
         save(FileLS);
      else  % looks better, but is much slower
         SaveNames = sbdData(1:2:length(sbdData)-1)
         save(FileLS, SaveNames{:}, sbdFileAppend);
      end


% End of function
