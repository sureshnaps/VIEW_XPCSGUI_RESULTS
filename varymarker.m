function y = varymarker(varargin)

if nargin ~=1, error('Incorrect input argument'); return; end
x = varargin{1};
if ~isnumeric(x) || length(x)~=1 || x<=0 || round(x)~=x, error('Incorrect input argument'); return; end
mlist = {'s','o','d','^','v','<','>','p','h','+','*','.','x'};
y = repmat(mlist,[1,ceil(x/length(mlist))]);
y = y(1:x);



