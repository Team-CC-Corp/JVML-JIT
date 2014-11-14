package cc;

public final class LuaFunction extends NativeObject {
	static {
		System.load("cc/native/LuaFunction.lua");
	}
	private LuaFunction()
	{
	}
	public native Object[] call(Object[] args);
}
