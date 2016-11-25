function result = fit_fixedparams_g2s(varargin)

result=varargin{1};
nBatch=varargin{2};
%%baseline,contrast,gamma(1/tau),exponent
start_val=varargin{3};
fit_flag=varargin{4};
min_val=varargin{5};
max_val=varargin{6};

list_of_qs=1:numel(result.dynamicQs{nBatch});

which_phi=1;

FIT1=1; %%single exp
FIT2=1; %%stretched exp

warning('off','MATLAB:NonScalarInput');
warning('off','MATLAB:singularMatrix');

delay=result.delay{nBatch};
if (size(delay,1) == 1)
    delay=delay';
end

for which_q=list_of_qs 
    g2raw=squeeze(result.g2avg{nBatch}(which_q,which_phi,:));
    g2rawErr=squeeze(result.g2avg{nBatch}(which_q,which_phi,:));
    
    g2raw(isnan(g2raw))=1;
    g2rawErr(isnan(g2rawErr))=1;

%%%%%%%%FIT 
if (FIT1 == 1)
    [fit1data,baseline,contrast,gamma,baseline_err,contrast_err,gamma_err,resnorm]= ...
        fit1singleexp(delay,g2raw,g2rawErr,start_val,fit_flag,min_val,max_val);   
                fit1_results(which_q,which_phi,1)=baseline;
                fit1_results(which_q,which_phi,2)=contrast;
                fit1_results(which_q,which_phi,3)=gamma;
    
                sig1_results(which_q,which_phi,1)=baseline_err;
                sig1_results(which_q,which_phi,2)=contrast_err;
                sig1_results(which_q,which_phi,3)=gamma_err;

                g2avgFIT1(which_q,which_phi,:)=fit1data;
                
                resnormFIT1(which_q,which_phi,:)=resnorm;
                
end
        
if (FIT2 == 1)
    [fit2data,baseline,contrast,gamma,exponent,baseline_err,contrast_err,gamma_err,exponent_err,resnorm]= ...
        fit2stretchedexp(delay,g2raw,g2rawErr,start_val,fit_flag,min_val,max_val);
    fit2_results(which_q,which_phi,1)=baseline;
    fit2_results(which_q,which_phi,2)=contrast;
    fit2_results(which_q,which_phi,3)=gamma;
    fit2_results(which_q,which_phi,4)=exponent;
    
    sig2_results(which_q,which_phi,1)=baseline_err;
    sig2_results(which_q,which_phi,2)=contrast_err;
    sig2_results(which_q,which_phi,3)=gamma_err;
    sig2_results(which_q,which_phi,4)=exponent_err;
    
    g2avgFIT2(which_q,which_phi,:)=fit2data;
    
    resnormFIT2(which_q,which_phi,:)=resnorm;
    
end
        
        clear baseline baseline_err contrast contrast_err
        clear gamma gamma_err exponent exponent_err
             
end

if (FIT1 == 1)
    result.g2avgFIT1{nBatch}= {};
    result.baselineFIT1{nBatch}={};
    result.contrastFIT1{nBatch}={};
    result.tauFIT1{nBatch}={};
    result.baselineErrFIT1{nBatch}={};
    result.contrastErrFIT1{nBatch}={};
    result.tauErrFIT1{nBatch}={};
    
    result.g2avgFIT1{nBatch}= g2avgFIT1;
    result.baselineFIT1{nBatch}=fit1_results(:,:,1);
    result.contrastFIT1{nBatch}=fit1_results(:,:,2);
    result.tauFIT1{nBatch}=1./fit1_results(:,:,3);
    result.baselineErrFIT1{nBatch}=sig1_results(:,:,1);
    result.contrastErrFIT1{nBatch}=sig1_results(:,:,2);
    result.tauErrFIT1{nBatch}=sig1_results(:,:,3)./fit1_results(:,:,3).^2;
    
    result.chisqFIT1{nBatch}=resnormFIT1;
end

if (FIT2 == 1)
    result.g2avgFIT2{nBatch}= {};
    result.baselineFIT2{nBatch}={};
    result.contrastFIT2{nBatch}={};
    result.tauFIT2{nBatch}={};
    result.exponentFIT2{nBatch}={};
    result.baselineErrFIT2{nBatch}={};
    result.contrastErrFIT2{nBatch}={};
    result.tauErrFIT2{nBatch}={};
    result.exponentErrFIT2{nBatch}={};    

    result.g2avgFIT2{nBatch}= g2avgFIT2;
    result.baselineFIT2{nBatch}=fit2_results(:,:,1);
    result.contrastFIT2{nBatch}=fit2_results(:,:,2);
    result.tauFIT2{nBatch}=1./fit2_results(:,:,3);
    result.exponentFIT2{nBatch}=fit2_results(:,:,4);
    result.baselineErrFIT2{nBatch}=sig2_results(:,:,1);
    result.contrastErrFIT2{nBatch}=sig2_results(:,:,2);
    result.tauErrFIT2{nBatch}=sig2_results(:,:,3)./fit2_results(:,:,3).^2;
    result.exponentErrFIT2{nBatch}=sig2_results(:,:,4);
    
    result.chisqFIT2{nBatch}=resnormFIT2;

end




end
