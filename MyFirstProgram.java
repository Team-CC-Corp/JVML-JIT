import java.io.*;
import cc.*;

class Test {
	public void m() {
		System.out.println("Test.m");
	}
}

class Yo extends Test {
	public Yo() {
		System.out.println("Yo constructor");
	}

	@Override public void m() {
		super.m();
		System.out.println("Yo.m");
	}
	public void v() {
		m();
	}
}

public class MyFirstProgram {
	/** Print a hello message */ 
	public static void main(String[] args) {
		int a = getNumber();
		System.out.println("Hello, world!");
		System.out.println(Computer.isTurtle());
		System.out.println(a+a);
		new Yo().v();
	}
	
	public static int getNumber()
	{
		return 6;
	}

	static {
		System.out.println("Test static");
	}
}
