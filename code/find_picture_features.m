function [Z,A,pics] = find_picture_features(directory, pic_format, ...
	lambda_sq, Kinput, Nrestarts)
% pre-process image data
% then run BP-means
% then post-process the image features
% inputs:
% ----* directory: string name of directory with jpg data
% ----* pic_format: e.g. jpg, png
% ----* lambda_sq: lambda^2 value for penalty
% ----* Kinput: number of features (Inf if unknown in advance)
% ----* Nrestarts: number of random restarts to perform
% outputs:
% ----* Z: the N x K feature belonging matrix (binary)
% ----* A: the K x D matrix of feature means
% ----* pics: (aka X) the N x D data matrix

% set max iterations for one BP-means run
max_iters = 10000;

% first, find the pictures
pic_names = dir([directory,'*.',pic_format]);
N = length(pic_names); % Number of data points

% read in each picture
pic_size = []; % we'll use this later; assumes all sizes are the same
pics = [];
disp(sprintf('Reading in %d pictures\n', N));
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


% multiple random restarts
best_objective = Inf;
for(r = 1:Nrestarts) 
	disp(sprintf('Random restart # %d / %d', r, Nrestarts));

	% run BP means initialization
	[Zinit,Ainit] = bp_means_plus_plus(pics, lambda_sq, Kinput);

	% run BP means
	[Zprop,Aprop,new_objective] = bp_means(pics, Zinit, Ainit, lambda_sq, Kinput, max_iters);

	if(new_objective < best_objective)
		Z = Zprop;
		A = Aprop;
		best_objective = new_objective;
	end
end

% save results
results_dir = [directory, 'results/'];
% check for existing results directory
% 7 is the code for a directory
if(exist(results_dir,'dir') ~= 7)
	% make if doesn't already exist
	mkdir(results_dir);
end
save([results_dir,'bp_means_analysis.mat'], ...
	'Z', 'A', 'lambda_sq', 'Kinput');

% output A in pictures
Kout = size(A,1);
for k = 1:Kout
	this_pic = reshape(A(1,:) + A(k,:), pic_size);
	Ak_pic_name = [results_dir,sprintf('A_%d.',k),pic_format];
	imwrite(this_pic, Ak_pic_name);
end



end
