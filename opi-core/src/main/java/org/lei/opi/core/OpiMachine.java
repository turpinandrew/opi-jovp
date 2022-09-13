package org.lei.opi.core;

import org.lei.opi.core.structures.Parameters;
import org.lei.opi.core.structures.Parameter;

import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Stream;
import java.util.Optional;

import java.lang.reflect.Method;

import org.reflections.Reflections;

import com.google.gson.reflect.TypeToken;

import com.google.gson.Gson;

/**
 * The OPI standard for communication with perimeters
 *
 * @since 0.0.1
 */
abstract class OpiMachine {
  /** {@value BAD_CHOOSE} */
  static final String BAD_CHOOSE = "JSON object does not contain 'command:choose'.";
  /** {@value BAD_MACHINE} */
  static final String BAD_MACHINE = "JSON choos object does not contain the name 'machine'";
  /** {@value UNKNOWN_MACHINE} */
  static final String UNKNOWN_MACHINE = "machine:%s in JSON choose object is unknown.";
  /** {@value BAD_MACHINE_CONSTRUCT} */
  static final String BAD_MACHINE_CONSTRUCT = "Cannot construct machine %s in JSON choose object.\n";

  private boolean isInitialised; 
  public void setIsInitialised(boolean value) { this.isInitialised = value; }
  public boolean getIsInitialised() { return this.isInitialised; }

  /** IP Address of perimeter {@value IP} */
  public static final String IP = "{type: String, default = localhost}";
  /** TCP Port of perimeter {@value PORT} */
  public static final String PORT = "{type: Integer, min: 1, max: Inf}";


    /** Class to hold information of the 5 key OPI methods ready for use. 
    * Should be set in the constructor. 
    */
  protected class MethodData {
    protected Method method;
    protected Parameters parameters;   // The names expected in the JSON string that is a parameter of the 5 key OPI methods. 
  };
  protected HashMap<String, MethodData> opiMethods;
  protected HashMap<String, List<String>> enums; // Enum class : enum values defined in the package.

    /** Set the information about the 5 OPI methods in opiMethods.
     * It is assumed this is called by a subclass.  
     */
  public OpiMachine() {
    this.isInitialised = false;

    opiMethods = new HashMap<String, MethodData>();
    for (Method method : this.getClass().getMethods()) {
      MethodData data = new MethodData();
      data.method = method;

      Reflections reflections = new Reflections(this.getClass().getPackageName());
      enums = new HashMap<String, List<String>>();
      for (Class<? extends Enum> e : reflections.getSubTypesOf(Enum.class))
        enums.put(e.getName(), Stream.of(e.getEnumConstants()).map((Enum c) -> c.name().toLowerCase()).toList());

        // key is method name, value is array of annotations on that method
      data.parameters = method.getAnnotation(Parameters.class);

      opiMethods.put(method.getName(), data);
    }
  }

   /** Map the 'command' to a function, check it has the right parameters, and then call it.
    *
    * @param  nameValuePairs A list of name:value pairs with at least the name "command".
    * 
    * @return Json object like OpiManger.ok() or OpiManager.error()
    */
  public MessageProcessor.Packet process(HashMap<String, String> nameValuePairs) {
        // (1) Find the function which is the value of the JSON name "command"
        // (2) Check that the params for the function are in the JSON (via the Params Annotation)
        // (3) Then execute the function.
    String funcName = (String)nameValuePairs.get("command");
    MethodData methodData = opiMethods.get(funcName);

    if (methodData == null)
        return OpiManager.error(String.format("cannot find function %s in %s.", 
          funcName, this.getClass()));

        // (2) 
    if (methodData.parameters != null)
        for (Parameter param : methodData.parameters.value()) {
            if (!nameValuePairs.containsKey(param.name()))
                return OpiManager.error(String.format ("parameter %s is missing for function %s in %s.", param.name(), funcName, this.getClass()));
       
            Object valueObj = nameValuePairs.get(param.name());

            if (valueObj instanceof ArrayList<?> && ((ArrayList<?>)valueObj).size() == 0)
                return OpiManager.error(String.format ("Parameter %s is a list of length 0 in function %s in %s.", param.name(), funcName, this.getClass()));
     
            //Predicate<Object> pDouble = v -> v.doubleValue() >= param.min() && v.doubleValue() <= param.max();
            //Predicate<Object> pString = v -> v instanceof String;

            if (enums.containsKey(param.className().getName())) {
                Stream<String> enumVals = enums.get(param.className().getName()).stream();

                Optional<Object> result = Stream.of(valueObj)
                    .filter(v -> !(v instanceof String) || !  enumVals.anyMatch(s -> s.contains(((String)v).toLowerCase())))
                    .findAny();
                if (result.isPresent())
                    return OpiManager.error(String.format ("I cannot find %s in enum type %s for parameter %s in function %s in %s.", 
                          result.get(), param.className(), param.name(), funcName, this.getClass()));
            } else if (param.className().getSimpleName().equals("Double")) {
                Optional<Object> result = Stream.of(valueObj)
                    .filter(v -> !(v instanceof Double) || ((Double)v).doubleValue() < param.min() || ((Double)v).doubleValue() > param.max())
                    .findAny();
                if (result.isPresent())
                    return OpiManager.error(String.format ("Parameter %s in funciton %s of %s is either not a double or not in range [%s,%s].", 
                        param.name(), funcName, this.getClass(), param.min(), param.max()));
            } else { // assuming param is a String
                Optional<Object> result = Stream.of(valueObj)
                    .filter(v -> !(v instanceof String))
                    .findAny();
                if (result.isPresent())
                    return OpiManager.error(String.format ("Parameter %s in funciton %s of %s should be a String.", 
                        param.name(), funcName, this.getClass()));
            }
        }
           // (3)
    MessageProcessor.Packet result;
    try {
      result = (MessageProcessor.Packet)methodData.method.invoke(this, nameValuePairs);
    } catch(IllegalAccessException | InvocationTargetException e) {
      return OpiManager.error(String.format("cannot execute %s in %s.", funcName, this.getClass()), e);
    }
    return result;
  };

  /**
   * Query the settings and capabilities of the perimetry device
   * 
   * @param args pairs of argument name and value
   *
   * @return A JSON-structured string with machine specific query information
   *
   * @since 0.0.1
   */
  public abstract MessageProcessor.Packet query(HashMap<String, String> args);

  /**
   * Initialize the OPI on the corresponding machine
   * 
   * @param args pairs of argument name and value
   *
   * @return A JSON-structured string with machine specific initialization feedback. 
   *         If successful should set isInitialised to true
   *
   * @since 0.0.1
   */
  public abstract MessageProcessor.Packet initialize(HashMap<String, String> args);
  public MessageProcessor.Packet initialise(HashMap<String, String> args) { return this.initialize(args);}

  /**
   * Change device background and overall settings
   * 
   * @param args pairs of argument name and value
   * 
   * @return A JSON-structured string with machine specific setup feedback
   *
   * @since 0.0.1
   */
  public abstract MessageProcessor.Packet setup(HashMap<String, String> args);

  /**
   * Present OPI stimulus in perimeter
   * 
   * @param args pairs of argument name and value
   * 
   * @return A JSON-structured string with machine specific presentation feedback
   *
   * @since 0.0.1
   */
  public abstract MessageProcessor.Packet present(HashMap<String, String> args);

  /**
   * Close OPI connection
   * 
   * @param args pairs of argument name and value
   *
   * @return A JSON-structured string with machine specific closing feedback
   *         If successful should set isInitialised to false.
   *
   * @since 0.0.1
   */
  public abstract MessageProcessor.Packet close(HashMap<String, String> args);
}
