#include "Panel.h"

ASymbol::ASymbol(unsigned short main_symbol, unsigned short attribute, wchar_t start_symbol, wchar_t end_symbol)
	: Main_Symbol(main_symbol), Attribute(attribute), Start_Symbol(start_symbol), End_Symbol(end_symbol)
{
	
}



APanel::APanel(unsigned short x_pos, unsigned short y_pos, unsigned short width, unsigned short height, CHAR_INFO* screen_buffer, unsigned short screen_width)
	: X_Pos(x_pos), Y_Pos(y_pos), Width(width), Height(height), Screen_Buffer(screen_buffer), Screen_Width(screen_width)
{

}

void APanel::Draw()
{
	//1.Горизонтальные линии
	//1.1. верхняя двойная линия
	{
		ASymbol symbol(L'═', 0x1b, L'╔', L'╗');
		SPos pos(0, 0, Screen_Width, Width - 2);
		Draw_Line_Horizontal(Screen_Buffer, pos, symbol);
	}

	

	//1.2. нижняя двойная линия
	{
		ASymbol symbol(L'═', 0x1b, L'╚', L'╝');
		SPos pos(0, Height - 1, Screen_Width, Width - 2);
		Draw_Line_Horizontal(Screen_Buffer, pos, symbol);
	}
	
	//2.Вертикальные линии
	//2.1. Левая двойная линия
	{
		ASymbol symbol(L'║', 0x1b, L'║', L'║');
		SPos pos(0, 1, Screen_Width, Height - 4);
		Draw_Line_Vertical(Screen_Buffer, pos, symbol);
	}

	

	//2.2. Правая двойная линия
	{
		ASymbol symbol(L'║', 0x1b, L'║', L'║');
		SPos pos(Width - 1, 1, Screen_Width, Height - 4);
		Draw_Line_Vertical(Screen_Buffer, pos, symbol);
	}

	//1.2. средняя горизонтальная линия
	{
		ASymbol symbol(L'─', 0x1b, L'╟', L'╢');
		SPos pos(0, Height - 3, Screen_Width, Width - 2);
		Draw_Line_Horizontal(Screen_Buffer, pos, symbol);
	}

	//2.2. Средняя вертикальная линия
	{
		ASymbol symbol(L'║', 0x1b, L'╦', L'╨');
		SPos pos(Width / 2, 0, Screen_Width, Height - 4);
		Draw_Line_Vertical(Screen_Buffer, pos, symbol);
	}
	//Draw_Line_Vertical(Screen_Buffer, pos, symbol);
	//Show_Colors(Screen_Buffer, pos, symbol);
}
