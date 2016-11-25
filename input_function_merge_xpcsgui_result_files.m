function varargout = input_function_merge_xpcsgui_result_files(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin >=1)
    files = varargin{1};
else
    disp('No files match the defined wildcard criteria....');
    disp('Exiting the script.....');
    return;
end

if (nargin >=2)
    batches_to_merge = varargin{2};
else
    batches_to_merge = [];
end

if (nargin ==3)
    Combined_File_Name = varargin{3};
else
    Combined_File_Name = '';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(files)
    disp('No files match the defined wildcard criteria....');
    disp('Exiting the script.....');
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename_list_to_average_input=squeeze(struct2cell(files));
if (numel(fieldnames(files)) > 1)
    filename_list_to_average_input=filename_list_to_average_input(1,:);
end
clear files;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[viewresultinfo,filename_list_to_average_output]=function_merge_xpcsgui_result_files ...
    (filename_list_to_average_input,batches_to_merge);
clear batches_to_merge;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (isempty(viewresultinfo) || isempty(filename_list_to_average_output))
    disp('None of the input files seems to have results...');
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii=1:numel(filename_list_to_average_output)
    if (ii==1)
        fprintf('\n');
        fprintf('%s\n','------------------------------');
        fprintf('%s,%s\n','File_Number','Result_FileName');
        fprintf('%s\n','------------------------------');
    end
    fprintf('%03i,%s\n',ii,filename_list_to_average_output{ii});
    fprintf('%s\n','------------------------------');
end
clear ii;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (exist('Combined_File_Name','var') && (~isempty(deblank(Combined_File_Name))))
    fprintf('Saving the processed Combined Result Filename: %s\n',Combined_File_Name);
    save(Combined_File_Name,'viewresultinfo');
    viewresult(Combined_File_Name);
else
    viewresult(viewresultinfo);
end
clear Combined_File_Name;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargout>=1)
    varargout{1}=viewresultinfo;
end

if (nargout==2)
    varargout{2}=filename_list_to_average_output;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
