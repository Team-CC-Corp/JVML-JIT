package cc;

public final class LuaFunction {
    private Object NATIVE_handle;//Warning:DO NOT USE THIS.
	static {
		System.load("cc/native/LuaFunction.lua");
	}
	private LuaFunction()
	{
	}
	public native Object[] call(Object[] args);
}
