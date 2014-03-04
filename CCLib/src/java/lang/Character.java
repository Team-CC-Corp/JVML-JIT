package java.lang;

public class Character {
    private final char value;

    public static Character valueOf(char value) {
        return new Character(value);
    }

    public Character(char value) {
        this.value = value;
    }

    public String toString() {
        return new String(new char[] {value});
    }
}