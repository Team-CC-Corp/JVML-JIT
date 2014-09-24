package cc.event;

import java.lang.reflect.Method;
import java.util.ArrayList;

public class EventBus {
	private class Handler {
		private final Object o;
		private final Method m;

		private Handler(Object o, Method m) {
			this.o = o;
			this.m = m;
		}
	}

	private ArrayList<Handler> handlers = new ArrayList<>();

	public void addEventHandler(Object o) {
		for (Method m : o.getClass().getMethods()) {
			if (m.getAnnotation(EventHandler.class) != null && m.getParameterCount() == 1) {
				handlers.add(new Handler(o, m));
			}
		}
	}

	public void post(Object o) {
		Class<?> cls = o.getClass();
		for (Handler h : handlers) {
			Class<?>[] params = h.m.getParameterTypes();
			if (params[0].isAssignableFrom(cls)) {
				h.m.invoke(o, h.o);
			}
		}
	}
}