%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename='S0p5_01_66wp_P400_75p0C_att0_Fq1p5_007_0001-4096.hdf';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%PROVIDE INITIAL GUESS VALUES FOR THE FIT PARAMETERS%%%%%%%%%%%%%%%
%%%baseline,contrast,gamma(1/tau),exponent%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_val=[1.00,0.2,0.005,1.5]; %%initial parameters for the fit
min_val=[0.95,0,0,0]; %%lower bounds for the fit
max_val=[1.1,4.25,Inf,2]; %%upper bounds for the fit
fit_flag=[1,1,1,1]; %%1 varies the parameter and 0 fixes the parameter

%%this many points will be thrown from the beginning of the data for g2,g2Err,delay
skip_this_many_points_beginning = 0; %%set to zero for no removal
%%this many points will be thrown from the end of the data for g2,g2Err,delay
skip_this_many_points_end = 0; %%set to zero for no removal
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

nBatch=[1];

if (skip_this_many_points_beginning ~=0)
    result.g2avg{nBatch}=result.g2avg{nBatch}(:,:,skip_this_many_points_beginning+1:end);
    result.g2avgErr{nBatch}=result.g2avgErr{nBatch}(:,:,skip_this_many_points_beginning+1:end);    
    result.delay{nBatch}=result.delay{nBatch}(skip_this_many_points_beginning+1:end);
end

if (skip_this_many_points_end ~=0)
    result.g2avg{nBatch}=result.g2avg{nBatch}(:,:,1:end - skip_this_many_points_end);
    result.g2avgErr{nBatch}=result.g2avgErr{nBatch}(:,:,1:end - skip_this_many_points_end);    
    result.delay{nBatch}=result.delay{nBatch}(1:end - skip_this_many_points_end);
end


custom_fit_result_filename=[filename_noext,'_fitfixedparams','.mat'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for which_batch=nBatch
    fprintf('Fitting batch number %02i\n',which_batch);
    result=fit_fixedparams_g2s(result,which_batch,start_val,fit_flag,min_val,max_val);
end

viewresultinfo.result=result;

clear result is_data_from_cluster filename filename_noext;
clear fit_flag min_val max_val start_val which_batch nBatch;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(custom_fit_result_filename,'viewresultinfo');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
viewresult(custom_fit_result_filename);
clear custom_fit_result_filename;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
