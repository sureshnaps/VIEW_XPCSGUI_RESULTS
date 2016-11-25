%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
%%%%One of the 2 ways to define a set of files are given below
%%%%XPCSGUI analysis location OR CLUSTER analysis location OR CUSTOM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DALSA/SMD CCD results%%%%%%%%%%%%%%%
% results_folder='/mnt/nfs/or-data/xpcs8/2014-2/NXtest201406/cluster_results/';
% cd(results_folder);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ls%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% files=dir('Lat*Fq1*.hdf');
% Combined_File_Name = ''; %  leave it empty or use a proper name
 Combined_File_Name = '/tmp/foo_TimeSeries.mat';
%%%%%%%%%%%%%Create your own array of filenames with arbitrary names%%%%%%%
  files(1).name = 'R024_Fmoc-FF_12p0_x05_25C_att1_Sq1_004_0001-0234.hdf';  
  files(2).name = 'R024_Fmoc-FF_12p0_x05_25C_att1_Sq1_005_0001-0234.hdf';  
    files(3).name = 'R024_Fmoc-FF_12p0_x05_25C_att1_Sq1_006_0001-0234.hdf';  
      files(4).name = 'R024_Fmoc-FF_12p0_x05_25C_att1_Sq1_007_0001-0234.hdf';  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
batches_to_merge=[]; %%leave it as empty,[], to include all the batches
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
viewresultinfo = input_function_merge_xpcsgui_result_files(files,batches_to_merge,Combined_File_Name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
