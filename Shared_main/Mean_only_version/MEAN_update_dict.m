function W = MEAN_update_dict(n,y,I,H,W,opt)
%UPDATE_DICT Summary of this function goes here
%   Detailed explanation goes here



m = size(W,1);
d = (m-1)/2;
xs  = repmat(-d:d, m, 1);
ys  = xs';
%   rs2 = (xs.^2+ys.^2);
    
for j = 1:1
        % add back the contribution from these maps
%     imap = zeros(1, Nmaps);
%     imap(subs{j}) = 1;


    [dW] = MEAN_pick_patches(y,I,H,W);
    COV_mean = zeros(size(dW,1));
    for i1 = 1:size(dW,1)
      for j1 = 1:size(dW,1)
        COV_mean(i1,j1) = nansum(dW(i1,:).*dW(j1,:));
      end
    end

    shifted_COV_mean = zeros(size(COV_mean));
    
    %remove the mean covariance of COV_mean and COV_cov
    for i11 = 1:size(COV_mean,2)
      shifted_COV_mean(:,i11) = circshift(COV_mean(:,i11), -i11+1);
    end
    shifted_COV_mean = bsxfun(@minus,shifted_COV_mean, mean(shifted_COV_mean,2));
    for i1 = 1:size(COV_mean,2)
      COV_mean(:,i1) = circshift(shifted_COV_mean(:,i1), i1-1);
    end

    COV_mean = (COV_mean - mean(COV_mean(:)))./std(COV_mean(:));


    COV = COV_mean;

    [U, Sv] = svd(COV);
    
    xr      = U' * dW;
    signs   = 2 * (mean(xr>0, 2)>0.5) - 1;
    U = U .* repmat(signs', [m^2 1]);

    if opt.MP
        U(:,2:end) = 0;
    elseif opt.inc && opt.warmup
        k = ceil(n/opt.inc);
        U(:,(1+k):end) = 0;
%                 UR(:,1+k:end) = 0;
    end

    W = reshape(U(:,1:size(W,3)), m, m, []);


    absW = abs(W(:,:,1));
    absW = absW/mean(absW(:));
    x0 =  mean(mean(absW .* xs));
    y0 =  mean(mean(absW .* ys));

    xform = [1 0 0; 0 1 0; -x0 -y0 1];
    tform_translate = maketform('affine',xform);

    for k = 1:size(W,3)
        W(:,:,k) = imtransform(W(:,:,k), tform_translate,...
            'XData', [1 m], 'YData',   [1 m]);
        W(:,:,k) = W(:,:,k) - mean2(W(:,:,k));
        if std2(W(:,:,k))~=0
          W(:,:,k) = W(:,:,k)./std2(W(:,:,k));
        end
    end
end


end

