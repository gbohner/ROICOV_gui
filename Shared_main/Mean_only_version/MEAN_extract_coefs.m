function [ I, H, X, L] = MEAN_extract_coefs( Wy, GW, y, W, Akki, opt, varargin )
%EXTRACT_COV_COEFS Summary of this function goes here
%   Detailed explanation goes here

if opt.fig
  h_dl = figure(2);  
  h_yres = figure(4);
end
Nmax = opt.cells_per_image*numel(y); % Maximum number of objects found per image * num image
yres = y;

I = zeros(Nmax,1); % Which image (number)
H = zeros(Nmax,2); % Which pixel within image
X = zeros(Nmax,size(W,3)); % Coefficients
L = zeros(Nmax,1); % Likelihood increase

m = size(W,1);
d = (m-1)/2;

if nargin > 6
  Mask = varargin{1}; %Use user-defined mask initially
else
  Mask = cell(size(Wy));
  for i1 = 1:numel(Wy)
    Mask{i1} = ones(size(Wy{i1},1),size(Wy{i1},2)); % Possible cell placements (no overlap / nearby cells);
  end
end

for i1 =1:numel(Wy)
  dL{i1} = zeros([size(Wy{i1},1),size(Wy{i1},2)]); % delta log likelihood
  xk{i1} = zeros([size(Wy{i1},1),size(Wy{i1},2), size(W,3)]); % Coefficients for the mean image filter reconstruction
  pk{i1} = zeros([size(Wy{i1},1),size(Wy{i1},2), size(W,3)]); % Coefficients for the covariance filter reconstruction
end


% Keep track of which image needs to be updated
im_changed = ones(numel(y),1);
%Also keep track of what's the negative log likelihood decrease in each im
im_dL_max = zeros(numel(y),1);
im_dL_max_pos = zeros(numel(y),2);

for j = 1:Nmax
  
  % Update delta log-likelihoods for each image
  %Reset filter coefficients
  for i1 = 1:numel(y)
    if im_changed(i1) == 0, continue, end
    sz = size(Wy{i1});
    xk{i1}(:) = 0;

    %Update filter coefficients (MAP estimate)
    for map = 1:size(W,3)
      xk{i1} = xk{i1} + reshape(reshape(Wy{i1}(:,:,map),prod(sz(1:2)),1)*Akki(map,1:size(W,3)),sz(1),sz(2),size(W,3));
    end

  %     xk(xk<0) = 0;
  %     pk(pk<0) = 0;

      %Compute delta log-likelihood
      dL{i1}(:,:) = - sum(Wy{i1}(:,:,:).*xk{i1}(:,:,:),3);
      
      % Find maximum decrease in each image
      [AbsMin, ind] = min( dL{i1}(:).*Mask{i1}(:) );
      [row, col] = ind2sub(size(dL{i1}),ind);
      im_dL_max(i1) = AbsMin;
      im_dL_max_pos(i1,:) = [row,col];
  end

  %Check if there is not enough likelihood increase anymore
  if sum(im_dL_max < 0) == 0
    break;
  end
  
  %Find which cell in which image is the best option
  I(j) = find(im_dL_max == min(im_dL_max),1);
  row = im_dL_max_pos(I(j),1);
  col = im_dL_max_pos(I(j),2);
  sz = size(Wy{I(j)});
    
  
  if opt.fig
    set(0,'CurrentFigure',h_dl); imagesc(dL(:,:,1).*Mask(:,:,1)); colorbar; pause(0.05);
%     t = 1;
%     set(0,'CurrentFigure',h_dl); imagesc(- sum(Wy{i1}(:,:,subs{t}).*xk(:,:,subs{t}),3)); colorbar; pause(0.05);
%     set(0,'CurrentFigure',h_dl2); imagesc(- relweight*sum(WC_collapse(:,:,subs{t}).*pk(:,:,subs{t}),3)); colorbar; pause(0.05);
  end
  
  
  
  
  %Affected local area
  % Size(,1) : number of rows, size(,2): number of columns
 [inds, cut] = mat_boundary(sz(1:2),row-m+1:row+m-1,col-m+1:col+m-1);
  
 
 
 % Compute the changes in Wy
 for map = 1:size(W,3)
    Wy{I(j)}(inds{1},inds{2},map) = Wy{I(j)}(inds{1},inds{2},map) - mply(GW(1+cut(1,1):end-cut(1,2),1+cut(2,1):end-cut(2,2),map,1:size(W,3)),squeeze(xk{I(j)}(row,col,1:size(W,3))));
 end
%    figure(4); imagesc(Wy(:,:,1)); colorbar; pause(0.05);

  
%   % Compute changes in yres
%   [yinds, ycut] = mat_boundary(sz(1:2),row-d:row+d,col-d:col+d);
%   for map = subs{type}
%     yres(yinds{1},yinds{2}) = yres(yinds{1},yinds{2}) - W(1+ycut(1,1):end-ycut(1,2),1+ycut(2,1):end-ycut(2,2),map)*xk(row,col,map);
%   end
  
  % Update the patch around the point found
%   Mask(max(row-3,1):min(row+3,end),max(col-3,1):min(col+3,end),type) = 0; % Make it impossible to put cells to close to eachother
  Mask{I(j)}(max(row-1,1):min(row+1,end),max(col-1,1):min(col+1,end),:) = 0; % Make it impossible to put cells to close to eachother
  
  [yinds, ycut] = mat_boundary(sz(1:2),row-m:row+m,col-m:col+m);
  [gridx,gridy] = meshgrid(-m:m,-m:m);
  grid_dist = sqrt(gridx.^2+gridy.^2);
%   grid_dist = 2*(logsig(grid_dist-floor(d/2))-0.5);
  grid_dist = logsig(0.5*grid_dist-floor(d/2)); % favourite distance based function
%   grid_dist = logsig(0.3*grid_dist-floor(d/2)); % favourite distance based function
  grid_dist = grid_dist - min(grid_dist(:)); %normalize
  grid_dist = grid_dist ./ max(grid_dist(:));
  grid_dist = grid_dist(1+ycut(1,1):end-ycut(1,2),1+ycut(2,1):end-ycut(2,2));
  
  Mask{I(j)}(yinds{1},yinds{2},:) = Mask{I(j)}(yinds{1},yinds{2},:).*repmat(grid_dist,[1,1,size(Mask{I(j)},3)]); % Make it impossible to put cells to close to eachother
  
%   if opt.fig
% %     set(0, 'CurrentFigure', h_yres); imagesc(WC_collapse(:,:,1)); colorbar; pause(0.05);
%     set(0, 'CurrentFigure', h_yres); imagesc(yres(:,:,1)); colorbar; pause(0.05);
%   end
  
  
  H(j,:) = [row,col];
  X(j,:) = reshape(xk{I(j)}(row,col,:),1,[]);
  L(j,:) = dL{I(j)}(row,col);
  
  
%   writeVideo(Video_dl, getframe(h_dl));
%   writeVideo(Video_yres, getframe(h_yres));
  
  if opt.fig
    disp([num2str(j) ' objects found, current type: ' num2str(type)]);
  end
end

% close(Video_dl);
% close(Video_yres);
end

