import java.io.*;
import cc.*;

public class Test {
    public static void main(String[] args) {
        System.out.println('k');
        for(int i = 0; i < 10; i++) {
            Event event = Computer.pullEvent("key");
            System.out.println(event.getArgument(0));
        }
    }
}