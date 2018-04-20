% Ryan M. Davis - 10/26/2015
% 01/22/2016 - add ability for mapping
% This function reads a .spc file from the Renshaw Raman microscope.  It
% reads spectral size and bandwidth from file header.

function out = readRenishawSpc(path)

%% read in data from file
fid     = fopen(path,'r');

num1 = fread(fid,2,'int32',0,'l');
num2 = roundn(fread(fid,2,'double',0,'l'),-2);
num3 = fread(fid,16,'int32',0,'l');

%% parse header into useful parameters
number_of_spectra=num3(1);
spectra_size=num1(2);
wavenumbers=linspace(num2(1),num2(2),spectra_size);
    
% Read text just before data
text1=textscan(fid,'%c',70);

if strfind(text1{1}','Streamline')
    temp=textscan(fid,'%c',10);
    inter_spectra_buffer_size=8;
    after_spectra_buffer_size=14;
    mode = 'Streamline';
elseif strfind(text1{1}','spectral')
    inter_spectra_buffer_size=9;
    after_spectra_buffer_size=16;
    mode = 'Spectrum';
elseif strfind(text1{1}','mappingmeasurement')
    temp=textscan(fid,'%c',8); %12
    inter_spectra_buffer_size=8;
    after_spectra_buffer_size=14;
    mode = 'Map';
else
    error('Exeperiment type not recognized');
end

% describe data before spectra
buffer_size=85;
temp0_precision='single';
temp0= fread(fid,buffer_size*4/sizeof(temp0_precision),temp0_precision);

% initialize memory for spectra, and read in spectral data.  Discard the
% data in between spectra
spectra=zeros(number_of_spectra,spectra_size);
temp2=zeros(number_of_spectra,inter_spectra_buffer_size);

for spectrum_num=1:number_of_spectra
    temp_precision='single';
    temp2(spectrum_num,:)=fread(fid,inter_spectra_buffer_size*4/sizeof(temp_precision),temp_precision);
    temp = fread(fid,spectra_size,'single');
    spectra(spectrum_num,:) = temp;
end

num2_precision='single';
num2=fread(fid,after_spectra_buffer_size*4/sizeof(num2_precision),num2_precision);

% read all of the rest of the footer text
text2=textscan(fid,'%c',inf);
text2=text2{1}';

% find the power value
laser_txt='Laserpower:';
power_loc = strfind(text2,laser_txt)+size(laser_txt',1);
power_loc_end=strfind(text2(power_loc:end),'%')+power_loc-2;
power_percent=str2num(text2(power_loc:power_loc_end));
power_mW=55*power_percent/100; %max power corresponds to 55 mW.

% find the number of accumulations
acc_txt='Accumulations:';
acc_loc = strfind(text2,acc_txt)+size(acc_txt',1);
acc_loc_end=strfind(text2(acc_loc:end),'Cosmic')+acc_loc-2;
acc_num=str2num(text2(acc_loc:acc_loc_end));

% find expsosure time
exp_txt='Exposure_time=Time:';
exp_loc = strfind(text2,exp_txt)+size(exp_txt',1);
exp_loc_end=strfind(text2(exp_loc:end),'s')+exp_loc-2;
exp_sec=str2num(text2(exp_loc:exp_loc_end));

% normalize the spectra and assign output
normalization_divisor=power_mW*acc_num*exp_sec;
if isempty(normalization_divisor) normalization_divisor=1; end
normalized_spectra=spectra/normalization_divisor;
out=struct('wavenumber',wavenumbers,'spectra',normalized_spectra,'normalization_divisor',normalization_divisor,'normalization_divisor_unit','mW*(# accs)','mode',mode,'exposure_seconds',exp_sec);

% close file
fclose(fid);