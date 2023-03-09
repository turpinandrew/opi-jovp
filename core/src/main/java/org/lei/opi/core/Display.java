package org.lei.opi.core;

import java.util.HashMap;

import javafx.scene.Scene;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.chart.ScatterChart;
import javafx.scene.control.Button;
import javafx.scene.control.TextArea;
import javafx.scene.Node;
import javafx.scene.chart.XYChart;

/**
 * Opens up a window wherever the JOVP wants it
 */
public class Display extends Jovp {
    
    public static class Settings extends Jovp.Settings { ; }  // here to trick GUI

    public Display(Scene parentScene) throws InstantiationException { 
        super(parentScene); 
    }

     /**
     * opiInitialise: initialize OPI
     * @param args A map of name:value pairs for Params
     * @return A JSON object with machine specific initialise information
     * @since 0.2.0
     */
    public Packet initialize(HashMap<String, Object> args) {
        if (textAreaCommands != null)
            textAreaCommands.appendText("OPI Initialized");
        return super.initialize(args);
    };
  
    /**
     * opiQuery: Query device
     * @return settings and state machine state
     * @since 0.2.0
     */
    public Packet query() { 
        Packet p = super.query();
        if (textAreaCommands != null)
            textAreaCommands.appendText(p.getMsg().toString());
        return p;
    }
  
    /**
     * opiSetup: Change device background and overall settings
     * @param args pairs of argument name and value
     * @return A JSON object with return messages
     * @since 0.2.0
     */
    public Packet setup(HashMap<String, Object> args) {
        if (textAreaCommands != null) {
            this.textAreaCommands.appendText("Setup:\n");
            for (String k : args.keySet())
                this.textAreaCommands.appendText(String.format("\t%s = %s\n", k, args.get(k).toString()));
        }

        return super.setup(args);
    }
  
    /**
     * opiPresent: Present OPI stimulus in perimeter
     * @param args pairs of argument name and value
     * @return A JSON object with return messages
     * @since 0.2.0
     */
    public Packet present(HashMap<String, Object> args) {
        if (textAreaCommands != null) {
            this.textAreaCommands.appendText("Present:\n");
            for (String k : args.keySet())
                this.textAreaCommands.appendText(String.format("\t%s = %s\n", k, args.get(k).toString()));
        }
        try {
            double x = ((Double)args.get("x")).doubleValue();
            double y = ((Double)args.get("y")).doubleValue();

            while (!dataSeries.getData().isEmpty())
                dataSeries.getData().remove(0);
            dataSeries.getData().add(new ScatterChart.Data(x, y));

        } catch (Exception ignored) { ; }

        return super.present(args);
    }
  
    //-------------- FXML below here ---

    @FXML
    private Button btnClose;

    @FXML
    private ScatterChart<Double, Double> scatterChartVF;

    private XYChart.Series<Double, Double> dataSeries;

    @FXML
    private TextArea textAreaCommands;

    @FXML
    void initialize() {
        assert btnClose != null : "fx:id=\"btnClose\" was not injected: check your FXML file 'Display.fxml'.";
        assert scatterChartVF != null : "fx:id=\"scatterChartLeft\" was not injected: check your FXML file 'Display.fxml'.";
        assert textAreaCommands != null : "fx:id=\"textAreaCommands\" was not injected: check your FXML file 'Display.fxml'.";

        dataSeries = new XYChart.Series<Double, Double>();
        scatterChartVF.getData().add(dataSeries);
    }

    @FXML
    void actionBtnClose(ActionEvent event) {
        returnToParentScene((Node)event.getSource());
    }

}