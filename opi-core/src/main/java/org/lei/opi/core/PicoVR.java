package org.lei.opi.core;

import java.util.HashMap;

/**
 * PicoVR client
 *
 * @since 0.0.1
 */
public class PicoVR extends Jovp {

  public PicoVR() { super(); }

    /* (non-Javadoc)
     * @see org.lei.opi.core.OpiMachine#query()
     */
     public MessageProcessor.Packet query(HashMap<String, String> args) {
      return new MessageProcessor.Packet("");
    }
  
    /* (non-Javadoc)
     * @see org.lei.opi.core.OpiMachine#init()
     */
    public MessageProcessor.Packet initialize(HashMap<String, String> args) {
      setIsInitialised(true);
      return new MessageProcessor.Packet("");
    }
  
    /* (non-Javadoc)
     * @see org.lei.opi.core.OpiMachine#setup()
     */
    public MessageProcessor.Packet setup(HashMap<String, String> args) {
      return new MessageProcessor.Packet("");
    }
  
    /* (non-Javadoc)
     * @see org.lei.opi.core.OpiMachine#present()
     */
    public MessageProcessor.Packet present(HashMap<String, String> args) {
      return new MessageProcessor.Packet("");
    }
  
    /* (non-Javadoc)
     * @see org.lei.opi.core.OpiMachine#close()
     */
    public MessageProcessor.Packet close(HashMap<String, String> args) {
      setIsInitialised(false);
      return new MessageProcessor.Packet(true, "");
    }
}