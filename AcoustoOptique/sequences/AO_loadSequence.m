function SEQ = AO_loadSequence( SEQ , AixplorerIP )
%load sequence after log file or fast loop as executed

%%%    Do NOT CHANGE - Sequence execution 
%%%    Initialize remote on systems


 %% initialize communation with remote aixplorer and load sequence
try
 SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);
 display('============== Remote OK =============');
 display('Loading sequence to Hardware'); tic ;
 SEQ = SEQ.loadSequence();
 fprintf('Sequence has loaded in %f s \n\r',toc)
 display('--------ready to use -------------');
 
catch e
  fprintf(e.message);  
end



end

