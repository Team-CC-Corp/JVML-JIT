package jvml.util;

public interface ListIterator<E> extends Iterator<E> {
	public void add(E e);
	public boolean hasPrevious();
	public int nextIndex();
	public E previous();
	public int previousIndex();
	public void set(E e);
}