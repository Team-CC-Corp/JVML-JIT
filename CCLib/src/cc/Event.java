package cc;
import java.io.*;

public class Event {
    String type;
    Object[] args;
    
    public Event(String type, Object[] args) {
        this.type = type;
        this.args = args;
    }

    public String getType() {
        return type;
    }

    public Object getArgument(int index) {
        return args[index];
    }
}
