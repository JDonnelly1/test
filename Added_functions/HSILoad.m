
function [I,info]=HSILoad(filename)
tic;
info = read_envihdr([filename '.hdr']);

switch info.data_type
    case {1}
        format = 'uint8';
        bits = 1;
    case {2}
        format= 'int16';
        bits = 2;
    case{3}
        format= 'int32';
        bits = 4;
    case {4}
        format= 'single';
        bits = 4;
    case {5}
        format= 'double';
        bits = 8;
    case {6}
        disp('>> Sorry, Complex (2x32 bits)data currently not supported');
        disp('>> Importing as double-precision instead');
        format= 'double';
    case {9}
        error('Sorry, double-precision complex (2x64 bits) data currently not supported');
    case {12}
        format= 'uint16';
        bits = 2;
    case {13}
        format= 'uint32';
    case {14}
        format= 'int64';
    case {15}
        format= 'uint64';
    otherwise
        error(['File type number: ',num2str(dtype),' not supported']);
end
    

%I = multibandread([filename '.raw'], [info.lines info.samples info.bands], format, info.header_offset, info.interleave, 'ieee-le');
fid=fopen([filename '.raw'],'r');
LPBVal = round(info.lines*0);
LPEVal = round(info.lines*1);
SPBVal = round(info.samples*0);
SPEVal = round(info.samples*1);
BPBVal = round(info.bands*0);
BPEVal = round(info.bands*1);
fprintf('Lines %d to %d \n', LPBVal, LPEVal);
fprintf('Samples %d to %d \n', SPBVal, SPEVal);
fprintf('Bands %d to %d \n', BPBVal, BPEVal);
I = zeros([LPEVal-LPBVal,SPEVal-SPBVal,BPEVal-BPBVal],format);
A = size(I);
fprintf('I is %d by %d by %d \n', A);

CurLine=0;
fseek(fid, info.header_offset+(bits*info.samples*info.bands*LPBVal), 'bof');
ReadLength = length(LPBVal+1:LPEVal);
for i=LPBVal+1:LPEVal
        CurLine=CurLine+1;
        %fprintf('Line %d of %d \n', i,length(1+floor(info.lines*LPB):floor(info.lines*LPE)));
        %fprintf('Line %d of %d \n', CurLine,info.lines);
        fprintf('Line %d of %d \n', i-LPBVal,ReadLength);
        X =  fread(fid, [info.bands,info.samples],format);
        fprintf('X is %d of %d \n', size(X));
        %fprintf('%d:%d %d:%d \n', 1+floor(info.samples*SPB),ceil(info.samples*SPE),1+floor(info.bands*BPB),ceil(info.bands*BPE));
        Y=X;%(1+SPBVal:SPEVal,1+BPBVal:BPEVal);
        %SY = size(Y);
        %fprintf('Y is %d by %d \n', SY);
        I(CurLine,:,:) = Y';
end
fclose(fid);
fprintf('Hypercube read took approx. %f seconds \n', toc);
%fprintf('info.header_offset %d \n', info.header_offset);

