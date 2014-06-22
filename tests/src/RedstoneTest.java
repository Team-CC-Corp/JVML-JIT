import cc.redstone.IRedstone;
import cc.redstone.SidedRedstone;

public class RedstoneTest {
	public static void main(String[] args) {
		IRedstone rs = new SidedRedstone("back");
		rs.setOutput(true);
		System.out.println(rs.getOutput());
		rs.setOutput(false);
		System.out.println(rs.getOutput());
	}
}