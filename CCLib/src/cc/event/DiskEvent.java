package cc.event;

public abstract class DiskEvent {
    public final String side;

    public DiskEvent(String side) {
        this.side = side;
    }

    public static class DiskInsertEvent extends DiskEvent {
        public DiskInsertEvent(String side) {
            super(side);
        }
    }

    public static class DiskEjectEvent extends DiskEvent {
        public DiskEjectEvent(String side) {
            super(side);
        }
    }
}