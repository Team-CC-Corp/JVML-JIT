package cc.event;

public enum Keys {
    ONE(2), TWO(3), THREE(4), FOUR(5), FIVE(6),
    SIX(7), SEVEN(8), EIGHT(9), NINE(10), ZERO(11),
    MINUS(12), EQUALS(13), BACKSPACE(14), TAB(15),
    Q(16), W(17), E(18), R(19), T(20), Y(21),
    U(22), I(23), O(24), P(25),
    LEFT_BRACKET(26), RIGHT_BRACKET(27), ENTER(28),LEFTCTRL(29),
    A(30), S(31), D(32), F(33), G(34), H(35),
    J(36), K(37), L(38), SEMICOLON(39), APOSTROPHE(40),
    GRAVE(41), LEFT_SHIFT(42), BACKSLASH(43),
    Z(44), X(45), C(46), V(47), B(48), N(49), M(50),
    COMMA(51), PERIOD(52), SLASH(53), RIGHT_SHIFT(54),
    MULTIPLY(55), LEFT_ALT(56), SPACE(57), CAPS_LOCK(58),
    F1(59), F2(60), F3(61), F4(62), F5(63),
    F6(64), F7(65), F8(66), F9(67), F10(68),
    NUM_LOCK(69), SCROLL_LOCK(70),
    NUMPAD_7(71), NUMPAD_8(72), NUMPAD_9(73), NUMPAD_SUBTRACT(74),
    NUMPAD_4(75), NUMPAD_5(76), NUMPAD_6(77), NUMPAD_ADD(78),
    NUMPAD_1(79), NUMPAD_2(80), NUMPAD_3(81), NUMPAD_0(82),
    NUMPAD_DECIMAL(83),
    F11(87), F12(88), F13(100), F14(101), F15(102),
    KANA(112), CONVERT(121), NO_CONVERT(123), YEN(125),
    NUMPAD_EQUALS(141), CIRCUMFLEX(144), AT(145),
    COLON(146), UNDERSCORE(147), KANJI(148), STOP(149), AX(150),
    NUMPAD_ENTER(152), RIGHT_CTRL(153), NUMPAD_COMMA(179),
    NUMPAD_DIVIDE(181), RIGHT_ALT(184), PAUSE(197), HOME(199),
    UP(200), PAGE_UP(201), LEFT(203), RIGHT(205), END(207),
    DOWN(208), PAGE_DOWN(209), INSERT(210), DELETE(211)
    ;

    private final int key;
    Keys(int key) {
        this.key = key;
    }

    public static Keys getKey(int key) {
        for (Keys k : values()) {
            if (k.key == key) {
                return k;
            }
        }
        return null;
    }
}