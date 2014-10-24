package cc.event;

import cc.peripheral.PeripheralNotFoundException;

public class EventLoop implements Runnable {
    private EventBus bus;
    private EventStream stream;
    private boolean shouldBreak = false;

    public EventLoop(EventBus bus, EventStream stream) {
        this.bus = bus;
        this.stream = stream;
    }

    public EventLoop(EventBus bus) {
        this(bus, new PullEventStream());
    }

    public EventLoop(EventStream stream) {
        this(new EventBus(), stream);
    }

    public EventLoop() {
        this(new EventBus(), new PullEventStream());
    }

    public EventBus eventBus() {
        return bus;
    }

    public EventStream eventStream() {
        return stream;
    }

    public void breakLoop() {
        shouldBreak = true;
    }

    @Override
    public void run() {
        for (Event e : stream) {
            bus.post(e);
            if (e.type.equals("char")) {
                char c = ((String)e.getArgument(0)).toCharArray()[0];
                bus.post(new CharEvent(c));
            } else if (e.type.equals("key")) {
                bus.post(Keys.getKey((Integer)e.getArgument(0)));
            } else if (e.type.equals("paste")) {
                bus.post(new PasteEvent((String)e.getArgument(0)));
            } else if (e.type.equals("timer")) {
                bus.post(new TimerEvent((Integer)e.getArgument(0)));
            } else if (e.type.equals("alarm")) {
                bus.post(new AlarmEvent((Integer)e.getArgument(0)));
            } else if (e.type.equals("redstone")) {
                bus.post(new RedstoneEvent());
            } else if (e.type.equals("terminate")) {
                bus.post(new TerminateEvent());
            } else if (e.type.equals("disk")) {
                bus.post(new DiskEvent.DiskInsertEvent((String)e.getArgument(0)));
            } else if (e.type.equals("disk_eject")) {
                bus.post(new DiskEvent.DiskEjectEvent((String)e.getArgument(0)));
            } else if (e.type.equals("peripheral")) {
                bus.post(new PeripheralEvent.PeripheralAttachEvent((String)e.getArgument(0)));
            } else if (e.type.equals("peripheral_detach")) {
                bus.post(new PeripheralEvent.PeripheralDetachEvent((String)e.getArgument(0)));
            } else if (e.type.equals("mouse_click")) {
                MouseEvent.MouseButton b = MouseEvent.MouseButton.getButton((Integer)e.getArgument(0));
                bus.post(new MouseEvent.MouseClickEvent(b, (Integer)e.getArgument(1), (Integer)e.getArgument(2)));
            } else if (e.type.equals("mouse_scroll")) {
                MouseEvent.MouseScrollDirection s = MouseEvent.MouseScrollDirection.getScrollDirection((Integer)e.getArgument(0));
                bus.post(new MouseEvent.MouseScrollEvent(s, (Integer)e.getArgument(1), (Integer)e.getArgument(2)));
            } else if (e.type.equals("mouse_drag")) {
                MouseEvent.MouseButton b = MouseEvent.MouseButton.getButton((Integer)e.getArgument(0));
                bus.post(new MouseEvent.MouseDragEvent(b, (Integer)e.getArgument(1), (Integer)e.getArgument(2)));
            } else if (e.type.equals("monitor_touch")) {
                bus.post(new MonitorEvent.MonitorTouchEvent((String)e.getArgument(0),
                    (Integer)e.getArgument(1),
                    (Integer)e.getArgument(2)));
            } else if (e.type.equals("monitor_resize")) {
                try {
                    bus.post(new MonitorEvent.MonitorResizeEvent((String)e.getArgument(0)));
                } catch(PeripheralNotFoundException exc) {
                }
            } else if (e.type.equals("term_resize")) {
                bus.post(new TermResizeEvent());
            } else if(e.type.equals("modem_message")) {
                bus.post(new ModemMessageEvent((String)e.getArgument(0),
                        (Integer)e.getArgument(1),
                        (Integer)e.getArgument(2),
                        (String)e.getArgument(3),
                        (Integer)e.getArgument(4)));
            }

            if (shouldBreak) {
                shouldBreak = false;
                break;
            }
        }
    }
}