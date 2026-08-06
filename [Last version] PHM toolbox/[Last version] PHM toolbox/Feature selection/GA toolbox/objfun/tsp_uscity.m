% TSP utility function, reads US City definitions
%
% This function reads data from TSP definition files and processes
% them for use under Matlab.
%
% Syntax: [Coord, Labels, Dist] = tsp_uscity(Filename)
%
% Input parameter:
%    FileName  - String containing the name of the data file(s) to use.
%                if empty, a dialog box will be opened for selection of
%                the file name.
%
% Output parameter:
%    Coord     - Matrix containing the coordinates of the cities
%    Labels    - Matrix containing strings for the cities
%    Dist      - Matrix containing the distances between all cities
%
% See also: scrtspus, tbxperm, initpp, mutswap, mutexch, recgp, recpm

% Author:   Hartmut Pohlheim
% History:  08.09.98    file created


function [Coord, Labels, Dist] = tsp_uscity(FileName)

% Reassign nargout
   NAOUT = nargout;

% Define some values
   ExtDataFile = '.ll';
   ExtLabelFile = '.lab';


   % When no file name is given, ask for one
   if isempty(FileName),
      % Open file selection dialog box
      FilePathLoad = ['*' ExtDataFile];
      [FileNameData, PathNameData]=uigetfile(FilePathLoad, 'Select file with definition of us city problem!');
      if FileNameData == 0,
         error('The file selection of the data file failed !');
      else
         FileName = [PathNameData FileNameData];
      end
   else
      FileName = [FileName ExtDataFile];
   end

   % Open the data file and test for errors
   [fidtspus, error_message] = fopen(FileName, 'rt');
   if fidtspus == -1, 
      disp(sprintf('error during fopen of data file (%s): %s', FileName, error_message));
      Coord = [];
   else
      fclose(fidtspus);
      % Read the data from the file
      Coord = load(FileName);
   end
         
   % Look for corresponding label file
   if NAOUT >= 2,
      % Open the label file and test for errors
      LabelFileName = strrep(FileName, ExtDataFile, ExtLabelFile)
      [fidtspus, error_message] = fopen(LabelFileName, 'rt');
      if fidtspus == -1, 
         disp(sprintf('error during fopen of data file (%s): %s', FileName, error_message));
         Labels = [];
      else
         Labels = []; IxLabel = 1;
         while 1,
            line = fgetl(fidtspus);
            if ~isstr(line), break, end
            Labels{IxLabel} = deblank(line(1,16:50));
            IxLabel = IxLabel + 1;
         end
         fclose(fidtspus);
      end
   end

   % Compute the full distance matrix
   if NAOUT >= 3,
      Ncity = size(Coord, 1);
      Dist = zeros([Ncity, Ncity]); 
      for i = 1:Ncity,
         % create full matrix with distances, every distance twice,
         ScaledCoord = Coord * 0.00000001745329251994;
         Diff1 = repmat(ScaledCoord(i,:), [Ncity-1 1]);
         Diff2 = ScaledCoord; Diff2(i,:) = [];
         LonC1 = Diff1(:,1); LatC1 = Diff1(:,2);
         LonC2 = Diff2(:,1); LatC2 = Diff2(:,2);
         Disti = 63783.88 * acos(cos(LonC1).*cos(LatC1).*cos(LonC2).*cos(LatC2) + ...
                                 sin(LonC1).*cos(LatC1).*sin(LonC2).*cos(LatC2) + ...
                                 sin(LatC1).*sin(LatC2) ), pause
         % #define cs(x) cos(x*0.00000001745329251994)
         % #define sn(x) sin(x*0.00000001745329251994)
         % { ff = dist[c1][c2] = acos(
         %    cs(lon(c1))*cs(lat(c1))*cs(lon(c2))*cs(lat(c2))+
         %    sn(lon(c1))*cs(lat(c1))*sn(lon(c2))*cs(lat(c2))+
         %    sn(lat(c1))*sn(lat(c2))         )*63781.5;
      end
   else
      Dist = [];
   end
   
   
% End of function