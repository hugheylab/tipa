# Peak times of bioluminescence (in hours)
phaseRefTimes = c(-75.5, -51.5, -27.4, -3.8,
		  20.5, 42.4, 65.5, 88.0)
result = tipaPhaseRef(phaseRefTimes, stimOnset = 0)

# Data from multiple (simulated) experiments
extrFile = system.file('extdata', 'phaseRefTimes.csv', package = 'tipa')
stimFile = system.file('extdata', 'stimOnsets.csv', package = 'tipa')

extrDf = read.csv(extrFile, stringsAsFactors = FALSE)
stimDf = read.csv(stimFile, stringsAsFactors = FALSE)

resultList = lapply(stimDf$expId, function(ii) {
	phaseRefTimes = extrDf$phaseRefTime[extrDf$expId == ii]
	stimOnset = stimDf$stimOnset[stimDf$expId == ii]
   tipaPhaseRef(phaseRefTimes, stimOnset)
})

phaseShifts = sapply(resultList, function(r) r$phaseShift)

write.csv(data.frame(expId = stimDf$expId, phaseShift = phaseShifts),
          'tipa_phaseref.csv', quote = FALSE, row.names = FALSE)
