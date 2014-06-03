======================== 
======== README ========
======================== 

======================== 
0. Citation and Licensing
======================== 

If you use this code and/or the simulated data set, please cite 
Broderick, T., Kulis, B. and Jordan, M. I. "MAD-bayes: MAP-based asymptotic derivations from Bayes." International Conference on Machine Learning. 2013.

If you use the tabletop data set, please cite
Griffiths, T. L., and Ghahramani, Z. "The Indian Buffet Process: An introduction and review." The Journal of Machine Learning Research 12 (2011): 1185-1224.

Note: This is the README for BP-MEANS.

BP-MEANS Copyright 2013, 2014 Tamara Broderick (tab@stat.berkeley.edu)

BP-MEANS is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

BP-MEANS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with BP-MEANS.  If not, see <http://www.gnu.org/licenses/>.

======================== 
1. Example use cases
======================== 

The following examples assume the user is running Matlab from within the “code” directory.

(0.0) Find exactly 4 features in the simulated png dice data without running PCA on the pictures first. Return the best run after 1000 random restarts.

>> [Z,A,pics] = find_picture_features('../data/simulated','png','Nstarts',1000,'Kinput',4);

(0.1) Find features of an unknown cardinality that optimize the BP-means objective with lambda^2 penalty equal to 40. Use the simulated png dice data. Don’t run PCA first. Return the best run after 1000 random restarts.

>> [Z,A,pics] = find_picture_features('../data/simulated','png','Nstarts',1000,'lambda_sq',40);

(0.2) Find exactly 5 features in the jpg tabletop data after running PCA (with 100 dimensions) on the pictures first. Return the best run after 1000 random restarts. Note: this saves the results of PCA for later use in the file “data/tabletop/results/pca_results.mat”.

>> [Z,A,pics] = find_picture_features('../data/tabletop','jpg','pca_dims',100,'Nstarts',1000,'Kinput',5);

(0.3) Find features of an unknown cardinality that optimize the BP-means objective with lambda^2 penalty equal to 20. Use the jpg tabletop data. Use the principal components already found in the previous computation. Return the best run after 1000 random restarts.

>> [Z,A,pics] = find_picture_features('../data/tabletop','jpg','pca_dims',100,'pca_file','../data/tabletop/results/pca_results.mat','Nstarts',1000,'lambda_sq',20);

======================== 
2. Data overview
======================== 

The “data” directory contains two folders: “simulated” and “tabletop”.

The “simulated” folder contains the code “simulate_feature_data.m” for simulating noiseless “dice” pictures. In these pictures, the natural interpretation is that the features should cover all the dice pips, or dots. A sample collection of 100 simulated data points generated from this code is included.

The “tabletop” folder contains a data set described in the following paper and provided by the authors of that paper:
—————
Griffiths, T. L., and Ghahramani, Z. "The Indian Buffet Process: An introduction and review." The Journal of Machine Learning Research 12 (2011): 1185-1224.
—————
In these pictures, the natural interpretation is that the features should cover the different combinations of items on the tables. E.g., one possible feature allocation would make each of the following a feature: (1) the table and background together, (2) the Klein bottle, (3) the handaxe, (4) the cell phone, (5) the $20 bill. 

======================== 
3. Code overview
======================== 

Most code is in the “code” directory. The one exception is the following code in the directory “data/simulated”:

* simulate_feature_data.m: Simulates dice data, where the features are (modulo equivalency classes) the dice pips/dots. Takes as input the number of data points to generate and the number of features/pips/dots.

The main code file in the “code” directory is the following:

* find_picture_features.m: Extracts features from user-specified picture data using BP-means. It requires the user to specify the directory with the image data and the format of the image data (e.g., jpg, png). The user should also specify either the number of features (optional argument ‘Kinput’) or the lambda^2 penalty value (optional argument ‘lamdba_sq’).

The remaining files support “find_picture_features.m”:

* bp_means_plus_plus.m: Runs the BP-means++ initialization.
* bp_means.m: Runs BP-means (with either fixed number of features or with a finite lambda^2 penalty).
* calc_objective.m: Calculates the BP-means objective value for a particular feature allocation.
* run_high_dim_pca.m: Finds the principal components for a specified data matrix.
* reverse_high_dim_pca.m: Takes data in the principal components space and returns it to the original problem space.

======================== 
4. Some example outputs
======================== 

* Running (0.0) in Section 0 above returns the following objective values for different K. Note that we expect that an objective value of 0.0 should be obtainable for the right number of features (4) since this data is simulated exactly from a feature allocation without noise. We expect optimal objectives to decrease as K increases since we are using lambda^2 = 0 here, and more features gives a better fit for the Frobenius norm part.

K = 1 ; Best objective found: 768.5
K = 2 ; Best objective found: 518.1
K = 3 ; Best objective found: 252.0
K = 4 ; Best objective found: 0.0

* Similarly, running (0.2) in Section 0 above returns the following objective values for different K. Note that we expect the true number of features to be 5, representing one feature for each of: the table and the four distinct objects that may be on the table. There is a noticeable “elbow” at K = 5 in the following.

K = 1 ; Best objective found: 615.9
K = 2 ; Best objective found: 423.2
K = 3 ; Best objective found: 295.3
K = 4 ; Best objective found: 205.8
K = 5 ; Best objective found: 161.2
K = 6 ; Best objective found: 156.1
K = 7 ; Best objective found: 150.9
K = 8 ; Best objective found: 143.5
