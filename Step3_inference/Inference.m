function [ y_orig, x_coord, y_coord, dLL ] = Inference( tmp )
%INFERENCE Summary of this function goes here
%   Detailed explanation goes here

if ~isdir([tmp.workdir 'Results']), mkdir(tmp.workdir, 'Results'); end;

%Load the model (hopefully the same opt file as in the preprocessed files)
load(tmp.model, 'model')
W = model.W;
opt = model.opt;

%Load the data from the preprocessed files
y={};
y_orig = {};
if opt.mask
  UserMask = {};
end
  

for i1 = 1:numel(tmp.ToLoad)
  bla = load([tmp.workdir 'Preprocessed' filesep tmp.ToLoad{i1}(1:end-4) tmp.timestamp '.mat'],'y','y_orig');
  y{i1} = bla.y;
  y_orig{i1} = bla.y_orig;
  if opt.mask
    bla = load([tmp.workdir 'Preprocessed' filesep tmp.ToLoad{i1}(1:end-4) tmp.timestamp '.mat'],'UserMask');
    UserMask{i1} = bla.UserMask;
  end
end

opt.cells_per_image = tmp.infer_num;


[ Wy, Akki, GW] =  MEAN_compute_filters( y, W );
if opt.mask
  [ I, H, X, dLL] = MEAN_extract_coefs( Wy, GW, y, W, Akki, opt, UserMask );
else
  [ I, H, X, dLL] = MEAN_extract_coefs( Wy, GW, y, W, Akki, opt );
end

% Create a common results file with tmp opts and all the results,
%then separate results by file (keeping the correct timestamp).

%all cells from all files (file number is in 'I', corresponding to the file
%tmp.ToLoad(I(.)) )
save([tmp.workdir '/Results/all_results_' tmp.timestamp '.mat'], 'I', 'H', 'X', 'dLL', 'y_orig', 'W', 'opt', 'tmp','-v7.3');
  

%save cells by filename:
for i1 = 1:numel(y_orig)
  %First weed out the unnecessary
  H_single = H(I==i1,:);
  X_single = X(I==i1,:);
  dLL_single = dLL(I==i1,:);
  y_orig_single = y_orig{i1};
  
  save([tmp.workdir '/Results/' tmp.ToLoad{i1} '_' tmp.timestamp 'results.mat'],'y_orig_single','H_single','X_single','dLL_single');
  %Convert H into x-y coordinates to save in a text file
 for j1 = 1:size(H_single,1)
    y_coord(j1,1) = H_single(j1,1);
    x_coord(j1,1) = H_single(j1,2);
  end
  
  [dLL_single,inds] = sort(dLL_single);
  y_coord = y_coord(inds);
  x_coord = x_coord(inds);
  
  % Show figures;
  if opt.fig
    figure(30+i1);
    imagesc(y_orig{i1}); colormap gray;
    hold on;
    scatter(x_coord,y_coord,10,'r');
  end
  
  
  fileID = fopen([tmp.workdir '/Results/' tmp.ToLoad{i1} '_' tmp.timestamp 'results.txt'],'w');  
  for j1 = 1:length(x_coord)
    fprintf(fileID,'%d %d %5.3f\n', x_coord(j1), y_coord(j1), dLL_single(j1));
  end
  fclose(fileID);
%   
  
 
end

