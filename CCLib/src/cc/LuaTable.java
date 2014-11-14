package cc;

public final class LuaTable {
    private Object NATIVE_handle;//Warning:DO NOT USE THIS.
	static {
		System.load("cc/native/LuaTable.lua");
	}
	private LuaTable()
	{
	}
	public native Object getValue(Object index);
}
