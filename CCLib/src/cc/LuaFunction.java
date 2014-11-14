package cc;

public final class LuaFunction extends NativeObject {
	static {
		System.load("cc/native/LuaFunction.lua");
	}
	private LuaFunction()
	{
	}
    public LuaFunction(String code)
    {
        compileCode(code);
    }
    private native void compileCode(String code);
	public native Object[] call(Object[] args);
}
