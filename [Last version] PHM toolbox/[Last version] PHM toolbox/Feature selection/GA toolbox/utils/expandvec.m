% This function replicates a vector vec
% as often as defined in a vector reps
% into one vector
%
% Example: turn vec = [1 5 3], reps = [1 5 3] => y = [1 5 5 5 5 5 3 3 3]
% 2nd Example: turn vec = [1 2 3 4], reps = [3 4 2 1] => y = [1 1 1 2 2 2 2 3 3 4]
% 
% Quelle: Usenet,
%         Message-ID: <derrico-A33B2E.22244112042002@news.newsguy.com>
% 
% Author: John D'Errico

function y = replicate(reps, vec)

  n=sum(reps);
  ind=zeros(n,1);
  i=cumsum([1;reps(:)]);
  ind=sparse(i(1:(end-1)),1,1,n,1);
  ind=cumsum(ind);
  y=vec(ind);

% End of function