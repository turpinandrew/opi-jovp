# Open Perimetry Interface implementation for Compass
#
# Copyright [2022] [Andrew Turpin & Ivan Marin-Franch]
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

require(rjson)

    # environment for this machine in R
if (exists(".opi_env") && !exists("Compass", where = .opi_env))
    assign("Compass", new.env(), envir = .opi_env)

#' Implementation of opiInitialise for the Compass machine.
#'
#' This is for internal use only. Use [opiInitialise()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param port TCP port of the OPI Monitor.
#' @param ip IP Address of the OPI Monitor.
#'
#' @return a list contianing:
#'  * res List with all of the other fields described in @ReturnMsg except 'error'.
#'    - res$msg The success or error message.
#'    - res$error Error code '0' if all good, something else otherwise.
#'
#' @details 
#' `port` can take on values in the range [0.0, 65535.0].
#'
#' @examples
#' chooseOpi("Compass")
#' result <- opiInitialise(port = 50001, ip = "localhost")
#'
#' @seealso [opiInitialise()]
#'
opiInitialise_for_Compass <- function(port = NULL, ip = NULL) {
    if (!exists("socket", where = .opi_env$Compass))
        assign("socket", open_socket(ip, port), .opi_env$Compass)
    else
        return(list(error = 4, msg = "Socket connection to Monitor already exists. Perhaps not closed properly last time? Restart Monitor and R."))

    msg <- list(port = port, ip = ip)
    msg <- c(list(command = "initialize"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$Compass$socket)

    res <- readLines(.opi_env$Compass$socket, n = 1)
    if (length(res) == 0)
        return(list(error = 5, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- rjson::fromJSON(res)
    return(res)
}

#' Implementation of opiQueryDevice for the Compass machine.
#'
#' This is for internal use only. Use [opiQueryDevice()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#'
#'
#' @return a list contianing:
#'  * res List with all of the other fields described in @ReturnMsg except 'error'.
#'    - res$msg The error message or a structure with the following data.
#'    - res$error '0' if success, something else if error.
#'
#'
#'
#' @examples
#' chooseOpi("Compass")
#' result <- opiQueryDevice()
#'
#' @seealso [opiQueryDevice()]
#'
opiQueryDevice_for_Compass <- function() {
if(!exists(".opi_env") || !exists("Compass", envir = .opi_env) || !("socket" %in% names(.opi_env$Compass)) || is.null(.opi_env$Compass$socket))
    stop("Cannot call opiQueryDevice without an open socket to Monitor. Did you call opiInitialise()?.")

    msg <- list()
    msg <- c(list(command = "query"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$Compass$socket)

    res <- readLines(.opi_env$Compass$socket, n = 1)
    if (length(res) == 0)
        return(list(error = 5, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- rjson::fromJSON(res)
    return(res)
}

#' Implementation of opiSetup for the Compass machine.
#'
#' This is for internal use only. Use [opiSetup()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param fixShape Fixation target type for eye.
#' @param fixCx x-coordinate of fixation target (degrees): Only valid values are
#'              -20, -6, -3, 0, 3, 6, 20 for fixation type 'spot' and -3, 0, 3
#'              for fixation type 'square'.
#' @param tracking Whether to correct stimulus location based on eye position.
#'
#' @return a list contianing:
#'  * res List with all of the other fields described in @ReturnMsg except 'error'.
#'    - res$msg The error message or a structure with the result of QUERY OPI command.
#'    - res$error '0' if success, something else if error.
#'
#' @details 
#' `fixShape` can take on values in the set {spot, square}.
#' `fixCx` can take on values in the range [-20.0, 20.0].
#' `tracking` can take on values in the range [0.0, 1.0].
#'
#' @examples
#' chooseOpi("Compass")
#' result <- opiSetup(settings = list(fixShape = "spot", fixCx = 0, tracking = 0))
#'
#' @seealso [opiSetup()]
#'
opiSetup_for_Compass <- function(settings = list(fixShape = NULL, fixCx = NULL, tracking = NULL)) {
if(!exists(".opi_env") || !exists("Compass", envir = .opi_env) || !("socket" %in% names(.opi_env$Compass)) || is.null(.opi_env$Compass$socket))
    stop("Cannot call opiSetup without an open socket to Monitor. Did you call opiInitialise()?.")

    msg <- list(fixShape = settings$fixShape, fixCx = settings$fixCx, tracking = settings$tracking)
    msg <- c(list(command = "setup"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$Compass$socket)

    res <- readLines(.opi_env$Compass$socket, n = 1)
    if (length(res) == 0)
        return(list(error = 5, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- rjson::fromJSON(res)
    return(res)
}

#' Implementation of opiPresent for the Compass machine.
#'
#' This is for internal use only. Use [opiPresent()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param t Presentation time (ms).
#' @param lum Stimuli luminance (cd/m^2).
#' @param w Response window (ms).
#' @param x x co-ordinates of stimulus (degrees).
#' @param y y co-ordinates of stimulus (degrees).
#'
#' @return a list contianing:
#'  * res JSON Object with all of the other fields described in @ReturnMsg except 'error'.
#'    - res$eyet Time of (eyex, eyey) pupil from stimulus onset (ms).
#'    - res$eyex x co-ordinates of pupil at times eyet (pixels).
#'    - res$eyey y co-ordinates of pupil at times eyet (pixels).
#'    - res$num_track_events Number of tracking events that occurred during presentation.
#'    - res$msg$time Response time from stimulus onset if button pressed (ms).
#'    - res$eyed Diameter of pupil at times eyet (mm).
#'    - res$time_resp Time since 'epoch' when stimulus response is received, or
#'                    response window expired (ms).
#'    - res$msg Error message or a structure with the following fields.
#'    - res$error '0' if success, something else if error.
#'    - res$msg$seen '1' if seen, '0' if not.
#'    - res$num_motor_fails Number of times motor could not follow fixation movement during presentation.
#'    - res$time_rec Time since 'epoch' when command was received at Compass or Maia (ms).
#'
#' @details 
#' `t` can take on values in the range [200.0, 200.0].
#' `lum` can take on values in the range [0.0, 3183.099].
#' `w` can take on values in the range [200.0, 2680.0].
#' `x` can take on values in the range [-30.0, 30.0].
#' `y` can take on values in the range [-30.0, 30.0].
#'
#' @examples
#' chooseOpi("Compass")
#' result <- opiPresent(stim = list(t = 200, lum = 100, w = 1500, x = 0, y = 0))
#'
#' @seealso [opiPresent()]
#'
opiPresent_for_Compass <- function(stim = list(t = NULL, lum = NULL, w = NULL, x = NULL, y = NULL)) {
if(!exists(".opi_env") || !exists("Compass", envir = .opi_env) || !("socket" %in% names(.opi_env$Compass)) || is.null(.opi_env$Compass$socket))
    stop("Cannot call opiPresent without an open socket to Monitor. Did you call opiInitialise()?.")

    msg <- list(t = stim$t, lum = stim$lum, w = stim$w, x = stim$x, y = stim$y)
    msg <- c(list(command = "present"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$Compass$socket)

    res <- readLines(.opi_env$Compass$socket, n = 1)
    if (length(res) == 0)
        return(list(error = 5, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- rjson::fromJSON(res)
    return(res)
}

#' Implementation of opiClose for the Compass machine.
#'
#' This is for internal use only. Use [opiClose()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#'
#'
#' @return a list contianing:
#'  * res List with all of the other fields described in @ReturnMsg except 'error'.
#'    - res$msg The error message or additional results from the CLOSE command
#'    - res$error '0' if success, something else if error.
#'    - res$time The time stamp for fixation data
#'    - res$x The time stamp for fixation data
#'    - res$y The time stamp for fixation data
#'
#'
#'
#' @examples
#' chooseOpi("Compass")
#' result <- opiClose()
#'
#' @seealso [opiClose()]
#'
opiClose_for_Compass <- function() {
if(!exists(".opi_env") || !exists("Compass", envir = .opi_env) || !("socket" %in% names(.opi_env$Compass)) || is.null(.opi_env$Compass$socket))
    stop("Cannot call opiClose without an open socket to Monitor. Did you call opiInitialise()?.")

    msg <- list()
    msg <- c(list(command = "close"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$Compass$socket)

    res <- readLines(.opi_env$Compass$socket, n = 1)
    if (length(res) == 0)
        return(list(error = 5, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- rjson::fromJSON(res)
    return(res)
}


#' Set background color and luminance in both eyes.
#' Deprecated for OPI >= v3.0.0 and replaced with [opiSetup()].
#' @usage NULL
#' @seealso [opiSetup()]
opiSetBackground_for_Compass <- function(lum, color, ...) {return("Deprecated")}


