function [spectra_out,rows_cols]=concatenateRamanSpectraRows(parent_dir)

d=dir(parent_dir);

%find number of .spc files containing the string '_to_', and put those files in d_spc
spc_ind=~cellfun('isempty',strfind({d.name},'_to_'));
num_spc=sum(spc_ind);
d_spc=d(spc_ind);
clear d

% make sure parent dir has slash at end
if ~strcmp(parent_dir(end),mkslash) parent_dir = strcat(parent_dir,mkslash); end

% load first spectra from slides
spectrum1=readRenishawSpc(strcat(parent_dir,d_spc(1).name));

% find the row number of each file
column_number=zeros(1,num_spc);

for file_num=1:num_spc    
   to_loc=strfind(d_spc(file_num).name,'_to_'); 
   underscore_loc=strfind(d_spc(file_num).name,'_');
   column_number(file_num)=str2double(d_spc(file_num).name(underscore_loc(end-2)+1:to_loc-1));
end

file_num_to_row_num=column_number/size(spectrum1.spectra,1)+1;

raman_map=zeros(num_spc, size(spectrum1.spectra,1), size(spectrum1.spectra,2));
for file_num=1:num_spc 
   % load spectrum and unmix
    spectra=readRenishawSpc(strcat(parent_dir,d_spc(file_num).name));
    raman_map(file_num_to_row_num(file_num),:,:)=spectra.spectra;
end

if strcmp(spectrum1.mode,'Streamline')
    % if we used a Streamline acquisition then the system acquires one column
    % at a time rather than one row at a time (as is done for mapping
    % acquisition).  
    % 
    % Fix: for each spectral bin, there is an image.  Concatenate all of the
    % rows of that image, then reshape to the correct shape.
    % I.e. for each spectral bin: transpose image --> make linear with reshape
    % --> reshape to correct image size. --> flip rows to match physical
    % orientation
    siz=size(raman_map);
    
    % the above series of tranformations is accomplished with this line:
    raman_map=fliplr(reshape(reshape(permute(raman_map,[2 1 3]),1,siz(1)*siz(2),siz(3)),siz(1),siz(2),siz(3)));
end

spectra_out=spectrum1;
spectra_out.spectra=raman_map;
rows_cols=[num_spc size(spectrum1.spectra,1)];