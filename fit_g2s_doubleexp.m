function viewresultinfo = fit_g2s_doubleexp(varargin)

viewresultinfo = varargin{1};
nBatch = varargin{2};
parInit = varargin{3};      % initial paramters (5x1)
fitFlag = varargin{4};      % parameters to fit (5x1)

parInit = parInit(:);
fitFlag = fitFlag(:);

list_of_qs=1:numel(viewresultinfo.result.dynamicQs{nBatch(1)});
delay=viewresultinfo.result.delay{nBatch(1)};

% get g2
g2raw_avg = double(mean(cell2mat(viewresultinfo.result.g2avg(nBatch)),2));
g2rawErr_avg = double(1/numel(nBatch) * sqrt(sum(cell2mat(viewresultinfo.result.g2avgErr),2)));

which_phi = 1;

for which_q=list_of_qs
    % --- get g2 for each q
    g2raw=shiftdim(g2raw_avg(which_q,which_phi,:),2);
    g2rawErr=shiftdim(g2rawErr_avg(which_q,which_phi,:),2);
    foo_index = find(isnan(g2raw));
    g2raw(foo_index)=1.0;
    g2rawErr(foo_index)=0.0;
    
    % --- fitting
    [fit3data,baseline,contrast,ratio,tau1,tau2,...
        baseline_err,contrast_err,ratio_err,tau1_err,tau2_err] = ...
        fit3doubleexp(delay,g2raw,g2rawErr,parInit,fitFlag);
    % --- assign result
    fit3_results(which_q,which_phi,1)=baseline;
    fit3_results(which_q,which_phi,2)=contrast;
    fit3_results(which_q,which_phi,3)=ratio;
    fit3_results(which_q,which_phi,4)=tau1;
    fit3_results(which_q,which_phi,5)=tau2;
    
    sig3_results(which_q,which_phi,1)=baseline_err;
    sig3_results(which_q,which_phi,2)=contrast_err;
    sig3_results(which_q,which_phi,3)=ratio_err;
    sig3_results(which_q,which_phi,4)=tau1_err;
    sig3_results(which_q,which_phi,5)=tau2_err;      
            
    g2avgFIT3(which_q,which_phi,:)=fit3data;
end


% --- assign viewresultinfo
if numel(nBatch) == 1
    viewresultinfo.result.g2avgFIT3{nBatch}= {};
    viewresultinfo.result.baselineFIT3{nBatch}={};
    viewresultinfo.result.contrastFIT3{nBatch}={};
    viewresultinfo.result.ratioFIT3{nBatch}={};
    viewresultinfo.result.tau1FIT3{nBatch}={};
    viewresultinfo.result.tau2FIT3{nBatch}={};
    viewresultinfo.result.baselineErrFIT3{nBatch}={};
    viewresultinfo.result.contrastErrFIT3{nBatch}={};
    viewresultinfo.result.ratioErrFIT3{nBatch}={};
    viewresultinfo.result.tau1ErrFIT3{nBatch}={};
    viewresultinfo.result.tau2ErrFIT3{nBatch}={};
    
    viewresultinfo.result.g2avgFIT3{nBatch}= g2avgFIT3;
    viewresultinfo.result.baselineFIT3{nBatch}      = fit3_results(:,:,1);
    viewresultinfo.result.contrastFIT3{nBatch}      = fit3_results(:,:,2);
    viewresultinfo.result.ratioFIT3{nBatch}         = fit3_results(:,:,3);
    viewresultinfo.result.tau1FIT3{nBatch}          = fit3_results(:,:,4);
    viewresultinfo.result.tau2FIT3{nBatch}          = fit3_results(:,:,5);
    viewresultinfo.result.baselineErrFIT3{nBatch}   = sig3_results(:,:,1);
    viewresultinfo.result.contrastErrFIT3{nBatch}   = sig3_results(:,:,2);
    viewresultinfo.result.ratioErrFIT3{nBatch}      = sig3_results(:,:,3);
    viewresultinfo.result.tau1ErrFIT3{nBatch}       = sig3_results(:,:,4);
    viewresultinfo.result.tau2ErrFIT3{nBatch}       = sig3_results(:,:,5);
elseif numel(nBatch)>1
    viewresultinfo.result.batches2average   = nBatch;
    viewresultinfo.result.g2Batchavg        = g2raw;
    viewresultinfo.result.g2BatchavgErr     = g2rawErr;
    % --- save FIT3 results
    viewresultinfo.result.g2BatchavgFIT3 = g2avgFIT3;
    viewresultinfo.result.baselineBatchavgFIT3      = fit3_results(:,:,1);
    viewresultinfo.result.contrastBatchavgFIT3      = fit3_results(:,:,2);
    viewresultinfo.result.ratioBatchavgFIT3         = fit3_results(:,:,3);
    viewresultinfo.result.tau1BatchavgFIT3          = fit3_results(:,:,4);
    viewresultinfo.result.tau2BatchavgFIT3          = fit3_results(:,:,5);
    viewresultinfo.result.baselineErrBatchavgFIT3   = sig3_results(:,:,1);
    viewresultinfo.result.contrastErrBatchavgFIT3   = sig3_results(:,:,2);
    viewresultinfo.result.ratioErrBatchavgFIT3      = sig3_results(:,:,3);
    viewresultinfo.result.tau1ErrBatchavgFIT3       = sig3_results(:,:,4);
    viewresultinfo.result.tau2ErrBatchavgFIT3       = sig3_results(:,:,5);
    
end
return;

