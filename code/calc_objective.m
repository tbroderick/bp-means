function [weights, objective, keep_going] = calc_objective(Xloc, Zloc, Aloc, ...
        lambda_sq, K, old_obj)
% inputs:
% ----* Xloc: current N x D data matrix
% ----* Zloc: current N x k feature belonging matrix
% --------* (k = current # of features)
% ----* Aloc: current k x D matrix of feature means
% ----* lambda_sq: value of lambda^2 in the objective (zero if none)
% ----* K: if finite, fixed K value (otherwise Inf)
% ----* old_obj: old objective value, for comparison
% outputs:
% ----* weights: N x 1 unnormalized vector of weights
% ----* objective: the objective value given the inputs
% ----* keep_going: a boolean value (true [1]  means keep iterating)
%
% ---------------------------------------
% BP-MEANS Copyright 2013, 2014 Tamara Broderick (tab@stat.berkeley.edu)
%
% BP-MEANS is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% BP-MEANS is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with BP-MEANS.  If not, see <http://www.gnu.org/licenses/>.
% ---------------------------------------

        weights = sum((Xloc - Zloc * Aloc).^2,2);
      	k = size(Zloc, 2);

        % how to count # features in the objective
        if(K < Inf)
		k_obj = K;
	else
		k_obj = k;
	end
	objective = sum(weights) + lambda_sq * k_obj;
        % case 1: K is fixed and finite
        keep_going = (K < Inf)*(k <= K) + ...
                ... % case 2: we are finding K
                (~(K < Inf))*(objective < old_obj);
end

