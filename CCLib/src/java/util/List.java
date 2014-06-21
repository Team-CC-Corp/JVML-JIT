package java.util;

public interface List<E> extends Collection<E> {
	public E get(int index);
    public E set(int index, E element);
    public void add(int index, E element);
    public E remove(int index);
    public List<E> subList(int fromIndex, int toIndex);

    default public int lastIndexOf(E e) {
    	for (int i = size()-1; i >= 0; --i) {
    		if (get(i) == e) {
    			return i;
    		}
    	}
    	return -1;
    }

    default public int indexOf(E e) {
    	for (int i = 0; i < size(); ++i) {
    		if (get(i) == e) {
    			return i;
    		}
    	}
    	return -1;
    }

    public class UtilityIterator<T> implements Iterator<T> {
    	protected int i = -1;
    	protected List<T> list;

    	public UtilityIterator(List<T> l) {
    		list = l;
    	}

    	@Override
		public boolean hasNext() {
			return i < list.size()-1;
		}

		@Override
		public T next() {
			return list.get(++i);
		}

		@Override
		public void remove() {
			list.remove(i);
		}
    }

    public class LIterator<U> extends UtilityIterator<U> implements ListIterator<U> {
    	public LIterator(List<U> l) {
    		super(l);
    	}

    	public LIterator(List<U> l, int index) {
    		super(l);
    		i = index - 1;
    	}

    	@Override
    	public void add(U e) {
    		list.add(i + 1, e);
    	}

    	@Override
		public boolean hasPrevious() {
			return i > 0;
		}

    	@Override
		public int nextIndex() {
			return i + 1;
		}

    	@Override
		public U previous() {
			return list.get(--i);
		}

    	@Override
		public int previousIndex() {
			return i - 1;
		}

    	@Override
		public void set(U e) {
			list.set(i, e);
		}
    }

    default public ListIterator<E> listIterator() {
    	return new LIterator<E>(this);
    }
    
    default public ListIterator<E> listIterator(int index) {
    	return new LIterator<E>(this, index);
    }



    // Collection
    @Override
	default public boolean contains(E e) {
		for (E item : this) {
			if (item == e) {
				return true;
			}
		}
		return false;
	}

	//Iterable
    @Override
	default public Iterator<E> iterator() {
		return new UtilityIterator<E>(this);
	}
}