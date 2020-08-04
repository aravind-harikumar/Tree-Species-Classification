function mainFunctionOfMethord()
    % The ALS/TLS of data individual trees are manually/automatically delineated, and filtered to remove noisy points.
    % Define the filepath here and file name variable in this code. Give this filepath and name as input to the getConiferIGFs and
    % getConiferEGFs function and (remove filepath from them) to avoid repetition of filepath and filename data.

    %IGFs_proposed = 6 Internal Geometric Features derived from the proposed model
    %IGFs_proposed = 6 Internal Geometric Features derived from the SoA model
    %EGFs = 6 External Geometric Features

    % Provide full path of the folder containing the .las files
    % The full path should not have '-' (hyphens) in it %
    
    % Proved full name of specific .las file if needed, else for considering 
    % all the .las files the folder (on by one) provide '*.las'.
    
        
    FolderPath = '.\';
    addpath(genpath(strcat(FolderPath,'Matlab_depedencies')));
    addpath(genpath(strcat(FolderPath,'SVM_Classifiers\')));
    InputFilePath = strcat(FolderPath,'LiDARDataSingleTrees\');
    speciesFolder = {'ar' 'la' 'pc' 'ab'}; % LiDAR data of the four different species.    
    OutFolder = strcat(FolderPath,'generatedCSVs\');
    
    IGFsProposed=[]; IGFSoAs=[]; EGFs=[]; Labels=[]; 

    % Show 3D plots true/false
    plotOn = true;
    
    for i=1:size(speciesFolder,2)
        % Provide specific .las file if needed. Else for considering all 
        % the .las files the folder (on by one) provide '*.las'
        inFilepath = char(strcat(InputFilePath,speciesFolder(i),'\')); % cycles through all the input folders
        files = dir(strcat(inFilepath,'*.las'));
        disp(strcat('Currently working on:', {' '}, num2str(speciesFolder{i})) );
        
        % Get the IGFs from the Proposed method        
        if(plotOn)
            figure(1);
        end        
        [A, ASliced, numBranches] = getConiferIGFs_Proposed(inFilepath, speciesFolder{i}, files, plotOn);
        %A = getConiferIGFs_Method2(inFilepath, speciesFolder{i}, files, plotOn);        
        % 6 IGFs from entire tree (proposed method)   
        IGFsProposed = [IGFsProposed; A(:,1:6)];
        
        %Get the EGFs from the respective Cone fit & Convex hull
        if(plotOn)
            figure(3);
        end
        C = getEGFs(inFilepath,speciesFolder{i},files, plotOn); 
        EGFs = [EGFs; C];

        % Label column values
        Labels=[Labels; repmat(i,size(C,1),1)];
    end
    
    % Feature value normalization
    Norm_IGFsPCA = normalize(IGFsProposed); 
    Norm_EGFs = normalize(EGFs);    
    
    % Generate Excel Files with feature values for experiments
    Normalized_features_set0=[Norm_EGFs Labels];  % For experiments 1
    Normalized_features_set2=[Norm_IGFsPCA Labels];  % For experiments 2
    Normalized_features_set4=[Norm_IGFsPCA, Norm_EGFs, Labels];  % For experiments 3
     
    % Print result in CSV
    csvwrite(strcat(OutFolder,'Norm_EGFs.csv'),Normalized_features_set0);
    csvwrite(strcat(OutFolder,'Norm_IGFsPCA.csv'),Normalized_features_set2);
    csvwrite(strcat(OutFolder,'Norm_IGFsPCA_EGFs.csv'),Normalized_features_set4);

end

% Function for normalization column by column
function Norm=normalize(A)
    Norm_A=[];
    for i=1:size(A,2)
        Norm_col=(A(:,i)-min(A(:,i)))/(max(A(:,i))-min(A(:,i)));
        Norm_A=[Norm_A,Norm_col];
    end
    Norm=Norm_A;
end