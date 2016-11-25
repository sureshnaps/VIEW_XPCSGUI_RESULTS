function result = fit_fixedparams_g2s_avg(varargin)

result=varargin{1};
%%baseline,contrast,gamma(1/tau),exponent
start_val=varargin{2};
fit_flag=varargin{3};
min_val=varargin{4};
max_val=varargin{5};

list_of_qs=1:numel(result.dynamicQs{result.batches2average(1)});

which_phi=1;

FIT1=1; %%single exp
FIT2=1; %%stretched exp

warning('off','MATLAB:NonScalarInput');
warning('off','MATLAB:singularMatrix');

delay=result.delay{result.batches2average(1)};
if (size(delay,1) == 1)
    delay=delay';
end

for which_q=list_of_qs 
        g2raw=squeeze(result.g2Batchavg(which_q,which_phi,:));
        g2rawErr=squeeze(result.g2Batchavg(which_q,which_phi,:));
        
        g2raw(isnan(g2raw))=1;
        g2rawErr(isnan(g2rawErr))=1;
        
%%%%%%%%FIT 
if (FIT1 == 1)
    [fit1data,baseline,contrast,gamma,baseline_err,contrast_err,gamma_err]= ...
        fit1singleexp(delay,g2raw,g2rawErr,start_val,fit_flag,min_val,max_val);   
                fit1_results(which_q,which_phi,1)=baseline;
                fit1_results(which_q,which_phi,2)=contrast;
                fit1_results(which_q,which_phi,3)=gamma;
    
                sig1_results(which_q,which_phi,1)=baseline_err;
                sig1_results(which_q,which_phi,2)=contrast_err;
                sig1_results(which_q,which_phi,3)=gamma_err;

                g2BatchavgFIT1(which_q,which_phi,:)=fit1data;
                
end
        
if (FIT2 == 1)
    [fit2data,baseline,contrast,gamma,exponent,baseline_err,contrast_err,gamma_err,exponent_err]= ...
        fit2stretchedexp(delay,g2raw,g2rawErr,start_val,fit_flag,min_val,max_val);
    fit2_results(which_q,which_phi,1)=baseline;
    fit2_results(which_q,which_phi,2)=contrast;
    fit2_results(which_q,which_phi,3)=gamma;
    fit2_results(which_q,which_phi,4)=exponent;
    
    sig2_results(which_q,which_phi,1)=baseline_err;
    sig2_results(which_q,which_phi,2)=contrast_err;
    sig2_results(which_q,which_phi,3)=gamma_err;
    sig2_results(which_q,which_phi,4)=exponent_err;
    
    g2BatchavgFIT2(which_q,which_phi,:)=fit2data;
end
        
        clear baseline baseline_err contrast contrast_err
        clear gamma gamma_err exponent exponent_err
             
end

if (FIT1 == 1)
    result.g2BatchavgFIT1= {};
    result.baselineBatchavgFIT1={};
    result.contrastBatchavgFIT1={};
    result.tauBatchavgFIT1={};
    result.baselineErrBatchavgFIT1={};
    result.contrastErrBatchavgFIT1={};
    result.tauErrBatchavgFIT1={};
    
    result.g2BatchavgFIT1= g2BatchavgFIT1;
    result.baselineBatchavgFIT1=fit1_results(:,:,1);
    result.contrastBatchavgFIT1=fit1_results(:,:,2);
    result.tauBatchavgFIT1=1./fit1_results(:,:,3);
    result.baselineErrBatchavgFIT1=sig1_results(:,:,1);
    result.contrastErrBatchavgFIT1=sig1_results(:,:,2);
    result.tauErrBatchavgFIT1=sig1_results(:,:,3)./fit1_results(:,:,3).^2;
end

if (FIT2 == 1)
    result.g2BatchavgFIT2= {};
    result.baselineBatchavgFIT2={};
    result.contrastBatchavgFIT2={};
    result.tauBatchavgFIT2={};
    result.exponentBatchavgFIT2={};
    result.baselineErrBatchavgFIT2={};
    result.contrastErrBatchavgFIT2={};
    result.tauErrBatchavgFIT2={};
    result.exponentErrBatchavgFIT2={};    

    result.g2BatchavgFIT2= g2BatchavgFIT2;
    result.baselineBatchavgFIT2=fit2_results(:,:,1);
    result.contrastBatchavgFIT2=fit2_results(:,:,2);
    result.tauBatchavgFIT2=1./fit2_results(:,:,3);
    result.exponentBatchavgFIT2=fit2_results(:,:,4);
    result.baselineErrBatchavgFIT2=sig2_results(:,:,1);
    result.contrastErrBatchavgFIT2=sig2_results(:,:,2);
    result.tauErrBatchavgFIT2=sig2_results(:,:,3)./fit2_results(:,:,3).^2;
    result.exponentErrBatchavgFIT2=sig2_results(:,:,4);
end




end
