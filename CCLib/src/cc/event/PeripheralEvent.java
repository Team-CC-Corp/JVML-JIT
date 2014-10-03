package cc.event;

public abstract class PeripheralEvent {
    public final String side;

    public PeripheralEvent(String side) {
        this.side = side;
    }

    public static class PeripheralAttachEvent extends PeripheralEvent {
        public PeripheralAttachEvent(String side) {
            super(side);
        }
    }

    public static class PeripheralDetachEvent extends PeripheralEvent {
        public PeripheralDetachEvent(String side) {
            super(side);
        }
    }
}