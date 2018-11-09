/**
ANSI colour modes for text.
Foreground colour codes start at 30-37 for dark, then 90-97 for light
Background colour codes start at 40-47 for dark, then 100-107 for light
**/
enum ANSIColor
{
    Black;
    Red;
    Green;
    Yellow;
    Blue;
    Magenta;
    Cyan;
    /**
    Not really white, LightWhite is pure #ffffff (usually)
    **/
    White;
    LightBlack;
    LightRed;
    LightGreen;
    LightYellow;
    LightBlue;
    LightMagenta;
    LightCyan;
    LightWhite;
}