function [Z,A,obj] = bp_means(X, Zinit, Ainit, lambda_sq, Kinput, max_iters, verbose)
% Performs BP-means algorithm (both finite and variable K versions)
% inputs:
% ---- * X: an N x D matrix for N data points with D dimensions each
% ---- * Zinit: initial N x Kinit feature belonging matrix
% ---- * Ainit: initial Kinit x D feature means matrix
% ---- * lambda_sq: the penalty for features in the objective
% -------- (set to zero for no penalty)
% ---- * Kinput: if finite, K is fixed to Kinput;
% -------- if Inf, K is dynamic
% ---- * max_iters: Max # of iterations to run
% ---- * verbose: if true, writes status updates to screen
% outputs:
% ---- * Z: final N x K feature belonging matrix
% ---- * A: final K x D feature means matrix
% ---- * obj: final objective value for Z and A
%
% ---------------------------------------
% BP-MEANS Copyright 2013, 2014 Tamara Broderick (tab@stat.berkeley.edu)
%
% This file is part of BP-MEANS.
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

% initialize
Z = Zinit;
A = Ainit;
[N, D] = size(X);

% calculate the objective from the starting point
diffs = X - Z * A;
new_objective = sum(sum(diffs.^2)) + ...
	lambda_sq * size(Zinit,2);
keep_going = (max_iters > 0); % whether to keep iterating

% start the iteration counter
Niter = 0;
while(keep_going)

	% iterate through each data point
	for(n = 1:N)
		% iterate through existing features
		% not a for loop since # features
		% might change inside the loop;
		% k = feature index
		% K = total # features
		K = size(Z,2);
		k = 1;
		while(k <= K)
			% consider switching Z_{n,k} to other value
			Zprop = 1 - Z(n,k);
			current_diff = X(n,:) - Z(n,:) * A;
			proposal_diff = current_diff - ...
				(Zprop - Z(n,k))*A(k,:);

			% did we lose a feature by switching?
			did_lose_feat = (sum(Z(:,k)) - Z(n,k) == 0);

			% decide whether to switch
			if(sum(current_diff.^2) + did_lose_feat * lambda_sq ...
				> sum(proposal_diff.^2))
				% make switch
				Z(n,k) = Zprop;

				if(did_lose_feat)
					Z(:,k) = [];
					K = K - 1;
					k = k - 1;
					A(k,:) = [];
				end
			end
			
			% go to next feature
			k = k + 1;
		end

		% if # features is dynamic,
		% decide whether to add a new feature
		if( ~(Kinput < Inf) )
			current_diff = X(n,:) - Z(n,:) * A;
			if(sum(current_diff.^2) > lambda_sq)
				K = K + 1;
				Z(:,K) = zeros(N,1);
				Z(n,K) = 1;
				A(K,:) = current_diff;
			end
		end
	end	

	% testing
	%diffs = X - Z * A;
	%disp(sprintf('check: %f, %d', sum(sum(diffs.^2)) + ...
	%	lambda_sq * size(Z,2), size(Z,2)));

	% update A
	A = inv(Z' * Z) * Z' * X;

	% recalculate objective
	old_objective = new_objective;
	diffs = X - Z * A;
	new_objective = sum(sum(diffs.^2)) + ...
		lambda_sq * size(Z,2);

	% update iteration counter
	Niter = Niter + 1;

	% decide whether to continue
	keep_going = (Niter < max_iters) && ...
		(new_objective < old_objective);

	if(verbose)
		disp(sprintf('BP-means (iter %d): old obj: %f, new obj: %f', ...
			Niter, old_objective, new_objective));
	end
end

% return objective value
obj = old_objective;

end
