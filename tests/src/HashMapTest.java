import java.util.Map;
import java.util.HashMap;

public class HashMapTest {
    public static void main(String[] args) {
        Map<String, Integer> map = new HashMap<>();
        map.put("hello", 50);
        System.out.println(map.get("hello"));
    }
}