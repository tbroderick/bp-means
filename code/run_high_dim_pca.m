function [Xout, V, meanXin] = run_high_dim_pca(Xin, N_pca_dims)
% Runs PCA on the input data Xin, which is assumed to have high
% second dimension D
% inputs:
% ----* Xin: N x D data matrix; N > 1
% ----* N_pca_dims: number of PCA dimensions to keep
% outputs:
% ----* Xout: output matrix in new space
% ----* V: the desired principal components

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
