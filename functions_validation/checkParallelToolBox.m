function bInstalled = checkParallelToolBox()

cTmp = ver('parallel');
bInstalled = cTmp.Name == "Parallel Computing Toolbox";

end