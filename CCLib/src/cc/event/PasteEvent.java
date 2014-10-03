package cc.event;

public class PasteEvent {
    public final String clipboardText;

    public PasteEvent(String text) {
        clipboardText = text;
    }
}