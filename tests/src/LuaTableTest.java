import cc.Computer;
import cc.LuaFunction;
import cc.LuaTable;
public class LuaTableTest {
	public static void TreeDisplay(Object o,String s)
	{
        if (o==null)
		System.out.println(s+"nil");
		if (o instanceof LuaTable)
		{
			System.out.println(s+"-+:table "+o.toString());
			LuaTable luaTable=(LuaTable) o;
            for (LuaTable.TableEntry te : luaTable)
            {
				Object kk=te.key;
				if (kk==null) continue;
				Object oo=te.value;
				if (oo==null) continue;
				TreeDisplay(oo,s+" |-"+kk+":");
			}
            return;
		}
		if (o instanceof LuaFunction)
        {
			System.out.println(s+"LuaFunction");
            return;
        }
		System.out.println(s+"?:"+o.toString());
	}
	public static void main(String[] args)
	{

		LuaFunction print=(LuaFunction)(Computer.getGlobalTable().getValue("print"));
		print.call(new Object[]{"Yep,calling a LuaFunction works."});

		System.out.println("Now testing to see how well reading modem messages will go.");
		String tableCode="return {\"Cat\",{\"Siamese\",\"Tabby\"}}";
		System.out.println("Test code to make the table is:"+tableCode);
		LuaFunction loadstring=(LuaFunction)(Computer.getGlobalTable().getValue("loadstring"));
		System.out.println("Loadstring compiled");
		LuaFunction tablemaker=(LuaFunction)(loadstring.call(new Object[]{tableCode})[0]);
		System.out.println("Table-making function compiled");
        Object[] returns=tablemaker.call(new Object[]{});
 		TreeDisplay((LuaTable)(returns[0]),"");
	}
}
