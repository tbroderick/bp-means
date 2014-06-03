function [Xout, V, meanXin] = run_high_dim_pca(Xin, N_pca_dims)
% Runs PCA on the input data Xin, which is assumed to have high
% second dimension D
% inputs:
% ----* Xin: N x D data matrix; N > 1
% ----* N_pca_dims: number of PCA dimensions to keep
% outputs:
% ----* Xout: output matrix in new space
% ----* V: the desired principal components
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

	[N,D] = size(Xin);
	if(N <= 1)
		error(sprintf('Number of data points too small; N = %d', N));
	end

	Xin = (1/sqrt(N-1))*Xin;
	meanXin = mean(Xin,1);
	Xin = Xin - repmat(meanXin,N,1);
	% about 1.5 or 2x run time: Xin = Xin - ones(N,1)*meanXin;

	% SVD for PCA
	[U, S, V] = svds(Xin, N_pca_dims);
	Xout = Xin * V;	

end
