class A {
    public void m(){
        System.out.println("A.m");
    }
}

class B extends A {
    @Override
    public void m() {
        super.m();
        System.out.println("B.m");
    }

    public void v() {
        m();
    }
}

public class Test {
    public static void main(String[] args) {
        //Integer intt = new Integer(0xBEEFBABE);
        //Object[] ints = new Object[4];
        //ints[0] = "swag";
        Test test = new Test();
        A obj = new B();
        obj.m();
        ((B) obj).v();
    }

    public Test() {
        String string = (String) test();
        System.out.println(string);
    }

    public Object test() {
        return "hello";
    }
}