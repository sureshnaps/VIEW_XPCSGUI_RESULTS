%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename='B060_aerogel_att2_Eq1_001_0001-50000.hdf';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%PROVIDE INITIAL GUESS VALUES FOR THE FIT PARAMETERS%%%%%%%%%%%%%%%
%%%baseline,contrast,gamma(1/tau),exponent%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_val=[1.00,0.08,0.02,1.5]; %%initial parameters for the fit
min_val=[0.95,0,0,0]; %%lower bounds for the fit
max_val=[1.1,0.15,Inf,2]; %%upper bounds for the fit
fit_flag=[0,1,1,1]; %%1 varies the parameter and 0 fixes the parameter
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
