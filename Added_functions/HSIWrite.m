function HSIWrite(I,filename,WLS)
%%
%filename = 'Quick';
height = size(I,1);
width = size(I,2);
bands = size(I,3);

datatype = class(I);
switch datatype
    case {'uint8'}
        format = 1;
    case {'int16'}
        format= 2;
    case{'int32'}
        format= 3;
    case {'single'}
        format= 4;
    case {'double'}
        format= 5;
    case {'uint16'}
        format= 12;
    case {'uint32'}
        format= 13;
    case {'int64'}
        format= 14;
    case {'uint64'}
        format= 15;
    otherwise
        error(['File type number: ',num2str(dtype),' not supported']);
end
wls = ['{ ' sprintf('%f,\n', WLS(1:end-1)) sprintf('%f\n', WLS(end)) '}'];

info = struct('samples',width,'lines',height,'bands',bands,'header_offset',0,'file_type','ENVI Standard','data_type', format,'interleave', 'bil','byte_order', 0,'Wavelength', wls);

envihdrwrite(info,[filename '.hdr']);

fid = fopen([filename '.raw'],'w+');
for i=1:height
    %for j=1:bands
            fwrite(fid,I(i,:,:),class(I));
            fprintf('Line %u of %u\n',i, height);
    %end
end
fclose(fid);