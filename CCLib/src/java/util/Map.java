package java.util;

public interface Map<K, V> {
	
	public void clear();
	
	public default boolean containsKey(K key) {
		return get(key) != null;
	}
	
	public Set<Entry<K, V>> entrySet();
	
	public V put(K key, V value);
	public V get(K key);
	public V remove(K key);
	public int size();

	
	interface Entry<K, V> {
		
		public K getKey();
		public V getValue();
		
	}
}
