# Open Perimetry Interface implementation for Display
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
if (exists(".opi_env") && !exists("Display", where = .opi_env))
    assign("Display", new.env(), envir = .opi_env)

#' Implementation of opiInitialise for the Display machine.
#'
#' This is for internal use only. Use [opiInitialise()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param ip_Monitor IP Address of the OPI JOVP server.
#' @param port_Monitor TCP port of the OPI JOVP server.
#'
#' @return a list contianing:
#'  * error Empty string for all good, else error messages from Display.
#'  * msg Object with all of the other fields.
#'    - msg$jovp Any messages that the JOVP sent back.
#'
#' @examples
#' chooseOpi("Display")
#' result <- opiInitialise(null)
#'
#' @seealso [opiInitialise()]
#'
opiInitialise_for_Display <- function(ip_Monitor = NULL, port_Monitor = NULL) {
    assign("socket", open_socket(ip_Monitor, port_Monitor), .opi_env$Display)
    msg <- list(ip_Monitor = ip_Monitor, port_Monitor = port_Monitor)
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$Display$socket)

    res <- rjson::fromJSON(readLines(.opi_env$Display$socket, n=1))
    return(res)
}

#' Implementation of opiQueryDevice for the Display machine.
#'
#' This is for internal use only. Use [opiQueryDevice()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#'
#'
#' @return a list contianing:
#'  * error Empty string for all good, else error message.
#'  * msg Object with all of the other fields.
#'    - msg$jovp Any messages that the JOVP sent back.
#'
#' @examples
#' chooseOpi("Display")
#' result <- opiQueryDevice(null)
#'
#' @seealso [opiQueryDevice()]
#'
opiQueryDevice_for_Display <- function() {
if(!exists(".opi_env$Display") || !exists(".opi_env$Display$socket") || is.null(.opi_env$Display$socket))
    stop("Cannot call opiQueryDevice without an open socket to Monitor. Did you call opiInitialise()?.")

    msg <- list()
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$Display$socket)

    res <- rjson::fromJSON(readLines(.opi_env$Display$socket, n=1))
    return(res)
}

#' Implementation of opiSetup for the Display machine.
#'
#' This is for internal use only. Use [opiSetup()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param bgRed Background color for the screen: red channel. (0..255)
#' @param bgGreen Background color for the screen: green channel (0..255).
#' @param bgBlue Background color for the screen: blue channel (0..255).
#'
#' @return a list contianing:
#'  * error Empty string for all good, else error messages from Display.
#'  * msg Object with all of the other fields.
#'    - msg$jovp Any messages that the JOVP sent back.
#'
#' @examples
#' chooseOpi("Display")
#' result <- opiSetup(settings = list(null))
#'
#' @seealso [opiSetup()]
#'
opiSetup_for_Display <- function(settings = list(bgRed = NULL, bgGreen = NULL, bgBlue = NULL)) {
if(!exists(".opi_env$Display") || !exists(".opi_env$Display$socket") || is.null(.opi_env$Display$socket))
    stop("Cannot call opiSetup without an open socket to Monitor. Did you call opiInitialise()?.")

    msg <- list(bgRed = settings$bgRed, bgGreen = settings$bgGreen, bgBlue = settings$bgBlue)
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$Display$socket)

    res <- rjson::fromJSON(readLines(.opi_env$Display$socket, n=1))
    return(res)
}

#' Implementation of opiPresent for the Display machine.
#'
#' This is for internal use only. Use [opiPresent()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param x List of x co-ordinates of stimuli (degrees).
#' @param y List of y co-ordinates of stimuli (degrees).
#' @param t List of stimuli presentation times (ms).
#' @param w List of stimuli response windows (ms).
#' @param size Stimulus size (degrees).
#' @param colorRed List of stimuli colors: red channel (0..1).
#' @param colorGreen List of stimuli colors: green channel (0..1).
#' @param colorBlue List of stimuli colors: blue channel (0..1).
#' @param lum List of luminances (cd/m^2).
#'
#' @return a list contianing:
#'  * error Empty string for all good, else error messages from Display.
#'  * msg Object with all of the other fields.
#'    - msg$seen true if seen, false if not.
#'    - msg$time Response time from stimulus onset if button pressed, -1
#'                  otherwise (ms).
#'    - msg$jovp Any JOVP-specific messages that the JOVP sent back.
#'
#' @examples
#' chooseOpi("Display")
#' result <- opiPresent(stim = list(null))
#'
#' @seealso [opiPresent()]
#'
opiPresent_for_Display <- function(stim = list(x = NULL, y = NULL, t = NULL, w = NULL, size = NULL, colorRed = NULL, colorGreen = NULL, colorBlue = NULL, lum = NULL)) {
if(!exists(".opi_env$Display") || !exists(".opi_env$Display$socket") || is.null(.opi_env$Display$socket))
    stop("Cannot call opiPresent without an open socket to Monitor. Did you call opiInitialise()?.")

    msg <- list(x = stim$x, y = stim$y, t = stim$t, w = stim$w, size = stim$size, colorRed = stim$colorRed, colorGreen = stim$colorGreen, colorBlue = stim$colorBlue, lum = stim$lum)
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$Display$socket)

    res <- rjson::fromJSON(readLines(.opi_env$Display$socket, n=1))
    return(res)
}

#' Implementation of opiClose for the Display machine.
#'
#' This is for internal use only. Use [opiClose()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#'
#'
#' @return a list contianing:
#'  * error Empty string for all good, else error messages from Display.
#'  * msg Object with all other fields.
#'    - msg$jovp Any messages that the JOVP sent back.
#'
#' @examples
#' chooseOpi("Display")
#' result <- opiClose(null)
#'
#' @seealso [opiClose()]
#'
opiClose_for_Display <- function() {
if(!exists(".opi_env$Display") || !exists(".opi_env$Display$socket") || is.null(.opi_env$Display$socket))
    stop("Cannot call opiClose without an open socket to Monitor. Did you call opiInitialise()?.")

    msg <- list()
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$Display$socket)

    res <- rjson::fromJSON(readLines(.opi_env$Display$socket, n=1))
    return(res)
}


#' Set background color and luminance in both eyes.
#' Deprecated for OPI >= v3.0.0 and replaced with [opiSetup()].
#' @usage NULL
#' @seealso [opiSetup()]
opiSetBackground_for_Display <- function(lum, color, ...) {return("Deprecated")}

