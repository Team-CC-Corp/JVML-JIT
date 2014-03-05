import java.io.*;
import cc.*;

public class Test {
    public static void main(String[] args) {
        float start = Computer.getClock();
        for(int i = 0; i < 100000; i++);
        System.out.println(Computer.getClock() - start);
    }
}