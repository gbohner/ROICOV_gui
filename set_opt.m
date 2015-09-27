function opt = set_opt()
% Set up options

opt = struct(); 

%% Stuff you should be playing around with

% Data extraction and preprocessing
opt.spatial_scale = 1; % Rescale data spatially (make sure to change numbers below accordingly)
opt.m = 19; % ODD NUMBER Basis function size in pixels - approx maximal cell diameter (basis function needs to cover the whole cell)
opt.init_sig1 = 17; %ODD NUMBER smoothing filter large (approx medium cell size)
opt.init_sig2 = 3; %ODD NUMBER smoothing filter small (approx dendrite size - to get rid of)
opt.mask = 1; % Set if the region of interest is only part of the image stack (you probably need this on (=1) every time)

% Learning parameters
opt.KS = 4; % Dimensionality of space (i.e. number of basis functions)
opt.niter = 10; % number of iterations
opt.inc     = 2; % every opt.inc iterations estimate a new subspace (set low for quicker but less stable learning)
opt.cells_per_image = 70; % a rough estimate of the average number of cells per image


%Visualization
opt.fig = 0; %Whether to visualize or not during learning and inference (if 0 you only get output files, if 1 you can check progress of basis function learning and cells found during the process)


%% And stuff that you shouldn't need to be

% Model setup
opt.NSS = 1; % Number of object types (should be 1, this version does not work for multiple)

% Data extraction and preprocessing

opt.time_scale = 1; % Rescale data temporally

opt.data_type = 'stack'; %Input data type (frames / stack)
opt.src_string = '*'; %in case of loading multiple frames from a directory, look for this substring to load files
opt.rand_proj = 50; %20; %0 if no random projections, otherwise number of projection dimensions required
opt.d = opt.rand_proj; %Easier to access later
opt.mom = 1; %Number of moments used

%Learning Parameters
opt.relweight = 10; % weighting between importance of covariance / mean
opt.ex          = 1; % what example image to display during training
opt.MP      = 0; % somewhat redundant: if set to 1 always uses one subspace per object

opt.warmup = 1;
opt.spatial_push = @(grid_dist)logsig(0.3*grid_dist-floor(opt.m/4)); % Specified distance based function (leave as [] if not desired)

end