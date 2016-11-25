function result = loadhdf5result(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdf5_metadata_fullfile=varargin{1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin == 1)
    xpcs_group_name='/xpcs';
    result_group_location=h5read(hdf5_metadata_fullfile,[xpcs_group_name,'/output_data']);
elseif (nargin == 2)
    xpcs_group_name = varargin{2};
    result_group_location=h5read(hdf5_metadata_fullfile,[xpcs_group_name,'/output_data']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result_group_location=deblank(result_group_location); %removes leading/trailing white spaces
if iscellstr(result_group_location)
    result_group_location=result_group_location{1};
    result_group_location=cellstr(result_group_location);
    result_group_location=result_group_location{1};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nBatch=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Loading from the HDF5 file: RESULTS Group: %s, XPCS Group: %s\n',...
    result_group_location,xpcs_group_name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%add these fields to the result structure for making some further steps easier
result.hdf5_filename{nBatch} = hdf5_metadata_fullfile;
result.result_group_location{nBatch} = result_group_location;
result.xpcs_group_name{nBatch} = xpcs_group_name;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result.staticQs{nBatch}=h5read(hdf5_metadata_fullfile,[xpcs_group_name,'/sqlist']);
result.dynamicQs{nBatch}=h5read(hdf5_metadata_fullfile,[xpcs_group_name,'/dqlist']);
result.staticPHIs{nBatch}=h5read(hdf5_metadata_fullfile,[xpcs_group_name,'/sphilist']);
result.dynamicPHIs{nBatch}=h5read(hdf5_metadata_fullfile,[xpcs_group_name,'/dphilist']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_begin_todo=h5read(hdf5_metadata_fullfile,[xpcs_group_name,'/data_begin_todo']);
data_end_todo=h5read(hdf5_metadata_fullfile,[xpcs_group_name,'/data_end_todo']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    result.stride_frames=h5read(hdf5_metadata_fullfile,[xpcs_group_name,'/stride_frames']);
catch
    result.stride_frames=1;
end

try
    result.avg_frames=h5read(hdf5_metadata_fullfile,[xpcs_group_name,'/avg_frames']);
catch
    result.avg_frames=1;
end

result.new_framespacing_factor = double(result.stride_frames .* result.avg_frames);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check for kinetics mode
kinetics_state=h5read(hdf5_metadata_fullfile,[xpcs_group_name,'/kinetics']);
if iscellstr(kinetics_state)
    kinetics_state = kinetics_state{1};
end
is_kinetics = regexp(kinetics_state,'ENABLED','once');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result.aIt{nBatch}=transpose(h5read(hdf5_metadata_fullfile,[result_group_location,'/pixelSum']));
if (is_kinetics)
    kinetics_window_size=h5read(hdf5_metadata_fullfile,...
        '/measurement/instrument/detector/kinetics/window_size');
    result.aIt{nBatch}=result.aIt{nBatch}(1:kinetics_window_size,:);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foo=h5read(hdf5_metadata_fullfile,[result_group_location,'/frameSum']);
result.totalIntensity{nBatch}=foo(:,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%read time stamps from hdf (kinetics hdf shows every slice so there is a
%need to pick only one per frame
camera_make=h5read(hdf5_metadata_fullfile,'/measurement/instrument/detector/manufacturer');
if iscellstr(camera_make)
    camera_make=camera_make{1};
end

try
    %older hadoop version used this single field for both types of
    %timestamps
    foo=h5read(hdf5_metadata_fullfile,[result_group_location,'/timeStamps']);
catch
    %split timestamps into system clock type and frame grabber type
    foo_clock=h5read(hdf5_metadata_fullfile,[result_group_location,'/timestamp_clock']);
    foo_tick=h5read(hdf5_metadata_fullfile,[result_group_location,'/timestamp_tick']);
    if (~isempty(regexp(camera_make,'PI Princeton Instruments','once')))
        foo = foo_clock;
    else
        foo = foo_tick;
    end
end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (is_kinetics == 1) %%pick one time stamp per frame for kinetics mode
    kinetics_firstslice = h5read(hdf5_metadata_fullfile,...
        '/measurement/instrument/detector/kinetics/first_usable_window/');
    kinetics_numfirst_skipped = kinetics_firstslice-1; %%used later for the extra slice tau point
    
    kinetics_lastslice = h5read(hdf5_metadata_fullfile,...
        '/measurement/instrument/detector/kinetics/last_usable_window/');
    total_row_height = h5read(hdf5_metadata_fullfile,...
        '/measurement/instrument/detector/y_dimension');
    %%used later for the extra slice tau point
    kinetics_numlast_skipped = floor(total_row_height/kinetics_window_size) - kinetics_lastslice;
    
    kinetics_numslices = (kinetics_lastslice - kinetics_firstslice) + 1;
    k=1:uint64(numel(foo(:,2))/kinetics_numslices);
    foo_timestamps=foo(:,2);
    foo_timestamps=foo_timestamps(uint64(k).*cast(kinetics_numslices,'like',k));
    result.timeStamps{nBatch}=foo_timestamps;
else %%not kinetics mode, no need to make any changes
    if ( max(size(foo)) < data_end_todo )
        data_end_todo=max(size(foo));
        data_begin_todo=1;
    end
    result.timeStamps{nBatch}=foo(data_begin_todo:data_end_todo,2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%correct for overflow in the timestamp for DALSA/FCCD
if (~isempty(regexp(camera_make,'DALSA','once')))
    corecotick = result.timeStamps{nBatch}*1e6; %%scale by 1 MHz clock
    a2 = 2^31; % overflow value (2^31)
    c2 = find(diff(corecotick) < 0); % find positions where an overflow occured
    if ( numel(c2) > 0 )
        for ii = 1 : numel(c2)
            corecotick(c2(ii)+1:end) = corecotick(c2(ii)+1:end) + a2; % correct corecotick
        end
    end
    clear a2 c2
result.timeStamps{nBatch} = corecotick/1e6; %undo scaling by 1 MHz clock
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute the frame spacing from the raw timestamps
adu_per_photon=h5read(hdf5_metadata_fullfile,'/measurement/instrument/detector/adu_per_photon');
try
    if ~isempty(regexp(camera_make,'FastCCD','once')) && (adu_per_photon > 10) %%kludge to detect FCCD vs Eiger
        foo_fccd_exposure_time=h5read(hdf5_metadata_fullfile,...
            '/measurement/instrument/detector/exposure_time');
        if ~isempty(foo_fccd_exposure_time)
            result.framespacing{nBatch}=foo_fccd_exposure_time .* result.new_framespacing_factor;
        else
            result.framespacing{nBatch}=1.0 .* result.new_framespacing_factor;
        end
        result.StdDevframespacing{nBatch}=0;
    else
        result.framespacing{nBatch}=mean(diff(result.timeStamps{nBatch})) .* result.new_framespacing_factor;
        result.StdDevframespacing{nBatch}=std(diff(result.timeStamps{nBatch}));
    end
catch
    result.framespacing{nBatch}=1.0 .* result.new_framespacing_factor;
    result.StdDevframespacing{nBatch}=0.0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(regexp(camera_make,'FastCCD','once')) && (adu_per_photon < 10) %%kludge to detect FCCD vs Eiger
    foo_eiger_exposure_time=h5read(hdf5_metadata_fullfile,...
        '/measurement/instrument/detector/exposure_time');
    if ~isempty(foo_eiger_exposure_time)
        result.framespacing{nBatch}=foo_eiger_exposure_time.* result.new_framespacing_factor;
    else
        result.framespacing{nBatch}=1.0.* result.new_framespacing_factor;
    end
    result.StdDevframespacing{nBatch}=0;    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%kinetics mode time delay + includes the extra slice tau point
if (is_kinetics == 1)
    kinetics_time = h5read(hdf5_metadata_fullfile,...
        '/measurement/instrument/detector/exposure_time/');    
    foo_kinetics=h5read(hdf5_metadata_fullfile,[result_group_location,'/tau-kinetics']);
    %%all but the last extra slice tau point
    foo_kinetics(1:end-1)=foo_kinetics(1:end-1).* kinetics_time;
    %compute tau for the extra tau slice point separately
    %tau for extra slice = number of slices first skipped + number of
    %slices skipped last + one accounting for the extra slice itself
    foo_kinetics(end) = double(kinetics_numlast_skipped + kinetics_numfirst_skipped + 1)*kinetics_time ...
        + (result.framespacing{nBatch} - double(floor(total_row_height/kinetics_window_size))*kinetics_time);
else
    foo_kinetics=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foo_frame=h5read(hdf5_metadata_fullfile,[result_group_location,'/tau']);
foo_frame = foo_frame .* result.framespacing{nBatch};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foo_delays=[foo_kinetics;foo_frame];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result.delay{nBatch}=foo_delays;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    darkAverages=h5read(hdf5_metadata_fullfile,[result_group_location,'/darkAverages']);
    result.darkAverages{nBatch}=darkAverages;
catch
    result.darkAverages{nBatch}=NaN;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    darkStdDev=h5read(hdf5_metadata_fullfile,[result_group_location,'/darkStdDev']);
    result.darkStdDev{nBatch}=darkStdDev;
catch
    result.darkStdDev{nBatch}=NaN;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foo=h5read(hdf5_metadata_fullfile,[result_group_location,'/partition-mean-total']);
result.Iqphi{nBatch}=reshape(foo,size(foo,1),1,size(foo,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foo=h5read(hdf5_metadata_fullfile,[result_group_location,'/partition-mean-partial']);
result.Iqphit{nBatch}=reshape(foo,size(foo,1),1,[]);
if (is_kinetics)
    partition_mean_size = double(h5read(hdf5_metadata_fullfile,...
        [xpcs_group_name,'/static_mean_window_size']));
    num_slices=numel(result.totalIntensity{nBatch});
    num_Iqphit = floor(num_slices/partition_mean_size);
    result.Iqphit{nBatch} = result.Iqphit{nBatch}(:,:,1:min(num_Iqphit,size(result.Iqphit{nBatch},3)));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%change the g2 result format from using compound to simple data set in HDF5
try %%compound data set for g2 norm
    norm_g2=h5read(hdf5_metadata_fullfile,[result_group_location,'/norm']);
    result.g2avg{nBatch}=reshape(norm_g2.g2,size(norm_g2.g2,2),1,size(norm_g2.g2,3));
    result.g2avgErr{nBatch}=reshape(norm_g2.g2StdErr,size(norm_g2.g2StdErr,2),1,size(norm_g2.g2StdErr,3));    
catch %%simple data set for g2 norm and g2 error
    if (numel(result.dynamicQs{nBatch}) > 1)
        norm_g2=squeeze(h5read(hdf5_metadata_fullfile,[result_group_location,'/norm-0-g2']));
        result.g2avg{nBatch}=reshape(norm_g2,size(norm_g2,1),1,size(norm_g2,2));
        norm_g2StdErr=squeeze(h5read(hdf5_metadata_fullfile,[result_group_location,'/norm-0-stderr']));
        result.g2avgErr{nBatch}=reshape(norm_g2StdErr,size(norm_g2StdErr,1),1,size(norm_g2StdErr,2));
    else %%check with Zhang %%%
        norm_g2=(h5read(hdf5_metadata_fullfile,[result_group_location,'/norm-0-g2']));
        result.g2avg{nBatch}=reshape(norm_g2,size(norm_g2,1),1,size(norm_g2,3));
        norm_g2StdErr=(h5read(hdf5_metadata_fullfile,[result_group_location,'/norm-0-stderr']));
        result.g2avgErr{nBatch}=reshape(norm_g2StdErr,size(norm_g2StdErr,1),1,size(norm_g2StdErr,3));        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fit the g2s if the fit result fields do not exist
try
    h5read(hdf5_metadata_fullfile,[result_group_location,'/g2avgFIT1']);
    disp('g2 fits already exist in the HDF5 file. Bringing up the viewresult window...');
    disp('------------------------------------------------');
catch
    disp('Starting to Fit g2s. Please wait...');
    tstart=clock;
    try
        result = fit_hadoop_g2s(result);
    catch
        disp('g2 fitting failed for some reason, so faking fits with NaN...');
        result=fake_g2_fits(result);
    end
    tend=clock;
    telapsed=etime(tend,tstart);
    fprintf('g2 fits took %f seconds\n',telapsed);
    disp('Saving g2 fit results into the HDF5 file');
    disp('------------------------------------------------');
    save_g2fit_hdf5(hdf5_metadata_fullfile,result_group_location,result);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%read the fit related result variables
try
    result.g2avgFIT1{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/g2avgFIT1']);
    
    result.tauFIT1{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/tauFIT1']);
    result.tauErrFIT1{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/tauErrFIT1']);
    
    result.baselineFIT1{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/baselineFIT1']);
    result.baselineErrFIT1{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/baselineErrFIT1']);
    
    result.contrastFIT1{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/contrastFIT1']);
    result.contrastErrFIT1{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/contrastErrFIT1']);
catch
end

try
    result.g2avgFIT2{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/g2avgFIT2']);
    
    result.tauFIT2{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/tauFIT2']);
    result.tauErrFIT2{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/tauErrFIT2']);
    
    result.baselineFIT2{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/baselineFIT2']);
    result.baselineErrFIT2{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/baselineErrFIT2']);
    
    result.contrastFIT2{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/contrastFIT2']);
    result.contrastErrFIT2{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/contrastErrFIT2']);
    
    result.exponentFIT2{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/exponentFIT2']);
    result.exponentErrFIT2{nBatch}=h5read(hdf5_metadata_fullfile,[result_group_location,'/exponentErrFIT2']);
catch
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result = hadoop_cluster_result_reshape(result);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
