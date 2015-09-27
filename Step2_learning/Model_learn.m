function [ output_args ] = Model_learn( tmp )
%MODEL_LEARN Summary of this function goes here
%   Detailed explanation goes here

if ~isdir([tmp.workdir 'Model']), mkdir(tmp.workdir, 'Model'); end;

%Collect all preprocessed files into relevant cell arrays, and during
%learning we will loop through the cells arrays.

%Firstly load the opt file shared amongst all files.
load([tmp.workdir 'Preprocessed' filesep tmp.ToLoad{1}(1:end-4) tmp.timestamp '.mat'],'opt');

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

W  = Model_initialize( opt );

%Learn from only half the expected amount of cells
opt.cells_per_image = round(opt.cells_per_image./2);

%% Run the learning
for n = 1:opt.niter 
    
    
    disp('start');
    tic;    
    [ Wy, Akki, GW] =  MEAN_compute_filters( y, W );
    if opt.mask
      [ I, H, X, dLL] = MEAN_extract_coefs( Wy, GW, y, W, Akki, opt, UserMask );
    else
      [ I, H, X, dLL] = MEAN_extract_coefs( Wy, GW, y, W, Akki, opt );
    end
        
    model.W = W;
    model.opt = opt;
    
    save([tmp.workdir 'Model/model_' tmp.timestamp '_iter' num2str(n) '.mat'], 'model');
    
    W = MEAN_update_dict(n,y,I,H,W,opt);
    
    if opt.fig
      mysubs = {[1:(opt.NSS*opt.KS)]};

      update_visualize( y_orig{1},H(I==1,:),W,opt,mysubs);
    end
    
    pause(0.2);
    
    
    if rem(n,1)==0
        fprintf('Iteration %d , elapsed time is %0.2f seconds\n', n, toc)
    end
    

end

end

