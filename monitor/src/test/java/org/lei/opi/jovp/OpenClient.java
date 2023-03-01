package org.lei.opi.jovp;

import org.lei.opi.core.OpiClient;

import org.junit.jupiter.api.Test;

public class OpenClient {

    @Test
    public void constructOpiClient() {
        OpiClient opiClient = new OpiClient(50002);
        System.out.println("Constructred opiClient...sleeping 5 seconds");
        try { Thread.sleep(5000); } catch (InterruptedException e) { ; }
        opiClient.closeListener();
        System.out.println("Closed opiClient...");
    }
}