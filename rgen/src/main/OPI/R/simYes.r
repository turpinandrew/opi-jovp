#
# An implementation of the OPI that simulates a patient that always responds.
#
# Author: Andrew Turpin    (aturpin@unimelb.edu.au)
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
#

#' Does nothing.
#'
#' @return NULL
#'
opiClose_for_SimYes <- function() NULL

#' Returns a simple list.
#'
#' @return A list with one element `machine` that is `"SimYes"`.
#'
opiQueryDevice_for_SimYes <- function() list(machine = "SimYes")

#' Does nothing.
#'
#' @param ... Any other paramters you like, they are ignored.
#'
#' @return NULL
#'
opiInitialise_for_SimYes <- function(...) NULL

#' Does nothing.
#'
#' @param state Any object you like, it is ignored.
#'
#' @return NULL
#'
opiSetup_for_SimYes <- function(state) NULL

#' Always respond 'yes' immediately to any parameter.
#' No checking is done on the validity of `stim`.
#'
#' @param stim Any stimulus object or list.
#' @param ... Any other paramters you like, they are ignored.
#'
#' @return A list contianing:
#'   * err, and error code that is always NULL
#'   * seen, which is always TRUE
#'   * time, which is always 0
#'
opiPresent_for_SimYes <- function(stim, ...) list(err = NULL, seen = TRUE, time = 0)