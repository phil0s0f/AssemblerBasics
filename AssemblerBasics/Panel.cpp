#include "Panel.h"

AFile_Descriptor::AFile_Descriptor(unsigned attributes, unsigned size_low, unsigned size_high, wchar_t* file_name)
	: Attributes(attributes), File_Name(file_name)
{
	File_Size = ((unsigned long long)size_high << 32) | (unsigned long long)size_low;
}


APanel::APanel(unsigned short x_pos, unsigned short y_pos, unsigned short width, unsigned short height, CHAR_INFO* screen_buffer, unsigned short screen_width)
	: X_Pos(x_pos), Y_Pos(y_pos), Width(width), Height(height), Screen_Buffer(screen_buffer), Screen_Width(screen_width)
{

}

void APanel::Draw()
{
	Draw_Panels();
	Draw_Files();
}

void APanel::Get_Directory_Files()
{
	HANDLE search_handle;
	WIN32_FIND_DATAW find_data{};
	search_handle = FindFirstFileW(L"*.*", &find_data);
	while (FindNextFileW(search_handle, &find_data))
	{
		AFile_Descriptor* file_descriptor = new AFile_Descriptor(find_data.dwFileAttributes, find_data.nFileSizeLow, find_data.nFileSizeHigh, find_data.cFileName);
		Files.push_back(file_descriptor);
	}
}

void APanel::Draw_Panels()
{
	ASymbol symbol(L' ', 0x1b, L' ', L' ');
	SArea_Pos area_pos(X_Pos + 1, Y_Pos + 1, Screen_Width, Width - 2, Height - 2);
	Clear_Area(Screen_Buffer, area_pos, symbol);
	//1.Горизонтальные линии
	//1.1. верхняя двойная линия
	{
		ASymbol symbol(L'═', 0x1b, L'╔', L'╗');
		SPos pos(X_Pos, Y_Pos, Screen_Width, Width - 2);
		Draw_Line_Horizontal(Screen_Buffer, pos, symbol);
	}



	//1.2. нижняя двойная линия
	{
		ASymbol symbol(L'═', 0x1b, L'╚', L'╝');
		SPos pos(X_Pos, Y_Pos + Height - 1, Screen_Width, Width - 2);
		Draw_Line_Horizontal(Screen_Buffer, pos, symbol);
	}

	//2.Вертикальные линии
	//2.1. Левая двойная линия
	{
		ASymbol symbol(L'║', 0x1b, L'║', L'║');
		SPos pos(X_Pos, Y_Pos + 1, Screen_Width, Height - 4);
		Draw_Line_Vertical(Screen_Buffer, pos, symbol);
	}



	//2.2. Правая двойная линия
	{
		ASymbol symbol(L'║', 0x1b, L'║', L'║');
		SPos pos(X_Pos + Width - 1, Y_Pos + 1, Screen_Width, Height - 4);
		Draw_Line_Vertical(Screen_Buffer, pos, symbol);
	}

	//1.2. средняя горизонтальная линия
	{
		ASymbol symbol(L'─', 0x1b, L'╟', L'╢');
		SPos pos(X_Pos, Y_Pos + Height - 3, Screen_Width, Width - 2);
		Draw_Line_Horizontal(Screen_Buffer, pos, symbol);
	}

	//2.2. Средняя вертикальная линия
	{
		ASymbol symbol(L'║', 0x1b, L'╦', L'╨');
		SPos pos(X_Pos + Width / 2, Y_Pos, Screen_Width, Height - 4);
		Draw_Line_Vertical(Screen_Buffer, pos, symbol);
	}
}

void APanel::Draw_Files()
{
	unsigned short attributes;
	int x_offset = 0;
	int y_offset = 0;
	for (auto* file : Files)
	{
		if (file->Attributes & FILE_ATTRIBUTE_DIRECTORY)
			attributes = 0x1f;//Если файл директория то белый цвет
		else
			attributes = 0x1b;//Если файл НЕ директория то синий цвет
		SText_Pos pos(X_Pos + x_offset + 1, Y_Pos + y_offset + 2, Screen_Width, attributes);
		Draw_Text(Screen_Buffer, pos, file->File_Name.c_str());

		++y_offset;
		if (y_offset >= Height - 15)// -5 строк
		{//дошли до конца колонки
			if (x_offset == 0)
			{
				x_offset += Width / 2;
				y_offset = 0;
			}
			else
			{
				break; //выводим только 2 колонки
			}
		}
	}
}

