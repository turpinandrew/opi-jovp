package org.lei.opi.core;

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.stream.Stream;

import org.lei.opi.core.definitions.Packet;
import org.lei.opi.core.definitions.PacketDeserializer;
import org.lei.opi.core.definitions.PacketSerializer;

import com.google.gson.JsonSyntaxException;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

/**
 *
 * An instance of this runs a ServerSocket in a separate thread that applies 
 * this.process() to any incoming messages. It assumes that the messages are 
 * JSON objects terminated with a \n that at least contain a name:value pair 
 * "command":"x" where x is one of the 5 OPI commands. If the JSON string 
 * does match this pattern it is parsed into name:value pairs and these are passed onto 
 * this.machine.processPairs().
 *
 * @since 0.2.0
 */
public class OpiListener extends Thread {

  /**
   * Command. In JSON files they will appear as:
   *    name:value pair where name == "command"
   *
   * @since 0.0.1
   */
    public enum Command {
      /** Query device constants */
      QUERY,
      /** Setup OPI */
      SETUP,
      /** Initialize OPI connection */
      INITIALIZE,
      /** Present OPI static, kinetic, or temporal stimulus */
      PRESENT,
      /** Close OPI connection */
      CLOSE
    }
  
    /** For exception messages: {@value NO_COMMAND_FIELD} */
    public static final String NO_COMMAND_FIELD = "Json message does not contain field 'command'.";
    /** For exception messages: {@value BAD_COMMAND_FIELD} {@link Command} */
    public static final String BAD_COMMAND_FIELD = "value of 'command' name in Json message is not one of Command'.";
    /** For exception messages: {@value NO_OPI_MACHINE} */
    public static final String NO_OPI_MACHINE = "null OpiMachine passed to OpiClient.";
    /** Charset is {@value CHARSET_NAME} */
    private static final String CHARSET_NAME = "UTF8";
    /** {@value LISTENER_FAILED} */
    private static final String LISTENER_FAILED = "Listener failed.";
    /** {@value CLOSE_FAILED} */
    private static final String CLOSE_FAILED = "Cannot close the socket.";
    /** {@value CLOSE_FAILED} */
    private static final String CANNOT_OBTAIN_ADDRESS = "Cannot obtain public address.";

    /** to parse JSONs with fromJson method */
    public static final GsonBuilder gsonBuilder = new GsonBuilder();

    public static Gson gson = new Gson();

    /** Given a JSON string, return name:value pairs */
    public static HashMap<String, Object> jsonToPairs(String jsonStr) throws JsonSyntaxException {
        return gson.fromJson(jsonStr, new TypeToken<HashMap<String, Object>>() {}.getType());
    }

    /** Connection address */
    private InetAddress address;
    /** Connection port */
    protected int port;
    /** Socket server */
    private ServerSocket server;
        /** Reader for incoming messages on the socket */
    BufferedReader incoming;
        /** Writer for outgoing messages to the socket */
    PrintWriter outgoing;
    /** Whether it is connected to a client */
    protected boolean connected;
    /** The OpiMachine object that commands will be passed to */
    private OpiMachine machine;

    /**
     * Start the OPI manager with an opiMachine that is already chosen/constructed
     *
     * @since 0.2.0
     */
    public OpiListener(int port, OpiMachine machine) {
        gsonBuilder.registerTypeAdapter(Packet.class, new PacketSerializer());
        gsonBuilder.registerTypeAdapter(Packet.class, new PacketDeserializer());
        gson = gsonBuilder.create();  

        this.machine = machine; 
        this.port = port; 
        this.address = obtainPublicAddress(); // run on localhost
        this.connected = false; // true when connection established
        this.start(); // kick off this thread
    }
  
    /**
     * Process incoming Json commands. If it is a 'choose' command, then
     * set the private field machine to a new instance of that machine.
     * If it is another command, then process it using the machine object.
     *
     * @param jsonStr A JSON object that at least contains the name 'command'.
     * 
     * @return Packet with JSON string inside
     * 
     * @since 0.1.0
     */
      public Packet process(String jsonStr) {
              // Parse JSON to hashmap with pairs of name:values
          HashMap<String, Object> pairs;
          try {
              pairs = jsonToPairs(jsonStr);
          }  catch (JsonSyntaxException e) {
              return Packet.error("Cannot get hashmap of pairs from JSON in process()", e);
          }
   
              // Get command
          if (!pairs.containsKey("command")) // needs a command
              return Packet.error(NO_COMMAND_FIELD);
          String cmd;
          try {
              cmd = (String) pairs.get("command");
          } catch (ClassCastException e) {
              return Packet.error(BAD_COMMAND_FIELD);
          }
   
              // Check it is a valid command
          if (!Stream.of(Command.values()).anyMatch((e) -> e.name().equalsIgnoreCase(cmd)))
              return Packet.error(BAD_COMMAND_FIELD);
   
          if (machine != null)
              return this.machine.processPairs(pairs);
          else
              return Packet.error(NO_OPI_MACHINE);
      }


    /** 
     * Run a socket server that only accepts one connection and then dies.
     * Applies process() to every incoming message, sending the result back on the same connection.
     * 
     * Will run forever until process() returns a Packet with close == true.
     *
     * Runs in its own thread */
    @Override
    public void run() {
        Socket socket;
        try {
            server = new ServerSocket(this.port); //, 0, this.address);
            socket = server.accept();
            this.connected = true;
            incoming = new BufferedReader(new InputStreamReader(socket.getInputStream(), CHARSET_NAME));
            outgoing = new PrintWriter(socket.getOutputStream());
            String inputLine;
            while (this.connected && (inputLine = incoming.readLine()) != null) {
                    Packet pack = process(inputLine);
                    send(gson.toJson(pack));
                    if (pack.getClose()) break; // if close requested, break loop
            }
            server.close();
        } catch (SocketException ignored) {
          ;
        } catch (IOException e) {
          throw new RuntimeException(LISTENER_FAILED, e);
        }
    }
  
    /**
     *
     * Send message.
     * Strip any internal newlines as \n terminates a message.
     *
     * @param message  The message to deliver
     *
     * @since 0.0.1
     */
    public void send(String message) {
      outgoing.write(message.replace("\n", "") + "\n");
      outgoing.flush();
    }
  
    /**
     * Signal stop listening and wait
     *
     * @since 0.0.1
     */
    public void closeListener() {
      if (this.connected) {
        this.connected = false;  // should trigger close after loop finishes
      } else {
          // server is just waiting to accept a connection, better kill it
        try {
          server.close();
        } catch (IOException ignored) { ; }
      }

      synchronized (this) {
        try {
          this.join();
        } catch (InterruptedException e) {
          throw new RuntimeException(CLOSE_FAILED, e);
        }
      }
    }
  
    public String toString() {
      return "OpiListener server listening at " + getIP() + ":" + getPort();
    }
  
    /**
     * Get local address
     *
     * @return the local address
     *
     * @since 0.0.1
     */
    public InetAddress getAddress() { return address; }
  
    /**
     * Get local IP address
     *
     * @return the local IP address
     *
     * @since 0.0.1
     */
    public String getIP() { return address.getHostAddress(); }
  
    /**
     * Get local port
     *
     * @return the local port
     *
     * @since 0.0.1
     */
    public int getPort() { return port; }
  
    /** get network address for public access */
    public static InetAddress obtainPublicAddress() {
      try {
        for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();) {
          NetworkInterface networkInterface = en.nextElement();
          for (Enumeration<InetAddress> address = networkInterface.getInetAddresses(); address.hasMoreElements();) {
            InetAddress inetAddress = address.nextElement();
            if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) {
              return inetAddress;
            }
          }
        }
      } catch (SocketException e) {
        throw new RuntimeException(CANNOT_OBTAIN_ADDRESS, e);
      }
      return null;
    }
  
}