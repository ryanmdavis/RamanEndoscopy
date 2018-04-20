function [means, stdevs] = retrieve(tissue,channel)
    urothelium={'E1S2','E4S2','E5S1','E6S1','E8S5'};
    tumor={'E2S1','E2S2','E5S2','E8S3','E8S4'};
    muscle={'E1S1','E1S3','E4S1','E6S2','E6S3','E8S1','E8S2'};
    
    keyboard;
    
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
    
    for sample_num=1:size(samples,2)
%         eval(strcat(samples(sample_num) 
    end
            
            
            
%             
%             means=zeros(1,size(muscle,2));
%             stdevs=zeros(1,size(muscle,2));
%             for sample_num=
            