package org.lei.opi.core;

import static org.lei.opi.core.definitions.JsonProcessor.toIntArray;
import static org.lei.opi.core.definitions.JsonProcessor.toDoubleArray;
import static org.lei.opi.core.definitions.JsonProcessor.toEnumArray;

import java.io.IOException;
import java.util.HashMap;

import org.lei.opi.core.definitions.MessageProcessor;
import org.lei.opi.core.definitions.Parameter;
import org.lei.opi.core.definitions.ReturnMsg;

/**
 * Octopus O900 client
 *
 * @since 0.0.1
 */
public class O900 extends OpiMachine {

  /** Allowed eye values */
  public enum Eye {LEFT, RIGHT}
  /** Allowed background luminances */
  public enum Luminance {BG_OFF, BG_1, BG_10, BG_100}
  /** Allowed fixation types */
  public enum Fixation {CENTER, CROSS, RING}
  /** Allowed background colors */
  public enum BackgroundColor {WHITE, YELLOW}
  /** Stimulus type */
  public enum Type {STATIC, KINETIC}
  /** Allowed stimulus colors */
  public enum Color {WHITE, RED, BLUE}
  /** Allowed sizes */
  public enum Size {GI, GII, GIII, GIV, GV, GVI}

  /** {@value DEFAULT_EYESUITE} */
  private static final String DEFAULT_EYESUITE = "C:/ProgramData/Haag-Streit/EyeSuite/";
  /** {@value NA_STRING} */
  private static final String NA_STRING = "NA";

  /** {@value OPI_INITIALIZE} */
  private static final String OPI_INITIALIZE = "OPI_INITIALIZE ";
  /** {@value OPI_SET_BACKGROUND} */
  private static final String OPI_SET_BACKGROUND = "OPI_SET_BACKGROUND";
  /** {@value OPI_PRESENT_STATIC} */
  private static final String OPI_PRESENT_STATIC = "OPI_PRESENT_STATIC";
  /** {@value OPI_PRESENT_STATIC_F310} */
  private static final String OPI_PRESENT_STATIC_F310 = "OPI_PRESENT_STATIC_F310";
  /** {@value OPI_PRESENT_KINETIC} */
  private static final String OPI_PRESENT_KINETIC = "OPI_PRESENT_KINETIC";
  /** {@value OPI_CLOSE} */
  private static final String OPI_CLOSE = "OPI_CLOSE";
  /** {@value OPI_INITIALIZE_FAILED} */
  private static final String OPI_INITIALIZE_FAILED = "Problem with OPI_INITIALIZE: ";
  /** {@value OPI_SET_BACKGROUND_FAILED} */
  private static final String OPI_SET_BACKGROUND_FAILED = "Problem with OPI_SET_BACKGROUND: ";
  /** {@value LIST_SIZE_TOO_LONG} */
  private static final String LIST_SIZE_TOO_LONG = "Stimulus list sizes must be either 1 or 2 (for sending the position of the next stimulus).";
  /** {@value INCONSISTENT_ARGUMENTS} */
  private static final String INCONSISTENT_ARGUMENTS = "List sizes are inconsistent.";
  /** {@value WRONG_STATIC_LUM_SIZE} */
  private static final String WRONG_STATIC_LUM_SIZE_T = "For a static stimulus, size, luminance, and presentation time must be an array of length 1.";
  /** {@value WRONG_PRESENTATION_TIME} */
  private static final String WRONG_STATIC_PRESENTATION_TIME = "Presentation time cannot be greater than response window";
  /** {@value WRONG_SIZE} */
  private static final String WRONG_SIZE = "Wrong stimulus size. It is ";

  /** Whether device maximum is 10000 abs or 4000 abs */
  private boolean max10000;
  /** Whether device has a big wheel (i.e., allows presentation of Goldmann VI stimulus sizes) */
  private boolean bigWheel;
  /** Whether clicker is Logitech's F310 */
  private boolean f310;

  /**
   * opiQuery: Query device
   * 
   * @return settings and state machine state
   *
   * @since 0.0.1
   */
  @ReturnMsg(name = "res", desc = "JSON Object with all of the other fields described in @ReturnMsg except 'error'.")
  @ReturnMsg(name = "res.error", desc = "'0' if success, '1' if error.")
  @ReturnMsg(name = "res.msg", desc = "The success or error message.")
  public MessageProcessor.Packet query(HashMap<String, Object> args) {
    if (!initialized) return OpiManager.error(NOT_INITIALIZED);
    // TODO QUERY
    return new MessageProcessor.Packet("");
  };

  /**
   * opiSetup: Change device background and overall settings
   * 
   * @param args pairs of argument name and value
   * 
   * @return A JSON object with return messages
   *
   * @since 0.0.1
   */
  @Parameter(name = "eye", desc = "Eye to set.", className = Eye.class, defaultValue = "left")
  @Parameter(name = "eyeSuite", desc = "Path to EyeSuite.", className = String.class, defaultValue = "C:/ProgramData/Haag-Streit/EyeSuite/")
  @Parameter(name = "gazeFeed", desc = "Path where to save gaze feed. Directory must exists", className = String.class, defaultValue = "C:/XXX/gazeFeed/")
  @Parameter(name = "bigWheel", desc = "Whether O900 has a big wheel for displaying Goldmann Size VI stimuli.", className = Double.class, min = 0, max = 1, defaultValue = "0")
  @Parameter(name = "pres", desc = "Volume for auditory feedback when a stimulus is presented: 0 means no buzzer.", className = Double.class, min = 0, max = 3, defaultValue = "0")
  @Parameter(name = "resp", desc = "Volume for auditory feedback when observer presses the clicker: 0 means no buzzer.", className = Double.class, min = 0, max = 3, defaultValue = "0")
  @Parameter(name = "max10000", desc = "Whether O900 can handle a maximum luminance of 10000 apostilbs instead of 4000. Check the settings in EyeSuite", className = Double.class, min = 0, max = 1, defaultValue = "0")
  @Parameter(name = "bgLum", desc = "Background luminance for eye.", className = Double.class, defaultValue = "10", min = 0, max = 3183.099)
  @Parameter(name = "bgCol", desc = "Background color for eye.", className = BackgroundColor.class, defaultValue = "white")
  @Parameter(name = "fixType", desc = "Fixation target.", className = Fixation.class, defaultValue = "center")
  @Parameter(name = "fixIntensity", desc = "Fixation intensity(from 0% to 100%).", className = Double.class, defaultValue = "50", min = 0, max = 100)
  @Parameter(name = "f310", desc = "Whether to use Logitech's F310 controller", className = Double.class, defaultValue = "0", min = 0, max = 1)
  @ReturnMsg(name = "res", desc = "JSON Object with all of the other fields described in @ReturnMsg except 'error'.")
  @ReturnMsg(name = "res.error", desc = "'0' if success, '1' if error.")
  @ReturnMsg(name = "res.msg", desc = "The success or error message.")
  public MessageProcessor.Packet setup(HashMap<String, Object> args) {
    if (!initialized) return OpiManager.error(NOT_INITIALIZED);
    StringBuilder opiMessage;
    String result;
    try {
      // Prepare and send OPI_INITIALIZE
      String eyeSuite = (String) args.get("eyeSuite");
      if (eyeSuite.isBlank()) eyeSuite = DEFAULT_EYESUITE;
      String gazeFeed = (String) args.get("gazeFeed");
      if (eyeSuite.isBlank()) gazeFeed = NA_STRING;
      opiMessage = new StringBuilder(OPI_INITIALIZE).append(" ")
        .append("\"").append(eyeSuite).append("\"").append(" ")
        .append("\"").append(((String) args.get("eye"))).append("\"").append(" ")
        .append((int) ((double) args.get("pres"))).append(" ")
        .append((int) ((double) args.get("resp"))).append(" ")
        .append((int) ((double) args.get("max10000"))).append(" ")
        .append("\"").append(gazeFeed).append("\"").append(" ");
      writer.send(opiMessage.toString());
      while (writer.empty()) Thread.onSpinWait();
      result = writer.receive();
      if (!result.equals("1")) return OpiManager.error(OPI_INITIALIZE_FAILED + result);
      initialized = true;
      // Prepare and send OPI_SET_BACKGROUND
      int bgCol = switch(BackgroundColor.valueOf(((String) args.get("bgCol")).toUpperCase())) {
        case WHITE -> 0; // TODO: find correct code for background white
        case YELLOW -> 1; // TODO: find correct code for background yellow
      };
      int bgLum = switch(Luminance.valueOf(((String) args.get("bgLum")).toUpperCase())) {
        case BG_OFF -> 0; // TODO: find correct code for background 0 cdm2
        case BG_1 -> 1; // TODO: find correct code for background 1 cdm2
        case BG_10 -> 10; // TODO: find correct code for background 10 cdm2
        case BG_100 -> 100; // TODO: find correct code for background 100 cdm2
      };
      int fixType = switch(Fixation.valueOf(((String) args.get("fixType")).toUpperCase())) {
        case CENTER -> 0; // TODO: find correct code for fixation CENTER
        case CROSS -> 1; // TODO: find correct code for fixation CROSS
        case RING -> 10; // TODO: find correct code for fixation RING
      };
      opiMessage = new StringBuilder(OPI_SET_BACKGROUND).append(" ")
        .append(bgCol).append(" ")
        .append(bgLum).append(" ")
        .append(fixType).append(" ")
        .append((int) ((double) args.get("fixIntensity")));
      writer.send(opiMessage.toString());
      while (writer.empty()) Thread.onSpinWait();
      result = writer.receive();
      if (!result.equals("1")) return OpiManager.error(OPI_SET_BACKGROUND_FAILED + result);  
      // finish setup, max10000, bigWheel and F310 are managed here
      if ((int) ((double) args.get("max10000")) == 0) max10000 = false;
      else max10000 = false;
      if ((int) ((double) args.get("bigWheel")) == 0) bigWheel = false;
      else bigWheel = false;
      if ((int) ((double) args.get("f310")) == 0) f310 = false;
      else f310 = false;
      return new MessageProcessor.Packet(result); // TODO build result
    } catch (IOException | ClassCastException | IllegalArgumentException e) {
      return OpiManager.error(OPI_SETUP_FAILED, e);
    }
  }

  /**
   * opiPresent: Present OPI stimulus in perimeter
   * 
   * @param args pairs of argument name and value
   * 
   * @return A JSON object with return messages
   *
   * @since 0.0.1
   */
  @Parameter(name = "type", desc = "Stimulus type: STATIC, KINETIC, TEMPORAL.", className = Type.class, defaultValue = "static")
  @Parameter(name = "x", desc = "List of x co-ordinates of stimuli (degrees).", className = Double.class, min = -90, max = 90, isList = true, defaultValue = "list(0)")
  @Parameter(name = "y", desc = "List of y co-ordinates of stimuli (degrees).", className = Double.class, min = -90, max = 90, isList = true, defaultValue = "list(0)")
  @Parameter(name = "lum", desc = "List of stimuli luminances (cd/m^2).", className = Double.class, min = 0, max = 3183.099, isList = true, defaultValue = "list(100)")
  @Parameter(name = "size", desc = "Stimulus size (degrees). Can be Goldmann Size I to V (or VI if device has a big wheel)", className = Size.class, isList = true, defaultValue = "list('GV')")
  @Parameter(name = "t", desc = "List of stimuli presentation times (ms).", className = Double.class, min = 0, isList = true, defaultValue = "list(200)")
  @Parameter(name = "color", desc = "Stimulus color (degrees) [STATIC].", className = Color.class, defaultValue = "white")
  @Parameter(name = "w", desc = "List of stimuli response windows (ms) [STATIC].", className = Double.class, min = 0, defaultValue = "1500")
  @ReturnMsg(name = "res", desc = "JSON Object with all of the other fields described in @ReturnMsg except 'error'.")
  @ReturnMsg(name = "res.error", desc = "'0' if success, '1' if error.")
  @ReturnMsg(name = "res.msg", desc = "Error message or a structure with the following data.")
  @ReturnMsg(name = "res.msg.seen", desc = "true if seen, false if not.", className = Boolean.class)
  @ReturnMsg(name = "res.msg.time", desc = "Response time from stimulus onset if button pressed, -1 otherwise (ms).", className = Double.class, min = -1)
  public MessageProcessor.Packet present(HashMap<String, Object> args) {
    if (!initialized) return OpiManager.error(NOT_INITIALIZED);
    try {
      String opiMessage = switch(Type.valueOf(((String) args.get("type")).toUpperCase())) {
        case STATIC -> buildStatic(args);
        case KINETIC -> buildKinetic(args);
      };
      writer.send(opiMessage.toString());
      while (writer.empty()) Thread.onSpinWait();
      return parseResult(writer.receive());  
    } catch (IOException | ClassCastException | IllegalArgumentException e) {
      return OpiManager.error(OPI_PRESENT_FAILED, e);
    }
  }

  /**
   * opiClose: Close OPI connection
   * 
   * @param args pairs of argument name and value
   *
   * @return A JSON object with return messages
   *
   * @since 0.0.1
   */
  @ReturnMsg(name = "res", desc = "JSON Object with all of the other fields described in @ReturnMsg except 'error'.")
  @ReturnMsg(name = "res.error", desc = "'0' if success, '1' if error.")
  @ReturnMsg(name = "res.msg", desc = "The success or error message")
  public MessageProcessor.Packet close() {
    try {
      writer.send(OPI_CLOSE);
      writer.close();
      initialized = false;
      return OpiManager.ok(DISCONNECTED_TO_HOST + writer, true);
    } catch (IOException e) {
      return OpiManager.error(COULD_NOT_DISCONNECT + writer, e);
    }
  };

  /**
   * Build OPI_PRESENT_KINETIC or OPI_PRESENT_STATIC_F310 command
   * 
   * @param args pairs of argument name and value
   * 
   * @return A JSON object with return messages
   *
   * @since 0.0.1
   */
  private String buildStatic(HashMap<String, Object> args) throws ClassCastException, IllegalArgumentException {
    int[] x = toIntArray(args.get("x"));
    int[] y = toIntArray(args.get("y"));
    double[] lum = toDoubleArray(args.get("lum"));
    Size[] size = (Size[]) toEnumArray(args.get("size"), Size.class);
    int[] t = toIntArray(args.get("t"));
    int w = (int) ((double) args.get("w"));
    String color =  Color.valueOf(((String) args.get("color")).toUpperCase()).toString().toLowerCase();
    if (x.length > 2) throw new IllegalArgumentException(LIST_SIZE_TOO_LONG);
    if (x.length != y.length) throw new IllegalArgumentException(INCONSISTENT_ARGUMENTS);
    if (lum.length != 1 || size.length != 1 || t.length != 1) throw new IllegalArgumentException(WRONG_STATIC_LUM_SIZE_T);
    if (t[0] > w) throw new IllegalArgumentException(WRONG_STATIC_PRESENTATION_TIME);
    int xNext, yNext;
    if(x.length == 1) {
      xNext = x[0];
      yNext = y[0];
    } else {
      xNext = x[1];
      yNext = y[1];
    }
    int sizeValue = switch(size[0]) {
      case GI -> 1;
      case GII -> 2;
      case GIII -> 3;
      case GIV -> 4;
      case GV -> 5;
      case GVI -> 6;
    };
    if (!bigWheel & sizeValue == 6) throw new IllegalArgumentException(WRONG_SIZE + size[0]);
    double level = Math.round(-100 * Math.log10(lum[0] / ((max10000 ? 10000 : 4000)) / Math.PI)) / 10;
    StringBuilder opiMessage = new StringBuilder(f310 ? OPI_PRESENT_STATIC_F310 : OPI_PRESENT_STATIC).append(" ")
      .append(10 * x[0]).append(" ").append(10 * y[0]).append("").append(" ")
      .append(String.format("%.1f", level)).append(" ").append(size[0]).append(" ")
      .append(t[0]).append(" ").append(w).append(" ")
      .append(10 * xNext).append(" ").append(10 * yNext).append("").append(" ")
      .append(color);
    return opiMessage.toString();
  }

  /**
   * Build OPI_PRESENT_KINETIC command
   * 
   * @param args pairs of argument name and value
   * 
   * @return A JSON object with return messages
   *
   * @since 0.0.1
   */
  private String buildKinetic(HashMap<String, Object> args) throws ClassCastException {
    // TODO: implement kinetic instruction
    //int[] x = toIntArray(args.get("x"));
    //int[] y = toIntArray(args.get("y"));
    //double[] lum = toDoubleArray(args.get("lum"));
    //double[] size = toDoubleArray(args.get("size"));
    //double[] speed = toDoubleArray(args.get("size"));

    //stim$speeds[i-1] <- d/stim$speeds[i-1]

    StringBuilder opiMessage = new StringBuilder(OPI_PRESENT_KINETIC).append(" ");
/**
    msg <- paste(c(msg, length(xs), xs, ys), collapse=" ")
    msg <- paste(c(msg, sapply(stim$levels, cdTodb, maxStim=.OpiEnv$O900$zero_db_in_asb/pi)), collapse=" ")
    msg <- paste(c(msg, stim$sizes), collapse=" ")
    msg <- paste(c(msg, stim$speeds), collapse=" ")  
 */
    return opiMessage.toString();
  }

  /**
   * Parse results: construct JSON from the 1-liner string from O900
   * 
   * @param received  1-liner string received from O900
   * 
   * @return A JSON object with return messages
   *
   * @since 0.0.1
   */
  private MessageProcessor.Packet parseResult(String received) {
    return new MessageProcessor.Packet(""); // TODO return something
  }

}