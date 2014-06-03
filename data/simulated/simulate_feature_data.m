function simulate_feature_data(N, K)
% Simulates datasets with rudimentary features.
% Features are chosen as independent Bernoullis
% with the same success probability for each pt.
% inputs:
% ----* N: number of data points to generate
% ----* K: number of features to generate 
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

% form feature matrix
% implicitly each feature has Bernoulli prob 0.5
Z = randi(2,N,K)-1;

% Find the smallest square integer larger than K
N_blocks_per_edge = ceil(sqrt(K));

% form features
block_size = 3;
padding = 2;
grid_size = block_size + 2*padding;
full_edge = grid_size * N_blocks_per_edge;
A = zeros(K, full_edge * full_edge);
for k = 1:K
	block_row = floor((k-1)/N_blocks_per_edge);
	block_col = mod(k-1,N_blocks_per_edge);
	kpic = zeros(full_edge, full_edge);
	
	loc_rows = block_row * grid_size + padding + (1:block_size);
	loc_cols = block_col * grid_size + padding + (1:block_size);

	kpic(loc_rows,loc_cols) = 255;
	A(k,:) = reshape(kpic,1,full_edge*full_edge);
end

% data matrix from feature belonging and features
X = Z * A;

% output data points
for n = 1:N
	npic = reshape(X(n,:),full_edge,full_edge);
	% Note: using png here since jpg introduces artifacts
	% and lossless jpg can't be read by most normal programs
	imwrite(uint8(npic),sprintf('sim_pic_%d.png',n));
end



