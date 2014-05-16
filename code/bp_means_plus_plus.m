function [Z,A] = bp_means_plus_plus(X, lambda_sq, K)
% Performs BP-means++ initialization (both finite and variable K versions)
% inputs:
% ---- * X: an N x D matrix for N data points with D dimensions each
% ---- * lambda_sq: the penalty for features in the objective
% -------- (set to zero for no penalty)
% ---- * K: set to a finite number for a fixed number of features
% -------- (set to Inf to find a number of features)
% outputs:
% ---- * Z: initial N x k feature belonging matrix (for k either K or dynamic)
% ---- * A: initial k x D feature means matrix

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
	disp(sprintf('BP-means++ (prop K = %d): old obj: %f, new obj: %f', ...
		k, old_obj, objective));
end

end

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
	
	weights = sum((Xloc - Zloc * Aloc).^2,2);
	k = size(Zloc, 2);

	% how to count # features in the objective
	k_obj = (K < Inf)*K + (~(K < Inf))*k;
	objective = sum(weights) + lambda_sq * k_obj;
	% case 1: K is fixed and finite
	keep_going = (K < Inf)*(k <= K) + ...
		... % case 2: we are finding K
		(~(K < Inf))*(objective < old_obj);
end

