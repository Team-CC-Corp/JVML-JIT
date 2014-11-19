package java.util;

public interface Iterator<E> {
    public boolean hasNext();
    public E next() throws NoSuchElementException;
    public void remove() throws UnsupportedOperationException;
}
