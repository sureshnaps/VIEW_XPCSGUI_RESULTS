function varargout = compare_xpcsgui_average_g2s(varargin)
%function allows you to plot multiple files that are already averaged and
%exported using viewresult GUI. This is always a .mat file
%
average_filenames = varargin{1};

for nBatch=1:numel(average_filenames)
    foo = load(average_filenames{nBatch});
    try
        tmp = foo.viewresultinfo.result;
    catch
        tmp = foo.ccdimginfo.result;
    end
    clear foo;
    
    fprintf('Averaged result filename#: %03i------%s\n',nBatch,average_filenames{nBatch});
    
    result.staticQs{nBatch} = tmp.staticQs{tmp.batches2average(1)};
    result.staticPHIs{nBatch} = tmp.staticPHIs{tmp.batches2average(1)};
    
    result.dynamicQs{nBatch} = tmp.dynamicQs{tmp.batches2average(1)};
    result.dynamicPHIs{nBatch} = tmp.dynamicPHIs{tmp.batches2average(1)};
    
    result.aIt{nBatch}=tmp.aIt{tmp.batches2average(1)};
    result.totalIntensity{nBatch}=tmp.totalIntensity{tmp.batches2average(1)};
    result.framespacing{nBatch}=tmp.framespacing{tmp.batches2average(1)};
    
    result.Iqphi{nBatch}=tmp.Iqphi{tmp.batches2average(1)};
    result.Iqphit{nBatch}=tmp.Iqphit{tmp.batches2average(1)};
    
    result.delay{nBatch}=tmp.delay{tmp.batches2average(1)};
    
    result.g2avg{nBatch}=tmp.g2Batchavg;
    result.g2avgErr{nBatch}=tmp.g2BatchavgErr;
    
     result.g2avgFIT1{nBatch}=tmp.g2BatchavgFIT1;
     result.tauFIT1{nBatch}=tmp.tauBatchavgFIT1;
     result.tauErrFIT1{nBatch}=tmp.tauErrBatchavgFIT1;
     result.baselineFIT1{nBatch}=tmp.baselineBatchavgFIT1;
     result.baselineErrFIT1{nBatch}=tmp.baselineErrBatchavgFIT1;
     result.contrastFIT1{nBatch}=tmp.contrastBatchavgFIT1;
     result.contrastErrFIT1{nBatch}=tmp.contrastErrBatchavgFIT1;
    
    result.g2avgFIT2{nBatch}=tmp.g2BatchavgFIT2;
    result.tauFIT2{nBatch}=tmp.tauBatchavgFIT2;
    result.tauErrFIT2{nBatch}=tmp.tauErrBatchavgFIT2;
    result.baselineFIT2{nBatch}=tmp.baselineBatchavgFIT2;
    result.baselineErrFIT2{nBatch}=tmp.baselineErrBatchavgFIT2;
    result.contrastFIT2{nBatch}=tmp.contrastBatchavgFIT2;
    result.contrastErrFIT2{nBatch}=tmp.contrastErrBatchavgFIT2;
    result.exponentFIT2{nBatch}=tmp.exponentBatchavgFIT2;
    result.exponentErrFIT2{nBatch}=tmp.exponentErrBatchavgFIT2;
end

viewresultinfo.result = result;

if (nargout==1)
    varargout{1}=viewresultinfo;
end

viewresult(viewresultinfo);

end
