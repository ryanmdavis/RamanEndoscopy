function background_pc_out=loadBackgroundPC(num_pc_use,varargin)

% assign optional arguments
invar = struct('raman_shift_scale',[],'smooth',30,'parent_path','C:\Users\rdavis5\Documents\Gambhir lab\Gambhir Data and Analysis\Renishaw Data\');
argin = varargin;
invar = generateArgin(invar,argin);

load(strcat(invar.parent_path,'07202016 - normal and tumor background.pr.mat'));
load(strcat(invar.parent_path,'tissue mask.mat'),'BW');

background_index_linear=reshape(BW,1,numel(BW));
background_spectra_linear=reshape(out.im2.b,size(out.im2.b,1)*size(out.im2.b,2),size(out.im2.b,3));
background_spectra=background_spectra_linear(background_index_linear,:);

coeff=pca(background_spectra);

background_pc=coeff(:,1:num_pc_use).';
background_pc(:,end)=background_pc(:,end-1);

if isempty(invar.raman_shift_scale)
    background_pc_out=zeros(size(background_pc));
else
    background_pc_out=zeros(size(background_pc,1),max(size(invar.raman_shift_scale)));
end

% smooth the PCs
for pc_num=1:size(background_pc,1)
    background_pc(pc_num,:)=smooth(background_pc(pc_num,:),invar.smooth);
    if ~isempty(invar.raman_shift_scale)
        background_pc_out(pc_num,:)=interp1(out.im2.wavenumber_b,background_pc(pc_num,:),invar.raman_shift_scale);
    else
        background_pc_out(pc_num,:)=smooth(background_pc(pc_num,:),invar.smooth);
    end
end