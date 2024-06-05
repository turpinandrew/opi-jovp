package org.lei.opi.core;

import java.util.Arrays;
import java.util.HashMap;

import org.lei.opi.core.definitions.Packet;
import org.lei.opi.core.definitions.ReturnMsg;

import es.optocom.jovp.Controller;
import javafx.fxml.FXML;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.scene.Node;

import org.bytedeco.javacv.FrameGrabber;
import org.bytedeco.javacv.JavaFXFrameConverter;
import org.bytedeco.javacv.OpenCVFrameConverter;
import org.bytedeco.javacv.OpenCVFrameGrabber;
import org.bytedeco.javacv.CanvasFrame;
import org.bytedeco.javacv.Frame;

/**
 * Opens up a window wherever the JOVP wants it
 */
public class ImoVifa extends Jovp {

    public static class Settings extends Jovp.Settings { ; }  // here to trick GUI

    private FrameGrabber grabberLeft, grabberRght;
    private JavaFXFrameConverter frameConverter;

    private CanvasFrame frameLeft;  //temp
    private CanvasFrame frameRght;  //temp

    public ImoVifa(Scene parentScene) throws InstantiationException { 
        super(parentScene); 

        this.fxmlFileName = String.format("%s_%s.fxml", "stereo", "yes_tracking");
    }
    public ImoVifa(Scene parentScene, boolean connect) throws InstantiationException { 
        super(parentScene, connect); 

        this.fxmlFileName = String.format("%s_%s.fxml", "stereo", "yes_tracking");
    }

     /**
     * opiInitialise: initialize OPI
     * Update GUI, call super.initialize().
     * @param args A map of name:value pairs for Params (ignored)
     * @return A Package containing a JSON object with machine specific initialise information
     * @since 0.2.0
     */
    public Packet initialize(HashMap<String, Object> args) {
        output("OPI Monitor: OPI Initialized");

            // Make sure screen = 1 and viewMode = "STEREO" is present for ImoVifa
            // Also it seems the monitor does not report it's correct size...
        settings.setPhysicalSize(new int[] {121, 68});
        settings.setScreen(1);
        settings.setViewMode("STEREO");

        String [] comPorts = Controller.getSuitableControllers();
        if (!Arrays.asList(comPorts).contains(settings.input)) 
            return(Packet.error(new StringBuilder("OPI Settings has ")
                .append(settings.input)
                .append(" as the clicker port which is not in the avilable ports: ")
                .append(Arrays.toString(comPorts))
                .toString()));

        try {
            this.grabberLeft = new OpenCVFrameGrabber(0);
            this.grabberRght = new OpenCVFrameGrabber(1);
            this.frameConverter = new JavaFXFrameConverter();
            this.grabberLeft.start();
            this.grabberRght.start();
        } catch (FrameGrabber.Exception e) {
            System.out.println("Cannot start frame grabber in ImoVifa");
            e.printStackTrace();
        }

        this.frameLeft = new CanvasFrame("eyes"); // temp
        this.frameRght = new CanvasFrame("eyes"); // temp
        
        return super.initialize(null);
    };
  
    /**
     * opiQuery: Query device
     * call super.query(), update GUI.
     * @return A packet containing a JSON object describing settings and machine state
     * @since 0.2.0
     */
    public Packet query() { 
        Packet p = super.query();
        output("OPI Query result\n" + p.getMsg().toString());
        return p;
    }
  
    /**
     * opiSetup: Change device background and overall settings
     * Update GUI, call super.setup() 
     * @param args pairs of argument name and value
     * @return A packet containing a JSON object as for `query()`
     * @since 0.2.0
     */
    public Packet setup(HashMap<String, Object> args) {
        StringBuffer sb = new StringBuffer();
        sb.append("Setup:\n");
        for (String k : args.keySet())
            sb.append(String.format("\t%s = %s\n", k, args.get(k).toString()));
        output(sb.toString());
        return super.setup(args);
    }
 
    /**
     * opiPresent: Present OPI stimulus in perimeter
     * Update GUI, call super.present() 
     * @param args pairs of argument name and value
     * @return A packet containing a JSON object
     * @since 0.2.0
     */
    //TODO
    //@ReturnMsg(name = "eyed", className = Double.class, desc = "Diameter of pupil at times eyet (mm).")
    //@ReturnMsg(name = "eyet", className = Double.class, desc = "Time of (eyex, eyey) pupil from stimulus onset (ms).", min = 0)
    @ReturnMsg(name = "eyex", className = Double.class, desc = "x co-ordinates of pupil at ??? (degrees).")
    @ReturnMsg(name = "eyey", className = Double.class, desc = "y co-ordinates of pupil at ??? (degrees).")
    public Packet present(HashMap<String, Object> args) {
        updateGUIOnPresent(args);

        frameLeft.showImage(getFrame(this.grabberLeft));
        frameRght.showImage(getFrame(this.grabberLeft));
        //System.out.println(img.getWidth() + " x " + img.getHeight());
        //args.put("units", new ArrayList<String>(Arrays.asList(new String[] {"ANGLES"})));
        //double sx[] = Jovp.toDoubleArray(args.get("sx"));
        //double sy[] = Jovp.toDoubleArray(args.get("sy"));
        //double x[] = Jovp.toDoubleArray(args.get("x"));
        //double y[] = Jovp.toDoubleArray(args.get("y"));
        //args.put("units", new ArrayList<String>(Arrays.asList(new String[] {"PIXELS"})));
        //args.put("sx", new ArrayList<Double>(Arrays.stream(sx).map(d -> 18.34 * d).boxed().collect(Collectors.toList())));
        //args.put("sy", new ArrayList<Double>(Arrays.stream(sy).map(d -> 18.34 * d).boxed().collect(Collectors.toList())));
        //args.put("x", new ArrayList<Double>(Arrays.stream(x).map(d -> 18.34 * d).boxed().collect(Collectors.toList())));
        //args.put("y", new ArrayList<Double>(Arrays.stream(y).map(d -> 18.34 * d).boxed().collect(Collectors.toList())));
        return super.present(args);
    }

    /**
   * opiClose: Update GUI, call super.close()
   * 
   * @param args pairs of argument name and value
   *
   * @return A Packet containing JSON object with return messages
   *
   * @since 0.0.1
   */
    public Packet close() {
        output("OPI Monitor: Close received.\n");
        returnToParentScene((Node)textAreaCommands);

        return super.close();
    }

    /**
     * Get a frame from the camera
     * @return An Image object representing the frame (or null if there was an error)
     */
    private Frame getFrame(FrameGrabber grabber) {
        //Image im = null;
        Frame frame = null;
        try {
            frame = grabber.grab();

            //im = frameConverter.convert(frame);
        } catch (FrameGrabber.Exception e) {
            System.out.println("Error trying to grab a frame in ImoVifa");
            e.printStackTrace();
        }
        return frame;
    }

 //--------------- FXML stuff
    
    @FXML
    void initialize() {
        setupJavaFX("ImoVifa");

        // Create a thread that will get UDP packets from udp_socket and put them in imageViewLeft
        /*
        Thread t = new Thread() {
            public void run() { 
                int image_size = 640 * 480 * 1;
                byte [] data = new byte[image_size];
                DatagramPacket p = new DatagramPacket(data, data.length);

                int errorCount = 0;

                boolean isRunning = true;
                while (isRunning) {
                    try {
                        Thread.sleep(20);
                        udp_socket.receive(p);

                        Image img = new Image(new ByteArrayInputStream(p.getData()));
                        Platform.runLater(() -> {
                            imageViewLeft.setImage(img);
                        });
                    } catch (InterruptedException e) {
                        isRunning = false;
                    } catch (IOException e) {
                        System.out.println("Error receiving UDP packet from ImoVifa camera");
                        e.printStackTrace();
                        errorCount++;
                        if (errorCount > 20) {
                            System.out.println("Received more than 20 errors from UDP socket: giving up.");
                            isRunning = false;
                        }
                    }
                }
            }
        };
        t.start();
        */
    }
}