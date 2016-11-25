function save_g2fit_hdf5(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdf5_metadata_fullfile=varargin{1};
result_group_location=varargin{2};
udata.result=varargin{3};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nBatch=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a=udata.result.dynamicQs{nBatch};
b=~isnan(a);%%find only the non-NaN
udata.result.real_dynamicQ_indices{nBatch}=find(b==1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%FIT1 stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/g2avgFIT1'],udata.result.g2avgFIT1{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/g2avgFIT1'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2),numel(udata.result.delay{nBatch})]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/g2avgFIT1'],udata.result.g2avgFIT1{nBatch});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/tauFIT1'],udata.result.tauFIT1{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/tauFIT1'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/tauFIT1'],udata.result.tauFIT1{nBatch});
end

try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/tauErrFIT1'],udata.result.tauErrFIT1{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/tauErrFIT1'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/tauErrFIT1'],udata.result.tauErrFIT1{nBatch});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/baselineFIT1'],udata.result.baselineFIT1{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/baselineFIT1'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/baselineFIT1'],udata.result.baselineFIT1{nBatch});
end

try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/baselineErrFIT1'],udata.result.baselineErrFIT1{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/baselineErrFIT1'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/baselineErrFIT1'],udata.result.baselineErrFIT1{nBatch});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/contrastFIT1'],udata.result.contrastFIT1{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/contrastFIT1'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/contrastFIT1'],udata.result.contrastFIT1{nBatch});
end

try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/contrastErrFIT1'],udata.result.contrastErrFIT1{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/contrastErrFIT1'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/contrastErrFIT1'],udata.result.contrastErrFIT1{nBatch});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%FIT2 stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/g2avgFIT2'],udata.result.g2avgFIT2{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/g2avgFIT2'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2),numel(udata.result.delay{nBatch})]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/g2avgFIT2'],udata.result.g2avgFIT2{nBatch});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/tauFIT2'],udata.result.tauFIT2{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/tauFIT2'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/tauFIT2'],udata.result.tauFIT2{nBatch});
end

try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/tauErrFIT2'],udata.result.tauErrFIT2{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/tauErrFIT2'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/tauErrFIT2'],udata.result.tauErrFIT2{nBatch});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/baselineFIT2'],udata.result.baselineFIT2{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/baselineFIT2'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/baselineFIT2'],udata.result.baselineFIT2{nBatch});
end

try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/baselineErrFIT2'],udata.result.baselineErrFIT2{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/baselineErrFIT2'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/baselineErrFIT2'],udata.result.baselineErrFIT2{nBatch});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/contrastFIT2'],udata.result.contrastFIT2{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/contrastFIT2'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/contrastFIT2'],udata.result.contrastFIT2{nBatch});
end

try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/contrastErrFIT2'],udata.result.contrastErrFIT2{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/contrastErrFIT2'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/contrastErrFIT2'],udata.result.contrastErrFIT2{nBatch});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/exponentFIT2'],udata.result.exponentFIT2{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/exponentFIT2'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/exponentFIT2'],udata.result.exponentFIT2{nBatch});
end

try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/exponentErrFIT2'],udata.result.exponentErrFIT2{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/exponentErrFIT2'],[size(udata.result.real_dynamicQ_indices{nBatch},1),size(udata.result.real_dynamicQ_indices{nBatch},2)]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/exponentErrFIT2'],udata.result.exponentErrFIT2{nBatch});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end




















