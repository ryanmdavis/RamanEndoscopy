function [A,channel_names,wavenumbers]=defineRamanForwardProblem(system,num_background_pc)

mf=mfilename('fullpath');
slash_loc=strfind(mf,mkslash);
standard_spectra_path=strcat(mf(1:slash_loc(end)),'standard spectra',mkslash);
background_spectra_path=strcat(mf(1:slash_loc(end)),'background',mkslash);

if strcmp(system,'Renishaw')
    % load standard spectra (S440, S421)
    S421=reconRamRen(strcat(standard_spectra_path,'S421 - standard - 5s.spc'));
    S440=reconRamRen(strcat(standard_spectra_path,'S440 - standard - 5s.spc'));

    % load background principal components
    background_spectra_path=strcat(mf(1:slash_loc(end)),'background',mkslash,'microscope background pcs.mat');
    load(background_spectra_path);

    % A=[S440.out.spectra; S421.out.spectra; mean(S440.out.spectra)*ones(size(S440.out.spectra)); (1:size(S440.out.spectra,2))/size(S440.out.spectra,2)];
    % channel_names={'S440','S421','constant','linear'};
    A=[S440.out.spectra; S421.out.spectra; background_pc];
    
    wavenumbers=S440.out.wavenumbers;
elseif strcmp(system,'Endoscope')
    
    %load reference spectra
    ref = readRamanEndoscopeTxt(strcat(standard_spectra_path,'refTest.txt'));
    
    % normalize reference spectra by integral of first channel.  Note that
    % only first reference is technical normalized
    refs = ref.spectra/norm(ref.spectra(1,:));

    % load "air" spectrum
    temp = load(strcat(background_spectra_path,'endoscope background air.mat'),'endoscope_background_air');
    background_spectrum_air=temp.endoscope_background_air;
    
    % subtract endoscope "air" spectrum based on signal at 1,760 cm^-1
    [~,i_1760]=min(abs(ref.wavenumber-1760));
    for ref_num=1:size(refs,1)
       refs(ref_num,:)=refs(ref_num,:)-background_spectrum_air*refs(ref_num,i_1760)/background_spectrum_air(i_1760);
    end
    
    % calculate or load normalized background PCs
    if ~exist(strcat(background_spectra_path,'endoscope background pcs.mat'))
        background_pcs = normr(calcEndoscopeBackgroundPCs('num_pcs',num_background_pc));
        save(strcat(background_spectra_path,'endoscope background pcs.mat'),'background_pcs');
    else
        load(strcat(background_spectra_path,'endoscope background pcs.mat'));
    end
    
    % define output
    A=[refs; background_pcs; ones(1,size(refs,2))];
    wavenumbers=ref.wavenumber;
end

channel_names={'S440','S421','pc1','pc2','pc3','pc4','pc5','pc6','pc7','pc8','pc9','pc10'};