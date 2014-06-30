package java.lang;

public class Character {
    private final char value;
    public static final Class<Character>  TYPE = (Class<Character>) Class.getPrimitiveClass("char");

    public static Character valueOf(char value) {
        return new Character(value);
    }

    public Character(char value) {
        this.value = value;
    }

    public String toString() {
        return new String(new char[] {value});
    }

    public char charValue() {
        return value;
    }

    @Override
    public boolean equals(Object obj) {
        if(obj instanceof Character) {
            return value == ((Character)obj).charValue();
        }
        return false;
    }
}