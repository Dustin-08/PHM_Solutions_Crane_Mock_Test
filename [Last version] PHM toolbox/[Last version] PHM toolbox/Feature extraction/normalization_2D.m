function [norm_vals, min_val, max_val]=normalization_2D(vals, min_val, max_val)

if nargin<3
    min_val=min(min(vals));
    max_val=max(max(vals));
end
    

norm_vals=(vals-min_val)./(max_val-min_val);