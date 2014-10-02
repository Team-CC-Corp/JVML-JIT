package cc.event;

import cc.Computer;

public class PullEventStream extends EventStream {
    @Override
    public Event pullEvent() {
        return Computer.pullEvent();
    }

    @Override
    public Event pullEvent(String filter) {
        return Computer.pullEvent(filter);
    }
}