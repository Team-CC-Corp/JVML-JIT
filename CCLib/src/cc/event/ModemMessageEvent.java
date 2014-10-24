package cc.event;

/**
 * Created by sci4me on 10/24/14.
 */
public class ModemMessageEvent extends PeripheralEvent {
    public final int senderChannel;
    public final int replyChannel;
    public final String message;
    public final int distance;

    public ModemMessageEvent(String modemSide, int senderChannel, int replyChannel, String message, int distance) {
        super(modemSide);
        this.senderChannel = senderChannel;
        this.replyChannel = replyChannel;
        this.message = message;
        this.distance = distance;
    }
}
