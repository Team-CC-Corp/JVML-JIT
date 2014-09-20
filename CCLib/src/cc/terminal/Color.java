package cc.terminal;

public enum Color {
	WHITE(1),
	ORANGE(2),
	MAGENTA(4),
	LIGHTBLUE(8),
	YELLOW(16),
	LIME(32),
	PINK(64),
	GRAY(128),
	LIGHTGRAY(256),
	CYAN(512),
	PURPLE(1024),
	BLUE(2048),
	BROWN(4096),
	GREEN(8192),
	RED	(16384),
	BLACK(32768);

	public final int intValue;
	Color(int n) {
		this.intValue = n;
	}
}