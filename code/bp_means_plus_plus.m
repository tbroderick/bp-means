function [Z,A] = bp_means_plus_plus(X, lambda_sq, K, verbose)
% Performs BP-means++ initialization (both finite and variable K versions)
% inputs:
% ---- * X: an N x D matrix for N data points with D dimensions each
% ---- * lambda_sq: the penalty for features in the objective
% -------- (set to zero for no penalty)
% ---- * K: set to a finite number for a fixed number of features
% -------- (set to Inf to find a number of features)
% ---- * verbose: if true, writes status updates to screen
% outputs:
% ---- * Z: initial N x k feature belonging matrix (for k either K or dynamic)
% ---- * A: initial k x D feature means matrix
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

% extract dimensions
[N,D] = size(X);

% Initialize Z and A to represent no features (yet)
Z = zeros(N,0); % "zeros" so Z * A will be all-zeros matrix
A = zeros(0,D);
Zprop = Z;
Aprop = A;

old_obj = Inf; % sure to enter the while loop once
[weights, objective, keep_going] = calc_objective(...
	X,Zprop,Aprop,lambda_sq,K,old_obj);

% iterate until initialization is finished
while(keep_going)
	% update current estimates with latest proposals
	Z = Zprop;
	A = Aprop;

	% randomly sample a data point to provide the new feature
	if(sum(weights) > 0)
		n = randsample(N,1,true,weights);
	else
		n = randsample(N,1);
	end

	% obtain the proposed new feature mean and belonging matrix
	Ak = X(n,:) - Z(n,:) * A;
	Zprop = Z;
	k = size(Z,2)+1;
	Zprop(:,k) = (sum((X - Z*A - ones(N,1)*Ak).^2,2) < sum((X-Z*A).^2,2));
	Aprop = [A; Ak];

	% if K is finite and fixed, check whether K is reached yet
	% if K is dynamic, check whether objective still decreasing
	old_obj = objective;
	[weights, objective, keep_going] = calc_objective(...
		X,Zprop,Aprop,lambda_sq,K,old_obj);
	if(verbose)
		disp(sprintf('BP-means++ (prop K = %d): old obj: %f, new obj: %f', ...
			k, old_obj, objective));
	end
end

end

