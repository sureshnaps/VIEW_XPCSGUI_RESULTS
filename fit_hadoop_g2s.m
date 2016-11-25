function tmp = fit_hadoop_g2s(varargin)
%%Pass the result strucure as input and get the result structure with the
%%fits as output and assign that to the result structure:

tmp=varargin{1};

nBatch=1;

a=tmp.dynamicQs{nBatch};
b=~isnan(a);%%find only the non-NaN
c=find(b==1);

% list_of_qs=1:numel(tmp.dynamicQs{nBatch});%%fails if there are NaN in q's
list_of_qs=1:numel(c);%%better way to deal with NaN

which_phi=1;

FIT1=1; %%single exp
FIT2=1; %%stretched exp

warning('off','MATLAB:NonScalarInput');

delay=tmp.delay{nBatch};
    
for which_q=list_of_qs 
        g2raw=squeeze(tmp.g2avg{nBatch}(which_q,which_phi,:));
        g2rawErr=squeeze(tmp.g2avgErr{nBatch}(which_q,which_phi,:));
        if sum(isnan(g2raw)) == numel(g2raw)
            g2raw = ones(size(g2raw))*eps;
        end
        
%%%%%%%%FIT 
if (FIT1 == 1)
    [fit1data,baseline,contrast,gamma,baseline_err,contrast_err,gamma_err]= ...
        fit1singleexp(delay,g2raw,g2rawErr);
    fit1_results(which_q,which_phi,1)=baseline;
    fit1_results(which_q,which_phi,2)=contrast;
    fit1_results(which_q,which_phi,3)=gamma;
    
    sig1_results(which_q,which_phi,1)=baseline_err;
    sig1_results(which_q,which_phi,2)=contrast_err;
    sig1_results(which_q,which_phi,3)=gamma_err;
    
    % kludge to re-insert values into fit1data when g2raw
    % contains NaN('s) and the fit eliminates those value(s) from the
    % list of returned values (fit1data).
    % fit1dataDefault are the default values to insert (1)
    insertIdx = find(isnan(g2raw)); % find indices where g2raw==NaN
    if ~isempty(insertIdx)
        fit1dataDefault = ones(1,length(insertIdx)); % create array of default vals (1) to insert in place of NaN
        fit1dataNew = zeros(1,length(g2raw)) + NaN;
        fit1dataNew(insertIdx) = fit1dataDefault;
        fit1dataNew(isnan(fit1dataNew)) = fit1data;
        fit1data = fit1dataNew;
    end
    
    g2avgFIT1(which_q,which_phi,:)=fit1data;
                
end
        
if (FIT2 == 1)
    [fit2data,baseline,contrast,gamma,exponent,baseline_err,contrast_err,gamma_err,exponent_err]= ...
        fit2stretchedexp(delay,g2raw,g2rawErr);
    fit2_results(which_q,which_phi,1)=baseline;
    fit2_results(which_q,which_phi,2)=contrast;
    fit2_results(which_q,which_phi,3)=gamma;
    fit2_results(which_q,which_phi,4)=exponent;
    
    sig2_results(which_q,which_phi,1)=baseline_err;
    sig2_results(which_q,which_phi,2)=contrast_err;
    sig2_results(which_q,which_phi,3)=gamma_err;
    sig2_results(which_q,which_phi,4)=exponent_err;
    
    % kludge to re-insert values into fit2data when g2raw
    % contains NaN('s) and the fit eliminates those value(s) from the
    % list of returned values (fit2data).
    % fit2dataDefault are the default values to insert (1)
    insertIdx = find(isnan(g2raw)); % find indices where g2raw==NaN
    if ~isempty(insertIdx)
        fit2dataDefault = ones(1,length(insertIdx)); % create array of default vals (1) to insert in place of NaN
        fit2dataNew = zeros(1,length(g2raw)) + NaN;
        fit2dataNew(insertIdx) = fit2dataDefault;
        fit2dataNew(isnan(fit2dataNew)) = fit2data;
        fit2data = fit2dataNew;
    end
    
    g2avgFIT2(which_q,which_phi,:)=fit2data;
end
        
        clear baseline baseline_err contrast contrast_err
        clear gamma gamma_err exponent exponent_err
             
end

if (FIT1 == 1)
    tmp.g2avgFIT1{nBatch}= {};
    tmp.baselineFIT1{nBatch}={};
    tmp.contrastFIT1{nBatch}={};
    tmp.tauFIT1{nBatch}={};
    tmp.baselineErrFIT1{nBatch}={};
    tmp.contrastErrFIT1{nBatch}={};
    tmp.tauErrFIT1{nBatch}={};
    
    tmp.g2avgFIT1{nBatch}= g2avgFIT1;
    tmp.baselineFIT1{nBatch}=fit1_results(:,:,1);
    tmp.contrastFIT1{nBatch}=fit1_results(:,:,2);
    tmp.tauFIT1{nBatch}=1./fit1_results(:,:,3);
    tmp.baselineErrFIT1{nBatch}=sig1_results(:,:,1);
    tmp.contrastErrFIT1{nBatch}=sig1_results(:,:,2);
    tmp.tauErrFIT1{nBatch}=sig1_results(:,:,3)./fit1_results(:,:,3).^2;
end

if (FIT2 == 1)
    tmp.g2avgFIT2{nBatch}= {};
    tmp.baselineFIT2{nBatch}={};
    tmp.contrastFIT2{nBatch}={};
    tmp.tauFIT2{nBatch}={};
    tmp.exponentFIT2{nBatch}={};
    tmp.baselineErrFIT2{nBatch}={};
    tmp.contrastErrFIT2{nBatch}={};
    tmp.tauErrFIT2{nBatch}={};
    tmp.exponentErrFIT2{nBatch}={};    

    tmp.g2avgFIT2{nBatch}= g2avgFIT2;
    tmp.baselineFIT2{nBatch}=fit2_results(:,:,1);
    tmp.contrastFIT2{nBatch}=fit2_results(:,:,2);
    tmp.tauFIT2{nBatch}=1./fit2_results(:,:,3);
    tmp.exponentFIT2{nBatch}=fit2_results(:,:,4);
    tmp.baselineErrFIT2{nBatch}=sig2_results(:,:,1);
    tmp.contrastErrFIT2{nBatch}=sig2_results(:,:,2);
    tmp.tauErrFIT2{nBatch}=sig2_results(:,:,3)./fit2_results(:,:,3).^2;
    tmp.exponentErrFIT2{nBatch}=sig2_results(:,:,4);
end




end
