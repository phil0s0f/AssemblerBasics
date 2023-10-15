#include "Panel.h"

APanel::APanel(unsigned short x_pos, unsigned short y_pos, unsigned short width, unsigned short height)
	: X_Pos(x_pos), Y_Pos(y_pos), Width(width), Height(height)
{
	
}

void APanel::Draw()
{
	CHAR_INFO symbol{};
	symbol.Char.UnicodeChar = L'-';
	symbol.Attributes = 0x1b;
	SPos pos(2, 1, screen_buffer_info.dwSize.X, 10);


	//Draw_Line_Horizontal(screen_buffer, pos, symbol);
	Draw_Line_Vertical(screen_buffer, pos, symbol);
	//Show_Colors(screen_buffer, pos, symbol);
}
