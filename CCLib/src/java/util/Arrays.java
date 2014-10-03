package java.util;

public class Arrays {
    public static <T> List<T> asList(T[] arr) {
        List<T> list = new ArrayList<T>();
        for (T t : arr) {
            list.add(t);
        }
        return list;
    }
}