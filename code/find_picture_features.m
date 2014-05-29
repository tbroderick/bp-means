function [Z,A,pics] = find_picture_features(directory, pic_format, varargin)
% pre-process image data
% then run BP-means
% then post-process the image features
% required inputs:
% ----* directory: string name of directory with image data
% ----* pic_format: a Matlab-readable image format: e.g. jpg, png
% optional inputs:
% ----* lambda_sq: lambda^2 value for penalty
% ----* Kinput: number of features (Inf if unknown in advance)
% ----* Nstarts: number of random starts to perform
% ----* max_iters: maximum number of iterations for one BP-means run
% ----* pca_file: file with pca results pre-calculated
% -------- Should include 'pics', 'princ_comps', and 'mean_pics'
% ----* pca_dims: how many dimensions of PCA to use (if 0, don't use PCA)
% ----* verbose: if true, print bp_means(_plus_plus) status
% outputs:
% ----* Z: the N x K feature belonging matrix (binary)
% ----* A: the K x D matrix of feature means
% ----* pics: (aka X) the N x D data matrix


%%% gather optional inputs
% Default values of optional inputs
options = struct( ...
	'lambda_sq', 0, ... % Default is to have no penalty
	'Kinput', Inf, ... % Default is to assume # features is unknown
	'Nstarts', 1, ... % Default is to run just once
	'max_iters', 10000, ... % Default is a huge max # of iterations
	'pca_file', '', ... % Default is no existing PCA data
	'pca_dims', 0, ... % Default is to not run PCA
	'verbose', false ... % Default is not to print status
);

% read in values of optional inputs
% varargin is array of form NAME VALUE NAME VALUE and so on
while ~isempty(varargin)
	switch(lower(varargin{1})) % put in lower case so case isn't issue
		case 'lambda_sq'
			options.lambda_sq = varargin{2};
			varargin(1:2) = [];

		case 'kinput'
			options.Kinput = varargin{2};
			varargin(1:2) = [];

		case 'nstarts'
			options.Nstarts = varargin{2};
			varargin(1:2) = [];
		
		case 'max_iters'
			options.max_iters = varargin{2};
			varargin(1:2) = [];

		case 'pca_file'
			options.pca_file = varargin{2};
			varargin(1:2) = [];

		case 'pca_dims'
			options.pca_dims = varargin{2};
			varargin(1:2) = [];

		case 'verbose'
			options.verbose = varargin{2};
			varargin(1:2) = [];

		otherwise 
			error(['Undefined option name: ', varargin{1}]);

	end
end

%%% some preparation
% make sure directory name ends in "/"
if(directory(end) ~= '/')
	directory = [directory,'/'];
end
% make sure file format doesn't have a "."
if(pic_format(1) == '.')
	pic_format = pic_format(2:end);
end

% prepare place to store results
results_dir = [directory, 'results/'];
% check for existing results directory
% 7 is the code for a directory
if(exist(results_dir,'dir') ~= 7)
	% make if doesn't already exist
	mkdir(results_dir);
end

%%% read in data
% find the pictures
pic_names = dir([directory,'*.',pic_format]);
N = length(pic_names); % Number of data points

% read in each picture if PCA not already computed
if(length(options.pca_file) == 0)
	pic_size = []; % we'll use this later; assumes all sizes are the same
	pics = [];
	disp(sprintf('Reading in %d pictures', N));
	tic;
	for(n = 1:N)
		pic_file_name = [directory,pic_names(n).name];
		this_pic = imread(pic_file_name);
		pic_size = size(this_pic);
		% flatten picture to an array of pixels x channels
		pics(n,:) = reshape(this_pic, prod(pic_size), 1);

		% sanity check on reading in pics
		%disp(pic_size)
		%test = reshape(pics(n,:), pic_size);
		%test_out_name = [directory,'test',pic_names(n).name];
		%imwrite(test,test_out_name);
	end
	time_read = toc;
	disp(sprintf('--- time: %f s', time_read));
	
	% put data between 0 and 1
	pics = pics/255;
end

%%% pre-process data
% check if PCA already run; run PCA if desired
if(length(options.pca_file) > 0)
	load(options.pca_file);
	disp('Loaded pre-computed PCA data');
elseif(options.pca_dims > 0)
	disp(sprintf('Running PCA with %d components', ...
		options.pca_dims));
	tic;
	[pics, princ_comps, mean_pics] = run_high_dim_pca(...
		pics, options.pca_dims);
	time_pca = toc;
	disp(sprintf('--- time: %f s', time_pca));

	% save pca results
	save([results_dir,'pca_results.mat'], ...
		'pics', 'pic_size', 'princ_comps', 'mean_pics');	
else
	disp('Not running PCA');
end

%%% multiple random restarts
best_objective = Inf;
init_time = zeros(options.Nstarts,1);
run_time = zeros(options.Nstarts,1);
for(r = 1:options.Nstarts) 
	% random permutation of the data
	rand_order = randperm(N);
	[tmp, reverse_rand_order] = sort(rand_order);

	% run BP means initialization
	tic;
	[Zinit,Ainit] = bp_means_plus_plus( ...
		pics(rand_order,:), options.lambda_sq, ...
		options.Kinput, options.verbose);
	init_time(r) = toc;

	% run BP means
	tic;
	%Zprop = Zinit;
	%Aprop = Ainit;
	%[tmp1, new_objective, tmp2] = calc_objective( ...
	%	pics, Zprop, Aprop, options.lambda_sq, Inf, Inf);
	[Zprop,Aprop,new_objective] = bp_means( ...
		pics(rand_order,:), Zinit, Ainit, ...
		options.lambda_sq, options.Kinput, ...
		options.max_iters, options.verbose);
	run_time(r) = toc;

	if(new_objective < best_objective)
		Z = Zprop(reverse_rand_order,:);
		A = Aprop;
		best_objective = new_objective;
	end

	disp(sprintf(['Random restart # %d / %d; ', ...
		'obj value: %f, # features: %d'], ...
		r, options.Nstarts, ...
		new_objective, size(Zprop,2) ...
		));
end

% running times summaries
disp(sprintf('Avg init time: %f; avg run time: %f', ...
	mean(init_time), mean(run_time)));
disp(sprintf('Total init time: %f; total run time: %f', ...
	sum(init_time), sum(run_time)));
disp(sprintf('Best objective: %f, # features: %d', ...
	best_objective, size(A,1)));

%%% save results
lambda_sq = options.lambda_sq;
Kinput = options.Kinput;
pca_dims = options.pca_dims;
save([results_dir,'bp_means_analysis.mat'], ...
	'pics', ...
	'Z', 'A', 'lambda_sq', 'Kinput', ...
	'pca_dims' ...
	);

%% output A in pictures
Kout = size(A,1);
if(Kout > 0)
	disp(sprintf('Creating pictures of the %d feature means', ...
		Kout));
	% add first feature to every feature after the first
	A_to_print = A + [zeros(1,size(A,2)); repmat(A(1,:), Kout-1, 1)];
	% check if PCA was used (and reverse if so)
	if(options.pca_dims > 0)
		A_to_print = reverse_high_dim_pca(...
			A_to_print, princ_comps, mean_pics, N); 	
	end
	% write A to files
	for k = 1:Kout
		this_pic = reshape(A_to_print(k,:), pic_size);
		% convert to [0,1] range
		this_pic = min(max(this_pic,0),1);
		Ak_pic_name = [results_dir,sprintf('A_%d.',k),pic_format];
		imwrite(this_pic, Ak_pic_name);
	end
else
	disp('There are 0 feature means to output');
end

end

