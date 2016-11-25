% filename = 't_star5k_58nm_130C_F1_02_0001-0266.hdf';
% filename = 't_star5k_78nm_130C_F1_01_0001-0330.hdf';
% filename = 't_star5k_78nm_130C_K1_01_0001-0106.hdf';
% filename = 'A001_AuP2VP10K_P2VP1p5K_50nm_85C_F1_002_0001-0522.hdf';
filename = 'Fig8_23nm_130C_F1_TimeSeries.mat';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,~,file_ext]=fileparts(filename);
if strcmp(file_ext,'.hdf')
    tmp.result=loadhdf5result(filename);
    batch_list=1;%%do not change this
else %%mat file
    tmp=load(filename);
    try
    tmp.result=tmp.viewresultinfo.result;
    tmp=rmfield(tmp,'viewresultinfo');
    catch
    tmp.result=tmp.ccdimginfo.result;
    tmp=rmfield(tmp,'ccdimginfo');        
    end
    batch_list = [1];             % batch # to fit
end
clear file_ext;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('OFF','MATLAB:singularMatrix');
warning('OFF','MATLAB:Axes:NegativeDataInLogAxis');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --- fit individual batches
for ii=1:length(batch_list)
    % --- fitting settings
    % initialize parameters [baseline,contrast,ratio (for tau1), tau1, tau2]
    parInit = [1.0, 0.05, 0.08, 30, 400];
    fitFlag = [0, 1,  1,  1,  1];    % determine parameters to fit 1/0 fit/nofit
    tmp = fit_g2s_doubleexp(tmp,batch_list(ii),parInit,fitFlag);
end
%% --- fit averaged batch (same input argument except batch_list is a vector
    tmp = fit_g2s_doubleexp(tmp,batch_list,parInit,fitFlag);
%% --- individual batch plot
viewresult_doubleexp(tmp,batch_list,filename); 
%% --- averaged plot (leave batch_list [])
viewresult_doubleexp(tmp,[],filename);

%%
%how to save the results to a file
[~,result_file,~]=fileparts(filename);
save([result_file,'_doubleexp.mat'],'tmp');
%%
%top open and plot the result
%load the result filename (load(filename))
%matfile(result_file)
% viewresult_doubleexp(tmp,batch_list);
% viewresult_doubleexp(tmp,[]);

%%
