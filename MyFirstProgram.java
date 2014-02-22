import java.io.*;
import cc.*;
class MyFirstProgram {
	/** Print a hello message */ 
	public static void main(String[] args) {
		int a = getNumber();
		System.out.println("Hello, world!");
		System.out.println(Computer.isTurtle());
		System.out.println(a+a);
	}
	
	public static int getNumber()
	{
		return 6;
	}
}
