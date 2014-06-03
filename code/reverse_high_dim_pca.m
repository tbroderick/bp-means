function Yout = reverse_high_dim_pca(Yin, V, meanXorig, Ndata)
% recovers matrix in the original dimensions
% given the PCAed version (first dimension is M
% since this isn't usually the original data matrix
% we're dealing with)
% inputs:
% ----* Yin: M x N_pca_dims data matrix
% ----* V: the principal components
% ----* meanXorig: mean subtracted from raw data
% ----* Ndata: # data points in raw data; Ndata > 1
% outputs:
% ----* Yout: M x D data matrix
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

	[M, N_pca_dims] = size(Yin);

	% reverse PCAing
	Yout = Yin * V';
	Yout = (Yout + repmat(meanXorig, M, 1)) * sqrt(Ndata - 1);

end
