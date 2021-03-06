package dk.statsbiblioteket.deck.client;

import dk.statsbiblioteket.deck.Constants;
import dk.statsbiblioteket.deck.rmiInterface.compute.Compute;
import org.apache.log4j.Logger;

import java.net.MalformedURLException;
import java.rmi.Naming;
import java.rmi.NotBoundException;
import java.rmi.RMISecurityManager;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;

/**
 * Created by IntelliJ IDEA.
 * User: bytestroop
 * Date: Nov 23, 2006
 * Time: 11:12:46 AM
 * To change this template use File | Settings | File Templates.
 */
public class RecorderCtrl {

    //"start","record",userName,clientHostName,encoderName,cardName,captureFormat,captureLength,captureSize,fileName

    static Logger log = Logger.getLogger(RecorderCtrl.class.getName());

    //private static String prop;
    //private static int propInt;
    //private static final String configure = Constants.DEFAULT_CLIENTCONF_DIRECTORY + "/adminRMIClient.xml";
    //private static final String configureServer = Constants.DEFAULT_SERVERCONF_DIRECTORY + "/server.xml";

    final int encoderRMIport = Constants.DEFAULT_RMI_CLIENT_PORT ;
    
    private String command;
    private String recordType;
    private String userName;
    private String clientHostName;
    private String encoderName;
    private int cardName;
    private String channelID;
    private int frameWidth;
    private int frameHeight;
    private String captureFormat;
    private int captureBitrate;
    private int captureMaxBitrate;
    private String fileName;
    private long startTime;
    private long origStartDate;
    private long origStartTime;
    private long captureTime;
    private int captureSize;
    private String extension;


    /**
     *
     * @param encoderName
     */
    public RecorderCtrl(String encoderName) {
        this.encoderName = encoderName;
        this.extension = Constants.DEFAULT_EXTENSION;

        //log.debug("File Name" + fileName);
    };

     /**
     * Construct a task to operate the server to the specified
     * control command.
     */
     public RecorderCtrl(String command,
                        String recordType,
                        String userName,
                        String clientHostName,
                        String encoderName,
                        int cardName,
                        String channelID,
                        String captureFormat,
                        String fileName,
                        long origStartDate,
                        long captureTime,
                        int captureSize) {

        this.command = command;
        this.recordType = recordType;
        this.userName = userName;
        this.clientHostName = clientHostName;
        this.encoderName = encoderName;
        this.cardName = cardName;
        this.channelID = channelID;
        this.captureFormat = captureFormat;
        this.fileName = fileName;
        this.origStartDate = origStartDate;
        this.captureTime= captureTime;
        this.captureSize= captureSize;

        log.debug("RMI_Port: " + encoderRMIport);
        log.debug("RMI_HOST: " + encoderName);
        log.debug("on Encoder: " + command);
        log.debug("Type: " + recordType);
        log.debug("Person: " + userName);
        log.debug("from Hostname: " + clientHostName);
        log.debug("on Encoder: " + encoderName);
        log.debug("on Device: " + cardName);

        log.debug("Format: " + captureFormat);

        log.debug("File name: " + fileName);
        log.debug("Expected duration: " + captureTime);
        log.debug("Expected size: " + captureSize);
        log.debug("Recording Orig: " + origStartDate);
     }


    /** This is ignorant towards the available streamer application
     * Streamserver and encoder share the same host
     *
     * @throws java.rmi.RemoteException
     */
    public String remoteControl() throws RemoteException {

        System.out.println("Bind dk.statsbiblioteket.deck.client.RecorderCtrl");
        if (System.getSecurityManager() == null) {
                System.setSecurityManager(new RMISecurityManager());
        }

        LocateRegistry.getRegistry (encoderRMIport);

        String name = "//" + encoderName + ":" +encoderRMIport+ "/Compute";
        System.out.println("Client looks up name address: " + name);

        Compute comp = null;
        try {
            comp = (Compute) Naming.lookup(name);
        } catch (NotBoundException nb) {
            System.out.println("Not Bound");
            nb.printStackTrace();
            throw new RuntimeException(nb);
        } catch (MalformedURLException murl) {
            System.out.println("Check URL");
            murl.printStackTrace();
            throw new RuntimeException(murl);
        } catch (RemoteException re) {
            re.printStackTrace();
            throw new RuntimeException(re);
        }

        System.out.println("Execute the Command...");

        Recorder task = new Recorder(command,
                        recordType,
                        userName,
                        clientHostName,
                        encoderName,
                        cardName,
                        channelID,
                        captureFormat,
                        fileName,
                        captureTime,
                        captureSize,
                        origStartDate
        );

        String ctrl = null;
        try {
            ctrl = (String) (comp.executeTask(task));
            System.out.println(" Returns from the shell: " + ctrl);
            System.out.println("done");
            
        } catch (RemoteException e1) {
            log.error(" Failure, Task not executed! ", e1);
            e1.printStackTrace();
        }
        //System.out.println(ctrl);
        return ctrl;
    }

}
