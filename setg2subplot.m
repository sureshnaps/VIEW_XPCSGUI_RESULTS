function setg2subplot(varargin)
% SETSUBPLOT Set the properties of all the axes in the figure.
%   SETSUBPLOT(H,'PropertyName',PropertyValue) sets the valus of the
%   specified properties for all the axes in the figure with handle H. H
%   can be vector.
%
% Copyright 2006 
% Zhang Jiang $2006/07/06$

if nargin < 2 || mod(nargin,2) == 1
    error('Wrong input arguments.');
end

hg2=findall(0,'Tag','viewresult_Fig_G2','type','figure');
hg2avg=findall(0,'Tag','viewresult_Fig_G2Avg','type','figure');

h = [hg2(:);hg2avg(:)];

if isempty(h)
    error('No g2 figures');
end

% for ii=1:length(h)
%     if ~ishandle(h(ii)) || ~strcmpi(get(h(ii),'type'),'figure')
%         error('Invalid figure handle.');
%         % else
%         %     figure(h);
%     end
% end

h_axes = findall(h,'type','axes','visible','on');
if isempty(h_axes)
    error('No plot exist in the figure.');
end

for ii=1:length(h_axes)
    for i=1:2:nargin
        set(h_axes(ii),varargin{i},varargin{i+1});
    end
end