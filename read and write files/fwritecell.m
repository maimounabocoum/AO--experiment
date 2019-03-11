function fwritecell(filename, format, data)
% FWRITECELL writes formatted data from a cell array to a text file.
%
% fwritecell(filename, format, data) 
%     writes data using the C language conversion specifications in
%     variable "format" as with SPRINTF
%     Example: fwritecell('textfile1.txt','%2d %1d %21s %8.5f',C);
%     
% fwritecell(filename, data)
%     writes data using a fixed width format padded with whitespace. Note 
%     that the decimal point for floating point numbers may not be aligned
    
if nargin < 3 %Handles both function signatures
    data = format;
    format = [];
end

%Open file to write to
fid = fopen(filename,'w');

%Determine new line character for PC or Unix platform
if ispc
    nl=sprintf('\r\n');
else
    nl=sprintf('\n');
end

if ~isempty(format) %Write formatted data
    for i=1:size(data,1)
        try
            fprintf(fid,[format nl],data{i,:});
        catch ME
            disp(sprintf('Write failed on line %d',i));
            fclose(fid);
            rethrow(ME);
        end
    end
else %Write fixed width data
    
    %Determine which columns are characters
    dtypes = cellfun(@ischar,data(1,:));
    %Initialize the output string
    datastr = '';
    %Create a column of whitespace to separate fields
    sep = repmat(' ',size(data,1),1);
    %Loop through columns and convert to text
    for i = 1:length(dtypes)
        try
        if ~dtypes(i)
            datastr = [datastr sep num2str(cell2mat(data(:,i)))]; %#ok<AGROW>
        else
            datastr = [datastr sep char(data(:,i))]; %#ok<AGROW>
        end
        catch ME
            fclose(fid);
            fprintf('Error parsing fixed width columns on column %d\n',i);
            rethrow(ME);
        end
    end
    %Add new line character
    datastr = [datastr repmat(nl,size(datastr,1),1)];
    try
        fwrite(fid,datastr.','char');
    catch ME
        fclose(fid);
        rethrow(ME);
    end
        
end
fclose(fid);