import java.lang.reflect.Method;

package jvml.application;

public class AppMain extends Thread {
    public Method mainMethod;
    public String[] args;

    public AppMain(Method mainMethod, String[] args) {
        this.mainMethod = mainMethod;
        this.args = args;
    }

    @Override
    public void run() {
        mainMethod.invoke(null, args)
    }
}