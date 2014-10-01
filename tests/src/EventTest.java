import cc.event.EventHandler;
import cc.event.EventLoop;
import cc.event.TimerEvent;
import cc.event.Event;
import cc.Computer;

public class EventTest {
	private EventLoop loop;
	private int id;

	public EventTest() {
		loop = new EventLoop();
		loop.eventBus().addEventHandler(this);
		System.out.println("Starting timer");
		id = Computer.startTimer(5);
	}

	@EventHandler
	public void test(TimerEvent e) {
		if (e.id == id) {
			System.out.println("Timer Found");
			loop.breakLoop();
		}
	}

	public static void main(String[] args) {
		new EventTest().loop.run();
	}
}