# Peak times of bioluminescence (in hours)
phaseRefTimes = c(-75.5, -51.5, -27.4, -3.8,
		  20.5, 42.4, 65.5, 88.0)
result = tipaPhaseRef(phaseRefTimes, stimOnset = 0)

# Data from multiple (simulated) experiments
getExtrFile = function() system.file('extdata', 'phaseRefTimes.csv', package = 'tipa')
getStimFile = function() system.file('extdata', 'stimOnsets.csv', package = 'tipa')

extrDf = read.csv(getExtrFile(), stringsAsFactors = FALSE)
stimDf = read.csv(getStimFile(), stringsAsFactors = FALSE)

resultList = lapply(stimDf$expId, function(ii) {
	phaseRefTimes = extrDf$phaseRefTime[extrDf$expId == ii]
	stimOnset = stimDf$stimOnset[stimDf$expId == ii]
   tipaPhaseRef(phaseRefTimes, stimOnset)
})

phaseShifts = sapply(resultList, function(r) r$phaseShift)

write.csv(data.frame(expId = stimDf$expId, phaseShift = phaseShifts),
          'tipa_phaseref.csv', quote = FALSE, row.names = FALSE)
