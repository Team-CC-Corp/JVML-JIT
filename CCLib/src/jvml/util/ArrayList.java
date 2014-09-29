package jvml.util;


public class ArrayList<E>  {
	private E[] array;

	public ArrayList() {
		initArray();
	}

	native private void initArray();

	//Collection
	native public boolean add(E e);

	native public void clear();

	native public boolean remove(E e);

	public int size() {
		return array.length;
	}

	//List
	native public void add(int index, E element);

	native public E remove(int index);

	public E get(int index) {
		return array[index];
	}

	public E set(int index, E element) {
		E ret = array[index];
		array[index] = element;
		return ret;
	}

	public ArrayList<E> subList(int fromIndex, int toIndex) {
		ArrayList<E> newList = new ArrayList<E>();
		for (int i = fromIndex; i < toIndex; ++i) {
			newList.add(get(i));
		}
		return newList;
	}

	/*public <T extends E> boolean retainAll(Collection<T> c) {
		boolean ret = false;
		Iterator<E> i = iterator();
		while (i.hasNext()) {
			E e = i.next();
			if (!c.contains((T) e)) {
				i.remove();
				ret = true;
			}
		}
		return ret;
	}

	public boolean containsAll(Collection<? extends E> c) {
		for (E e : c) {
			if (!this.contains(e)) {
				return false;
			}
		}
		return true;
	}

	public boolean removeAll(Collection<? extends E> c) {
		boolean ret = false;
		for (E e : c) {
			ret = ret || this.remove(e);
		}
		return ret;
	}*/

	public boolean isEmpty() {
		return size() == 0;
	}

	/*public boolean addAll(Collection<? extends E> c) {
		boolean ret = false;
		for (E e : c) {
			ret = ret || this.add(e);
		}
		return ret;
	}*/

	public Object[] toArray() {
		Object[] arr = new Object[size()];
		int i = 0;
		for (E e : array) {
			arr[i++] = e;
		}
		return arr;
	}

	public <T> T[] toArray(T[] a) {
		int i = 0;
		for (E e : array) {
			a[i++] = (T) e;
		}
		return a;
	}

	public int lastIndexOf(E e) {
		for (int i = size() - 1; i >= 0; --i) {
			if (get(i) == e) {
				return i;
			}
		}
		return -1;
	}

	public int indexOf(E e) {
		for (int i = 0; i < size(); ++i) {
			if (get(i) == e) {
				return i;
			}
		}
		return -1;
	}

	public class UtilityIterator<T> implements Iterator<T> {
		protected int i = -1;
		protected ArrayList<T> list;

		public UtilityIterator(ArrayList<T> l) {
			list = l;
		}

		@Override
		public boolean hasNext() {
			return i < list.size() - 1;
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
		public LIterator(ArrayList<U> l) {
			super(l);
		}

		public LIterator(ArrayList<U> l, int index) {
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

	/*public ListIterator<E> listIterator() {
		return new LIterator<E>(this);
	}

	public ListIterator<E> listIterator(int index) {
		return new LIterator<E>(this, index);
	}*/

	// Collection
	public boolean contains(E e) {
		for (E item : array) {
			if (item == e) {
				return true; 
			}
		}
		return false;
	}

	//Iterable
	/*public Iterator<E> iterator() {
		return new UtilityIterator<E>(this);
	}*/
}