package java.lang;

public class Thread implements Runnable {
    private Runnable target;

    public Thread() { }

    public Thread(Runnable target) {
        this.target = target;
    }

    public void start() {
        start0();
    }

    @Override
    public void run() {
        if(target != null) {
            target.run();
        }
    }

    private native void start0();
}