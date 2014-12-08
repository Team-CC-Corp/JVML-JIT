package java.util;

public class HashMap<K, V> implements Map<K, V> {
	
	/**
	 * Puts a object into the map. If the key is null, it doesn't put a value at all.
	 * If there is already a mapping, the existing value is overwritten.
	 * 
	 * @param key
	 * @param value
	 * 
	 * @return the previous value
	 */
	@Override
	public V put(K key, V value) {
		if(key == null) {
			return null;
		}
		Object o = putHash(key, key.hashCode(), value);
		return o == null ? null : (V) o;
	}
	
	private native Object putHash(Object key, int keyHash, Object value);

	/**
	 * Returns the value corresponding with the given key. If the key is null, return null.
	 * If there is no matching key, return null. Two keys are considered matching, if they aure equal
	 * by the Object.equals() method.
	 * 
	 * @param key
	 */
	public V get(Object key) {
		if(key == null) {
			return null;
		}
		Object o =  getHash(key, key.hashCode());
		return o == null ? null : (V) o;
	}
	
	private native Object getHash(Object key, int keyHash);

	/**
	 * Removes the item corresponding to this key from the list. This method has the same effect as calling put(key, null)
	 * 
	 * @param key
	 */
	@Override
	public V remove(K key) {
		return put(key, null);
	}

}
