function [viewresultinfo,filename_list_to_average_output] = ...
    function_merge_xpcsgui_result_files(varargin)

filename_list_to_average_input=varargin{1};

if (nargin == 2)
    batches_to_merge = varargin{2};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file_index=0; %%Initialize a file number counter
k=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%find good file list, ones that have result fields in them, no guarantee of
%good results (could not think of a better/easier way)
disp('Checking for the Integrity of the result files...');
for file_num=1:numel(filename_list_to_average_input)
    try
        k=k+1;%%assume the file to be checked is good
        good_file_list(k)=file_num;
        [~,~,foo_ext]=fileparts(filename_list_to_average_input{file_num});
        if ((H5F.is_hdf5(filename_list_to_average_input{file_num})) && ~strcmp(foo_ext,'.mat')) %%hdf5 result file
            loadhdf5result(filename_list_to_average_input{file_num});
        else
            load(filename_list_to_average_input{file_num});
        end
    catch
        if (file_num == numel(filename_list_to_average_input));good_file_list(k)=[];end;
        k=k-1;%%if assumption is wrong, decrement the file number
    end
end

if isempty(good_file_list)
    viewresultinfo=[];
    filename_list_to_average_output={};
    return;
else
    fprintf('%i file(s) out of %i seem to have valid results...\n',...
        numel(good_file_list),numel(filename_list_to_average_input));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for file_num=good_file_list
    fprintf('File being processed is\t\t: %03i of %03i\n',...
        file_num,numel(filename_list_to_average_input));
    [~,~,foo_ext]=fileparts(filename_list_to_average_input{file_num});
    if ((H5F.is_hdf5(filename_list_to_average_input{file_num})) && ~strcmp(foo_ext,'.mat')) %%hdf5 result file        
        tmp.result=loadhdf5result(filename_list_to_average_input{file_num});        
        temp=tmp.result;
        clear tmp;        
    else %%mat result file        
        tmp = load(filename_list_to_average_input{file_num});
        if isfield(tmp,'viewresultinfo')
            if isfield(tmp.viewresultinfo,'cluster')
                temp = tmp.viewresultinfo.cluster.result;
                viewresultinfo=rmfield(tmp.viewresultinfo,'cluster');
            else
                temp=tmp.viewresultinfo.result;
                viewresultinfo=rmfield(tmp.viewresultinfo,'result');
            end
        elseif isfield(tmp,'ccdimginfo')
            if isfield(tmp.ccdimginfo,'cluster')
                temp = tmp.ccdimginfo.cluster.result;
                viewresultinfo=rmfield(tmp.ccdimginfo,'cluster');
            else
                temp=tmp.ccdimginfo.result;
                viewresultinfo=rmfield(tmp.ccdimginfo,'result');
            end
        else
            disp('result structure field name is not standard');
            return;
        end
	clear tmp;                        
    end
    
    field_names = fieldnames(temp);
    
    if ( (nargin == 1) || isempty(batches_to_merge) )
        batches_to_merge = numel(temp.aIt);
    end
    
    for batch_num=1:batches_to_merge
        file_index = file_index + 1;
        filename_list_to_average_output{file_index}=...
                        filename_list_to_average_input{file_num}; %#ok<AGROW>
        for ii=1:length(field_names)
            out.(field_names{ii})(file_index) = temp.(field_names{ii})(batch_num);
        end
        
        out.resultfilenames{file_index}=filename_list_to_average_input{file_num};
        if ((H5F.is_hdf5(filename_list_to_average_input{file_num}))&& ~strcmp(foo_ext,'.mat')) %%hdf5 result file
            out.Start_Data_Collection_Time{file_index}=datestr(now);
            out.End_Data_Collection_Time{file_index}=datestr(now);
            out.batchinfoFile{file_index}='foo';
            out.specfile{file_index}=...
                h5read(filename_list_to_average_input{file_num},'/xpcs/specfile');
            out.specdata_scanN{file_index}=...
                h5read(filename_list_to_average_input{file_num},'/xpcs/specscan_data_number');
            tmp_input_filename = h5read(filename_list_to_average_input{file_num},'/xpcs/input_file_local');
            if iscellstr(tmp_input_filename)
                tmp_input_filename = tmp_input_filename{1};
            end
            [~,file_foo,ext_foo]=fileparts(tmp_input_filename);
            out.datafilename{file_index}=strcat(file_foo,ext_foo);
            out.ndata0todo{file_index}=...
                h5read(filename_list_to_average_input{file_num},'/xpcs/data_begin_todo');
            out.ndataendtodo{file_index}=...
                h5read(filename_list_to_average_input{file_num},'/xpcs/data_end_todo'); 
            
            viewresultinfo.result=out;

        else %%mat result file
            try
                out.Start_Data_Collection_Time{file_index}=viewresultinfo.start_time{batch_num};
                out.End_Data_Collection_Time{file_index}=viewresultinfo.end_time{batch_num};
                out.batchinfoFile{file_index}=viewresultinfo.batchinfoFile;
                out.specfile{file_index}=viewresultinfo.specfile;
                out.specdata_scanN{file_index}=viewresultinfo.data_scanN;
                [~,file_foo,ext_foo]=fileparts(viewresultinfo.imagefile{batch_num});
                out.datafilename{file_index}=strcat(file_foo,ext_foo);
                out.ndata0todo{file_index}=viewresultinfo.ndata0todo(batch_num);
                out.ndataendtodo{file_index}=viewresultinfo.ndataendtodo(batch_num);
            catch %%kludge to make merging multiple TimeSeries.mat files work
                out.Start_Data_Collection_Time{file_index}=datestr(now);
                out.End_Data_Collection_Time{file_index}=datestr(now);
                out.batchinfoFile{file_index}='foo';
                out.specfile{file_index}='foo';
                out.specdata_scanN{file_index}=NaN;
                out.datafilename{file_index}='null';
                out.ndata0todo{file_index}=NaN;
                out.ndataendtodo{file_index}=NaN;
                
            end

            viewresultinfo.result=out;
            
        end
    end
end

% clear field_names file_num foo ii temp filename_list_to_average_input;
% clear out is_data_from_cluster files batch_num file_foo ext_foo;
% clear file_index path_foo;
end
