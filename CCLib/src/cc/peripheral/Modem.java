package cc.peripheral;

/**
 * Created by sci4me on 10/24/14.
 */
public class Modem extends Peripheral {
    public Modem(String id) throws PeripheralNotFoundException {
        super(id);
    }

    public boolean isOpen(int channel) {
        assert (channel > 0);
        assert (channel < 65535);

        Object[] results = this.call("isOpen", channel);
        assert (results.length == 1);
        assert (results[0] instanceof Boolean);
        return ((Boolean) results[0]).booleanValue();
    }

    public void open(int channel) {
        assert (channel > 0);
        assert (channel < 65535);

        this.call("open", channel);
    }

    public void close(int channel) {
        assert (channel > 0);
        assert (channel < 65535);

        this.call("close", channel);
    }

    public void closeAll() {
        this.call("closeAll");
    }

    public void transmit(int channel, int replyChannel, String message) {
        assert (channel > 0);
        assert (channel < 65535);

        assert (replyChannel > 0);
        assert (replyChannel < 65535);

        this.call("transmit", channel, replyChannel, message);
    }

    public boolean isWireless() {
        Object[] results = this.call("isWireless");
        assert (results.length == 1);
        assert (results[0] instanceof Boolean);
        return ((Boolean) results[0]).booleanValue();
    }
}