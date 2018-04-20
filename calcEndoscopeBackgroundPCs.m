function background_pc = calcEndoscopeBackgroundPCs(varargin)

invar = struct('raman_shift_scale',[],'smooth',30,'num_pcs',3);
argin = varargin;
invar = generateArgin(invar,argin);

% locate the necessary files
mf=mfilename('fullpath');
slash_loc=strfind(mf,mkslash);
background_spectra_path=strcat(mf(1:slash_loc(end)),'background',mkslash);

% load and organize the background spectra, take the 1-norm of each spectra
background_spectra_quartz = readRamanEndoscopeTxt(strcat(background_spectra_path,'endoscope background quartz.txt'));
background_spectra_tissue = readRamanEndoscopeTxt(strcat(background_spectra_path,'endoscope background tissue.txt'));
background_spectra=normr([background_spectra_quartz.spectra; background_spectra_tissue.spectra]);

% perform the PCA analysis
coeff=pca(background_spectra);
background_pc=coeff(:,1:invar.num_pcs).';

% smooth the pcs
for pc_num=1:size(background_pc,1)
    background_pc(pc_num,:)=smooth(background_pc(pc_num,:),invar.smooth);
%     if ~isempty(invar.raman_shift_scale)
%         background_pc_out(pc_num,:)=interp1(out.im2.wavenumber_b,background_pc(pc_num,:),invar.raman_shift_scale);
%     else
%         background_pc_out(pc_num,:)=smooth(background_pc(pc_num,:),invar.smooth);
%     end
end