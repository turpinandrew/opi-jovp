package org.lei.opi.monitor;

import java.io.IOException;

import org.junit.jupiter.api.Test;
import org.lei.opi.jovp.Configuration.Machine;
import org.lei.opi.jovp.OpiJovp;
import org.lei.opi.core.OpiListener;

/**
 *
 * Integrated tests for connection in series from client to OPI JOVP
 *
 * @since 0.0.1
 */
public class RToMonitorToJovpTests {

  /** JOVP server port */
  private static final int JOVP_PORT = 51234;
  /** JOVP monitor port */
  private static final int MONITOR_PORT = 50001;

  /** The JOVP server */
  private OpiJovp server;
  /** The OPI monitor */
  private Core monitor;
  /** The R client */
  private OpiListener r;

  /** OPI_CHOOSE command */
  private String chooseJson;
  /** OPI_INITIALIZE command */
  private String initJson;
  /** OPI_SETUP command */
  private String[] setupJson;
  /** OPI_PRESENT command */
  private String[] presentJson;

  /**
   * Monitor controlling Display on monoscopic view
   *
   * @since 0.0.1
   */
  @Test
  public void monitorDisplay() {
    setupConnections(Machine.DISPLAY);
    setupCommands(Machine.DISPLAY);
    clientDriver();
    closeConnections();
  }

  /** setup connections */
  private void setupConnections(Machine machine) {
    try {
      server = new OpiJovp(JOVP_PORT); // first setup JOVP server
      monitor = new Core(MONITOR_PORT); // then setup monitor
      r = new OpiListener(monitor.getPort(), null); // finally setup R client
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  /** setup commands */
  private void setupCommands(Machine machine) {
    switch(machine) {
      case DISPLAY -> {
        chooseJson = "Display/opiChoose.json";
        initJson = "Display/opiInit.json";
        setupJson = new String[] {
          "Display/opiSetup.json"
        };
        presentJson = new String[] {
          "Display/opiPresentStatic1.json",
          "Display/opiPresentStatic2.json",
          "Display/opiPresentStatic3.json",
          "Display/opiPresentStatic1.json",
          "Display/opiPresentStatic2.json",
          "Display/opiPresentStatic3.json",
          "Display/opiPresentDynamic1.json",
          "Display/opiPresentDynamic2.json"
        };
      }
      case IMOVIFA -> {
        chooseJson = "ImoVifa/opiChoose.json";
        initJson = "ImoVifa/opiInit.json";
        setupJson = new String[] {
          "ImoVifa/opiSetup.json"
        };
        presentJson = new String[] {
          "ImoVifa/opiPresent.json",
          "ImoVifa/opiPresent2.json",
          "ImoVifa/opiPresent3.json",
          "ImoVifa/opiPresent4.json",
          "ImoVifa/opiPresent5.json",
          "Display/opiPresentDynamic2.json"
        };
      }
      case PICOVR -> {
        chooseJson = "PicoVR/opiChoose.json";
        initJson = "PicoVR/opiInit.json";
        setupJson = new String[] {
          "PicoVR/opiSetup.json"
        };
        presentJson = new String[] {
          "PicoVR/opiPresent.json",
        };
      }
      case PHONEHMD -> {
        chooseJson = "PhoneHMD/opiChoose.json";
        initJson = "PhoneHMD/opiInit.json";
        setupJson = new String[] {
          "PhoneHMD/opiSetup.json"
        };
        presentJson = new String[] {
          "PhoneHMD/opiPresent.json",
        };
      }
    }
  }

  /** close connections */
  private void closeConnections() {
    try {
      monitor.close();
      r.closeListener();
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  /** execute commands from driver */
  private void clientDriver() {
    new Thread() {
      public void run() {
        try {
          Thread.sleep(500); // need to wait for PsychoEngine to start
          executeCommands();
        } catch (IOException | InterruptedException e) {
          throw new RuntimeException(e);
        }
      }
    }.start();
  }

  /** server driver with lists of present/query etc*/
  private void executeCommands() throws IOException, InterruptedException {
    sendAndReceive(chooseJson); // Choose OPI
    sendAndReceive(initJson); // Initialize OPI
    Thread.sleep(1000);
    sendAndReceive("opiQuery.json"); // Query OPI
    for (String s : setupJson) {
      sendAndReceive(s); // Setup OPI
      Thread.sleep(1000);
    }
    for (String s : presentJson) { // Present OPI
      sendAndReceive(s);
      Thread.sleep(500);
    } // Present OPI
    sendAndReceive("opiClose.json"); // Close OPI  
  }
  
  /** R sends to and receives from monitor */
  private void sendAndReceive(String message) throws IOException {
    System.out.println("R SENDS\n" + message);
    //r.send(message);
    //System.out.println("R RECEIVES\n" + r.receive());
  }

}
