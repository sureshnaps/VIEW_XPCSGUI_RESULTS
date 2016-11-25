function varargout = fake_g2_fits(varargin)

tmp=varargin{1};
nBatch=1;

a=tmp.dynamicQs{nBatch};
b=~isnan(a);%%find only the non-NaN
real_dynamicQs=find(b==1);


tmp.g2avgFIT1{nBatch}=tmp.g2avg{nBatch}*NaN;
tmp.baselineFIT1{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.contrastFIT1{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.tauFIT1{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.baselineErrFIT1{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.contrastErrFIT1{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.tauErrFIT1{nBatch}=ones(length(real_dynamicQs),1)*NaN;

tmp.g2avgFIT2{nBatch}=tmp.g2avg{nBatch}*NaN;
tmp.baselineFIT2{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.contrastFIT2{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.exponentFIT2{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.tauFIT2{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.baselineErrFIT2{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.contrastErrFIT2{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.exponentErrFIT2{nBatch}=ones(length(real_dynamicQs),1)*NaN;
tmp.tauErrFIT2{nBatch}=ones(length(real_dynamicQs),1)*NaN;

if (nargout == 1)
    varargout{1}=tmp;
end


end
