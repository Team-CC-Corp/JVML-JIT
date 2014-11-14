package cc;

import cc.event.Event;

public final class Computer
{
    static {
        System.load("cc/native/Computer.lua");
    }

    private Computer() {}
    public static native void shutdown();
    public static native void restart();
    public static native void sleep(double s);
    public static native boolean isTurtle();
    public static native int getTime();
    public static native float getClock();
    public static native Event pullEvent();
    public static native Event pullEvent(String filter);
    public static native Event pullEventRaw();
    public static native Event pullEventRaw(String filter);
    public static native void queueEvent(Event e);
    public static native int startTimer(double t);
    public static native int setAlarm(double t);
    public static native String getVersion();
    public static native int getComputerID();
    public static native String getComputerLabel();
    public static native void setComputerLabel(String label);
    public static native String read();
    public static native String read(String rep);
    public static native LuaTable getGlobalTable();
}
