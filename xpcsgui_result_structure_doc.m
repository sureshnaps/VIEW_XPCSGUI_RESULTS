%%default way of opening xpcsgui result file (analyzed at APS since Feb2013)
viewresultinfo.result=loadhdf5result('FeO_20nm_film5_44p90mm_027_0001-0212.hdf');

%%above default way opens the following, where /xpcs is the last analysis
%%performed
viewresultinfo.result=loadhdf5result('FeO_20nm_film11_47p26mm_004_0001-0212.hdf','/xpcs/output_data');

%%explicitly specify one of the older analysis done on the file
viewresultinfo.result=loadhdf5result('FeO_20nm_film11_47p26mm_004_0001-0212.hdf','/xpcs_1/output_data');

%%Other ways to open the result file in matlab
viewresult('FeO_20nm_film11_47p26mm_004_0001-0212.hdf') %%opens the last analysis

viewresult_all_hdf5('FeO_20nm_film11_47p26mm_004_0001-0212.hdf') %%opens all the analysis together
viewresult_debug %%puts udata in the workspace which contains the result structure (same as viewresultinfo.result)

%%loadhdf5result.m gives a fairly simple way of reading the result fields
%%in the hdf5 file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%use this file to merge more than one .mat result files
edit input_merge_xpcsgui_result_files.m 

%%(preferred) use this file to merge more than one .mat or .hdf5 or combo of .mat and .hdf result files
edit input_merge_xpcsgui_result_files_hadoopcluster.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%xpcsgui package should analyze/plot old/new data/result files
%%%%%%%%%%%%%%%%%%%files containing azimuthal%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
viewresultinfo.result
ans = 
            hdf5_filename: {'FeO_20nm_film5_44p90mm_027_0001-0212.hdf'}
    result_group_location: {'/exchange'}
          xpcs_group_name: {'/xpcs'}
                 staticQs: {[72x60 double]}
                dynamicQs: {[24x1 double]}
               staticPHIs: {[72x60 double]}
              dynamicPHIs: {[24x1 double]}
                      aIt: {[1300x1340 double]} %%2-d image of average intensity over all frames
           totalIntensity: {[202x1 double]} %%total intensity, one data point per frame (per kinetics slice for kinetics mode)
               timeStamps: {[202x1 double]} %%time stamp for each frame
             framespacing: {[3.132541805357482e+00]} %% constant spacing in time (sec) between frames
       StdDevframespacing: {[1.387878691212486e-02]} %%standard deviation in the time spacing (in sec)
                    delay: {[25x1 double]} %%time delay (sec) for the g2 plots
             darkAverages: {[NaN]} %%does not exist
               darkStdDev: {[NaN]} %%does not exist
                    Iqphi: {[72x60 double]} %%I(q) - time averaged
                   Iqphit: {[72x60x10 double]} %%I(q) with time - stability plot
                    g2avg: {[24x1x25 double]} %% measured g2 vs delay time (num of dyn qs x num dyn phis x number of delay)
                                          %%%squeeze(viewresultinfo.result.g2avg{1}(1,1,:))
% matlab syntax: squeeze(viewresultinfo.result.g2avg{1}(1,1,:))                                          
                 g2avgErr: {[24x1x25 double]} %%g2 error bars
                        %%%FIT1 is simple exp
                g2avgFIT1: {[24x1x25 double]} %%simple exp fitted values of g2
                  tauFIT1: {[24x1 double]} %%tau values at each dynamic q for simple exp
               tauErrFIT1: {[24x1 double]} %%tau error values at each dynamic q for simple exp
             baselineFIT1: {[24x1 double]} %%baseline values at each dynamic q for simple exp
          baselineErrFIT1: {[24x1 double]} %%baseline error values at each dynamic q for simple exp
             contrastFIT1: {[24x1 double]} %%contrast values at each dynamic q for simple exp
          contrastErrFIT1: {[24x1 double]} %%contrast error values at each dynamic q for simple exp
                        %%%FIT2 is stretched exp
                g2avgFIT2: {[24x1x25 double]} %%stretched exp fitted values of g2
                  tauFIT2: {[24x1 double]} %%tau values at each dynamic q for stretched exp
               tauErrFIT2: {[24x1 double]} %%tau error values at each dynamic q for stretched exp
             baselineFIT2: {[24x1 double]} %%baseline values at each dynamic q for stretched exp
          baselineErrFIT2: {[24x1 double]} %%baseline error values at each dynamic q for stretched exp
             contrastFIT2: {[24x1 double]} %%contrast values at each dynamic q for stretched exp
          contrastErrFIT2: {[24x1 double]} %%contrast error values at each dynamic q for stretched exp
             exponentFIT2: {[24x1 double]} %%exponent values at each dynamic q for stretched exp
          exponentErrFIT2: {[24x1 double]} %%exponent error values at each dynamic q for stretched exp
%%%%%%%%%%%%%%%%files NOT containing azimuthal%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
viewresultinfo.result
ans = 
            hdf5_filename: {'XR6_25p0C_Sq1_001_0001-0074.hdf'}
    result_group_location: {'/exchange'}
          xpcs_group_name: {'/xpcs'}
                 staticQs: {[90x1 double]} %%list of q-values in the static partition
                dynamicQs: {[18x1 double]} %%list of q-values in the dynamic partition
               staticPHIs: {[90x1 double]} %%list of PHI-values in the static partition
              dynamicPHIs: {[18x1 double]} %%list of PHI-values in the dynamic partition
                      aIt: {[1300x1340 double]} %%2-d image of average intensity over all frames
           totalIntensity: {[64x1 double]} %%total intensity, one data point per frame (per kinetics slice for kinetics mode)
               timeStamps: {[64x1 double]} %%time stamp for each frame
             framespacing: {[1.289641633866325e+00]} %% constant spacing in time (sec) between frames
       StdDevframespacing: {[1.222323102678448e-02]} %%standard deviation in the time spacing (in sec)
                    delay: {[19x1 double]} %%time delay (sec) for the g2 plots
             darkAverages: {[NaN]} %%does not exist
               darkStdDev: {[NaN]} %%does not exist
                    Iqphi: {[90x1 double]} %%I(q) - time averaged
                   Iqphit: {[90x1x10 double]} %%I(q) with time - stability plot
                    g2avg: {[18x1x19 double]} %% measured g2 vs delay time (num of dyn qs x num dyn phis x number of delay)
                                          %%%squeeze(viewresultinfo.result.g2avg{1}(1,1,:))
% matlab syntax: squeeze(viewresultinfo.result.g2avg{1}(1,1,:))                                                                                    
                 g2avgErr: {[18x1x19 double]} %%g2 error bars
                    %%%FIT1 is simple exp
                g2avgFIT1: {[18x1x19 double]} %%simple exp fitted values of g2
                  tauFIT1: {[18x1 double]} %%tau values at each dynamic q for simple exp
               tauErrFIT1: {[18x1 double]}%%tau error values at each dynamic q for simple exp
             baselineFIT1: {[18x1 double]} %%baseline values at each dynamic q for simple exp
          baselineErrFIT1: {[18x1 double]} %%baseline error values at each dynamic q for simple exp
             contrastFIT1: {[18x1 double]} %%contrast values at each dynamic q for simple exp
          contrastErrFIT1: {[18x1 double]} %%contrast error values at each dynamic q for simple exp
                 %%%FIT2 is stretched exp          
                g2avgFIT2: {[18x1x19 double]} %%stretched exp fitted values of g2
                  tauFIT2: {[18x1 double]} %%tau values at each dynamic q for stretched exp
               tauErrFIT2: {[18x1 double]} %%tau error values at each dynamic q for stretched exp
             baselineFIT2: {[18x1 double]} %%baseline values at each dynamic q for stretched exp
          baselineErrFIT2: {[18x1 double]} %%baseline error values at each dynamic q for stretched exp
             contrastFIT2: {[18x1 double]} %%contrast values at each dynamic q for stretched exp
          contrastErrFIT2: {[18x1 double]} %%contrast error values at each dynamic q for stretched exp
             exponentFIT2: {[18x1 double]} %%exponent values at each dynamic q for stretched exp
          exponentErrFIT2: {[18x1 double]} %%exponent error values at each dynamic q for stretched exp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Average of several individual batches each with a set of g2 at different
%%%q's (done using the GUI, select a set of batches to average and then use
%%%the Export tab at the right of the GUI to save the average results to a
%%%file. If not exported, the average g2s are plotted but not saved. Such
%%%an exported file contains the results of all the files, a field called 
% viewresultinfo.result.batches2average: [1 2 3 4]
%which shows the batches that were selected to average.

% % A typical structure of such a file is as shown below:
%%%%%%%%%%
load SPS64_140k_200nm_154C_F2_TimeSeries_avg.mat
% % will return viewresultinfo to the Matlab workspace which looks like:
%%skip several lines to see the fields containing "Batchavg"

viewresultinfo = 
    result: [1x1 struct]
    
viewresultinfo.result
ans = 
                 hdf5_filename: {1x4 cell}
         result_group_location: {'/exchange'  '/exchange'  '/exchange'  '/exchange'}
               xpcs_group_name: {'/xpcs'  '/xpcs'  '/xpcs'  '/xpcs'}
                      staticQs: {[54x60 double]  [54x60 double]  [54x60 double]  [54x60 double]}
                     dynamicQs: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
                    staticPHIs: {[54x60 double]  [54x60 double]  [54x60 double]  [54x60 double]}
                   dynamicPHIs: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
                           aIt: {[1300x1340 double]  [1300x1340 double]  [1300x1340 double]  [1300x1340 double]}
                totalIntensity: {[256x1 double]  [256x1 double]  [256x1 double]  [256x1 double]}
                    timeStamps: {[256x1 double]  [256x1 double]  [256x1 double]  [256x1 double]}
                  framespacing: {1x4 cell}
            StdDevframespacing: {1x4 cell}
                         delay: {[27x1 double]  [27x1 double]  [27x1 double]  [27x1 double]}
                  darkAverages: {[NaN]  [NaN]  [NaN]  [NaN]}
                    darkStdDev: {[NaN]  [NaN]  [NaN]  [NaN]}
                         Iqphi: {[54x60 double]  [54x60 double]  [54x60 double]  [54x60 double]}
                        Iqphit: {[54x60x10 double]  [54x60x10 double]  [54x60x10 double]  [54x60x10 double]}
                         g2avg: {[18x1x27 double]  [18x1x27 double]  [18x1x27 double]  [18x1x27 double]}
                      g2avgErr: {[18x1x27 double]  [18x1x27 double]  [18x1x27 double]  [18x1x27 double]}
                     g2avgFIT1: {[18x1x27 double]  [18x1x27 double]  [18x1x27 double]  [18x1x27 double]}
                       tauFIT1: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
                    tauErrFIT1: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
                  baselineFIT1: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
               baselineErrFIT1: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
                  contrastFIT1: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
               contrastErrFIT1: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
                     g2avgFIT2: {[18x1x27 double]  [18x1x27 double]  [18x1x27 double]  [18x1x27 double]}
                       tauFIT2: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
                    tauErrFIT2: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
                  baselineFIT2: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
               baselineErrFIT2: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
                  contrastFIT2: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
               contrastErrFIT2: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
                  exponentFIT2: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
               exponentErrFIT2: {[18x1 double]  [18x1 double]  [18x1 double]  [18x1 double]}
               resultfilenames: {1x4 cell}
    Start_Data_Collection_Time: {1x4 cell}
      End_Data_Collection_Time: {1x4 cell}
                 batchinfoFile: {'foo'  'foo'  'foo'  'foo'}
                      specfile: {1x4 cell}
                specdata_scanN: {' 28'  ' 30'  ' 32'  ' 34'}
                  datafilename: {1x4 cell}
                    ndata0todo: {[11]  [11]  [11]  [11]}
                  ndataendtodo: {[266]  [266]  [266]  [266]}
               batches2average: [1 2 3 4]
                    g2Batchavg: [18x1x27 double]
                 g2BatchavgErr: [18x1x27 double]
                g2BatchavgFIT1: [18x1x27 double]
          baselineBatchavgFIT1: [18x1 double]
          contrastBatchavgFIT1: [18x1 double]
               tauBatchavgFIT1: [18x1 double]
       baselineErrBatchavgFIT1: [18x1 double]
       contrastErrBatchavgFIT1: [18x1 double]
            tauErrBatchavgFIT1: [18x1 double]
                g2BatchavgFIT2: [18x1x27 double]
          baselineBatchavgFIT2: [18x1 double]
          contrastBatchavgFIT2: [18x1 double]
               tauBatchavgFIT2: [18x1 double]
          exponentBatchavgFIT2: [18x1 double]
       baselineErrBatchavgFIT2: [18x1 double]
       contrastErrBatchavgFIT2: [18x1 double]
            tauErrBatchavgFIT2: [18x1 double]
       exponentErrBatchavgFIT2: [18x1 double]

% % The fields above that contain "Batchavg" in the names are the average
% of the parameters and the names are obvious with same description as
% above.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Details about the ASCII conversion of the result files: There are 3
%%scripts that convert the result to ASCII. The files are called:

input_function_AsciiAvg_from_xpcsgui.m
input_function_AsciiwithFIT_from_xpcsgui.m
%the above are 2 new files that call the below scripts to do many files in
%batch mode 

Ascii_from_xpcsgui.m %-- Converts a single batch result file to 4 files named as
                            %.IQASCII,.g2ASCII,.tauFIT1ASCII,tauFIT2ASCII
                            % IQASCII: 3 columns: q,I(q),error in I(q)                            
                            %.g2avgASCII: delay as the 1st column, measured
                            %g2@q=1, measured error in g2@q=1. The 2 columns are
                            %repeated for all q's. So for 18 q's, there
                            %should be 1 for delay+18*2=37 columns
                            %.tauFIT1ASCII: q, tau, error in tau
                            %.tauFIT2ASCII: q, tau, error in tau, exponent,
                            %error in exponent                            
AsciiwithFIT_from_xpcsgui.m %-- Converts a single batch result file to 4 files named as
                            %.IQASCII,.g2ASCII,.tauFIT1ASCII,tauFIT2ASCII
                            % IQASCII: 3 columns: q,I(q),error in I(q)                            
                            %.g2ASCII: delay as the 1st column, measured
                            %g2@q=1, measured error in g2@q=1, g2FIT1,g2FIT2. The 4 columns are
                            %repeated for all q's. So for 18 q's, there
                            %should be 1 for delay+18*4=73 columns
                            %.tauFIT1ASCII: q, tau, error in tau
                            %.tauFIT2ASCII: q, tau, error in tau, exponent,
                            %error in exponent                            

AsciiAvg_from_xpcsgui.m %-- Converts the averaged batch result file to 4 files named as
                            %.IQASCII,.g2avgASCII,.tauavgFIT1ASCII,tauavgFIT2ASCII
                            % IQASCII: 3 columns: q,I(q),error in I(q)                            
                            %.g2avgASCII: delay as the 1st column, averaged
                            %g2@q=1, averaged g2 error in g2@q=1, g2avgFIT1,g2avgFIT2. The 4 columns are
                            %repeated for all q's. So for 18 q's, there
                            %should be 1 for delay+18*4=73 columns
                            %.tauavgFIT1ASCII: q, tau, error in tau
                            %.tauavgFIT2ASCII: q, tau, error in tau, exponent,
                            %error in exponent                            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

