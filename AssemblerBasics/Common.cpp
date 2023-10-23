#include "Common.h"

SPos::SPos(unsigned short x_pos, unsigned short y_pos, unsigned short screen_width, unsigned short len)
	: X_Pos(x_pos), Y_Pos(y_pos), Screen_Width(screen_width), Len(len)
{

}

SText_Pos::SText_Pos(unsigned short x_pos, unsigned short y_pos, unsigned short screen_width, unsigned short attribute)
	: X_Pos(x_pos), Y_Pos(y_pos), Screen_Width(screen_width), Attribute(attribute)
{

}

SArea_Pos::SArea_Pos(unsigned short x_pos, unsigned short y_pos, unsigned short screen_width, unsigned char width, unsigned char height)
	: X_Pos(x_pos), Y_Pos(y_pos), Screen_Width(screen_width), Width(width), Height(height)
{
}

ASymbol::ASymbol(unsigned short main_symbol, unsigned short attribute, wchar_t start_symbol, wchar_t end_symbol)
	: Main_Symbol(main_symbol), Attribute(attribute), Start_Symbol(start_symbol), End_Symbol(end_symbol)
{

}
