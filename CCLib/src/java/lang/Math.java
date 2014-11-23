package java.lang;

public class Math {
    native public static double pow(double a, double b);

    public static long min(long a, long b) {
        if (a < b)
            return a;
        return b;
    }

    public static double abs(double a) {
        if (a < 0)
            return -a;
        return a;
    }
}