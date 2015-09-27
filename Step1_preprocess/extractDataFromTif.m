function [y, Y, opt] = extractDataFromTif( tif_path, output_path, varargin )
%EXTRACTDATAFROMTIF Extracts the relavant information from an input tif
%stack 
% - give input tif file name
% - output path for large .mat file
% - other arguments:
%   - options struct
%   -  ...
  

  narg = nargin;
  
  y = [];
  V = [];

  % Default opts
  opt.init_sig1 = 15; %smoothing filter large
  opt.init_sig2 = 0.5; %smoothing filter small
  opt.m = 15; %basis function size
  opt.spatial_scale =1 ; % resize images
  opt.time_scale = 1; % resample time
  opt.data_type = 'frames'; %frames / stack
  opt.src_string = 'Ch2'; %in case of loading multiple frames from a directory, look for this substring to load files
  
  opt.tif_path = tif_path;
  opt.output_path = output_path;
  
  %Merge default and input options
  if nargin>=3
    opt = merge_structs(opt, varargin{1});
  end
  
  if strcmp(opt.data_type, 'stack')
    info = imfinfo(tif_path);
    T = numel(info); % Number of frames
    sz = size(imresize(imread(tif_path,1),opt.spatial_scale)); % Image size
    if T>1
      Is = zeros([T, sz(1), sz(2)]); % Image stack
      for i2 = 1:T
          Is(i2,:,:) = imresize(double(imread(tif_path, i2)),opt.spatial_scale);
      end
    else
      Is = imresize(double(imread(tif_path)),opt.spatial_scale);
    end
  elseif strcmp(opt.data_type, 'frames')
    filepath = fileparts(tif_path);
    allfiles = dir([filepath '/*' opt.src_string '*']);
    T = size(allfiles,1);
    sz = size(imresize(imread([filepath '/' allfiles(1).name]),opt.spatial_scale));
    Is = zeros([T, sz(1), sz(2)]); % Image stack
    for i2 = 1:T
      Is(i2, :,:) = imresize(double(imread([filepath '/' allfiles(i2).name])),opt.spatial_scale,'bicubic');
    end
  end
  
  y = mean(Is,3); %in case of color image
  y_orig = y;
  
  if opt.mask
    h_mask = figure(31);
    imshow(y);
    UserMask = roipoly(mat2gray(y));
    %TODO before asking to do this everytime, once it's done for a file,
    %save the mask and just ask to use the already done mask
    close(h_mask);
  end
  
  if T>1
    V = squeeze(var(Is,1,1));
  else
    V = ones(size(y));
  end
  
  m = opt.m;
  
  % Apply normalizing filters  
  if T>1
    [y, A, B] = normal_img(double(y), opt.init_sig1, opt.init_sig2,V);
  else
    [y, A, B] = normal_img(double(y), opt.init_sig1, opt.init_sig2);
  end
  opt.A = A;
  opt.B = B;
  
  save(output_path, 'y', 'y_orig','V', 'opt','-v7.3');

  if opt.mask
    save(output_path, 'UserMask', '-append');
  end
  
  clearvars -except Y y opt

end
  
  
  

