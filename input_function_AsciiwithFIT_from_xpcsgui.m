files=dir('*.hdf');

k=0;failed=[];
for ii=1:numel(files)
    disp(ii);
    try
        function_AsciiwithFIT_from_xpcsgui(files(ii).name);
    catch
        k=k+1;
        failed{k}=files(ii).name;
        fprintf('Failed: %i\n',ii);
    end
end

disp('all done...........');

%%%you are in cluster_results folder

% % cd Ascii_results


% % !zip E.zip E*


% %  sendmail({'kim.mongcopa@gmail.com'},'Composites data','5050 2080 unannealed','E.zip');


% % cd ..


%%%you should now be back in this folder
% % cd /net/wolfa/data/xpcs8/2015-1/Pinar201502/cluster_results
% % % % % % 
% % % % % % A025_PAES1p170_att2_25C_2016Mar04_Sq0_002_0001-0266_batch001.g2ASCII
% % % % % % A025_PAES1p170_att2_25C_2016Mar04_Sq0_002_0001-0266_batch001.IQASCII
% % % % % % A025_PAES1p170_att2_25C_2016Mar04_Sq0_002_0001-0266_batch001.tauFIT1ASCII
% % % % % % A025_PAES1p170_att2_25C_2016Mar04_Sq0_002_0001-0266_batch001.tauFIT2ASCII


%%%%function name::::: input_function_ASCiiwithFIT_from_xpcsgui.m*