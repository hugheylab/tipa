# Peak times of bioluminescence (in hours)
phaseRefTimes = c(-75.5, -51.5, -27.4, -3.8,
		  20.5, 42.4, 65.5, 88.0)
result = tipaPhaseRef(phaseRefTimes, switchTime=0)
result

# Data from multiple (simulated) experiments
extrFile = system.file('extdata', 'phaseRefTimes.csv', package='tipa')
switchFile = system.file('extdata', 'switchTimes.csv', package='tipa')

file.show(extrFile)
file.show(switchFile)

extrDf = read.csv(extrFile, stringsAsFactors=FALSE)
switchDf = read.csv(switchFile, stringsAsFactors=FALSE)

resultList = lapply(switchDf$expId, function(ii) {
	phaseRefTimes = extrDf$phaseRefTime[extrDf$expId==ii]
	switchTime = switchDf$switchTime[switchDf$expId==ii]
   tipaPhaseRef(phaseRefTimes, switchTime)
})

phaseShifts = sapply(resultList, function(r) r$phaseShift)

write.csv(data.frame(expId = switchDf$expId, phaseShift = phaseShifts),
          'tipa_phaseref.csv', quote=FALSE, row.names=FALSE)
