import java.util.Iterator;

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
        for (String s : args) {
            System.out.println(s+": String Building");
        }
        System.out.println(cc.Computer.getTime());
        Test test = new Test();
        A obj = new B();
        ((B) obj).v();

        System.out.println(String.class.getName());

        Iterable<String> i = new Iterable<String>() {
            @Override
            public Iterator<String> iterator() {
                return new Iterator<String>() {
                    private String[] strs = {"Test 1", "Test 2"};
                    private int i = 0;

                    @Override
                    public boolean hasNext() {
                        return i < strs.length;
                    }
                    @Override
                    public String next() {
                        return strs[i++];
                    }
                    @Override
                    public void remove() {}
                };
            }
        };

        for (String s : i) {
            System.out.println(s);
        }
        System.out.println(i instanceof Iterable);
    }

    Object obj;

    public Test() {
        test();
    }

    public void test() {
        obj = "hello";
    }
}