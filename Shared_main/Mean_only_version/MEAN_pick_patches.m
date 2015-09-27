function [py] = MEAN_pick_patches( y,I, H, W, varargin)
%PICK_PATCHES Summary of this function goes here
%   Detailed explanation goes here

m = size(W,1);
d = (m-1)/2;

if nargin > 6
  Mask = varargin{1}; %Use user-defined mask initially
else
  Mask = cell(size(y));
  for i1 = 1:numel(y)
    Mask{i1} = ones(size(y{i1},1),size(y{i1},2)); % Possible cell placements (no overlap / nearby cells);
  end
end

%Make sure not to take overlapping areas for learning
for i1 = 1:numel(y)
  sz = size(y{i1});
  j1 = 1;
  while j1<=size(H,1)
    if I(j1) ~= i1, j1 = j1+1; continue; end;
    row = H(j1,1);
    col = H(j1,2);
    if Mask{i1}(row,col) == 0 %overlapping with already selected area, skip it
      H(j1,:) = [];
      I(j1) = [];
    else
      [yinds,~] = mat_boundary(sz(1:2), row-d-1:row+d+1,col-d-1:col+d+1);
      Mask{i1}(yinds{1},yinds{2}) = 0;
      j1 = j1+1;
    end
  end
end


py = zeros(m^2,size(H,1));


%Pick the patches
for j1 = 1:size(I,1)
  py(:,j1) = get_y_patch(y{I(j1)},H(j1,1),H(j1,2),d);
end

  function out = get_y_patch(y,row,col,d)    
     % Compute changes in yres
     sz = size(y);
    [inds,cut] = mat_boundary(sz(1:2),row-d:row+d,col-d:col+d);
    out = nan(2*d+1);
    out(1+cut(1,1):end-cut(1,2), 1+cut(2,1):end-cut(2,2)) = y(inds{:});
    out = out(:);
  end
            

  

end

