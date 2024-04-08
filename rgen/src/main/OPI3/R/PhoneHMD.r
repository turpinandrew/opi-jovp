# This file is AUTOMATICALLY GENERATED from the rgen package.
# DO NOT MANUALLY ALTER.
#
# Open Perimetry Interface implementation for PhoneHMD
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

require(jsonlite)

    # environment for this machine in R
if (exists(".opi_env") && !exists("PhoneHMD", where = .opi_env))
    assign("PhoneHMD", new.env(), envir = .opi_env)

#' Implementation of opiInitialise for the PhoneHMD machine.
#'
#' This is for internal use only. Use [opiInitialise()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param \code{address} A list containing:
#'  * \code{port} TCP port of the OPI Monitor.
#'  * \code{ip} IP Address of the OPI Monitor.
#'
#' @return A list containing:
#'  * \code{error} \code{TRUE} if there was an error, \code{FALSE} if not.
#'  * \code{msg} If \code{error} is \code{TRUE}, then this is a string describing the error.
#'                If \code{error} is \code{FALSE}, this is an empty list.
#'

#'
#' @details
#'
#' \code{port} can take on values in the range \code{[0, 65535]}.
#'
#' @examples
#' chooseOpi("PhoneHMD")
#' result <- opiInitialise(address = list(port = 50001, ip = "localhost"))
#'
#' @seealso [opiInitialise()]
#'
opiInitialise_for_PhoneHMD <- function(address) {
    if (!exists("socket", where = .opi_env$PhoneHMD))
        assign("socket", open_socket(address$ip, address$port), .opi_env$PhoneHMD)
    else
        return(list(error = 4, msg = "Socket connection to Monitor already exists. Perhaps not closed properly last time? Restart Monitor and R."))

    if (is.null(.opi_env$PhoneHMD$socket))
        return(list(error = 2, msg = sprintf("Cannot Cannot find a server at %s on port %s", address$ip, address$port)))

    if (is.null(address)) return(list(error = 0 , msg = "Nothing to do in opiInitialise."))

    msg <- list(port = address$port, ip = address$ip)
    msg <- c(list(command = "initialize"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- jsonlite::toJSON(msg, auto_unbox = TRUE)
    writeLines(msg, .opi_env$PhoneHMD$socket)

    res <- readLines(.opi_env$PhoneHMD$socket, n = 1)
    if (length(res) == 0)
        return(list(error = TRUE, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- jsonlite::parse_json(res)
    return(res)
}

#' Implementation of opiQueryDevice for the PhoneHMD machine.
#'
#' This is for internal use only. Use [opiQueryDevice()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param \code{} A list containing:

#'
#' @return A list containing:
#'  * \code{error} \code{TRUE} if there was an error, \code{FALSE} if not.
#'  * \code{msg} If \code{error} is \code{TRUE}, then this is a string describing the error.
#'                If \code{error} is \code{FALSE}, this is an empty list.
#'

#'
#'
#'
#' @examples
#' chooseOpi("PhoneHMD")
#' result <- opiQueryDevice()
#'
#' @seealso [opiQueryDevice()]
#'
opiQueryDevice_for_PhoneHMD <- function() {
    if(!exists(".opi_env") || !exists("PhoneHMD", envir = .opi_env) || !("socket" %in% names(.opi_env$PhoneHMD)) || is.null(.opi_env$PhoneHMD$socket))
        return(list(error = 3, msg = "Cannot call opiQueryDevice without an open socket to Monitor. Did you call opiInitialise()?."))

    
    msg <- list()
    msg <- c(list(command = "query"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- jsonlite::toJSON(msg, auto_unbox = TRUE)
    writeLines(msg, .opi_env$PhoneHMD$socket)

    res <- readLines(.opi_env$PhoneHMD$socket, n = 1)
    if (length(res) == 0)
        return(list(error = TRUE, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- jsonlite::parse_json(res)
    return(res)
}

#' Implementation of opiSetup for the PhoneHMD machine.
#'
#' This is for internal use only. Use [opiSetup()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param \code{settings} A list containing:
#'  * \code{eye} The eye for which to apply the settings.#'  * \code{bgImageFilename} If present, display the image in the background for eye (Optional)
#'  * \code{fixShape} Fixation target type for eye. (Optional)
#'  * \code{fixLum} Fixation target luminance for eye. (Optional)
#'  * \code{fixType} Fixation target texture for eye. (Optional)
#'  * \code{fixCx} x-coordinate of fixation target (degrees). (Optional)
#'  * \code{fixCy} y-coordinate of fixation target (degrees). (Optional)
#'  * \code{fixCol} Fixation target color for eye. (Optional)
#'  * \code{bgLum} Background luminance for eye (cd/m^2). (Optional)
#'  * \code{tracking} Whether to correct stimulus location based on eye position. (Optional)
#'  * \code{bgCol} Background color for eye (rgb). (Optional)
#'  * \code{fixSx} diameter along major axis of ellipse (degrees). 0 to hide
#'                 fixation marker. (Optional)
#'  * \code{fixSy} diameter along minor axis of ellipse (degrees). If not
#'                 received, then sy = sx. (Optional)
#'  * \code{fixRotation} Angles of rotation of fixation target (degrees). Only
#'                       useful if sx != sy specified. (Optional)
#'  * \code{fixImageFilename} If fixType == IMAGE, the filename on the local
#'                            filesystem of the machine running JOVP of the image to use (Optional)
#'
#' @return A list containing:
#'  * \code{error} \code{TRUE} if there was an error, \code{FALSE} if not.
#'  * \code{msg} If \code{error} is \code{TRUE}, then this is a string describing the error.
#'                If \code{error} is \code{FALSE}, this is an empty list.
#'

#'
#' @details
#'
#' \code{fixShape} can take on values in the set \code{{"triangle",
#'           "square", "polygon", "hollow_triangle", "hollow_square",
#'           "hollow_polygon", "cross", "maltese", "circle", "annulus",
#'           "optotype", "text", "model"}}.
#'
#' \code{fixLum} can take on values in the range \code{[0.0, 1.0E10]}.
#'
#' \code{fixType} can take on values in the set \code{{"flat",
#'          "checkerboard", "sine", "squaresine", "g1", "g2", "g3", "text", "image"}}.
#'
#' \code{fixCx} can take on values in the range \code{[-90.0, 90.0]}.
#'
#' \code{fixCy} can take on values in the range \code{[-90.0, 90.0]}.
#'
#' Elements in \code{fixCol} can take on values in the range \code{[0.0, 1.0]}.
#'
#' \code{bgLum} can take on values in the range \code{[0.0, 1.0E10]}.
#'
#' \code{tracking} can take on values in the range \code{[0, 1]}.
#'
#' Elements in \code{bgCol} can take on values in the range \code{[0.0, 1.0]}.
#'
#' \code{eye} can take on values in the set \code{{"left", "right",
#'      "both", "none"}}.
#'
#' \code{fixSx} can take on values in the range \code{[0.0, 1.0E10]}.
#'
#' \code{fixSy} can take on values in the range \code{[0.0, 1.0E10]}.
#'
#' \code{fixRotation} can take on values in the range \code{[0.0, 360.0]}.
#'
#' @examples
#' chooseOpi("PhoneHMD")
#' result <- opiSetup(settings = list(eye = "BOTH"))
#'
#' @seealso [opiSetup()]
#'
opiSetup_for_PhoneHMD <- function(settings) {
    if(!exists(".opi_env") || !exists("PhoneHMD", envir = .opi_env) || !("socket" %in% names(.opi_env$PhoneHMD)) || is.null(.opi_env$PhoneHMD$socket))
        return(list(error = 3, msg = "Cannot call opiSetup without an open socket to Monitor. Did you call opiInitialise()?."))

    if (is.null(settings)) return(list(error = 0 , msg = "Nothing to do in opiSetup."))

    msg <- list(bgImageFilename = settings$bgImageFilename, fixShape = settings$fixShape, fixLum = settings$fixLum, fixType = settings$fixType, fixCx = settings$fixCx, fixCy = settings$fixCy, fixCol = settings$fixCol, bgLum = settings$bgLum, tracking = settings$tracking, bgCol = settings$bgCol, eye = settings$eye, fixSx = settings$fixSx, fixSy = settings$fixSy, fixRotation = settings$fixRotation, fixImageFilename = settings$fixImageFilename)
    msg <- c(list(command = "setup"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- jsonlite::toJSON(msg, auto_unbox = TRUE)
    writeLines(msg, .opi_env$PhoneHMD$socket)

    res <- readLines(.opi_env$PhoneHMD$socket, n = 1)
    if (length(res) == 0)
        return(list(error = TRUE, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- jsonlite::parse_json(res)
    return(res)
}

#' Implementation of opiPresent for the PhoneHMD machine.
#'
#' This is for internal use only. Use [opiPresent()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param \code{stim} A list containing:
#'  * \code{lum} List of stimuli luminances (cd/m^2).
#'  * \code{stim.length} The number of elements in this stimuli.
#'  * \code{color1} List of stimulus colors for FLAT shapes and patterns.
#'  * \code{sx} List of diameters along major axis of ellipse (degrees).
#'  * \code{sy} List of diameters along minor axis of ellipse (degrees).
#'  * \code{eye} The eye for which to apply the settings.
#'  * \code{t} List of stimuli presentation times (ms).
#'  * \code{w} Time to wait for response including presentation time (ms).
#'  * \code{x} List of x co-ordinates of stimuli (degrees).
#'  * \code{y} List of y co-ordinates of stimuli (degrees).#'  * \code{envSdx} List of envelope sd in x direction in degrees. Only useful
#'                  if envType != NONE (Optional)
#'  * \code{envSdy} List of envelope sd in y direction in degrees. Only useful
#'                  if envType != NONE (Optional)
#'  * \code{envRotation} List of envelope rotations in degrees. Only useful if envType != NONE (Optional)
#'  * \code{type} Stimulus type. Values include FLAT, SINE, CHECKERBOARD,
#'                SQUARESINE, G1, G2, G3, IMAGE (Optional)
#'  * \code{frequency} List of frequencies (in cycles per degrees) for
#'                     generation of spatial patterns. Only useful if type != FLAT (Optional)
#'  * \code{color2} List of second colors for non-FLAT shapes (Optional)
#'  * \code{fullFoV} If !0 fullFoV scales image to full field of view and sx/sy
#'                   are ignored. (Optional)
#'  * \code{phase} List of phases (in degrees) for generation of spatial
#'                 patterns. Only useful if type != FLAT (Optional)
#'  * \code{imageFilename} If type == IMAGE, the filename on the local
#'                         filesystem of the machine running JOVP of the image to use (Optional)
#'  * \code{shape} Stimulus shape. Values include CROSS, TRIANGLE, CIRCLE,
#'                 SQUARE, OPTOTYPE. (Optional)
#'  * \code{rotation} List of angles of rotation of stimuli (degrees). Only
#'                    useful if sx != sy specified. (Optional)
#'  * \code{texRotation} List of angles of rotation of stimuli (degrees). Only
#'                       useful if type != FLAT (Optional)
#'  * \code{defocus} List of defocus values in Diopters for stimulus post-processing. (Optional)
#'  * \code{envType} List of envelope types to apply to the stims). Only useful
#'                   if type != FLAT (Optional)
#'  * \code{contrast} List of stimulus contrasts (from 0 to 1). Only useful if
#'                    type != FLAT. (Optional)
#'  * \code{optotype} If shape == OPTOTYPE, the letter A to Z to use (Optional)
#'
#' @param \code{...} Parameters for other opiPresent implementations that are ignored here.
#'
#' @return A list containing:
#'  * \code{error} \code{TRUE} if there was an error, \code{FALSE} if not.
#'  * \code{msg} If \code{error} is \code{TRUE}, then this is a string describing the error.
#'                If \code{error} is \code{FALSE}, this is a list of:
#'    * \code{time} Response time from stimulus onset if button pressed (ms).
#'    * \code{seen} '1' if seen, '0' if not.

#'
#' @details
#'
#' Elements in \code{envSdx} can take on values in the
#'                    range \code{[-1.0E10, 1.0E10]}.
#'
#' Elements in \code{lum} can take on values in the range \code{[0.0, 1.0E10]}.
#'
#' Elements in \code{envSdy} can take on values in the
#'                    range \code{[-1.0E10, 1.0E10]}.
#'
#' Elements in \code{envRotation} can take on values
#'                         in the range \code{[-1.0E10, 1.0E10]}.
#'
#' Elements in \code{type} can take on values in the set
#'                  \code{{"flat", "checkerboard", "sine", "squaresine", "g1",
#'                  "g2", "g3", "text", "image"}}.
#'
#' \code{stim.length} can take on values in the range \code{[1, 2147483647]}.
#'
#' Elements in \code{frequency} can take on values in
#'                       the range \code{[0.0, 300.0]}.
#'
#' Elements in \code{color1} can take on values in the range \code{[0.0, 1.0]}.
#'
#' Elements in \code{color2} can take on values in the range \code{[0.0, 1.0]}.
#'
#' Elements in \code{fullFoV} can take on values in the
#'                     range \code{[-1.0E10, 1.0E10]}.
#'
#' Elements in \code{phase} can take on values in the range
#'                   \code{[0.0, 1.0E10]}.
#'
#' Elements in \code{shape} can take on values in the set
#'                   \code{{"triangle", "square", "polygon", "hollow_triangle",
#'                   "hollow_square", "hollow_polygon", "cross", "maltese",
#'                   "circle", "annulus", "optotype", "text", "model"}}.
#'
#' Elements in \code{sx} can take on values in the range \code{[0.0, 180.0]}.
#'
#' Elements in \code{sy} can take on values in the range \code{[0.0, 180.0]}.
#'
#' Elements in \code{rotation} can take on values in the
#'                      range \code{[0.0, 360.0]}.
#'
#' Elements in \code{texRotation} can take on values
#'                         in the range \code{[0.0, 360.0]}.
#'
#' Elements in \code{defocus} can take on values in the
#'                     range \code{[0.0, 1.0E10]}.
#'
#' Elements in \code{eye} can take on values in the set
#'                 \code{{"left", "right", "both", "none"}}.
#'
#' Elements in \code{t} can take on values in the range \code{[0.0, 1.0E10]}.
#'
#' Elements in \code{envType} can take on values in the
#'                     set \code{{"none", "square", "circle", "gaussian"}}.
#'
#' \code{w} can take on values in the range \code{[0.0, 1.0E10]}.
#'
#' Elements in \code{contrast} can take on values in the
#'                      range \code{[0.0, 1.0]}.
#'
#' Elements in \code{optotype} can take on values in the
#'                      set \code{{"a", "b", "c", "d", "e", "f", "g", "h", "i",
#'                      "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
#'                      "u", "v", "w", "x", "y", "z"}}.
#'
#' Elements in \code{x} can take on values in the range \code{[-90.0, 90.0]}.
#'
#' Elements in \code{y} can take on values in the range \code{[-90.0, 90.0]}.
#'
#' @examples
#' chooseOpi("PhoneHMD")
#' result <- opiPresent(stim = list(lum = list(300.0), stim.length = 1, color1 = list(list(0.0,
#'                   0.0, 0.0)), sx = list(1.72), sy = list(1.72),
#'                   eye = list("LEFT"), t = list(200.0), w = 1500.0, x = list(0.0), y = list(0.0)))
#'
#' @seealso [opiPresent()]
#'
opiPresent_for_PhoneHMD <- function(stim, ...) {
    if(!exists(".opi_env") || !exists("PhoneHMD", envir = .opi_env) || !("socket" %in% names(.opi_env$PhoneHMD)) || is.null(.opi_env$PhoneHMD$socket))
        return(list(error = 3, msg = "Cannot call opiPresent without an open socket to Monitor. Did you call opiInitialise()?."))

    if (is.null(stim)) return(list(error = 0 , msg = "Nothing to do in opiPresent."))

    msg <- list(envSdx = stim$envSdx, lum = stim$lum, envSdy = stim$envSdy, envRotation = stim$envRotation, type = stim$type, stim.length = stim$stim.length, frequency = stim$frequency, color1 = stim$color1, color2 = stim$color2, fullFoV = stim$fullFoV, phase = stim$phase, imageFilename = stim$imageFilename, shape = stim$shape, sx = stim$sx, sy = stim$sy, rotation = stim$rotation, texRotation = stim$texRotation, defocus = stim$defocus, eye = stim$eye, t = stim$t, envType = stim$envType, w = stim$w, contrast = stim$contrast, optotype = stim$optotype, x = stim$x, y = stim$y)
    msg <- c(list(command = "present"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- jsonlite::toJSON(msg, auto_unbox = TRUE)
    writeLines(msg, .opi_env$PhoneHMD$socket)

    res <- readLines(.opi_env$PhoneHMD$socket, n = 1)
    if (length(res) == 0)
        return(list(error = TRUE, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- jsonlite::parse_json(res)
    return(res)
}

#' Implementation of opiClose for the PhoneHMD machine.
#'
#' This is for internal use only. Use [opiClose()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param \code{} A list containing:

#'
#' @return A list containing:
#'  * \code{error} \code{TRUE} if there was an error, \code{FALSE} if not.
#'  * \code{msg} If \code{error} is \code{TRUE}, then this is a string describing the error.
#'                If \code{error} is \code{FALSE}, this is an empty list.
#'

#'
#'
#'
#' @examples
#' chooseOpi("PhoneHMD")
#' result <- opiClose()
#'
#' @seealso [opiClose()]
#'
opiClose_for_PhoneHMD <- function() {
    if(!exists(".opi_env") || !exists("PhoneHMD", envir = .opi_env) || !("socket" %in% names(.opi_env$PhoneHMD)) || is.null(.opi_env$PhoneHMD$socket))
        return(list(error = 3, msg = "Cannot call opiClose without an open socket to Monitor. Did you call opiInitialise()?."))

    
    msg <- list()
    msg <- c(list(command = "close"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- jsonlite::toJSON(msg, auto_unbox = TRUE)
    writeLines(msg, .opi_env$PhoneHMD$socket)

    res <- readLines(.opi_env$PhoneHMD$socket, n = 1)
    if (length(res) == 0)
        return(list(error = TRUE, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- jsonlite::parse_json(res)
    return(res)
}

