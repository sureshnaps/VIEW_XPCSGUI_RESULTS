function result = Local_cluster_result_reshape_SAXS(ccdimginfo,result)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nBatch = length(result.Iqphi);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
not_nans=~isnan(result.staticQs{1});
[spart_list,~]=find(not_nans==1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
snoq=ccdimginfo.partition.snpt(1);
snophi=ccdimginfo.partition.snpt(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- reshape some static stuff 
fieldnames = {...
    'Iqphi',...
    'Iqphit'};

for ii=1:nBatch
    if isempty(result.Iqphi{ii})
        continue;
    end
    for jj=1:length(fieldnames)
        result.(fieldnames{jj}){ii} = reshape_result(...
            result.(fieldnames{jj}){ii},...
            spart_list(1:end),...
            snoq,...
            snophi);
    end
end

% --- reshape some more static stuff
fieldnames = {...
    'staticQs',...    
    'staticPHIs'};
for ii=1:nBatch
    if isempty(result.Iqphi{ii})
        continue;
    end
    for jj=1:length(fieldnames)
        a=result.(fieldnames{jj}){ii};
        b=a(spart_list);
        result.(fieldnames{jj}){ii} = reshape_result(...
            b,...
            spart_list(1:end),...
            snoq,...
            snophi);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s1 = reshape_result(s0,list,noq,nophi)
if ndims(s0) == 3
    s1 = NaN*ones(noq*nophi,1,size(s0,3));
    s1(list,:,:) = s0;
    s1 = reshape(s1,noq,nophi,size(s0,3));
elseif ismatrix(s0)
    s1 = NaN*ones(noq*nophi,1); 
    s1(list,:) = s0;
    s1 = reshape(s1,noq,nophi);
else
    s1 = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
