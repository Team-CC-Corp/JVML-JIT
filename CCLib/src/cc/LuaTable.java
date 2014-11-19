package cc;
import java.util.Iterator;
import java.util.NoSuchElementException;
//Interface class to Lua.
public final class LuaTable extends NativeObject implements Iterable<LuaTable.TableEntry> {
    public static class TableEntry {
        public Object key,value;
    }
    //Iterates through the array.
    private static class TableIterator implements Iterator<TableEntry> {
        private Object[] data;
        int dataPtr;
        protected TableIterator(Object[] dt)
        {
            data=dt;
            dataPtr=0;
        }
        public boolean hasNext()
        {
            return (dataPtr+1)<data.length;
        }
        public TableEntry next() throws NoSuchElementException
        {
            TableEntry te=new TableEntry();
            if ((dataPtr+1)>=data.length) throw new NoSuchElementException();
            te.key=data[dataPtr++];
            te.value=data[dataPtr++];
            return te;
        }
        public void remove() throws UnsupportedOperationException
        {
            throw new UnsupportedOperationException();
        }
    }
	static {
		System.load("cc/native/LuaTable.lua");
	}
	public LuaTable()
    {
        newTable();
    }
    private native void newTable();//Constructor can't be native.

	public native Object getValue(Object index);
	public native void setValue(Object index,Object value);
    //Return the entries in a simple format:Key,then value,then another key,then another value,etc.
    private native Object[] entries();
    public Iterator<TableEntry> iterator()
    {
        return new TableIterator(entries());
    }

}
