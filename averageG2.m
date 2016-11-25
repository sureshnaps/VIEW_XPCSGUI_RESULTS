function udata = averageG2(varargin)
% functions to average g2 of mulitple batches
% $Revision: 1.0 $  $Date: unknown $ by Suresh
% $Revision: 1.1 $  $Date: 2014/03/31 $ by Zhang
%       Enable weighted averaging of g2
% 
% (commented so it could be used in the future as needed:
% Hack into averageG2 to replace error bars with the standard deviation of
% g2 Laurence Lurio, December 12, 2015
%
udata= varargin{1};
batches2average = varargin{2};

tmp=udata.result;

%%Initialize fields
tmp.batches2average = batches2average;
tmp.g2Batchavg = [];
tmp.g2BatchavgErr = [];
tmp.g2BatchavgFIT1 = [];
tmp.baselineBatchavgFIT1 = [];
tmp.contrastBatchavgFIT1 = [];
tmp.tauBatchavgFIT1 = [];
tmp.baselineErrBatchavgFIT1 = [];
tmp.contrastErrBatchavgFIT1 = [];
tmp.tauErrBatchavgFIT1 = [];
tmp.g2BatchavgFIT2 = [];
tmp.baselineBatchavgFIT2 = [];
tmp.contrastBatchavgFIT2 = [];
tmp.tauBatchavgFIT2 = [];
tmp.exponentBatchavgFIT2 = [];
tmp.baselineErrBatchavgFIT2 = [];
tmp.contrastErrBatchavgFIT2 = [];
tmp.tauErrBatchavgFIT2 = [];
tmp.exponentErrBatchavgFIT2 = [];


q_values = tmp.dynamicQs{batches2average(1)};
delay = tmp.delay{batches2average(1)}(:);

g2raw_allbatches = tmp.g2avg(batches2average);
g2rawErr_allbatches = tmp.g2avgErr(batches2average);

dim = [size(g2raw_allbatches{1})];
nbatches = size(g2raw_allbatches,2);
reshaped_g2batchavg = NaN*ones([dim,nbatches]);
reshaped_g2batchavgErr = NaN*ones([dim,nbatches]);
for ii=1:nbatches
    reshaped_g2batchavg(:,:,:,ii) = g2raw_allbatches{ii};
    reshaped_g2batchavgErr(:,:,:,ii) = g2rawErr_allbatches{ii};
end



% %--- evenly weighted
g2batchavg = mean(reshaped_g2batchavg,4);
g2batchavgErr = 1/nbatches * sqrt( sum(reshaped_g2batchavgErr.^2,4));


% --- weighted by errorbars (weight coefficient solved by Lagrange
% multilplier)
% w = 1./(reshaped_g2batchavgErr).^2 ./repmat(sum(1./reshaped_g2batchavgErr.^2,4),[1,1,1,nbatches]);
% w(isnan(w))=eps;
% g2batchavg = sum(w.*reshaped_g2batchavg,4);
% g2batchavgErr = sqrt(sum(w.^2.*reshaped_g2batchavgErr.^2,4));
% 
% % LBL This next code overwrites the errors with errors determined by the
% % standard deviation of the g2 data.  This will not quite be correct if the
% % data don't all have the same uncertainty.  
% disp('Lurio errorbar hack based on std of individual g2s being used...');
% sz=size(reshaped_g2batchavg);
% g2batchavgErr = std(reshaped_g2batchavg,0,4)/sqrt(sz(end));

% --- start fitting
g2BatchavgFIT1 = NaN*ones(size(g2batchavg));
g2BatchavgFIT2 = NaN*ones(size(g2batchavg));
[fit1_results,sig1_results] = deal(NaN*ones(dim(1),dim(2),3));
[fit2_results,sig2_results] = deal(NaN*ones(dim(1),dim(2),4));

for which_phi = 1:dim(2)
    for which_q=1:dim(1)
        g2=g2batchavg(which_q,which_phi,:);
        g2=g2(:);
        g2Err=g2batchavgErr(which_q,which_phi,:);
        g2Err=g2Err(:);
        
        %FIT1: Simple exponential - xpcsgui based fitting, not flexible
        [fit1data,baseline,contrast,gamma,baseline_err,contrast_err,gamma_err]=fit1singleexp(delay,g2,g2Err);
        
        % kludge to re-insert values into fit1data when g2raw
        % contains NaN('s) and the fit eliminates those value(s) from the
        % list of returned values (fit1data).
        % fit1dataDefault are the default values to insert (1)
        insertIdx = find(isnan(g2)); % find indices where g2raw==NaN
        if ~isempty(insertIdx)
            fit1dataDefault = ones(1,length(insertIdx)); % create array of default vals (1) to insert in place of NaN
            fit1dataNew = zeros(1,length(g2)) + NaN;
            fit1dataNew(insertIdx) = fit1dataDefault;
            fit1dataNew(isnan(fit1dataNew)) = fit1data;
            fit1data = fit1dataNew;
        end
        
        g2BatchavgFIT1(which_q,which_phi,:)= fit1data;
        
        fit1_results(which_q,which_phi,1)=baseline;
        fit1_results(which_q,which_phi,2)=contrast;
        fit1_results(which_q,which_phi,3)=gamma;
        sig1_results(which_q,which_phi,1)=baseline_err;
        sig1_results(which_q,which_phi,2)=contrast_err;
        sig1_results(which_q,which_phi,3)=gamma_err;
        
        %FIT2: Stretched exponential - xpcsgui based fitting, not flexible
        [fit2data,baseline,contrast,gamma,exponent,baseline_err,contrast_err,gamma_err,exponent_err]=fit2stretchedexp(delay,g2,g2Err);
        
        % kludge to re-insert values into fit2data when g2raw
        % contains NaN('s) and the fit eliminates those value(s) from the
        % list of returned values (fit2data).
        % fit2dataDefault are the default values to insert (1)
        insertIdx = find(isnan(g2)); % find indices where g2raw==NaN
        if ~isempty(insertIdx)
            fit2dataDefault = ones(1,length(insertIdx)); % create array of default vals (1) to insert in place of NaN
            fit2dataNew = zeros(1,length(g2)) + NaN;
            fit2dataNew(insertIdx) = fit2dataDefault;
            fit2dataNew(isnan(fit2dataNew)) = fit2data;
            fit2data = fit2dataNew;
        end
        
        g2BatchavgFIT2(which_q,which_phi,:)= fit2data;
        
        fit2_results(which_q,which_phi,1)=baseline;
        fit2_results(which_q,which_phi,2)=contrast;
        fit2_results(which_q,which_phi,3)=gamma;
        fit2_results(which_q,which_phi,4)=exponent;
        sig2_results(which_q,which_phi,1)=baseline_err;
        sig2_results(which_q,which_phi,2)=contrast_err;
        sig2_results(which_q,which_phi,3)=gamma_err;
        sig2_results(which_q,which_phi,4)=exponent_err;
        
        clear baseline baseline_err contrast contrast_err
        clear gamma gamma_err exponent exponent_err
    end
end
% --- save g2
tmp.g2Batchavg = g2batchavg;
tmp.g2BatchavgErr = g2batchavgErr;
% --- save FIT1 results
tmp.g2BatchavgFIT1 = g2BatchavgFIT1;
tmp.baselineBatchavgFIT1 = fit1_results(:,:,1);
tmp.contrastBatchavgFIT1 = fit1_results(:,:,2);
tmp.tauBatchavgFIT1 = 1./fit1_results(:,:,3);
tmp.baselineErrBatchavgFIT1 = sig1_results(:,:,1);
tmp.contrastErrBatchavgFIT1 = sig1_results(:,:,2);
tmp.tauErrBatchavgFIT1 = sig1_results(:,:,3)./fit1_results(:,:,3).^2;
% --- save FIT2 results
tmp.g2BatchavgFIT2 = g2BatchavgFIT2;
tmp.baselineBatchavgFIT2 = fit2_results(:,:,1);
tmp.contrastBatchavgFIT2 = fit2_results(:,:,2);
tmp.tauBatchavgFIT2 = 1./fit2_results(:,:,3);
tmp.exponentBatchavgFIT2 = fit2_results(:,:,4);
tmp.baselineErrBatchavgFIT2 = sig2_results(:,:,1);
tmp.contrastErrBatchavgFIT2 = sig2_results(:,:,2);
tmp.tauErrBatchavgFIT2 = sig2_results(:,:,3)./fit2_results(:,:,3).^2;
tmp.exponentErrBatchavgFIT2 = sig2_results(:,:,4);
% --- return result
udata.result=tmp;



