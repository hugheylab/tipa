circMean = function(a, maxVal=1, na.rm=TRUE, forcePos=FALSE) {
	x = cos(a / maxVal * 2 * pi)
	y = sin(a / maxVal * 2 * pi)
	m = atan2(sum(y, na.rm=na.rm), sum(x, na.rm=na.rm)) / 2 / pi
	if (forcePos) {
		ifelse(m < 0, m + 1, m) * maxVal
	} else {
		m * maxVal}}


tipaPeriod = function(extremumTimes, switchTime=0) {
	tPre = extremumTimes[extremumTimes < switchTime]
	tauPre = (max(tPre) - min(tPre)) / (length(tPre) - 1)
	tPost = extremumTimes[extremumTimes >= switchTime]
	tauPost = (max(tPost) - min(tPost)) / (length(tPost) - 1)
	list(pre = tauPre, post = tauPost)}


#' Calculate the phase shift induced by a stimulus during a circadian time-course.
#'
#' \code{tipa} calculates the phase shift based on the times of a phase reference point
#' (e.g., peak in bioluminescence) and the time of the stimulus. \code{tipa} accounts
#' for possible period changes and for the stage of the circadian cycle at which the stimulus
#' occurs, as described in \url{https://hugheylab.org/papers}.
#'
#' @param extremumTimes Vector of times of the chosen phase reference point.
#' @param switchTime Number corresponding to the time of the stimulus.
#' @param tau Optional list with elements "pre" and "post" corresponding to the period of
#' the oscillator prior to and subsequent to the stimulus. If not supplied, the periods
#' for pre- and post-stimulus are calculated as the mean time between occurrences of the
#' phase reference point within the respective epoch.
#'
#' @return A list.
#' \item{tau}{List containing the period of the oscillator pre- and post-stimulus.}
#' \item{extremaPost}{Data frame of intermediate calculations.}
#' \item{deltaPhi}{Estimated phase shift, in units of the original measurements. Negative values
#' indicate a delay, positive values an advance.}
#'
#' @example R/tipa_example.R
#'
#' @export
tipa = function(extremumTimes, switchTime, tau=NULL) {
	extremumTimes = sort(extremumTimes)
	if (is.null(tau)) {
		tau = tipaPeriod(extremumTimes, switchTime)}

	tPreLast = max(extremumTimes[extremumTimes < switchTime])
	fracCycleRem = 1 - (switchTime - tPreLast) / tau$pre

	tPost = extremumTimes[extremumTimes >= switchTime]
	tPostExpect = switchTime + tau$post * (fracCycleRem + 0:(length(tPost)-1))
	tPostResid = tPostExpect - tPost

	deltaPhi = circMean(tPostResid, maxVal=tau$post)
	extremaPost = data.frame(time = tPost, timeExpected = tPostExpect, timeResidual = tPostResid)
	list(tau = tau, extremaPost = extremaPost, deltaPhi = deltaPhi)}
