function filepath=makepath(varargin)
filepath=[];
for i=1:length(varargin)
    filepath=[filepath varargin{i} '\'];
end