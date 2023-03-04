---
title: "OPI Server II"
output:
  html_document:
    toc: true
    number_sections: true
---

# OPI Server II

Created by Iv&aacute;n Mar&iacute;n-Franch and Andrew Turpin commencing October 2022.

## Description

This is a complete re-write of the <a href="https://perimetry.org/opi">Open Perimetry Interface</a> 
middleware (or "OPI server") and some associated changes
to the <a href="https://cran.r-project.org/web/packages/OPI/index.html">OPI R package</a> 
to allow for use on screen-based devices such as phones, 
VR headsets, and monitors. In attempt to be device independent, it makes use of the 
<a href = "https://github.com/imarinfr/jovp">JOVP</a> written by Iv&aacute;n Mar&iacute;n-Franch which in turn
is built upon the Vulkan platform.

Some of the old implementations of the OPI Server (Octopus 900, Kowa AP7000 and iCare Compass)
will remain the same for the short term, but will eventually be incorporated into this 
framework (planned February 2023 for implementation in late 2023).

## Overall architecture

The system works using TCP/IP sockets to connect this code (the OPI SERVER II)
with both a controlling *client* (for example, R code that uses the OPI R package)
and a target *machine* (for example, an Octopus 900 perimeter or an Android Phone).
Messages are sent in JSON format according to the protocol specified as part of the 
core code using the `@Parameter` annotator.

<pre>
+--------------------+        +-----------+        +-----------------+
| Controlling Client |  JSON  |           |  JSON  |     Machine     |
| (eg OPI R package) |<------>|  Monitor  |<------>| (Display Device |
|                    | TCP/IP |           | TCP/IP |  or Perimeter)  |
+--------------------+        +-----------+        +-----------------+
</pre>

Both the client connection and machine connection are handled 
using socket connections that use JSON strings for messages. 

## Packages

### Monitor
The main executable of interest is driven by the `monitor` package, which displays a 
GUI written with javaFX for selecting and connecting to Machines, 
listening to Clients, and for displaying Machine relevant information about JSON 
messages that pass through from Client to Machine and back again. 
Specific GUI `Scenes` for each machine
are specified as FXML documents in the core/resources folder and
their class definitions (subclasses of `OpiMachine`) act as 
fx:controllers for the associated document.

                                  +---------+
                                  | Monitor |
                   +--------------+---------+--------------+
                   |                                       |
                   |                      +------------+   |
                   |  +----------+        | OPIMachine |   |
                   |  |   GUI    |      +-+------------+-+ |
                   |  |  fx:...  |      |                | |
                   |  +----------+      |  +----------+  | |
                   |                    |  |  Socket  |<-------> Machine
                   |                    |  +----------+  | |
                   |  +-------------+   |                | |
         Client <---->| OpiListener |   |  fx:controller |<- - - - - - core/resources/*.fxml
                   |  +-------------+   +----------------+ |
                   |                                       |   
                   +---------------------------------------+
     

### Core
The classes in the `core` module specify machines, the protocol and GUI for each machine, 
and basic utilities for socket communication and JSON processing. Reflection is used heavily 
in this system, so it is not for the Java novice.
The (abstract) super class for all devices is `OpiMachine` which defines the protocol and behaviour 
for the 5 functions defined in the OPI Standard: `opiInitialise`, `opiQueryDevice`, `opiSetup`,
`opiPresent`, and `opiClose`.

### jovp 

This package implements the Jovp Machine that in turn calls the 
<a href = "https://github.com/imarinfr/jovp">JOVP</a> library written by Iv&aacute;n Mar&iacute;n-Franch.
This library allows display of psychophysical stimuli on display devices.
This repo implements the left hand box in this JOVP machine diagram.

<pre>

                            A JOVP Machine
           +-------------------------------------------------+
           |                     Physical Device             |
           |                     (eg PicoVR, imoVifa, ...)   |
      JSON |  +---------+       +-------------------------+  |
     <-----+->|  jovp   |<----->|  +---------+            |  |
           |  | package |       |  |  JOVP   |  Native    |  |
           +  +---------|       |  | Library |  Software  |  |
           |                    |  +---------+            |  |
           |                    |  | Vulkan  |            |  |
           |                    |  +---------+            |  |
           |                    +-------------------------+  |
           +-------------------------------------------------+

</pre>
### R Generation
In an attempt to reduce mismatches in the protocol between the Client and Server and the 
protocol between the Server and Machine, the R code for sending messages is automatically
generated to match that expected by the relevant Machine. 
This happens in the `rgen` package. In essence, wthe `@Parameter` and `@ReturnMsg` 
annotators of the five opi functions in the `core::OpiMachine` subclasses are used to 
create the relevant R code.
This module is not for general use, but rather to be run to update the OPI 
R package whenever a new machine is added, or an interface to an existing machine changes.

## Licence and Copyright

The [OPI-project] (WEBSITE) project and all its modules are COPYRIGHTED by Andrew Turpin 
and Iv&aacute;n Mar&iacute;n-Franch, and is distributed 
under the Apache 2.0 license. Please read the license information in the attached file

## Future Work
* Write a doclet to format @Parmeters Annotaion nicely in javadoc.
* Modularise OpiMachine.process() so Enum, Double and List are all handled consistently.
* Add contrast, spatial frequency and defocus @Parameters to Imo.present()

* Add GUI elements somehow...

* Far future: incorporate O900 and Compass into this framework
