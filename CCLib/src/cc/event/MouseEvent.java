package cc.event;

public abstract class MouseEvent {
    public final int x, y;

    public MouseEvent(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public static class MouseClickEvent extends MouseEvent {
        public final MouseButton button;

        public MouseClickEvent(MouseButton b, int x, int y) {
            super(x, y);
            this.button = b;
        }
    }

    public static class MouseDragEvent extends MouseEvent {
        public final MouseButton button;

        public MouseDragEvent(MouseButton b, int x, int y) {
            super(x, y);
            this.button = b;
        }
    }

    public static class MouseScrollEvent extends MouseEvent {
        public final MouseScrollDirection scrollDirection;

        public MouseScrollEvent(MouseScrollDirection s, int x, int y) {
            super(x, y);
            this.scrollDirection = s;
        }
    }

    public static enum MouseButton {
        LEFT, RIGHT;

        public static MouseButton getButton(int button) {
            return button == 1 ? LEFT : button == 2 ? RIGHT : null;
        }
    }

    public static enum MouseScrollDirection {
        UP, DOWN;

        public static MouseScrollDirection getScrollDirection(int dir) {
            return dir < 0 ? UP : dir > 0 ? DOWN : null;
        }
    }
}