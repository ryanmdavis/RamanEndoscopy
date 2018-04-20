    function [means, stdevs,vals,samples] = retrieve(tissue,channel)
    % E8S5 was originally classified as normal by surgeon but I think it is
    % cancer
    ambiguous={}; %#ok<NASGU>
    urothelium={'E1S2','E3S1','E4S2','E5S1','E6S1','E10S1','E8S5'};
    tumor={'E2S1','E2S2','E5S2','E8S3','E8S4','E9S1','E9S2','E9S3'};
    muscle={'E1S1','E1S3','E4S1','E6S2','E6S3','E8S1','E8S2','E10S2'};

    switch channel
        case 's440'
            channel_num=3;
        case 's421'
            channel_num=2;
        case 's420'
            channel_num=1;
        otherwise
            error('channel must be s440,s421, or s420');
    end
    
    if ~iscell(tissue)
        switch tissue(1)
            case 'm'
                samples=muscle;
            case 't'
                samples=tumor;
            case 'u'
                samples=urothelium;
            otherwise
                error('tissue_type must be m(uscle), t(umor), or u(rothelium)');
        end
    elseif size(tissue,2)>1
        switch tissue{1}
            case 'm'
                a=muscle;
            case 't'
                a=tumor;
            case 'u'
                a=urothelium;
            otherwise
                error('tissue_type must be m(uscle), t(umor), or u(rothelium)');
        end
        
        switch tissue{2}
            case 'm'
                b=muscle;
            case 't'
                b=tumor;
            case 'u'
                b=urothelium;
            otherwise
                error('tissue_type must be m(uscle), t(umor), or u(rothelium)');
        end
        samples = union(a,b);
    end
        
    %union(eval('urothelium','caller'),eval('tumor','caller'));
    
    means=zeros(1,size(samples,2));
    stdevs=zeros(1,size(samples,2));
    
    vals=[];
    for sample_num=1:size(samples,2)
        load('C:\Users\rdavis5\Documents\Gambhir lab\Gambhir Data and Analysis\Raman Endoscope\Data summaries\ROI analysis of all samples\all_samples.mat',samples{sample_num});
        sample=eval(strcat(samples{sample_num},'(',num2str(channel_num),')'));
        means(sample_num)=mean(sample.values);
        stdevs(sample_num)=std(sample.values);
        vals=[vals;sample.values];
    end            