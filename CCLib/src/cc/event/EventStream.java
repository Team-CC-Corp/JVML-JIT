package cc.event;

import java.util.Iterator;

public abstract class EventStream implements Iterable<Event> {
	public abstract Event pullEvent();
	public abstract Event pullEvent(String filter);

	public Iterator<Event> iterator() {
		return new Iterator<Event>() {
			private Event next;
			private Event last;

			@Override
			public boolean hasNext() {
				next = pullEvent();
				return next != null;
			}

			@Override
			public Event next() {
				if (last == next) {
					if (!hasNext()) {
						return null;
					}
				}
				last = next;
				return next;
			}

			@Override
			public void remove() {
			}
		};
	}
}