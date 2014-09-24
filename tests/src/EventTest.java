import cc.event.EventHandler;
import cc.event.EventBus;

public class EventTest {
	@EventHandler
	public void test(String s) {
		System.out.println("HEdY");
	}

	public static void main(String[] args) {
		EventBus bus = new EventBus();
		bus.addEventHandler(new EventTest());
		bus.post("HEY");
	}
}