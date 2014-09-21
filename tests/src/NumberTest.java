public class NumberTest {
    public static void main(String[] args) {
        long a;
        int b;
        float c;
        double d;

        // Division and negatives.
        a = -16L;
        a /= 4L;
        System.out.println(a);

        // Over/underflow.
        a = 9223372036854775807L;
        a += 9223372036854775807L;
        System.out.println(a);

        a = 9223372036854775806L;
        a *= 235L;
        System.out.println(a);

        a = -9223372036854775808L;
        a -= 9223372036854775807L;
        System.out.println(a);

        a = -9223372036854775802L;
        a *= 235L;
        System.out.println(a);

        // Conversion.
        a = 5000L;
        b = (int)a;
        c = (float)a;
        d = (double)a;

        System.out.println(a);
        System.out.println(b);
        System.out.println(c);
        System.out.println(d);

        // Conversion (with over/underflow for ints).
        a = 132938835129648L;
        b = (int)a;
        c = (float)a;
        d = (double)a;

        System.out.println(a);
        System.out.println(b);
        System.out.println(c);
        System.out.println(d);

        // Conversion to long.

        b = 1000;
        c = 2000;
        d = 3000;

        a = (long)b * 2147483648L;
        System.out.println(a);

        a = (long)c * 2147483648L;
        System.out.println(a);

        a = (long)d * 2147483648L;
        System.out.println(a);
    }
}