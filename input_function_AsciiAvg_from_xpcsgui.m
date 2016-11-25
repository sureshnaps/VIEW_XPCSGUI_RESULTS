% cd /net/wolf/data/xpcs8/2016-2/hallinan201608/cluster_results;
%%
fit_filename = dir('*avg.mat');

%%
k=0;failed_avg=[];
for ii=1:numel(fit_filename)
    disp(ii);
    try
%         function_AsciiAvg_from_xpcsgui(fit_filename(ii).name);
        function_AsciiAvgwithFIT_from_xpcsgui(fit_filename(ii).name);        
    catch
        k=k+1;
        failed_avg{k}=fit_filename(ii).name;
        fprintf('Failed Avg: %i\n',ii);
    end
end

disp('all done...........');


%%

% [~,foo,~] = fileparts(fit_filename);
% ascii_1 = [foo,'.tauavgFIT1ASCII'];
% ascii_2 = [foo,'.tauavgFIT2ASCII'];


% you are in cluster_results folder

% cd Ascii_results;
% 
% !zip ryan.zip *ASCII
% 
% sendmail({'rdskut@gmail.com'},'Subject:ramanan20163 XPCS Data','Message:ascii files', 'ryan.zip');
% 
% %you should now be back in this folder
% cd /net/wolf/data/xpcs8/2015-3/ramanan201511/cluster_results

%%input_function_AsciiAvg_from_xpcsgui.m*