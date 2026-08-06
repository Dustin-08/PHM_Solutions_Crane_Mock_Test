% Get the data for the example vehicle routing problems 
%
% This function 
%
   %    XY = vertex coordinates
   %     q = vertex demands, with depot q(1) = 0
   %     Q = maximum route load
   %    ld = load/unload timespans
   % maxTC = maximum total route cost
%
%
% Syntax: VRPData = vrpgetdata(VRPFunName)
%
% Input parameter:
%    VRPFunName - String containing name of a vehicle routing problem 
%            (the points of the routes).
%
% Output parameter:
%    RouteIndOut - similar to RouteIndIn the converted individuals or routes
%
% See also: demovrp, objvrp, plotvrp, vrpconvind

% Author:   Hartmut Pohlheim
% History:  28.05.2005  file created


function VRPData = vrpgetdata(VRPFunName)

   NAIN = nargin; NAOUT = nargout;


   switch lower(VRPFunName),
      case 'vrpnc1',
         vrpdata = load('vrpnc1');
         VRPData.FunName = 'vrpnc1';
         VRPData.XYData = vrpdata.XY;
         VRPData.Demand = vrpdata.q;
         VRPData.TimeWindow = repmat([0 Inf], [size(VRPData.XYData,1)+1, 1]);
         VRPData.MaxLoad = 160; % vrpdata.Q;
         VRPData.LoadTime = vrpdata.ld;
         VRPData.MaxCost = vrpdata.maxTC;
         VRPData.Dists = dists(VRPData.XYData,VRPData.XYData,2);
         VRPData.MaxVehicle = ceil(1.3*sum(VRPData.Demand)/VRPData.MaxLoad);
         VRPData.BestCost = 524.6;

         % Best ObjVal: 604.01, Best Individual:  28   35    32    29    30    27    34    26    2    21    22    23     4    25    24   12    3     9    20   10     1    33    13    15    14    16     5    17     8    19    11     7    18     6    31
         % Best ObjVal: 609.49, Best Individual:  29   31    26    27    28    33    34     6    5    18     7     8    17    16    14   15   23    22    21    2    13    32    35     1    10    11    19    20     9     3    24    25     4    12    30 

      case 'sol25_r101',
         %       CUST NO.   XCOORD.   YCOORD.    DEMAND   READY TIME   DUE DATE   SERVICE TIME
         FileData = [ 0          35      35           0       0         230           0
                      1          41      49          10     161         171          10
                      2          35      17           7      50          60          10
                      3          55      45          13     116         126          10
                      4          55      20          19     149         159          10
                      5          15      30          26      34          44          10
                      6          25      30           3      99         109          10
                      7          20      50           5      81          91          10
                      8          10      43           9      95         105          10
                      9          55      60          16      97         107          10
                     10          30      60          16     124         134          10
                     11          20      65          12      67          77          10
                     12          50      35          19      63          73          10
                     13          30      25          23     159         169          10
                     14          15      10          20      32          42          10
                     15          30       5           8      61          71          10
                     16          10      20          19      75          85          10
                     17           5      30           2     157         167          10
                     18          20      40          12      87          97          10
                     19          15      60          17      76          86          10
                     20          45      65           9     126         136          10
                     21          45      20          11      62          72          10
                     22          45      10          18      97         107          10
                     23          55       5          29      68          78          10
                     24          65      35           3     153         163          10
                     25          65      20           6     172         182          10
                    ];
         VRPData.FunName = 'sol25_r101';
         VRPData.XYData = FileData(:,[2, 3]);
         VRPData.Demand = FileData(:,[4]);
         VRPData.TimeWindow = FileData([1:end,1],[5, 6]);
         VRPData.MaxLoad = 200;
         VRPData.LoadTime = 10;   % FileData(:,[7]);
         VRPData.MaxCost = Inf;
         VRPData.Dists = dists(VRPData.XYData,VRPData.XYData,2);
         VRPData.MaxVehicle = 10;   % ceil(1.4*sum(VRPData.Demand)/VRPData.MaxLoad);
         VRPData.BestCost = 617.1;

         % Best ObjVal: 598.04, Best Individual:  53    48     8    31    28     3    22     1    32    54    15    45    33    10    39    30    34    16    11    51    18    13    41    40    19    42    44    37    17    12    55     5    49     9    38     2    35    36    20    29    21    50    56    52    27     6    43    23    26     7    24    14    25     4    47    46


      otherwise,
         warning(sprintf('Unknown VRP instance  %s', VRPFunName));
   end


% End of function