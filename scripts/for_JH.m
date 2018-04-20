spectra_struct=readRenishawSpc('E:\Raman Imaging\mapping1.spc');
spectra=permute(reshape(spectra_struct.spectra,41,13,1011),[2,1,3]);
plastic_spectra=sum(reshape(spectra(12:13,1:12,:),[],1011),1).';
plastic_spectra_norm=plastic_spectra/norm(plastic_spectra);