function [true_positive_rate, false_positive_rate] = ldaRoc(data,sample_labels)

tumor_priors=linspace(0,1,100);
all_positives=cell(size(data,1),1);
all_positives(:)={'tumor'};
true_positive_rate=zeros(1,size(data,1));
false_positive_rate=zeros(1,size(data,1));
for prior_num=1:size(tumor_priors,2)
    MdlLinear = fitcdiscr(data,sample_labels,'Prior',[tumor_priors(prior_num) 1-tumor_priors(prior_num)]);
    predicted_labels=predict(MdlLinear,data);
    corrects=cellfun(@strcmp,predicted_labels,sample_labels.');
    predicted_positives=cellfun(@strcmp,all_positives,predicted_labels);
    real_positives=cellfun(@strcmp,all_positives,sample_labels.');
    true_positive_rate(prior_num)=sum(corrects.*real_positives)/sum(real_positives);
    false_positive_rate(prior_num)=sum((~corrects).*predicted_positives)/sum(~real_positives);
%     keyboard;
end

AUC = sum(true_positive_rate)/len(true_positive_rate);