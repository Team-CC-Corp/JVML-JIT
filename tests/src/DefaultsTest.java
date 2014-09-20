public class DefaultsTest {
    private static int a;
    private static boolean b;
    private static Object c;

    private int x;
    private boolean y;
    private Object z;

    public static void main(String[] args) {
        new DefaultsTest();
        new DefaultsTest();
    }

    public DefaultsTest() {
        System.out.print("STATIC: ");
        System.out.print(a);
        System.out.print(", ");
        System.out.print(b);
        System.out.print(", ");
        System.out.println(c);

        System.out.print("INSTANCE: ");
        System.out.print(x);
        System.out.print(", ");
        System.out.print(y);
        System.out.print(", ");
        System.out.println(z);

        a = 1;
        b = true;
        c = new Object();

        x = 1;
        y = true;
        z = new Object();

        System.out.print("STATIC: ");
        System.out.print(a);
        System.out.print(", ");
        System.out.print(b);
        System.out.print(", ");
        System.out.println(c);

        System.out.print("INSTANCE: ");
        System.out.print(x);
        System.out.print(", ");
        System.out.print(y);
        System.out.print(", ");
        System.out.println(z);
    }
}