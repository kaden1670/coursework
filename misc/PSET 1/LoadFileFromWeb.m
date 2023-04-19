function LoadFileFromWeb( FileNameList )
    if( ~iscell( FileNameList ) )
        FileNameList = { FileNameList };
    end
    
    for ii = 1:numel( FileNameList )
        headerFields = { 'Content-Type', 'application/octet-stream' };
        % Set the options for WEBREAD
        opt = weboptions;
        opt.MediaType = 'application/octet-stream';
        opt.CharacterEncoding = 'ISO-8859-1';
        opt.RequestMethod = 'post';
        opt.HeaderFields = headerFields;

        % Download the file
        try
            rawData = webread([ 'https://www.measurebiology.org/EdX/' FileNameList{ii}], opt);
        catch someException
            throw(addCause(MException('downloadFromDropbox:unableToDownloadFile',strcat('Unable to download file:',FileNameList{ii})),someException));
        end

        fullPath = fullfile( pwd, FileNameList{ii} );

        try
            fileID = fopen(fullPath,'w');
            fwrite(fileID,rawData);
            fclose(fileID);
        catch someException
            throw(addCause(MException('downloadFromDropbox:unableToSaveFile', sprintf('Unable to save downloaded file %s in the downloadPath',fileNames{i})),someException));
        end
    end
end