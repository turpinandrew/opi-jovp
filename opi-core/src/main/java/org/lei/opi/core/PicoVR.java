package org.lei.opi.core;

import java.util.HashMap;

/**
 * JOVP client
 *
 * @since 0.0.1
 */
public class PicoVR extends Jovp {

  public PicoVR() { super(); }

  /* (non-Javadoc)
   * @see org.lei.opi.core.OpiMachine#query()
   */
   public String query(HashMap<String, String> args) {
    return "";
  }

  /* (non-Javadoc)
   * @see org.lei.opi.core.OpiMachine#init()
   */
  public String initialize(HashMap<String, String> args) {
    setIsInitialised(true);
    return "";
  }

  /* (non-Javadoc)
   * @see org.lei.opi.core.OpiMachine#setup()
   */
  public String setup(HashMap<String, String> args) {
    return "";
  }

  /* (non-Javadoc)
   * @see org.lei.opi.core.OpiMachine#present()
   */
  public String present(HashMap<String, String> args) {
    return "";
  }

  /* (non-Javadoc)
   * @see org.lei.opi.core.OpiMachine#close()
   */
  public String close(HashMap<String, String> args) {
    setIsInitialised(false);
    return "";
  }

}