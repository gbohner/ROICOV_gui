function [ Wy, Akki, GW] = MEAN_compute_filters( y, W)
%COMPUTE_FILTERS Summary of this function goes here
%   Detailed explanation goes here

Nmaps = size(W,3); % number of filters
m = size(W,1); % filter size
d = (m-1)/2;
PrVar = 1000;

Wy = cell(size(y));
GW = zeros(2*m-1, 2*m-1, Nmaps, Nmaps);


% Compute the covariance matrices between filters

  for i = 1:Nmaps
      for j = 1:Nmaps
          GW(:,:,j,i) = conv2(W(:,:,i), rot90(W(:,:,j),2), 'full'); % Gram matrix of basis functions for finite distances
          % Gram matrix structure: dim1-2: position shift (inverse of shift
          % in image space), dim3: The shifted basis function, dim4: the
          % basis function we're computing the Wy dimension for. That's why
          % the order of j and i (KEEP IN MIND!)
          
          %NOTE: filter2(h, A) = conv2(A, rot90(h,2) );
      end
  end
  A = squeeze(GW(m, m, :, :)); %diagonal (non-shifted sum of Hadamard product of basis function)
  Akki = zeros(size(A));
  Akki = A + 1/PrVar * eye(size(A));
  Akki = inv(Akki);
  

% Do the filtering

for i1 = 1:numel(y)
  Wy{i1} = zeros([size(y{i1}), Nmaps]);
  for map = 1:Nmaps
      Wy{i1}(:,:,map) = filter2(W(:,:,map), y{i1}, 'same');
  end

end

