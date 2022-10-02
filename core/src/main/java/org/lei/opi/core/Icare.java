package org.lei.opi.core;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.HashMap;

import org.apache.commons.lang3.ArrayUtils;
import org.lei.opi.core.definitions.MessageProcessor;
import org.lei.opi.core.definitions.Parameter;
import org.lei.opi.core.definitions.ReturnMsg;

public class Icare extends OpiMachine {
  
  /** Allowed eye values */
  public enum Eye {LEFT, RIGHT}
  /** Allowed fixation types */
  public enum Fixation {SPOT, SQUARE}

  /** {@value OPI_OPEN} */
  private static final String OPI_OPEN = "OPI-OPEN";
  /** {@value OPI_SET_FIXATION} */
  private static final String OPI_SET_FIXATION = "OPI-SET-FIXATION ";
  /** {@value OPI_SET_TRACKING} */
  private static final String OPI_SET_TRACKING = "OPI-SET-TRACKING ";
  /** {@value OPI_PRESENT_STATIC} */
  private static final String OPI_PRESENT_STATIC = "OPI-PRESENT-STATIC ";
  /** {@value OPI_CLOSE} */
  private static final String OPI_CLOSE = "OPI-CLOSE";
  /** {@value BAD_OPEN} */
  private static final String BAD_OPEN = "Bad open";
  /** {@value INVALID_FIXATION_SETTING} */
  private static final String INVALID_FIXATION_SETTING = "Fixation position %s is invalid for fixation type %s";
  /** {@value INVALID_TRACKING_SETTING} */
  private static final String INVALID_TRACKING_SETTING = "Tracking can only have value 0 (false) and 1 (true). It has ";
  /** {@value OPI_OPEN_FAILED} */
  private static final String OPI_OPEN_FAILED = "Problem with OPI-OPEN";
  /** {@value OPI_SET_FIXATION_FAILED} */
  private static final String OPI_SET_FIXATION_FAILED = "Problem with OPI-SET-FIXATION";
  /** {@value OPI_SET_TRACKING_FAILED} */
  private static final String OPI_SET_TRACKING_FAILED = "Problem with OPI-SET-TRACKING";

  /** Icare constants */
  static int MIN_X;
  static int MAX_X;
  static int MIN_Y;
  static int MAX_Y;
  static int MIN_PRESENTATION_TIME;
  static int MAX_PRESENTATION_TIME;
  static int MIN_RESPONSE_WINDOW;
  static int MAX_RESPONSE_WINDOW;
  static double BACKGROUND_LUMINANCE;
  static double MIN_LUMINANCE;
  static double MAX_LUMINANCE;
  static boolean TRACKING;

  /**
   * opiInitialise: initialize OPI
   * 
   * @param args A map of name:value pairs for Params
   * 
   * @return A JSON object with machine specific initialise information
   * 
   * @since 0.0.1
   */
  public MessageProcessor.Packet initialize(HashMap<String, Object> args) {
    try {
      writer = new CSWriter((String) args.get("ip"), (int) ((double) args.get("port")));
      return OpiManager.ok(CONNECTED_TO_HOST + args.get("ip") + ":" + (int) ((double) args.get("port")));
    } catch (ClassCastException e) {
      return OpiManager.error(INCORRECT_FORMAT_IP_PORT);
    } catch (IOException e) {
      return OpiManager.error(String.format(SERVER_NOT_READY, args.get("ip") + ":" + (int) ((double) args.get("port"))));
    }
  };

  /**
   * opiQuery: Query device
   * 
   * @return settings and state machine state
   *
   * @since 0.0.1
   */
  public MessageProcessor.Packet query() {
    return OpiManager.ok(queryResults());
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
  @Parameter(name = "fixShape", className = Fixation.class, desc = "Fixation target type for eye.", defaultValue = "spot")
  @Parameter(name = "fixCx", className = Double.class, desc = "x-coordinate of fixation target (degrees): Only valid values are -20, -6, -3, 0, 3, 6, 20 for fixation type 'spot' and -3, 0, 3 for fixation type 'square'.", min = -20, max = 20, defaultValue = "0")
  @Parameter(name = "tracking", className = Double.class, desc = "Whether to correct stimulus location based on eye position.", min = 0, max = 1, defaultValue = "0")
  public MessageProcessor.Packet setup(HashMap<String, Object> args) {
    if (writer == null) return OpiManager.error(NOT_INITIALIZED);
    try {
      int fixCx = (int) ((double) args.get("fixCx"));
      int fixShape = -1;
      switch(Fixation.valueOf(((String) args.get("fixShape")).toUpperCase())) {
        case SPOT -> {
          if (fixCx != 0 && Math.abs(fixCx) != 3 && Math.abs(fixCx) != 6 && Math.abs(fixCx) != 20)
            return OpiManager.error(String.format(INVALID_FIXATION_SETTING, fixCx, Fixation.SPOT));
          fixShape = 0;
        }
        case SQUARE -> {
          if (fixCx != 0 && Math.abs(fixCx) != 3)
            return OpiManager.error(String.format(INVALID_FIXATION_SETTING, fixCx, Fixation.SPOT));
          fixShape = 1;
        }
      };
      int tracking = (int) ((double) args.get("tracking"));
      if (tracking != 0 && tracking != 1) return OpiManager.error(INVALID_TRACKING_SETTING + tracking);
      writer.send(OPI_OPEN);
      while (writer.empty()) Thread.onSpinWait();
      String jsonStr = parseOpiOpen(writer.receive());
      if (jsonStr.equals(BAD_OPEN)) return OpiManager.error(OPI_OPEN_FAILED);
      writer.send(OPI_SET_FIXATION + fixCx + " 0 " + fixShape);
      while (writer.empty()) Thread.onSpinWait();
      if (!writer.receive().split(" ")[0].equals("0"))
        return OpiManager.error(OPI_SET_FIXATION_FAILED);
      writer.send(OPI_SET_TRACKING + tracking);
      while (writer.empty()) Thread.onSpinWait();
      if (!writer.receive().split(" ")[0].equals("0"))
        return OpiManager.error(OPI_SET_TRACKING_FAILED);
      return OpiManager.ok(jsonStr);
    } catch (ClassCastException | IllegalArgumentException e) {
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
  @Parameter(name = "x", className = Double.class, desc = "x co-ordinates of stimulus (degrees).", min = -30, max = 30, defaultValue = "0")
  @Parameter(name = "y", className = Double.class, desc = "y co-ordinates of stimulus (degrees).", min = -30, max = 30, defaultValue = "0")
  @Parameter(name = "lum", className = Double.class, desc = "Stimuli luminance (cd/m^2).", min = 0, max = 3183.099, defaultValue = "100")
  @Parameter(name = "t", className = Double.class, desc = "Presentation time (ms).", min = 200, max = 200, defaultValue = "200")
  @Parameter(name = "w", className = Double.class, desc = "Response window (ms).", min = 200, max = 2680, defaultValue = "1500")
  @ReturnMsg(name = "res", desc = "JSON Object with all of the other fields described in @ReturnMsg except 'error'.")
  @ReturnMsg(name = "res.eyex", className = Double.class, desc = "x co-ordinates of pupil at times eyet (pixels).")
  @ReturnMsg(name = "res.eyey", className = Double.class, desc = "y co-ordinates of pupil at times eyet (pixels).")
  @ReturnMsg(name = "res.eyed", className = Double.class, desc = "Diameter of pupil at times eyet (mm).")
  @ReturnMsg(name = "res.eyet", className = Double.class, desc = "Time of (eyex, eyey) pupil from stimulus onset (ms).", min = 0)
  @ReturnMsg(name = "res.time_rec", className = Double.class, desc = "Time since 'epoch' when command was received at Compass or Maia (ms).", min = 0)
  @ReturnMsg(name = "res.time_resp", className = Double.class, desc = "Time since 'epoch' when stimulus response is received, or response window expired (ms).", min = 0)
  @ReturnMsg(name = "res.num_track_events", className = Double.class, desc = "Number of tracking events that occurred during presentation.", min = 0)
  @ReturnMsg(name = "res.num_motor_fails", className = Double.class, desc = "Number of times motor could not follow fixation movement during presentation.", min = 0)
  public MessageProcessor.Packet present(HashMap<String, Object> args) {
    if (writer == null) return OpiManager.error(NOT_INITIALIZED);
    try {
      int level = (int) Math.round(-10 * Math.log10((double) args.get("lum") / (10000 / Math.PI)));
      StringBuilder opiMessage = new StringBuilder(OPI_PRESENT_STATIC).append(" ")
        .append((int) ((double) args.get("x"))).append(" ")
        .append((int) ((double) args.get("y"))).append(" ")
        .append(level).append(" 3 ")
        .append((int) ((double) args.get("t"))).append(" ")
        .append((int) ((double) args.get("w")));
        writer.send(opiMessage.toString());
        while (writer.empty()) Thread.onSpinWait();
        return OpiManager.ok(parseResult(writer.receive()));
      } catch (ClassCastException | IllegalArgumentException e) {
      return OpiManager.error(OPI_SETUP_FAILED, e);
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
  @ReturnMsg(name = "res.time", desc = "The time stamp for fixation data")
  @ReturnMsg(name = "res.x", desc = "The time stamp for fixation data")
  @ReturnMsg(name = "res.y", desc = "The time stamp for fixation data")
  public MessageProcessor.Packet close() {
    try {
      writer.send(OPI_CLOSE);
      while (writer.empty()) Thread.onSpinWait();
      String message = parseOpiClose(writer.receive());
      writer.close();
      writer = null;
      return OpiManager.ok(message, true);
    } catch (IOException | ClassCastException | IllegalArgumentException e) {
      return OpiManager.error(COULD_NOT_DISCONNECT, e);
    }
  };

  /**
   * Parse results obtained for OPI-OPEN
   * 
   * @param received Message received from Icare machine
   * 
   * @return A string with return messages
   *
   * @since 0.0.1
   */
  private String parseOpiOpen(String received) {
    if (received.isBlank()) return BAD_OPEN;
    byte[] bytes = ArrayUtils.toPrimitive(Arrays.stream(received.split(" ")).map(str -> Byte.parseByte(str)).toArray(Byte[]::new));
    double prlx = ByteBuffer.wrap(Arrays.copyOfRange(bytes, 4, 8)).getFloat();
    double prly = ByteBuffer.wrap(Arrays.copyOfRange(bytes, 8, 12)).getFloat();
    double onhx = ByteBuffer.wrap(Arrays.copyOfRange(bytes, 12, 16)).getFloat();
    double onhy = ByteBuffer.wrap(Arrays.copyOfRange(bytes, 16, 20)).getFloat();
    ByteBuffer imageBuffer = ByteBuffer.allocate(bytes.length - 20).put(Arrays.copyOfRange(bytes, 20, bytes.length));
    double[] image = new double[(bytes.length - 20) / 4];
    for (int i = 0; i < image.length; i++) image[i] = (double) imageBuffer.getFloat(4 * i);
    return queryResults(prlx, prly, onhx, onhy, image);
  }

  /**
   * Parse query results
   * 
   * @return A JSON object with query results
   *
   * @since 0.0.1
   */
  private String queryResults() {
    return new StringBuilder("\n  {\n")
      .append("    \"MIN_X\": " + MIN_X + ",\n")
      .append("    \"MAX_X\": " + MAX_X + ",\n")
      .append("    \"MIN_Y\": " + MIN_Y + ",\n")
      .append("    \"MAX_Y\": " + MAX_Y + ",\n")
      .append("    \"MIN_PRESENTATION_TIME\": " + MIN_PRESENTATION_TIME+ ",\n")
      .append("    \"MAX_PRESENTATION_TIME\": " + MAX_PRESENTATION_TIME + ",\n")
      .append("    \"MIN_RESPONSE_WINDOW\": " + MIN_RESPONSE_WINDOW + ",\n")
      .append("    \"MAX_RESPONSE_WINDOW\": " + MAX_RESPONSE_WINDOW + ",\n")
      .append("    \"BACKGROUND_LUMINANCE\": " + BACKGROUND_LUMINANCE + ",\n")
      .append("    \"MIN_LUMINANCE\": " + MIN_LUMINANCE + ",\n")
      .append("    \"MAX_LUMINANCE\": " + MAX_LUMINANCE + ",\n")
      .append("    \"TRACKING\": " + TRACKING + ",\n")
      .append("\n  }").toString();
  };

  /**
   * Parse query results
   * 
   * @return A JSON object with query results
   *
   * @since 0.0.1
   */
  private String queryResults(double prlx, double prly, double onhx, double onhy, double[] image) {
    return new StringBuilder("\n  {\n")
      .append("    \"prlx\": " + prlx + ",\n")
      .append("    \"prly\": " + prly + ",\n")
      .append("    \"onhx\": " + onhx + ",\n")
      .append("    \"onhy\": " + onhy + ",\n")
      .append("    \"image\": " + Arrays.toString(image) + ",\n")
      .append("    \"MIN_X\": " + MIN_X + ",\n")
      .append("    \"MAX_X\": " + MAX_X + ",\n")
      .append("    \"MIN_Y\": " + MIN_Y + ",\n")
      .append("    \"MAX_Y\": " + MAX_Y + ",\n")
      .append("    \"MIN_PRESENTATION_TIME\": " + MIN_PRESENTATION_TIME+ ",\n")
      .append("    \"MAX_PRESENTATION_TIME\": " + MAX_PRESENTATION_TIME + ",\n")
      .append("    \"MIN_RESPONSE_WINDOW\": " + MIN_RESPONSE_WINDOW + ",\n")
      .append("    \"MAX_RESPONSE_WINDOW\": " + MAX_RESPONSE_WINDOW + ",\n")
      .append("    \"BACKGROUND_LUMINANCE\": " + BACKGROUND_LUMINANCE + ",\n")
      .append("    \"MIN_LUMINANCE\": " + MIN_LUMINANCE + ",\n")
      .append("    \"MAX_LUMINANCE\": " + MAX_LUMINANCE + ",\n")
      .append("    \"TRACKING\": " + TRACKING )
      .append("\n  }\n").toString();
  };

  /**
   * Parse results obtained for OPI-PRESENT-STATIC
   * 
   * @param received Message received from Icare machine
   * 
   * @return A JSON object with present results
   *
   * @since 0.0.1
   */
  private String parseResult(String received) {
    String[] message = received.split(" ");
    if (message[0] != "0") OpiManager.error(OPI_PRESENT_FAILED + "Error code received is: " + message[0]);
    return new StringBuilder("\n  {\n")
      .append("    \"seen\": " + message[1] + ",\n")
      .append("    \"time\": " + message[2] + ",\n")
      .append("    \"eyex\": " + message[9] + ",\n")
      .append("    \"eyey\": " + message[10] + ",\n")
      .append("    \"eyed\": " + message[8] + ",\n")
      .append("    \"eyet\": " + message[3] + ",\n")
      .append("    \"time_rec\": " + message[4] + ",\n")
      .append("    \"time_resp\": " + message[5] + ",\n")
      .append("    \"num_track_events\": " + message[6] + ",\n")
      .append("    \"num_motor_fails\": " + message[7] + ",\n  }").toString();
  }

  /**
   * Parse results obtained for OPI-CLOSE
   * 
   * @param received Message received from Icare machine
   * 
   * @return A string with close results
   *
   * @since 0.0.1
   */
  private String parseOpiClose(String received) {
    if (received.isBlank()) return BAD_OPEN;
    byte[] bytes = ArrayUtils.toPrimitive(Arrays.stream(received.split(" ")).map(str -> Byte.parseByte(str)).toArray(Byte[]::new));
    int[] time = new int[(bytes.length - 4) / 12];
    double[] posx = new double[(bytes.length - 4) / 12];
    double[] posy = new double[(bytes.length - 4) / 12];
    ByteBuffer imageBuffer = ByteBuffer.allocate(bytes.length - 4).put(Arrays.copyOfRange(bytes, 4, bytes.length));
    for (int i = 0; i < time.length; i++) {
      time[i] = imageBuffer.getInt(12 * i);
      posx[i] = (double) imageBuffer.getFloat(12 * i + 4);
      posy[i] = (double) imageBuffer.getFloat(12 * i + 8);
    }
    return new StringBuilder("\n  {\n")
      .append("    \"time\": " + Arrays.toString(time) + ",\n")
      .append("    \"posx\": " + Arrays.toString(posx) + ",\n")
      .append("    \"posy\": " + Arrays.toString(posy))
      .append("\n  }").toString();
  }
 
}