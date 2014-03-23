public class Test {
    public static void main(String[] args) {
        //Integer intt = new Integer(0xBEEFBABE);
        //Object[] ints = new Object[4];
        //ints[0] = "swag";
        Test test = new Test();
    }

    public Test() {
        String string = (String) test();
        System.out.println(string);
    }

    public Object test() {
        return "hello";
    }
}