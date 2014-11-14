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
			System.out.println(s+"-+:"+o.toString());
			LuaTable luaTable=(LuaTable) o;
            for (LuaTable.TableEntry te : luaTable)
            {
				Object kk=te.key;
				if (kk==null) continue;
				Object oo=te.value;
				if (oo==null) continue;
				Object oo2=luaTable.getValue(kk);
                if (!oo.equals(oo2)) throw new RuntimeException("Equality test failure-check equals,getValue,entries.");
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
        //Do a basic test on LuaTable and LuaFunction.If this fails,it's completely broken.
		LuaFunction print=(LuaFunction)(Computer.getGlobalTable().getValue("print"));
		print.call(new Object[]{"Yep,calling a LuaFunction works."});

		System.out.print("Creating table and displaying");
        //Create a multilevel tree using LuaTable.
        LuaTable cat=new LuaTable();
        cat.setValue(1,"Meow");
        cat.setValue(2,"Nyan");
		System.out.print(".");
        LuaTable dog=new LuaTable();
        dog.setValue(1,"Woof");
        dog.setValue(2,"Bark");
		System.out.print(".");
        LuaTable lt=new LuaTable();
        //Both pairs should show up.
        lt.setValue(1,cat);
        lt.setValue(2,dog);
        lt.setValue("Cat",cat);
        lt.setValue("Dog",dog);
		System.out.println(".");
 		TreeDisplay(lt,"");
	}
}
