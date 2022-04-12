library('tidyverse')
library('cowplot')
library('doParallel')
library('doRNG')

registerDoParallel(cores = 2) # can be adjusted based on your machine
set.seed(8675309)

eb = element_blank()
theme_set(theme_light() +
            theme(axis.text = element_text(color = 'black'), strip.text = element_text(color = 'black'),
                  panel.grid.minor = eb, legend.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = 'cm')))

folderPath = '~/Dropbox (VUMC)/hughey_lab/projects/active/period_phase_detector/accompaniment/'
simData = read_csv(file.path(folderPath, 'sim_cosinor_timecourses.csv'), col_types = cols())
simParams = read_csv(file.path(folderPath, 'sim_cosinor_params.csv'), col_types = cols())

###################################

idx = which(with(simParams, {snr == 10 & periodPost == 26 & phaseShift == 4 & nCycles == 3}))

startTime = Sys.time()
tipaResultList = foreach(ii = idx) %dorng% {
  simDataNow = filter(simData, simIdx == ii)
  tipaCosinor(simDataNow$time, simDataNow$y + simDataNow$time, stimOnset = 0, trend = FALSE)} #
phaseShiftFlat = sapply(tipaResultList, function(r) r$phaseShift)
runtimeFlat = Sys.time() - startTime

startTime = Sys.time()
tipaResultList = foreach(ii = idx) %dorng% {
  simDataNow = filter(simData, simIdx == ii)
  tipaCosinor(simDataNow$time, simDataNow$y + simDataNow$time, stimOnset = 0, trend = TRUE)}
phaseShiftTrend = sapply(tipaResultList, function(r) r$phaseShift)
runtimeTrend = Sys.time() - startTime
runtimeTrend

p = 4

sqrt(mean((p - phaseShiftFlat) ^ 2))
sqrt(mean((p - phaseShiftTrend) ^ 2))

# tipaResultList = foreach(ii=unique(simData$simIdx)) %dorng% {
# 	simDataNow = filter(simData, simIdx==ii)
# 	tipaCosinor(simDataNow$time, simDataNow$y, stimOnset=0, trend=TRUE)}

# simParams$phaseShiftEst = sapply(tipaResultList, function(r) r$phaseShift)
# simParams$periodPreEst = sapply(tipaResultList, function(r) r$epochInfo$period[1])
# simParams$periodPostEst = sapply(tipaResultList, function(r) r$epochInfo$period[2])

###################################

simParamsPlot = simParams %>%
  mutate(snr = paste('SNR:', snr),
         phaseShiftLabel = paste('Phase shift (c.h.):', phaseShift),
         phaseShiftErr = phaseShiftEst - phaseShift,
         periodPostErr = periodPostEst - periodPost)

pPeriod = ggplot(simParamsPlot) +
  facet_grid(snr ~ .) +
  geom_boxplot(aes(x = factor(periodPost), y = periodPostErr, fill = factor(nCycles)),
               width = 0.7, position = position_dodge(width = 0.8), outlier.shape = 21, outlier.size = 1) +
  labs(x = 'Post-stimulus period (h)', y = 'Period error (h)') +
  scale_fill_brewer(type = 'qual', palette = 'Set2', guide = FALSE)

pPhase = ggplot(simParamsPlot) +
  facet_grid(snr ~ phaseShiftLabel) +
  geom_boxplot(aes(x = factor(periodPost), y = phaseShiftErr, fill = factor(nCycles)),
               width = 0.7, position = position_dodge(width = 0.8), outlier.shape = 21, outlier.size = 1) +
  labs(x = 'Post-stimulus period (h)', y = 'Phase shift error (c.h.)', fill = 'Number of\ncycles') +
  scale_fill_brewer(type = 'qual', palette = 'Set2')
