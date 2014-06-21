package java.util;

public class ArrayList<E> implements List<E> {
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

    public List<E> subList(int fromIndex, int toIndex) {
    	List<E> newList = new ArrayList<E>();
    	for (int i = fromIndex; i < toIndex; ++i) {
    		newList.add(get(i));
    	}
    	return newList;
    }
}