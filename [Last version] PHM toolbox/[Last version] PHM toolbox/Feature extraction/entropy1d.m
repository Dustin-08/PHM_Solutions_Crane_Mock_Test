function E = entropy1d(signal, bins)

p = hist(signal,bins);

% remove zero entries in p 
p(p==0) = [];

% normalize p so that sum(p) is one.
p = p ./ numel(signal);

E = -sum(p.*log2(p));