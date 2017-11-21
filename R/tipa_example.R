# Peak times of bioluminescence (in hours)
extremumTimes = c(-75.5, -51.5, -27.4, -3.8,
		  20.5, 42.4, 65.5, 88.0)
result = tipa(extremumTimes, switchTime=0)
result

# Convert phase shift estimate to circadian hours
result$deltaPhi / result$tau$post * 24

# Example using csv files with data from multiple experiments
extrFile = system.file('extdata', 'extremumTimes.csv', package='tipa')
switchFile = system.file('extdata', 'switchTimes.csv', package='tipa')

file.show(extrFile)
file.show(switchFile)

extrDf = read.csv(extrFile, stringsAsFactors=FALSE)
switchDf = read.csv(switchFile, stringsAsFactors=FALSE)

resultList = lapply(switchDf$expId, function(ii) {
   tipa(extrDf$extremumTime[extrDf$expId==ii],
        switchDf$switchTime[switchDf$expId==ii])
})

deltaPhiVec = sapply(resultList, function(r) r$deltaPhi)

write.csv(data.frame(expId = switchDf$expId, deltaPhi = deltaPhiVec),
          'tipa_phase_shifts.csv', quote=FALSE, row.names=FALSE)
