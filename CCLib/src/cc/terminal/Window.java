package cc.terminal;

import java.util.ArrayList;
import java.util.Iterator;

// Type parameter is not necessary, only a convenience.
public class Window<T extends Terminal> implements Terminal {
	public final T parent;
	private final boolean autoRedraw;

	private final int parentXPos, parentYPos, width, height;
	private int cursorX, cursorY;
	private Color currentTextColor, currentBackgroundColor;

	ArrayList<Line> lines;

	public Window(T parent, int x, int y, int width, int height, Color tc, Color bg, boolean autoRedraw) {
		this.parent = parent;
		this.parentXPos = x;
		this.parentYPos = y;
		this.width = width;
		this.height = height;
		this.currentTextColor = tc;
		this.currentBackgroundColor = bg;
		this.autoRedraw = autoRedraw;

		lines = new ArrayList<Line>();
		for (int i = 0; i < height; ++i) {
			setCursor(0, i);
			lines.add(null);
			clearLine();
		}
		setCursor(0, 0);
	}

	public Window(T parent, int x, int y, int width, int height, boolean autoRedraw) {
		this(parent, x, y, width, height, Color.WHITE, Color.BLACK, autoRedraw);
	}

	public Window(T parent, int x, int y, int width, int height) {
		this(parent, x, y, width, height, true);
	}

	public void redraw() {
		for (int i = 0; i < lines.size(); ++i) {
			for (LineSegment seg : lines.get(i).segments) {
				parent.setCursor(parentXPos + seg.xPos, parentYPos + i);
				parent.setColor(seg.textColor, seg.backgroundColor);
				parent.write(seg.text.toString());
			}
		}
		parent.setCursor(parentXPos + cursorX, parentYPos + cursorY);
	}

	@Override
	public void write(char[] c) {
		Line l = lines.get(cursorY);
		cursorX += c.length;
		l.setText(c, currentTextColor, currentBackgroundColor, cursorX - c.length);
	}

	@Override
	public void write(char c) {
		write(new char[]{c});
	}

	@Override
	public void clearLine() {
		Line newLine = new Line();
		char[] c = new char[width];
		for (int i = 0; i < c.length; ++i) {
			c[i] = ' ';
		}
		lines.set(cursorY, newLine);
		newLine.setText(c, currentTextColor, currentBackgroundColor, 0);
	}

	@Override
	public void scroll(int n) {
		for (int i = 0; i < lines.size() - n; ++i) {
			lines.set(i, lines.get(i + n));
		}
		lines.set(lines.size() - 1, new Line());
	}

	@Override
	public int getCursorX() {
		return cursorX;
	}

	@Override
	public int getCursorY() {
		return cursorY;
	}

	@Override
	public void setCursor(int x, int y) {
		cursorX = x;
		cursorY = y;
	}

	@Override
	public boolean isColor() {
		return parent.isColor();
	}

	@Override
	public int width() {
		return width;
	}

	@Override
	public int height() {
		return height;
	}

	@Override
	public void setTextColor(Color c) {
		currentTextColor = c;
	}

	@Override
	public void setBackgroundColor(Color c) {
		currentBackgroundColor = c;
	}

	private class LineSegment {
		private Color textColor, backgroundColor;
		private int xPos;
		private StringBuilder text = new StringBuilder();

		public LineSegment(Color t, Color b, int x) {
			this.textColor = t;
			this.backgroundColor = b;
			this.xPos = x;
		}
	}

	private class Line {
		private ArrayList<LineSegment> segments = new ArrayList<>();

		private void setText(char[] c, Color tc, Color bg, int x) {
			if (c.length == 0) {
				return;
			}

			LineSegment leadingOverlap = null;
			LineSegment trailingOverlap = null;
			
			Iterator<LineSegment> li = segments.iterator();
			while(li.hasNext()) {
				LineSegment seg = li.next();
				int segX = seg.xPos;
				int segLen = seg.text.length();
				if (segX < x && segX + segLen > x) {
					leadingOverlap = seg;
				} else if(segX >= x && segX + segLen <= c.length + x) {
					li.remove();
				} else if(segX >= x && segX < x + c.length) {
					trailingOverlap = seg;
				}
			}

			if (leadingOverlap != null && trailingOverlap != null && leadingOverlap == trailingOverlap) {
				int start = x - leadingOverlap.xPos;
				int end = c.length - (leadingOverlap.xPos - x);
				leadingOverlap.text.delete(start, end);
				if (leadingOverlap.textColor == tc && leadingOverlap.backgroundColor == bg) {
					leadingOverlap.text.insert(start, c);
				} else {
					LineSegment newSeg = new LineSegment(tc, bg, x);
					newSeg.text.append(c);
					segments.add(newSeg);

					String newTail = leadingOverlap.text.substring(start);
					leadingOverlap.text.delete(start, leadingOverlap.text.length());
					LineSegment newTailSeg = new LineSegment(leadingOverlap.textColor, leadingOverlap.backgroundColor, end);
					newTailSeg.text.append(newTail);
					segments.add(newTailSeg);
				}
			} else if (leadingOverlap != null && trailingOverlap != null) {
				leadingOverlap.text.delete(x - leadingOverlap.xPos, leadingOverlap.text.length());
				trailingOverlap.text.delete(0, c.length - (trailingOverlap.xPos - x));
				trailingOverlap.xPos += c.length - (trailingOverlap.xPos - x);

				if (leadingOverlap.textColor == trailingOverlap.textColor && leadingOverlap.textColor == tc &&
					leadingOverlap.backgroundColor == trailingOverlap.backgroundColor && leadingOverlap.backgroundColor == bg) {
					leadingOverlap.text.append(c).append(trailingOverlap.text.toString());
					segments.remove(trailingOverlap);
				} else if (leadingOverlap.textColor == tc && leadingOverlap.backgroundColor == bg) {
					leadingOverlap.text.append(c);
				} else if (trailingOverlap.textColor == tc && trailingOverlap.backgroundColor == bg) {
					trailingOverlap.text.insert(0, c);
					trailingOverlap.xPos = x;
				} else {
					LineSegment newSeg = new LineSegment(tc, bg, x);
					newSeg.text.append(c);
					segments.add(newSeg);
				}
			} else if (leadingOverlap != null && trailingOverlap == null) {
				leadingOverlap.text.delete(x - leadingOverlap.xPos, leadingOverlap.text.length());
				if (leadingOverlap.textColor == tc && leadingOverlap.backgroundColor == bg) {
					leadingOverlap.text.append(c);
				} else {
					LineSegment newSeg = new LineSegment(tc, bg, x);
					newSeg.text.append(c);
					segments.add(newSeg);
				}
			} else if (leadingOverlap == null && trailingOverlap != null) {
				trailingOverlap.text.delete(0, c.length - (trailingOverlap.xPos - x));
				if (trailingOverlap.textColor == tc && trailingOverlap.backgroundColor == bg) {
					trailingOverlap.text.insert(0, c);
					trailingOverlap.xPos = x;
				} else {
					LineSegment newSeg = new LineSegment(tc, bg, x);
					newSeg.text.append(c);
					segments.add(newSeg);
					trailingOverlap.xPos += c.length - (trailingOverlap.xPos - x);
				}
			} else {
				LineSegment newSeg = new LineSegment(tc, bg, x);
				newSeg.text.append(c);
				segments.add(newSeg);
			}

			if (autoRedraw) {
				redraw();
			}
		}
	}
}