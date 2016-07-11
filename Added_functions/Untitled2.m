load fisheriris;
        svm = fitcsvm(meas,ones(size(meas,1),1),'Standardize',true,...
                'KernelScale','auto','OutlierFraction',0.05);
        cv = crossval(svm);
        [~,score] = kfoldPredict(cv);
        mean(score<0)