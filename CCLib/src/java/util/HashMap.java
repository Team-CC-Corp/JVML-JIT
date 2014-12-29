package java.util;

import java.util.Map;

public class HashMap<K, V> implements Map<K, V> {

    @Override
    public native void clear();

    @Override
    public Set<Map.Entry<K, V>> entrySet() {
        Map.Entry<K, V>[] entrys = entryArray();
        return new EntrySet(entrys);
    }
    
    private class EntrySet implements Set<Map.Entry<K, V>> {

        private final Map.Entry<K, V>[] elements;
        
        EntrySet(Map.Entry<K, V>[] elements) {
            this.elements = elements;
        }
        
        @Override
        public boolean contains(Map.Entry<K, V> e) {
            if(!(e instanceof Map.Entry<?, ?>)) {
                return false;
            }
            for(Map.Entry<K, V> element : elements) {
                if(e.equals(element)) {
                    return true;
                }
            }
            return false;
        }

        @Override
        public boolean add(Map.Entry<K, V> e) {
            return false;
        }

        @Override
        public void clear() {
            HashMap.this.clear();
        }

        @Override
        public Iterator<Map.Entry<K, V>> iterator() {
            return new EntrySetIterator();
        }

        @Override
        public boolean remove(Map.Entry<K, V> e) {
            return false;
        }

        @Override
        public int size() {
            return HashMap.this.size();
        }
        
        private class EntrySetIterator implements Iterator<Map.Entry<K, V>> {

            private int i;
            
            @Override
            public boolean hasNext() {
                return i < elements.length - 1;
            }

            @Override
            public java.util.Map.Entry<K, V> next() {
                i++;
                return elements[i];
            }

            @Override
            public void remove() {
                return;
            }
        }
        
    }
    
    private native Map.Entry<K, V>[] entryArray();
    
    @Override
    public native int size();

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
    
    class Entry<K, V> implements Map.Entry<K, V> {

        private K key;
        private V value;
        
        @Override
        public K getKey() {
            return key;
        }

        @Override
        public V getValue() {
            return value;
        }
        
    }

}
