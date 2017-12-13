circMean = function(a, maxVal=1, na.rm=TRUE, forcePos=FALSE) {
	x = cos(a / maxVal * 2 * pi)
	y = sin(a / maxVal * 2 * pi)
	m = atan2(sum(y, na.rm=na.rm), sum(x, na.rm=na.rm)) / 2 / pi
	if (forcePos) {
		ifelse(m < 0, m + 1, m) * maxVal
	} else {
		m * maxVal}}


tipaPeriod = function(phaseRefTimes, switchTime=0) {
	tPre = phaseRefTimes[phaseRefTimes < switchTime]
	periodPre = (max(tPre) - min(tPre)) / (length(tPre) - 1)
	tPost = phaseRefTimes[phaseRefTimes >= switchTime]
	periodPost = (max(tPost) - min(tPost)) / (length(tPost) - 1)
	list(pre = periodPre, post = periodPost)}


#' Calculate the phase shift induced by a stimulus during a circadian time-course.
#'
#' `tipaPhaseRef` calculates the phase shift based on the times of a phase reference point
#' (e.g., onset of activity), accounting for possible period changes and for the point in
#' the circadian cycle at which the stimulus occurred. If the rhythms of the measurement
#' are approximately sinusoidal, it is recommended to instead use `\link{tipaCosinor}`.
#'
#' @param phaseRefTimes Vector of times of the chosen phase reference point.
#' @param switchTime Time at which the stimulus started.
#' @param switchDuration Duration of the stimulus and any transients. Data between
#' `switchTime` and `switchTime + switchDuration` will be ignored.
#' @param period Optional list with elements "pre" and "post" corresponding to the period of
#' the oscillations prior to and subsequent to the stimulus. If not supplied, the periods
#' for pre- and post-stimulus are calculated as the mean time between occurrences of the
#' phase reference point within the respective epoch. It is recommended to not use this
#' argument.
#'
#' @return A list.
#' \item{phaseShift}{Estimated phase shift in circadian hours. Negative values
#' indicate a delay, positive values an advance.}
#' \item{epochInfo}{Dataframe containing estimated period for each epoch.}
#'
#' @example R/tipa_example_phaseref.R
#'
#' @seealso `\link{tipaCosinor}`
#'
#' @export
tipaPhaseRef = function(phaseRefTimes, switchTime, switchDuration=0, period=NULL) {
	phaseRefTimes = sort(phaseRefTimes)
	if (is.null(period)) {
		period = tipaPeriod(phaseRefTimes, switchTime)}

	tPreLast = max(phaseRefTimes[phaseRefTimes < switchTime])
	fracCycleRem = 1 - (switchTime - tPreLast) / period$pre

	tPost = phaseRefTimes[phaseRefTimes > switchTime + switchDuration]
	tPostExpect = switchTime + period$post * (fracCycleRem + 0:(length(tPost)-1))
	tPostResid = tPostExpect - tPost

	phaseShift = circMean(tPostResid, maxVal=period$post) * 24 / period$post
	epochInfo = data.frame(epoch = names(period), period = unname(unlist(period)), stringsAsFactors=FALSE)
	list(phaseShift = phaseShift, epochInfo = epochInfo)}


cosinor = function(time, y, per) {
	df = data.frame(y = y, timeCos = cos(2*pi*time/per), timeSin = sin(2*pi*time/per))
	stats::lm(y ~ timeCos + timeSin, data=df)}


cosinorCost = function(time, y, per) {
	fit = cosinor(time, y, per)
	mean(fit$residuals^2)}


fitCosinor = function(time, y, periodGuess=24) {#, nKnotsTrend=3) {
	optimFit = optimr::optimr(c(p=periodGuess), fn=function(p) cosinorCost(time, y, p),
									  lower=0, method='L-BFGS-B')
	period = optimFit$par[['p']]
	cosinorFit = cosinor(time, y, period)
	rmsError = sqrt(cosinorCost(time, y, period))
	phaseRad = atan2(stats::coef(cosinorFit)[['timeSin']], stats::coef(cosinorFit)[['timeCos']])
	data.frame(period = period, phaseRad = phaseRad, rmsError = rmsError)}


#' Calculate the phase shift induced by a stimulus during a circadian time-course.
#'
#' `tipaCosinor` calculates the phase shift based on fitting sine curves to waveform
#' data before and after the stimulus, accounting for possible period changes and for
#' the point in the circadian cycle at which the stimulus occurred. This function will
#' work best for measurements whose rhythms are approximately sinusoidal, or at least
#' smoothly increasing and decreasing. If your data are not sinusoidal, you can first
#' define the phase reference points and then use `\link{tipaPhaseRef}`.
#'
#' @param time Vector of time values for the full time-course.
#' @param y Vector of measurements (e.g., bioluminescence) for the full time-course.
#' @param switchTime Time at which the stimulus started.
#' @param switchDuration Duration of the stimulus and any transients. Data between
#' `switchTime` and `switchTime + switchDuration` will be ignored.
#' @param periodGuess Approximate period of the oscillations (in the same units used
#' in `time`), used as initial value in fitting the sine curves.
#' @param shortcut Calculate phase shift using the standard TIPA procedure or using a
#' shortcut based on the phases of the sine curve fits. The two methods give exactly
#' the same result.
#'
#' @return A list.
#' \item{phaseShift}{Estimated phase shift in circadian hours. Negative values
#' correspond to a delay, positive values an advance.}
#' \item{epochInfo}{Dataframe containing information about the sine curve fits for each epoch:
#' period (in the same units used in `time`), phase (in radians), and root mean square error
#' (in the same units used in `y`). If the RMS errors pre-stimulus and post-stimulus are
#' substantially different, then the stimulus may have induced a change in the waveform and thus
#' phase shift estimates may be invalid.}
#'
#' @example R/tipa_example_cosinor.R
#'
#' @seealso `\link{tipaPhaseRef}`
#'
#' @export
tipaCosinor = function(time, y, switchTime, switchDuration=0, periodGuess=24, shortcut=TRUE) {
	postTime = switchTime + switchDuration

	fitPre = fitCosinor(time[time < switchTime], y[time < switchTime], periodGuess)
	fitPre = data.frame(epoch = 'pre', fitPre, stringsAsFactors=FALSE)

	fitPost = fitCosinor(time[time > postTime], y[time > postTime], periodGuess)
	fitPost = data.frame(epoch = 'post', fitPost, stringsAsFactors=FALSE)

	if (shortcut) {
		phaseShift = (fitPre$phaseRad - fitPost$phaseRad) * 24 / 2 / pi
		phaseShift = phaseShift - 24 * (phaseShift > 12) + 24 * (phaseShift < (-12))
	} else {
		# find last peak time before switchTime
		tPreLast = stats::optimize(function(tt) -cos(tt*2*pi/fitPre$period - fitPre$phaseRad),
								  interval = c(switchTime - fitPre$period*1.1, switchTime))$minimum
		if (tPreLast + fitPre$period < switchTime) {
			tPreLast = tPreLast + fitPre$period}

		# estimate fraction of cycle remaining
		fracCycleRem = 1 - (switchTime - tPreLast) / fitPre$period

		# find first peak time after postTime
		tPostObs = stats::optimize(function(tt) -cos(tt*2*pi/fitPost$period - fitPost$phaseRad),
								  interval = c(postTime, postTime + fitPost$period*1.1))$minimum

		# find expected time of first fit peak after switchTime (ok even if non-zero transients)
		tPostExpect = switchTime + fitPost$period * fracCycleRem

		# circular mean of residual, using post period as reference
		phaseShift = circMean(tPostExpect - tPostObs, maxVal = fitPost$period)

		# convert phase shift to circadian hours
		phaseShift = phaseShift * 24 / fitPost$period}

	list(phaseShift = phaseShift, epochInfo = rbind(fitPre, fitPost))}
