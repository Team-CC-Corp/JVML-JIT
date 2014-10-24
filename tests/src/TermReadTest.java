public class TermReadTest
{
    public static void main(String[] args) throws Throwable
    {
        char c = (char)System.in.read();
        while (c != '\n') {
            System.out.println("read: " + c);
            c = (char)System.in.read();
        }
    }
}