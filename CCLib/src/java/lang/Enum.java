package java.lang;

public abstract class Enum<E extends Enum<E>> {
    private final String name;

    public final String name() {
        return name;
    }

    private final int ordinal;

    public final int ordinal() {
        return ordinal;
    }

    protected Enum(String name, int ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public String toString() {
        return name;
    }

    public final boolean equals(Object other) {
        return this==other;
    }

    private static native <T extends Enum<T>> T _valueOf(Class<T> enumType, String name);
    public static <T extends Enum<T>> T valueOf(Class<T> enumType, String name) {
        T result = _valueOf(enumType, name);
        if (result != null)
            return result;
        if (name == null)
            throw new NullPointerException("Name is null");
        throw new IllegalArgumentException(
            "No enum constant " + enumType.getName() + "." + name);
    }
    
    public native final Class<E> getDeclaringClass();
    
}