%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filename='SPS64_140k_200nm_144C_F1_001_0001-0522.hdf';
filename='PINIMS7p3_010C_Fq1_02_TimeSeries.mat';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%PROVIDE INITIAL GUESS VALUES FOR THE FIT PARAMETERS%%%%%%%%%%%%%%%
%%%baseline,contrast,gamma(1/tau),exponent%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_val=[1.00,0.11,10,1.5]; %%initial parameters for the fit
min_val=[0.95,0,0,0]; %%lower bounds for the fit
max_val=[1.1,0.35,Inf,2]; %%upper bounds for the fit
fit_flag=[1,1,1,0]; %%1 varies the parameter and 0 fixes the parameter
%%%%%%%%%%%%%%%%%%%%%%%%
overwrite_same_result_file=1;
%%%%%%%%%%%%%%%%%%%%%%%%
%%this many points will be thrown from the beginning of the data for g2,g2Err,delay
skip_this_many_points_beginning = 0; %%set to zero for no removal
%%this many points will be thrown from the end of the data for g2,g2Err,delay
skip_this_many_points_end = 0; %%set to zero for no removal
%%%%%%%%%%%%%%%%%%%%%%%%
%%select the batches to be averaged
batches_to_be_averaged=[1:3];
%%%%%%%%%%%%%%DO NOT MODIFY BELOW THIS LINE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,filename_noext,file_ext]=fileparts(filename);
if strcmp(file_ext,'.hdf')
    result=loadhdf5result(filename);
else %%mat file
    load(filename);
    try
        result = viewresultinfo.result;
    catch
        result = ccdimginfo.result;
    end
end

nBatch=1:numel(result.g2avg);

for which_batch_change=nBatch
    if (skip_this_many_points_beginning ~=0)
        result.g2avg{which_batch_change}=result.g2avg{which_batch_change}(:,:,skip_this_many_points_beginning+1:end);
        result.g2avgErr{which_batch_change}=result.g2avgErr{which_batch_change}(:,:,skip_this_many_points_beginning+1:end);
        result.delay{which_batch_change}=result.delay{which_batch_change}(skip_this_many_points_beginning+1:end);
    end
    
    if (skip_this_many_points_end ~=0)
        result.g2avg{which_batch_change}=result.g2avg{which_batch_change}(:,:,1:end - skip_this_many_points_end);
        result.g2avgErr{which_batch_change}=result.g2avgErr{which_batch_change}(:,:,1:end - skip_this_many_points_end);
        result.delay{which_batch_change}=result.delay{which_batch_change}(1:end - skip_this_many_points_end);
    end
end

if (overwrite_same_result_file == 1)
    custom_fit_result_filename = filename;
else
    custom_fit_result_filename=[filename_noext,'_batches',sprintf('%02i',batches_to_be_averaged),'_fitfixedparams_avg','.mat'];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for which_batch=nBatch
    fprintf('Fitting batch number %02i\n',which_batch);
    result=fit_fixedparams_g2s(result,which_batch,start_val,fit_flag,min_val,max_val);
end

viewresultinfo.result=result;

clear result is_data_from_cluster filename filename_noext;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(batches_to_be_averaged)
    viewresultinfo=averageG2(viewresultinfo,batches_to_be_averaged);
    result=viewresultinfo.result;
    result=fit_fixedparams_g2s_avg(result,start_val,fit_flag,min_val,max_val);
    viewresultinfo.result=result;
    clear fit_flag min_val max_val start_val which_batch nBatch;
    clear result;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(custom_fit_result_filename,'viewresultinfo');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
viewresult(custom_fit_result_filename);
clear custom_fit_result_filename;
fprintf('\nCustom Fitting is done\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
