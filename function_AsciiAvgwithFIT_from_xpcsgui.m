function function_AsciiAvgwithFIT_from_xpcsgui(varargin)

wild_card_input_of_files = varargin{1};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear all;clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
files=dir(wild_card_input_of_files);
if isempty(files)
    disp('No files match the specified criteria');
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ascii_results_folder='Ascii_results';
warning('off','MATLAB:MKDIR:DirectoryExists');
st=mkdir(ascii_results_folder);
if (~st)
    disp('Unable to create a directory to save Ascii_results....');
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii=1:numel(files)
    filename=files(ii).name;
    
    [~,~,file_ext]=fileparts(filename);
    if strcmp(file_ext,'.hdf')
        viewresultinfo.result=loadhdf5result(filename);
    else %%mat file
        load(filename);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        result=viewresultinfo.result; %%for the analysis done on the cluster
    catch
        result=ccdimginfo.result;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for nBatch=1:1
        if (strcmp(file_ext,'.hdf'))
            foo = strfind(filename,'.hdf');
        else
            foo = strfind(filename,'.mat');
        end        
        g2_asciiavg_filename = fullfile(ascii_results_folder,[char(filename(1:foo-1)),'.g2avgASCII']);
        IQ_ascii_filename = fullfile(ascii_results_folder,[char(filename(1:foo-1)),'.IQASCII']);
        tauavgFIT1_asciiavg_filename = fullfile(ascii_results_folder,[char(filename(1:foo-1)),'.tauavgFIT1ASCII']);
        tauavgFIT2_asciiavg_filename = fullfile(ascii_results_folder,[char(filename(1:foo-1)),'.tauavgFIT2ASCII']);
        fprintf('Converting to ASCII: File:%s, FileNumber:%i of %i\n',...
            filename,ii,numel(files));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%ascii for Iq vs q
        Iq_vs_q=[result.staticQs{nBatch},result.Iqphi{nBatch}];
        dlmwrite(IQ_ascii_filename,Iq_vs_q,'delimiter','\t');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%ascii for tau FIT1 (simple exp)
        tauavgFIT1_vs_q = [result.dynamicQs{nBatch},result.tauBatchavgFIT1,...
            result.tauErrBatchavgFIT1];
        dlmwrite(tauavgFIT1_asciiavg_filename,tauavgFIT1_vs_q,'delimiter','\t');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%ascii for tau FIT2 (stretched)
        tauavgFIT2_vs_q = [result.dynamicQs{nBatch},result.tauBatchavgFIT2,...
            result.tauErrBatchavgFIT2,result.exponentBatchavgFIT2,...
            result.exponentErrBatchavgFIT2];
        dlmwrite(tauavgFIT2_asciiavg_filename,tauavgFIT2_vs_q,'delimiter','\t');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%ascii for g2 vs delay time for a selected q
        %%%%a single file with g2 and g2Error bars in successive columns
        %%%%if there are 18 q's, then the first column is delay, 2nd is
        %%%%g2(q1),3rd is g2Err(q1) and so on.....
        delay=result.delay{nBatch};
        if (size(delay,2) == 1)
            delay=delay';
        end
        dynamicQs= result.dynamicQs{nBatch};
        which_phi=1;
        g2_and_g2Error=[];
        for jj=1:numel(dynamicQs)
            g2data=squeeze(result.g2Batchavg(jj,which_phi,:));
            g2Error=squeeze(result.g2BatchavgErr(jj,which_phi,:));

            g2FIT1data=squeeze(result.g2BatchavgFIT1(jj,which_phi,:));

            g2FIT2data=squeeze(result.g2BatchavgFIT2(jj,which_phi,:));

            g2_and_g2Error=[g2_and_g2Error,g2data,g2Error,g2FIT1data,g2FIT2data]; %#ok<*AGROW>                        

        end
        dlmwrite(g2_asciiavg_filename,[delay',g2_and_g2Error],'\t');
    end
end
clear viewresultinfo delay dynamicQs filename files g2data g2Error ii jj result
clear which_phi foo g2_and_g2Error g2_ascii_filename g2FIT1data g2FIT2data
clear IQ_ascii_filename Iq_vs_q batchnum nBatch num_batches tauFIT1_ascii_filename
clear tauFIT1_vs_q tauFIT2_ascii_filename tauFIT2_vs_q
