clear avg_file;
cd /mnt/nfs/or-data/xpcs8/2014-2/archer201405/cluster_results;
% avg_file{1}='SP1_att2_TimeSeries_avg.mat';
% avg_file{2}='SP1_att1_TimeSeries_avg.mat';

avg_file=dir('PINIMS7p3_000C_*_Fq1_TimeSeries_avg.mat');
avg_file=struct2cell(avg_file);
avg_file=avg_file(1,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
viewresultinfo = compare_xpcsgui_average_g2s(avg_file);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save PINIMS7p3_000C_AllTimes_Fq1_avg.mat viewresultinfo;
