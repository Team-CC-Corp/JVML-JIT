import cc.Computer;
import cc.LuaFunction;
public class LuaTableTest {
	public static void main(String[] args)
	{
		LuaFunction print=(LuaFunction)(Computer.getGlobalTable().getValue("print"));
		print.call(new String[]{"Yep,calling a LuaFunction works."});
	}
}
