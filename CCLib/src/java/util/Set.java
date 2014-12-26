package java.util;

public interface Set<E> extends Collection<E> {
	
	public boolean add(E e);
	public void clear();
	public Iterator<E> iterator();
	public boolean remove(E e);
	public int size();

}
