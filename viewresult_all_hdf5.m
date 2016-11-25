function viewresult_all_hdf5(varargin)
%
%Usage:viewresult_all_hdf5(hdf5_filename)
%plot all the /exchange result fields in the HADOOP hdf5 result file
%
if (nargin >=1)
    input_full_hdf5_filename=varargin{1};
elseif (nargin == 0)
    [filename, filepath] = uigetfile(...
        {'*.hdf', 'Result Files (*.hdf)'},'Select HDF5 Result File','MultiSelect', 'on');
    input_full_hdf5_filename=fullfile(filepath, filename);
end

if (nargin == 2)
    all_results_mat_filename = varargin{2};
else
    all_results_mat_filename = '';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscellstr(input_full_hdf5_filename) %multiple files are selected
    %nothing to do
else %%single file selected
    tmp_name=input_full_hdf5_filename;
    input_full_hdf5_filename=[];
    input_full_hdf5_filename{1}=tmp_name;
    clear tmp_name;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for num_hdf5_files=1:numel(input_full_hdf5_filename)
    full_hdf5_filename=input_full_hdf5_filename{num_hdf5_files};
    num_results = hdf5_find_group_suffix(full_hdf5_filename,'/xpcs');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        k=k+1;
        xpcs_group = '/xpcs';
        tmp.result=loadhdf5result(full_hdf5_filename,xpcs_group);
        temp=tmp.result;
        clear tmp;
        field_names = fieldnames(temp);
        for ii=1:length(field_names)
            out.(field_names{ii})(k) = temp.(field_names{ii});
        end
        viewresultinfo.result=out;
    catch
            fprintf('\n*******XPCS Group: %s : FAILED*******\n\n',xpcs_group);
            k=k-1;
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (num_results > 1)
        for result_num=1:num_results-1
            try
                k=k+1;
                xpcs_group = ['/xpcs_',num2str(result_num)];
                tmp.result=loadhdf5result(full_hdf5_filename,xpcs_group);
                temp=tmp.result;
                clear tmp;
                field_names = fieldnames(temp);
                for ii=1:length(field_names)
                    out.(field_names{ii})(k) = temp.(field_names{ii});
                end
                viewresultinfo.result=out;
            catch
                fprintf('\n*******XPCS Group: %s : FAILED*******\n\n',xpcs_group);
                k=k-1;
            end
        end
    end
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     try
    %         k=k+1;
    %         tmp.result=loadhdf5result(full_hdf5_filename,'/xpcs');
    %         temp=tmp.result;
    %         clear tmp;
    %         field_names = fieldnames(temp);
    %         for ii=1:length(field_names)
    %             out.(field_names{ii})(k) = temp.(field_names{ii});
    %         end
    %         viewresultinfo.result=out;
    %     catch
    %         %     k=k-1;
    %     end
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ( (isstruct(viewresultinfo)) && isfield(viewresultinfo,'result') )
    if ~isempty(deblank(all_results_mat_filename))
        save(all_results_mat_filename,'viewresultinfo');
        viewresult(all_results_mat_filename);
    else
        viewresult(viewresultinfo);
    end
else
    disp('No valid result field seems to be there');
    return;
end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
