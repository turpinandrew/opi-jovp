#
# MOCS algorithm for a single location, nAFC possible with beeps.
#
# Author: Andrew Turpin
#         (Based on disucssions with Tony Redmond July 2012).
# Date: May 2015
# Modified Tue 21 Mar 2023: changed licence from gnu to Apache 2.0 
#
# Copyright [2022] [Andrew Turpin]
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require(stats)
require(utils)

################################################################################
# Perform a MOCS, possibly with alternate-forced-choice stimuli.
# The number of AFC are given by the number of columns in params.
#
# Input parameters
#   params  A matrix where each row is 
#           x y loc_num number-of-present'ns correct_lum_num luminance-level-1 ll2 ll3 ...
#           Each row of params is presented number-of-presentations times in the
#           order determined by the "order" paramter. For a yes/no MOCS, there is 
#           only one luminance level. For @AFC, there are two, etc.
#
#   order     Control the order in which the stimuli are presented.
#               "random" - uniform random for all trials.
#               "fixed"   - just present in order of 1:nrow(params), ignoring 
#                           number-of-presentations column.
#
#   responseWindowMeth Control time perimeter waits for response. 
#               "speed" - after an average of the last 'speedHistory' 
#                         response times, with a minimum of 'responseFloor'.
#                         Initially responseFloor.
#               "constant" - always use responseFloor.
#               "forceKey" - wait for a keyboard input.
#
#   responseHistory - number of past yesses to average to get reposnse window
#                      (only used if responseWindowMeth == "speed")
#
#   responseFloor Minimum response window (for any responseWindowMeth except forceKey). 
#                   
#   keyHandler   Function to get a keyboard input and returns as for opiPresent:
#                list(seen={TRUE|FALSE}, response time (in ms), error code).
#                Param to function is correct lum level (col 4 of params), and 
#                result of opiPresent.
#                   
#   interStimMin Regardless of response, wait runif(interStimMin, interStimMax) ms.
#   interStimMax
#
#   beep_function A funtion that takes 'correct', 'incorrect', or a stimulus number
#                 and plays an appropriate sound.
#
#   makeStim  A helper function to take a row of params[] and a response window 
#             length in ms, and create a list of OPI stimuli types for 
#             passing to opiPresent. Might include checkFixationOK function.
#
#   stim_print A function that takes opiStaticStimulus and return list from opiPresent
#              and returns a string to print.
#
#   ...       Parameters for opiPresent
#
# Returns a data.frame with one row per stim, 
#       col 1 Location number (row number in input params matrix)
#       col 2 x 
#       col 3 y 
#       col 4 correct_lum_num 
#       col 5 true/false all fixations in trial good according to checkFixationOK (TRUE if no checkFixationOK)
#       ncol(params)-1 are same as params[5:],
#       column last-2 = correct/incorrect
#       column last-1 = response time 
#       column last   = err code
#
# Also prints x,y,fixations_good,stim_print(stim, return) for each trial
################################################################################
#' @rdname MOCS
#' @title Method of Constant Stimuli (MOCS)
#' @description MOCS performs either a yes/no or n-interval-forced-choice Method of
#' Constant Stimuli test
#' @param params A matrix where each row is \code{x y i n correct_n ll1 ll2 ... llm} where
#'   \itemize{
#'     \item{\code{x} is X coordinate of location}
#'     \item{\code{y} is Y coordinate of location}
#'     \item{\code{i} is a location number (assigned by caller)}'
#'     \item{\code{n} is Number of times this location/luminance(s) should be repeated}
#'     \item{\code{correct_n} is the index i of the luminance level (\code{lli}) that
#'       should be treated as a ``correct'' response (the correct interval). For a
#'       standard MOCS, this will be 1; for a 2AFC, this will be 1 or 2. This number will
#'       be in the range \code{[1,m]}.}
#'       \item{\code{lli} is the i'th luminance level to be used at this location for
#'       interval i of the presentation in cd/\eqn{\mbox{m}^2}{m^2}. For a standard MOCS,
#'       i=1, and the \code{params} matrix will have 5 columns. For a 2AFC, there will be
#'       two lli's, and \code{params} will have 6 columns.}
#'   }
#' @param order Control the order in which the stimuli are presented.
#'   \itemize{
#'     \item{\code{"random"} Randomise the order of trials/locations.}
#'     \item{\code{"fixed"} Present each row of \code{params} in order of
#'       \code{1:nrow(params)}, ignoring the \code{n} (3rd) column in \code{params}.}
#'   }
#' @param responseWindowMeth Control time perimeter waits for response.
#'   \itemize{
#'     \item{\code{"speed"} After an average of the last \code{speedHistory}
#'       response times, with a minimum of \code{responseFloor}. Initially
#'       \code{responseFloor}.}
#'     \item{\code{"constant"} Always use \code{responseFloor}.}
#'     \item{\code{"forceKey"} Wait for a keyboard input.}
#'   }
#' @param responseFloor Minimum response window (for any \code{responseWindowMeth}
#'   except \code{"forceKey"}).
#' @param responseHistory Number of past yeses to average to get response window
#'   (only used if \code{responseWindowMeth} is \code{"speed"}).
#' @param keyHandler Function to get a keyboard input and returns as for \code{opiPresent}:
#'   list(seen={TRUE|FALSE}, response time (in ms), error code). The parameters passed to
#'   the function are the correct interval number (column 4 of \code{params}), and the
#'   result of \code{opiPresent}. See Examples.
#' @param interStimMin Regardless of response, wait \code{runif(interStimMin, interStimMax)} ms.
#' @param interStimMax Regardless of response, wait \code{runif(interStimMin, interStimMax)} ms.
#' @param beep_function A function that takes the string \code{'correct'}, the string
#' \code{'incorrect'}, or a stimulus number and plays an appropriate sound.  See examples.
#' @param makeStim A helper function to take a row of \code{params} and a response window length
#' in ms, and create a list of OPI stimuli types for passing to opiPresent. This may include a
#' \code{checkFixationOK} function. See Example.
#' @param stim_print A function that takes an \code{opiStaticStimulus} and return list from
#' \code{opiPresent} and returns a string to print for each presentation. It is called
#' immediately after each \code{opiPresent}, and the string is prepended with the
#' (x,y) coordinates of the presentation and ends with a newline.
#' @param ... Extra parameters to pass to the opiPresent function.
#' @details Whether the test is yes/no or forced-choice is determined by the number of columns
#' in \code{params}. The code simply presents all columns from 5 onwards and collects a
#' response at the end. So if there is only 5 columns, it is a yes/no task. If there are 6
#' columns it is a 2-interval-forced-choice. Generally, an nIFC experiment has 4+n columns in
#' \code{params}.
#' 
#' Note that when the \code{order} is \code{"random"}, the number of trials in the test will be
#' the sum of the 3rd column of \code{params}. When the \code{order} is \code{"fixed"}, there is
#' only one presentation per row, regardless of the value in the 3rd column of \code{params}.
#' 
#' If a response is received before the final trial in a nIFC experiment, it is ignored.
#' 
#' If the \code{checkFixationOK} funciton is present in a stimulus, then it is called after each
#' presentation, and the result is ``anded'' with each stimulus in a trial to get a TRUE/FALSE
#' for fixating on all stimuli in a trial.
#' @return Returns a data.frame with one row per stimulus copied from params with extra columns
#' that are location number in the first column, and the return values from \code{opiPresent()}
#' and a record of fixation (if \code{checkFixationOK} present in stim objects returned from
#' \code{makeStim}: see example). These last values will differ depending on which
#' machine/simulation you are running (as chosen with \code{chooseOpi()}.
#' \itemize{
#'   \item{column 1: x}
#'   \item{column 2: y}
#'   \item{column 3: location number}
#'   \item{column 4: correct stimulus index}
#'   \item{column 5: TRUE/FALSE was fixating for all presentations in this trial according to
#'     \code{checkFixationOK}}
#'   \item{column 6...: columns from params}
#'   \item{...: columns from opiPresent return}
#' }
#' @references
#' A. Turpin, P.H. Artes and A.M. McKendrick. "The Open Perimetry Interface: An enabling tool for
#' clinical visual psychophysics", Journal of Vision 12(11) 2012.
#' @seealso \code{\link{dbTocd}}, \code{\link{opiPresent}}
#' @examples
#' # For the Octopus 900
#' # Check if pupil centre is within 10 pixels of (160,140)
#' checkFixationOK <- function(ret) return(sqrt((ret$pupilX - 160)^2 + (ret$pupilY - 140)^2) < 10)
#'
#' # Return a list of opi stim objects (list of class opiStaticStimulus) for each level (dB) in
#' # p[5:length(p)]. Each stim has responseWindow BETWEEN_FLASH_TIME, except the last which has
#' # rwin. This one assumes p is on old Octopus 900 dB scale (0dB == 4000 cd/m^2).
#' makeStim <- function(p, rwin) {
#'   BETWEEN_FLASH_TIME <- 750   # ms
#'   res <- NULL
#'   for(i in 5:length(p)) {
#'     s <- list(x=p[1], y=p[2], level=dbTocd(p[i],4000/pi), size=0.43, duration=200,
#'               responseWindow=ifelse(i < length(p), BETWEEN_FLASH_TIME, rwin),
#'               checkFixationOK=NULL)
#'     class(s) <- "opiStaticStimulus"
#'     res <- c(res, list(s))
#'   }
#'   return(res)
#' }
#' 
#' ################################################################
#' # Read in a key press 'z' is correct==1, 'm' otherwise
#' #    correct is either 1 or 2, whichever is the correct interval
#' #   
#' # Return list(seen={TRUE|FALSE}, time=time, err=NULL))
#' #        seen is TRUE if correct key pressed
#' ################################################################
#' \dontrun{
#'   if (length(dir(".", "getKeyPress.py")) < 1)
#'     stop('Python script getKeyPress.py missing?')
#' }
#' 
#' keyHandler <- function(correct, ret) { 
#'   return(list(seen=TRUE, time=0, err=NULL))
#'   ONE <- "b'z'"
#'   TWO <- "b'm'"
#'   time <- Sys.time()
#'   key <- 'q'
#'   while (key != ONE && key != TWO) {
#'     a <- system('python getKeyPress.py', intern=TRUE)
#'     key <- a # substr(a, nchar(a), nchar(a))
#'     print(paste('Key pressed: ',key,'from',a))
#'     if (key == "b'8'")
#'       stop('Key 8 pressed')
#'   }
#'   time <- Sys.time() - time
#'   if ((key == ONE && correct == 1) || (key == TWO && correct == 2))
#'     return(list(seen=TRUE, time=time, err=NULL))
#'   else
#'     return(list(seen=FALSE, time=time, err=NULL))
#' }
#'
#' ################################################################
#' # Read in return value from opipresent with F310 controller.
#' # First param is correct, next is 1 for left button, 2 for right button
#' # Left button (LB) is correct for interval 1, RB for interval 2
#' #    correct is either 1 or 2, whichever is the correct interval
#' #   
#' # Return list(seen={TRUE|FALSE}, time=time, err=NULL))
#' #        seen is TRUE if correct key pressed
#' ################################################################
#' F310Handler <- function(correct, opiResult) {
#'   z <- opiResult$seen == correct
#'   opiResult$seen <- z
#'   return(opiResult)
#' }
#'
#' ################################################################
#' # 2 example beep_function
#' ################################################################
#' \dontrun{
#'   require(beepr)
#'   myBeep <- function(type='None') {
#'     if (type == 'correct') {
#'       beepr::beep(2)  # coin noise
#'       Sys.sleep(0.5)
#'     }
#'     if (type == 'incorrect') {
#'       beepr::beep(1) # system("rundll32 user32.dll,MessageBeep -1") # system beep
#'       #Sys.sleep(0.0)
#'     }
#'   }
#'   require(audio)
#'   myBeep <- function(type="None") {
#'     if (type == 'correct') {
#'       wait(audio::play(sin(1:10000/10)))
#'     }
#'     if (type == 'incorrect') {
#'       wait(audio::play(sin(1:10000/20)))
#'     }
#'   }
#' }
#'
#' ################################################################
#' # An example stim_print function
#' ################################################################
#' \dontrun{
#'   stim_print <- function(s, ret) {
#'     sprintf("%4.1f %2.0f",cdTodb(s$level,10000/pi), ret$seen)
#'   }
#' }
#' @export
MOCS <- function(params=NA, 
                 order="random",
                 responseWindowMeth="constant", 
                 responseFloor=1500, 
                 responseHistory=5, 
                 keyHandler=function(correct,ret) return(list(TRUE, 0, NULL)),
                 interStimMin=200,
                 interStimMax=500,
                 beep_function,
                 makeStim,
                 stim_print, ...) {

        ################################################
        # expand the params matrix to every presentation
        # and order of rows in the matrix appropriately
        ################################################
    mocs <- NULL
    if (order == "random") {
        for(i in 1:nrow(params)) {
            reps <- params[i,4]
            mocs <- rbind(mocs, matrix(params[i,], ncol=ncol(params), nrow=reps, byrow=T))
        }
        mocs <- mocs[order(stats::runif(nrow(mocs))), ]
    } else if (order == "fixed") {
        mocs <- params
    } else {
        stop(paste("Invalid order in MOCS: ", order))
    }
    mocs <- rbind(mocs, rep(0, ncol(mocs)))  # add dummy for final nextStim

        ####################################################
        # Set up response window time data structures
        ####################################################
    if (responseWindowMeth == "speed") {
        respTimeHistory <- rep(responseFloor, responseHistory)
    } else if (!is.element(responseWindowMeth, c("constant", "forceKey"))) {
        stop(paste("Invalid responseWindowMeth in MOCS: ", responseWindowMeth))
    }
        ####################################################
        # loop through every presentation except last (is dummy)
        ####################################################
    error_count <- 0
    results <- NULL
    nextStims <- makeStim(as.double(mocs[1,]), responseFloor)
    for(i in 1:(nrow(mocs)-1)) {
        if (responseWindowMeth == "constant") {
            rwin <- responseFloor
        } else if (responseWindowMeth == "forceKey") {
            rwin <- 0
        } else {
            rwin <- max(responseFloor, mean(respTimeHistory))
        } 
        stims     <- nextStims
        nextStims <- makeStim(as.double(mocs[i+1,]), rwin)

        cat(sprintf('Trial,%g,Location,%g',i, mocs[i,3]))
        all_fixations_good <- TRUE
        for (stimNum in 1:length(stims)) {
            beep_function(stimNum)
            s <- stims[[stimNum]]
            if (stimNum == length(stims)) {
              ret <- opiPresent(stim=s, nextStim=nextStims[[stimNum]], ...)

              fixation_good <- TRUE
              if (!is.null(s$checkFixationOK))
                fixation_good <- s$checkFixationOK(ret)
              all_fixations_good <- all_fixations_good && fixation_good
            
              cat(sprintf(",%f,%f,%f,",s$x,s$y, fixation_good))
              cat(stim_print(s,ret))
            } else {
              startTime <- Sys.time()

              ret <- opiPresent(stim=s, nextStim=NULL, ...)

              fixation_good <- TRUE
              if (!is.null(s$checkFixationOK))
                fixation_good <- s$checkFixationOK(ret)
              all_fixations_good <- all_fixations_good && fixation_good
            
              cat(sprintf(",%f,%f,%f,",s$x,s$y, fixation_good))
              cat(stim_print(s,ret))

                # just check that the reponse window wasn't scuppered by a response
              while (Sys.time() - startTime < s$responseWindow/1000)
                Sys.sleep(0.05)
            }
        }

        if (responseWindowMeth == "forceKey")
          ret <- keyHandler(mocs[i, 6], ret)
 
        if (is.null(ret$err)) {
            if (ret$seen) 
                beep_function('correct')
            else 
                beep_function('incorrect')
        
            if (ret$seen && responseWindowMeth == "speed") 
                respTimeHistory <- c(utils::tail(respTimeHistory, -1), ret$time)
        } else {
            warning("Opi Present return error in MOCS")
            error_count <- error_count + 1 
        }

        cat(sprintf(',%g,%g\n',ret$seen,  ret$time))
        
        Sys.sleep(stats::runif(1, min=interStimMin, max=interStimMax)/1000)

        results <- rbind(results, c(mocs[i,1:5], all_fixations_good, mocs[i,6:ncol(mocs)], ret))
    }
    
    if (error_count > 0)
        warning(paste("There were", error_count, "Opi Present return errors in MOCS"))
    
    return(results)
}#MOCS()

###################################
# tests
###################################
###t0 <- matrix(c(
###    9,9, 3, 1, 3145  , 
###    6,6, 4, 1,  313  , 
###    3,3, 5, 1,   31.4
###), ncol=5, byrow=TRUE)
###
###t1 <- matrix(c(
###    9,9, 3, 1, 3145  , 314,
###    6,6, 4, 2,  313  , 314,
###    3,3, 5, 2,   31.4, 314
###), ncol=6, byrow=TRUE)
###
###a1 <- list(sin(1:10000/20), sin(1:10000/20), sin(1:10000/10), sin(1:10000/30))
###
###BETWEEN_FLASH_TIME <- 500   # ms
###
###makeStim <- function(p, rwin) {
###    res <- NULL
###    for(i in 5:length(p)) {
###
###        s <- list(x=p[1], y=p[2], level=p[5], size=0.43, duration=200,
###                  responseWindow=ifelse(i < length(p), 0, BETWEEN_FLASH_TIME),
###                  checkFixationOK=NULL
###             )
###        class(s) <- "opiStaticStimulus"
###        res <- c(res, list(s))
###    }
###    return(res)
###}
###
#### correct is either 1 or 2, whichever is the correct interval
###keyHandler <- function(correct) {
###    time <- Sys.time()
###    key <- 'q'
###    while (key != 'z' && key != 'm') {
###        a <- system('python getKeyPress.py', intern=TRUE)
###        key <- substr(a, nchar(a), nchar(a))
###    }
###    time <- Sys.time() - time
###    #print(paste('Key pressed: ',key))
###
###    if ((key == 'z' && correct == 1) || (key == 'm' && correct == 2))
###        return(list(seen=TRUE, time=time, err=NULL))
###    else
###        return(list(seen=FALSE, time=time, err=NULL))
###}
###
###require(OPI)
####chooseOpi("SimNo")
###chooseOpi("SimHenson")
###opiInitialise()
####r <- MOCS(params=t0, interStimMin=0, interStimMax=0, makeStim=makeStim, tt=10, fpr=0.0, fnr=0) 
####r <- MOCS(params=t1, interStimMin=0, interStimMax=0, makeStim=makeStim, tt=10, fpr=0, fnr=0) 
####r <- MOCS(params=t1, audio=a1, responseWindowMeth="forceKey", keyHandler=keyHandler, interStimMin=0, interStimMax=0, makeStim=makeStim, tt=10, fpr=0, fnr=0) 
###
####print(r)
###
###opiClose()