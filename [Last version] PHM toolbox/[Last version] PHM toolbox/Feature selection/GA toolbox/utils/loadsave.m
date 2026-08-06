% LOADing of data from a file and SAVing these data and more to the same file
%
% This function loads data from a mat-file. The even input variables P2,P4,...
% are renamed according to the odd input variables P1,P3,...
% Then all variables, the loaded and the input variables, are saved to the
% same data mat-file.
% This function works like save, however, new variables are appended and
% identical variables are overwriten. (workaround for Matlab4)
% In Matlab 5 this function is not directly necessary, because slective 
% saving of variables and appending of variables is possible. However,
% the function still works in Matlab 5.
%
% Remark: Loading the mat-file every time may consume loads of memory.
%         Thus, use careful and keep the amount of memory in mind.
%
% Syntax:  loadsave(FileLS, P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20)
%
% Input parameters:
%    FileLS    - String containing the name of the mat-file
%                   if the file doesn't exist, it will be created
%    P1-P20    - (optional) input variables
%                   even numbers: string containing name of next variable
%                   odd  numbers: matrix with values of variable
%                   example: P1 contains the name of the variable in P2
%                            P3 the name of the variable in P4 and so on
%
% Output parameter:
%    no output parameter
%
% Example:
%  % mat-file 'filename.mat' doesn't exist
%  >>loadsave('FileName', 'var2', var2, 'var3', var3)
%  % now mat-file 'filename.mat' contains 2 variables with name var2 and var3
%
%  >>loadsave('FileName', 'hell5', hell5, 'blurr2', blurr2)
%  % now mat-file 'filename.mat' contains 4 variables: var2, var3, hell5, blurr2
%
% See also: geamain

%  Author:  Hartmut Pohlheim
%  History: 23.01.97    file created


function loadsave(FileLS,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20)

   % check for MAT-file and load it 
      if exist([FileLS '.mat']) == 2, load(FileLS);
      elseif exist([FileLS]) == 2,    load(FileLS);
      end

   % Assign values of variables to correctly named variables 
      for irun = 1:2:nargin-1, eval([eval(['P' int2str(irun)]) '= P' int2str(irun+1) ';']); end

   % Clear not longer used P* parameters
      for irun = 1:nargin-1, eval(['clear P' int2str(irun) ';']); end
      clear irun;

   % Save all known variables
   % (FileLS is saved as well, no workaround known)
      eval(['save  ' FileLS]);

   
% End of function
