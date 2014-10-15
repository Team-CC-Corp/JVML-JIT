public class ThreadTest extends Thread {
    public static void main(String[] args) {
        new ThreadTest("thread 1").start();
        new ThreadTest("thread 2").start();
        //while(true) { Thread.yield(); }
    }

    private String msg;

    public ThreadTest(String msg) {
        this.msg = msg;
    }

    @Override
    public void run() {
        int x = 5;
        while(true) {
            System.out.println(msg);
            Thread.yield();
        }
    }
}