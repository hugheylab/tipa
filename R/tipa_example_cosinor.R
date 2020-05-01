# Time-course data from multiple (simulated) experiments
getTimecourseFile = function() system.file('extdata', 'timecourses.csv', package = 'tipa')
df = read.csv(getTimecourseFile(), stringsAsFactors = FALSE)

resultList = lapply(sort(unique(df$expId)), function(ii) {
	time = df$time[df$expId == ii]
	y = df$intensity[df$expId == ii]
   tipaCosinor(time, y, stimOnset = 0)
})

phaseShifts = sapply(resultList, function(r) r$phaseShift)

write.csv(data.frame(expId = sort(unique(df$expId)), phaseShift = phaseShifts),
          'tipa_cosinor.csv', quote = FALSE, row.names = FALSE)
