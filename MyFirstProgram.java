import java.io.*;
import cc.*;

class Test {
	public void m() {
		System.out.println("Test");
	}
}

class Yo extends Test {
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
}
