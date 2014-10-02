package cc.event;

import cc.Computer;

public class RawPullEventStream extends EventStream {
    @Override
    public Event pullEvent() {
        return Computer.pullEventRaw();
    }

    @Override
    public Event pullEvent(String filter) {
        return Computer.pullEventRaw(filter);
    }
}