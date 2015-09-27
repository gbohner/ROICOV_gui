function update_visualize( y,H, W, ops,subs,varargin)
%UPDATE_VISUALIZE Summary of this function goes here
%   Detailed explanation goes here

if nargin >5
  show_numbers = varargin{1};
else
  show_numbers = 0;
end

if nargin >6
  show_specific = varargin{2};
else
  show_specific = [];
end

NSS = ops.NSS;
KS = ops.KS;
Nmaps = size(W,3);
isfirst = zeros(1,Nmaps);
for i = 1:NSS
    isfirst(subs{i}(1)) =  1;
end
m = size(W,1);
d = (m-1)/2;
xs  = repmat(-d:d, m, 1);
ys  = xs';
rs2 = (xs.^2+ys.^2);

%     % which map is the cell map?
%     S_area = zeros(NSS,1);
%     S4_area = zeros(NSS,1);
%     for i =1:NSS
%         S_area(i) = sum(sum(rs2.*W(:,:,subs{i}(1)).^2)).^.5;
%     end
%     est_diam = 2*S_area+1;
%     [~, cell_map] = min((est_diam - ops.cell_diam).^2);


%     if cell_map>1
% %         V0 = V;
% %         V(subs{1})          = V0(subs{cell_map});
% %         V(subs{cell_map})   = V0(subs{1});
% %         W0 = W;
% %         W(:,:,subs{1})          = W0(:,:,subs{cell_map});
% %         W(:,:,subs{cell_map})   = W0(:,:,subs{1});
% 
%         cell_map = 1;
%     end

    sign_center = -squeeze(sign(W(d,d,:)));
    sign_center(:) = 1;
    Wi = reshape(W, m^2, Nmaps);
    nW = max(abs(Wi), [], 1);
    %             nW = sum(Wi.^2, 1).^.5;

    Wi = Wi./repmat(sign_center' .* nW, m*m,1);

    figure(11); visualSS(Wi, 4, KS, [-1 1]); colormap('jet')


    figure(13);colormap('jet')
%         Im = y(:,:,ex);
    Im = y;
    sig = nanstd(Im(:)); mu = nanmean(Im(:)); M1= mu - 4*sig; M2= mu + 12*sig;
    imagesc(Im, [M1 M2]);
    colormap gray
    mycolor = 'rymg';

    H0      = H;
    elem.ix = H0(:,1);
    elem.iy = H0(:,2);
    elem.map = ones(length(H),1);



    if isempty(show_specific)
      show_specific = 1:length(elem.iy);
    end
    hold on
    for i12 = show_specific%[1,5,10,20,30, 50] %1:length(elem.iy)
      if show_numbers
        text(elem.iy(i12), elem.ix(i12), num2str(i12), 'Color',mycolor(mod(elem.map(i12)-1,length(mycolor))+1),'FontSize',16,'FontWeight','bold');
      else
        plot(elem.iy(i12), elem.ix(i12), 'or' , 'Linewidth', 2, 'MarkerSize', 4, 'MarkerFaceColor', mycolor(mod(elem.map(i12)-1,length(mycolor))+1), 'MarkerEdgeColor', mycolor(mod(elem.map(i12)-1,length(mycolor))+1))
      end
%             text(elem.iy(i12), elem.ix(i12), num2str(i12), 'Color',mycolor(mod(elem.map(i12)-1,length(mycolor))+1));
%             title(i12);
%             waitforbuttonpress; 
    end

    hold off

    drawnow

end

