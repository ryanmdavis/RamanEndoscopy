function out = readRamanEndoscopeTxt(path)

fid=fopen(path,'r');
readings=textscan(fid,'%f');
fclose(fid);

% read spectra
num_spectral_bins=1024;
num_spectra=size(readings{1},1)/num_spectral_bins;
spectra=reshape(readings{1},num_spectral_bins,num_spectra).';

% read wavenumber
raman_shift=load(strcat(getParentDir('standard spectra'),'reference standards.mat'),'raman_shift_end');

out=struct('wavenumber',raman_shift.raman_shift_end,'spectra',spectra,'normalization_divisor',1,'normalization_divisor_unit','mW*(# accs)');

% keyboard;