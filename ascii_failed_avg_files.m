
kk=0;
for ii=1:numel(failed_avg)
    load(failed_avg{ii});
    for jj=1:numel(viewresultinfo.result.hdf5_filename)
        kk=kk+1;
        failed_avg_hdf_filenames{kk} = viewresultinfo.result.hdf5_filename{jj};      
    end
end


%%
k=0;failed=[];
for ii=1:numel(failed_avg_hdf_filenames)
    disp(ii);
    try
        function_AsciiwithFIT_from_xpcsgui(failed_avg_hdf_filenames{ii});
    catch
        k=k+1;
        failed_hdf{k}=failed_avg_hdf_filenames{ii};
        fprintf('Failed: %i\n',ii);
    end
end

disp('all done...........');