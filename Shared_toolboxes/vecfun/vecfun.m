function M=vecfun(f,A,dim)
% VECFUN: Apply function to each vector in turn in an array.
%
% Usage:
% M = vecfun(f,A,dim)
%
% f: function taking a column vector as argument and returning as output an
% array of size P
% A: array of size [d1,d2,...,dD]
% dim (defaults to 2): specifies the dimension along which the vectors are
% aligned in A (operates identically to dimension-specific MATLAB commands)
%
% Output M is size [d1,d2,...,P,...,dD] where d[dim] = P, providing a
% shortcut for a for-loop acting on vectors in this dimension and returning
% the output y of f converted into a vector y(:).
%
% Author: Adam W. Gripton (a.gripton -AT- hw.ac.uk) 2012/02/15
%
if nargin<=2 || isempty(dim)
    dim=2;
end

Ad=ndims(A);
if dim>Ad
    error 'dim too large'
end
As=size(A);
Asu=As(dim); %size of the input vectors
Ano=prod(As)/Asu; %number of vectors = total elements / vector size
Adi=(1:Ad);
Adi=Adi(Adi~=dim); %remaining list of dimensions
Arh=reshape(permute(A,[dim,Adi]),[Asu,Ano]); %Arh matrix of column vectors
Mrsk=f(Arh(:,1));
outsize=numel(Mrsk); %test on first element to ascertain output size
Mrs=zeros(outsize,Ano); %and set output matrix accordingly
Mrs(:,1)=Mrsk(:);
for k=2:Ano %for-loop the remainder
    Mrsk=f(Arh(:,k));
    Mrs(:,k)=Mrsk(:);
end
M=ipermute(reshape(Mrs,[outsize,As(Adi)]),[dim,Adi]); %inverse permute to regain original form
