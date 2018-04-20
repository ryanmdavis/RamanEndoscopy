%http://www3.cs.stonybrook.edu/~cse634/lecture_notes/07testing.pdf
%cross validation
function out=ramanCv(data,sample_labels,varargin)
invar = struct('print',0);
argin = varargin;
invar = generateArgin(invar,argin);

out=struct;

%% make input correct size
if size(sample_labels,1)>size(sample_labels,2)
    sample_labels=sample_labels.';
end

%% do resubstitution cross-validation QDA on data
MdlLinear = fitcdiscr(data,sample_labels,'DiscrimType','quadratic');
errors_quad_resub=zeros(1,size(data,1));
for test_number=1:size(data,1)
    [~,prediction]=getModelScores(MdlLinear,data(test_number,:));
    errors_quad_resub(test_number)=~(prediction==sample_labels(test_number));
end
out.qda_resub=round(100*sum(errors_quad_resub)/length(errors_quad_resub));

if invar.print
    display(strcat('error rate for quadratic descriminant analysis using resubstitution-CV:',num2str(out.qda_resub),'%'));
end

%% do leave-one-out cross-validation QDA on data
errors_quad_loo=zeros(1,size(data,1));
for leave_out=1:size(data,1)
    loo_data=[data(1:leave_out-1,:);data(leave_out+1:end,:)];
    loo_sample_labels=[sample_labels(1:leave_out-1) sample_labels(leave_out+1:end)];
    MdlLinear = fitcdiscr(loo_data,loo_sample_labels,'DiscrimType','quadratic');
    [~,prediction]=getModelScores(MdlLinear,data(leave_out,:));
    errors_quad_loo(leave_out)=~(prediction==sample_labels(leave_out));

end

out.qda_loo=round(100*sum(errors_quad_loo)/length(errors_quad_loo));
if invar.print
    display(strcat('error rate for quadratic descriminant analysis using LOO-CV:',num2str(out.qda_loo),'%'));
end

%% do resubstitution cross-validation LDA on data
MdlLinear = fitcdiscr(data,sample_labels,'DiscrimType','linear');
errors_lin_resub=zeros(1,size(data,1));
for test_number=1:size(data,1)
    [~,prediction]=getModelScores(MdlLinear,data(test_number,:));
    errors_lin_resub(test_number)=~(prediction==sample_labels(test_number));
end
out.lda_resub=round(100*sum(errors_lin_resub)/length(errors_lin_resub));

if invar.print
    display(strcat('error rate for linear descriminant analysis using resubstitution-CV:',num2str(out.lda_resub),'%'));
end

%% do leave-one-out cross-validation LDA on data
errors_lin_loo=zeros(1,size(data,1));
for leave_out=1:size(data,1)
    loo_data=[data(1:leave_out-1,:);data(leave_out+1:end,:)];
    loo_sample_labels=[sample_labels(1:leave_out-1) sample_labels(leave_out+1:end)];
    MdlLinear = fitcdiscr(loo_data,loo_sample_labels,'DiscrimType','linear');
    [~,prediction]=getModelScores(MdlLinear,data(leave_out,:));
    errors_lin_loo(leave_out)=~(prediction==sample_labels(leave_out));
end

out.lda_loo=round(100*sum(errors_lin_loo)/length(errors_lin_loo));

if invar.print
    display(strcat('error rate for linear descriminant analysis using LOO-CV:',num2str(out.lda_loo),'%'));
end

%% do LOO CV with Logistic Regression
errors_lrm_loo=zeros(1,size(data,1));
for leave_out=1:size(data,1)
    loo_data=[data(1:leave_out-1,:);data(leave_out+1:end,:)];
    loo_sample_labels=[sample_labels(1:leave_out-1) sample_labels(leave_out+1:end)];
    LRMdl_loo=fitglm(loo_data,loo_sample_labels,'Distribution','binomial','Link','logit');
    [~,prediction]=getModelScores(LRMdl_loo,data(leave_out,:));
    errors_lrm_loo(leave_out)=~(prediction==sample_labels(leave_out));
end

out.lrm_loo=round(100*sum(errors_lrm_loo)/length(errors_lrm_loo));
if invar.print
    display(strcat('error rate for Logistic Regression classification using LOO-CV:',num2str(out.lrm_loo),'%'));
end


%% do resubstitution CV with Logistic Regression Model
LRMdl=fitglm(data,sample_labels,'Distribution','binomial','Link','logit');
errors_lrm_resub=zeros(1,size(data,1));
for test_number=1:size(data,1)
    [~,prediction]=getModelScores(LRMdl,data(test_number,:));
    errors_lrm_resub(test_number)=~(prediction==sample_labels(test_number));
end

out.lrm_resub=round(100*sum(errors_lrm_resub)/length(errors_lrm_resub));
if invar.print
    display(strcat('error rate for Logistic Regression classification using resubstitution-CV:',num2str(out.lrm_resub),'%'));
end

%% do resubstitution CV with SVM
SVMMdl=fitcsvm(data,sample_labels);
errors_svm_resub=zeros(1,size(data,1));
for test_number=1:size(data,1)
    [~,prediction]=getModelScores(SVMMdl,data(test_number,:));
    errors_svm_resub(test_number)=~(prediction==sample_labels(test_number));
end

out.svm_resub=round(100*sum(errors_svm_resub)/length(errors_svm_resub));
if invar.print
    display(strcat('error rate for SVM classification using resubstitution-CV:',num2str(out.svm_resub),'%'));
end

%% do LOO CV with SVM
errors_svm_loo=zeros(1,size(data,1));
for leave_out=1:size(data,1)
    loo_data=[data(1:leave_out-1,:);data(leave_out+1:end,:)];
    loo_sample_labels=[sample_labels(1:leave_out-1) sample_labels(leave_out+1:end)];
    SVMMdl_loo = fitcsvm(loo_data,loo_sample_labels);
    [~,prediction]=getModelScores(SVMMdl_loo,data(leave_out,:));
    errors_svm_loo(leave_out)=~(prediction==sample_labels(leave_out));
end

out.svm_loo=round(100*sum(errors_svm_loo)/length(errors_svm_loo));
if invar.print
    display(strcat('error rate for SVM classification using LOO-CV:',num2str(out.svm_loo),'%'));
end

%% do LOO CV with LDA, one channel at a time
for channel_num=1:size(data,2)
    errors_lda_loo=zeros(1,size(data,1));
    for leave_out=1:size(data,1)
        loo_data=[data(1:leave_out-1,:);data(leave_out+1:end,:)];
        loo_sample_labels=[sample_labels(1:leave_out-1) sample_labels(leave_out+1:end)];
        LDAMdl_loo = fitcdiscr(loo_data(:,channel_num),loo_sample_labels);
        [~,prediction]=getModelScores(LDAMdl_loo,data(leave_out,channel_num));
        errors_lda_loo(leave_out)=~(prediction==sample_labels(leave_out));
    end
    fn=strcat('lda_loo_channel',num2str(channel_num));
    out.(fn)=round(100*sum(errors_lda_loo)/length(errors_lda_loo));

    if invar.print
        display(char(strcat('error rate for LDA classification using LOO-CV on channel #',num2str(channel_num),{': '},num2str(out.(fn)),'%')));
    end
end

%%
out.note='These numbers are error rate percentages';
