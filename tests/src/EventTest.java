import cc.event.EventHandler;
import cc.event.EventBus;

class Handler {
	@EventHandler
	public void handleString(String s) {
		System.out.println(s + " in handleString");
	}

	@EventHandler
	public void handleDouble(Double d) {
		System.out.println("Handling double" + d);
	}
}

public class EventTest {
	@EventHandler
	public void test(String s) {
		System.out.println(s);
	}

	public static void main(String[] args) {
		EventBus bus = new EventBus();
		bus.addEventHandler(new EventTest());
		bus.addEventHandler(new Handler());
		bus.post("Testing");
		bus.post((Double)3.0);
	}
}