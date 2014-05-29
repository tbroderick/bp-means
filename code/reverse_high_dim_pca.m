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

	[M, N_pca_dims] = size(Yin);

	% reverse PCAing
	Yout = Yin * V';
	Yout = (Yout + repmat(meanXorig, M, 1)) * sqrt(Ndata - 1);

end
