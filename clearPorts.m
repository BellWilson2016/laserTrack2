function clearPorts()

if (~isempty(instrfind))
    fclose(instrfind);      % closes matlab's open serial ports
end