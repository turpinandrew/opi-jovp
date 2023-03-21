# This file is AUTOMATICALLY GENERATED from the rgen package.
# DO NOT MANAULLY ALTER.
#
# Open Perimetry Interface implementation for ImoVifa
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
if (exists(".opi_env") && !exists("ImoVifa", where = .opi_env))
    assign("ImoVifa", new.env(), envir = .opi_env)

#' Implementation of opiInitialise for the ImoVifa machine.
#'
#' This is for internal use only. Use [opiInitialise()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param port TCP port of the OPI Monitor.
#' @param ip IP Address of the OPI Monitor.
#'
#' @return a list containing:
#'  * res List with all of the other fields described in @ReturnMsg except 'error'.
#'    - res$msg The success or error message.
#'    - res$error Error code '0' if all good, something else otherwise.
#'
#' @details 
#' `port` can take on values in the range \code{[0, 65535]}.
#'
#' @examples
#' chooseOpi("ImoVifa")
#' result <- opiInitialise(address = list(port = 50001, ip = "localhost"))
#'
#' @seealso [opiInitialise()]
#'
opiInitialise_for_ImoVifa <- function(address) {
    if (!exists("socket", where = .opi_env$ImoVifa))
        assign("socket", open_socket(address$ip, address$port), .opi_env$ImoVifa)
    else
        return(list(error = 4, msg = "Socket connection to Monitor already exists. Perhaps not closed properly last time? Restart Monitor and R."))

    if (is.null(.opi_env$ImoVifa$socket))
        return(list(error = 2, msg = sprintf("Cannot Cannot find a server at %s on port %s", address$ip, address$port)))

    if (is.null(address)) return(list(error = 0 , msg = "Nothing to do in opiInitialise."))

    msg <- list(port = address$port, ip = address$ip)
    msg <- c(list(command = "initialize"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$ImoVifa$socket)

    res <- readLines(.opi_env$ImoVifa$socket, n = 1)
    if (length(res) == 0)
        return(list(error = 5, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- rjson::fromJSON(res)
    return(res)
}

#' Implementation of opiQueryDevice for the ImoVifa machine.
#'
#' This is for internal use only. Use [opiQueryDevice()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#'
#'
#' @return a list containing:
#'  * res List with all of the other fields described in @ReturnMsg except 'error'.
#'    - res$msg The error message or a structure with the following data.
#'    - res$error '0' if success, something else if error.
#'
#'
#'
#' @examples
#' chooseOpi("ImoVifa")
#' result <- opiQueryDevice()
#'
#' @seealso [opiQueryDevice()]
#'
opiQueryDevice_for_ImoVifa <- function() {
    if(!exists(".opi_env") || !exists("ImoVifa", envir = .opi_env) || !("socket" %in% names(.opi_env$ImoVifa)) || is.null(.opi_env$ImoVifa$socket))
        return(list(error = 3, msg = "Cannot call opiQueryDevice without an open socket to Monitor. Did you call opiInitialise()?."))

    
    msg <- list()
    msg <- c(list(command = "query"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$ImoVifa$socket)

    res <- readLines(.opi_env$ImoVifa$socket, n = 1)
    if (length(res) == 0)
        return(list(error = 5, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- rjson::fromJSON(res)
    return(res)
}

#' Implementation of opiSetup for the ImoVifa machine.
#'
#' This is for internal use only. Use [opiSetup()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param eye The eye for which to apply the settings.
#' @param fixShape Fixation target type for eye.
#' @param fixLum Fixation target luminance for eye.
#' @param fixCx x-coordinate of fixation target (degrees).
#' @param fixSx diameter along major axis of ellipse (degrees).
#' @param fixCy y-coordinate of fixation target (degrees).
#' @param fixSy diameter along minor axis of ellipse (degrees). If not received,
#'              then sy = sx. (Optional)
#' @param fixRotation Angles of rotation of fixation target (degrees). Only
#'                    useful if sx != sy specified. (Optional)
#' @param fixCol Fixation target color for eye.
#' @param bgLum Background luminance for eye (cd/m^2).
#' @param tracking Whether to correct stimulus location based on eye position. (Optional)
#' @param bgCol Background color for eye (rgb).
#'
#' @return a list containing:
#'  * res List with all of the other fields described in @ReturnMsg except 'error'.
#'    - res$msg The error message or a structure with the result of QUERY OPI command.
#'    - res$error '0' if success, something else if error.
#'
#' @details 
#' `eye` can take on values in the set {left, right, both}.
#' `fixShape` can take on values in the set {triangle, square,
#'           polygon, hollow_triangle, hollow_square, hollow_polygon, cross,
#'           maltese, circle, annulus, optotype, text, model}.
#' `fixLum` can take on values in the range \code{[0.0, 1.0E10]}.
#' `fixCx` can take on values in the range \code{[-90.0, 90.0]}.
#' `fixSx` can take on values in the range \code{[0.0, 1.0E10]}.
#' `fixCy` can take on values in the range \code{[-90.0, 90.0]}.
#' `fixSy` can take on values in the range \code{[0.0, 1.0E10]}.
#' `fixRotation` can take on values in the range \code{[0.0, 360.0]}.
#' Elements in `fixCol` can take on values in the range \code{[0.0, 1.0]}.
#' `bgLum` can take on values in the range \code{[0.0, 1.0E10]}.
#' `tracking` can take on values in the range \code{[0, 1]}.
#' Elements in `bgCol` can take on values in the range \code{[0.0, 1.0]}.
#'
#' @examples
#' chooseOpi("ImoVifa")
#' result <- opiSetup(settings = list(eye = "BOTH", fixShape = "MALTESE", fixLum = 20.0, fixCx = 0.0,
#'                 fixSx = 1.0, fixCy = 0.0, fixCol = list(0.0, 1.0, 0.0),
#'                 bgLum = 10.0, bgCol = list(1.0, 1.0, 1.0)))
#'
#' @seealso [opiSetup()]
#'
opiSetup_for_ImoVifa <- function(settings) {
    if(!exists(".opi_env") || !exists("ImoVifa", envir = .opi_env) || !("socket" %in% names(.opi_env$ImoVifa)) || is.null(.opi_env$ImoVifa$socket))
        return(list(error = 3, msg = "Cannot call opiSetup without an open socket to Monitor. Did you call opiInitialise()?."))

    if (is.null(settings)) return(list(error = 0 , msg = "Nothing to do in opiSetup."))

    msg <- list(eye = settings$eye, fixShape = settings$fixShape, fixLum = settings$fixLum, fixCx = settings$fixCx, fixSx = settings$fixSx, fixCy = settings$fixCy, fixSy = settings$fixSy, fixRotation = settings$fixRotation, fixCol = settings$fixCol, bgLum = settings$bgLum, tracking = settings$tracking, bgCol = settings$bgCol)
    msg <- c(list(command = "setup"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$ImoVifa$socket)

    res <- readLines(.opi_env$ImoVifa$socket, n = 1)
    if (length(res) == 0)
        return(list(error = 5, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- rjson::fromJSON(res)
    return(res)
}

#' Implementation of opiPresent for the ImoVifa machine.
#'
#' This is for internal use only. Use [opiPresent()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#' @param phase List of phases (in degrees) for generation of spatial patterns.
#'              Only useful if type != FLAT (Optional)
#' @param imageFilename If type == IMAGE, the filename on the local filesystem
#'                      of the machine running JOVP of the image to use (Optional)
#' @param shape Stimulus shape. Values include CROSS, TRIANGLE, CIRCLE, SQUARE,
#'              OPTOTYPE. (Optional)
#' @param sx List of diameters along major axis of ellipse (degrees).
#' @param lum List of stimuli luminances (cd/m^2).
#' @param colorMax List of stimulus max colors for all shapes
#' @param sy List of diameters along minor axis of ellipse (degrees). If not
#'           received, then sy = sx (Optional)
#' @param rotation List of angles of rotation of stimuli (degrees). Only useful
#'                 if sx != sy specified. (Optional)
#' @param texRotation List of angles of rotation of stimuli (degrees). Only
#'                    useful if type != FLAT (Optional)
#' @param colorMin List of stimulus min colors for non-FLAT shapes. (Optional)
#' @param type Stimulus type. Values include FLAT, SINE, CHECKERBOARD,
#'             SQUARESINE, G1, G2, G3, IMAGE (Optional)
#' @param stim.length The number of elements in this stimuli.
#' @param defocus List of defocus values in Diopters for stimulus post-processing. (Optional)
#' @param frequency List of frequencies (in cycles per degrees) for generation
#'                  of spatial patterns. Only useful if type != FLAT (Optional)
#' @param eye The eye for which to apply the settings.
#' @param t List of stimuli presentation times (ms).
#' @param w Time to wit for response including presentation time (ms).
#' @param contrast List of stimulus contrasts (from 0 to 1). Only useful if type
#'                 != FLAT. (Optional)
#' @param optotype If shape == OPTOTYPE, the letter A to Z to use (Optional)
#' @param x List of x co-ordinates of stimuli (degrees).
#' @param y List of y co-ordinates of stimuli (degrees).
#'
#' @return a list containing:
#'  * res List with all of the other fields described in @ReturnMsg except 'error'.
#'    - res$msg$eyey y co-ordinates of pupil at times eyet (degrees).
#'    - res$msg$eyex x co-ordinates of pupil at times eyet (degrees).
#'    - res$msg$time Response time from stimulus onset if button pressed (ms).
#'    - res$msg$eyed Diameter of pupil at times eyet (mm).
#'    - res$msg$eyet Time of (eyex, eyey) pupil from stimulus onset (ms).
#'    - res$msg Error message or a structure with the following fields.
#'    - res$error '0' if success, something else if error.
#'    - res$msg$seen '1' if seen, '0' if not.
#'
#' @details 
#' Elements in `phase` can take on values in the range \code{[0.0, 1.0E10]}.
#' Elements in `shape` can take on values in the set
#'                   {triangle, square, polygon, hollow_triangle, hollow_square,
#'                   hollow_polygon, cross, maltese, circle, annulus, optotype, text, model}.
#' Elements in `sx` can take on values in the range \code{[0.0, 180.0]}.
#' Elements in `lum` can take on values in the range \code{[0.0, 1.0E10]}.
#' Elements in `colorMax` can take on values in the range \code{[0.0, 1.0]}.
#' Elements in `sy` can take on values in the range \code{[0.0, 180.0]}.
#' Elements in `rotation` can take on values in the range \code{[0.0, 360.0]}.
#' Elements in `texRotation` can take on values in
#'                         the range \code{[0.0, 360.0]}.
#' Elements in `colorMin` can take on values in the range \code{[0.0, 1.0]}.
#' Elements in `type` can take on values in the set {flat,
#'                  checkerboard, sine, squaresine, g1, g2, g3, text, image}.
#' `stim.length` can take on values in the range \code{[1, 2147483647]}.
#' Elements in `defocus` can take on values in the range \code{[0.0, 1.0E10]}.
#' Elements in `frequency` can take on values in the range \code{[0.0, 300.0]}.
#' Elements in `eye` can take on values in the set {left, right, both}.
#' Elements in `t` can take on values in the range \code{[0.0, 1.0E10]}.
#' `w` can take on values in the range \code{[0.0, 1.0E10]}.
#' Elements in `contrast` can take on values in the range \code{[0.0, 1.0]}.
#' Elements in `optotype` can take on values in the set
#'                      {a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z}.
#' Elements in `x` can take on values in the range \code{[-90.0, 90.0]}.
#' Elements in `y` can take on values in the range \code{[-90.0, 90.0]}.
#'
#' @examples
#' chooseOpi("ImoVifa")
#' result <- opiPresent(stim = list(sx = list(1.72), lum = list(20.0), colorMax = list(list(1.0,
#'                   1.0, 1.0)), stim.length = 1, eye = list("LEFT"),
#'                   t = list(200.0), w = 1500.0, x = list(0.0), y = list(0.0)))
#'
#' @seealso [opiPresent()]
#'
opiPresent_for_ImoVifa <- function(stim) {
    if(!exists(".opi_env") || !exists("ImoVifa", envir = .opi_env) || !("socket" %in% names(.opi_env$ImoVifa)) || is.null(.opi_env$ImoVifa$socket))
        return(list(error = 3, msg = "Cannot call opiPresent without an open socket to Monitor. Did you call opiInitialise()?."))

    if (is.null(stim)) return(list(error = 0 , msg = "Nothing to do in opiPresent."))

    msg <- list(phase = stim$phase, imageFilename = stim$imageFilename, shape = stim$shape, sx = stim$sx, lum = stim$lum, colorMax = stim$colorMax, sy = stim$sy, rotation = stim$rotation, texRotation = stim$texRotation, colorMin = stim$colorMin, type = stim$type, stim.length = stim$stim.length, defocus = stim$defocus, frequency = stim$frequency, eye = stim$eye, t = stim$t, w = stim$w, contrast = stim$contrast, optotype = stim$optotype, x = stim$x, y = stim$y)
    msg <- c(list(command = "present"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$ImoVifa$socket)

    res <- readLines(.opi_env$ImoVifa$socket, n = 1)
    if (length(res) == 0)
        return(list(error = 5, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- rjson::fromJSON(res)
    return(res)
}

#' Implementation of opiClose for the ImoVifa machine.
#'
#' This is for internal use only. Use [opiClose()] with
#' these Arguments and you will get the Value back.
#'
#' @usage NULL
#'
#'
#'
#' @return a list containing:
#'  * res List of result elements.
#'    - res$msg The error message or additional results from the CLOSE command
#'    - res$error '0' if success, something else if error.
#'
#'
#'
#' @examples
#' chooseOpi("ImoVifa")
#' result <- opiClose()
#'
#' @seealso [opiClose()]
#'
opiClose_for_ImoVifa <- function() {
    if(!exists(".opi_env") || !exists("ImoVifa", envir = .opi_env) || !("socket" %in% names(.opi_env$ImoVifa)) || is.null(.opi_env$ImoVifa$socket))
        return(list(error = 3, msg = "Cannot call opiClose without an open socket to Monitor. Did you call opiInitialise()?."))

    
    msg <- list()
    msg <- c(list(command = "close"), msg)
    msg <- msg[!unlist(lapply(msg, is.null))]
    msg <- rjson::toJSON(msg)
    writeLines(msg, .opi_env$ImoVifa$socket)

    res <- readLines(.opi_env$ImoVifa$socket, n = 1)
    if (length(res) == 0)
        return(list(error = 5, msg = "Monitor server exists but a connection was not closed properly using opiClose() last time it was used. Restart Monitor."))
    res <- rjson::fromJSON(res)
    return(res)
}


#' Set background color and luminance in both eyes.
#' Deprecated for OPI >= v3.0.0 and replaced with [opiSetup()].
#' @usage NULL
#' @seealso [opiSetup()]
opiSetBackground_for_ImoVifa <- function(lum, color, ...) {return("Deprecated")}


