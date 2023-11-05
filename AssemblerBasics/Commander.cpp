#include "Commander.h"





AMenu_Item::AMenu_Item(unsigned short x_pos, unsigned short y_pos, unsigned short len, const wchar_t* key, const wchar_t* name)
	: X_Pos(x_pos), Y_Pos(y_pos), Len(len), Key(key), Name(name)
{

}

void AMenu_Item::Draw(CHAR_INFO* screen_buffer, unsigned short screen_width)
{
	int key_str_len;

	SText_Pos key_pos(X_Pos, Y_Pos, screen_width, 0x07);
	key_str_len = Draw_Text(screen_buffer, key_pos, Key);

	SText_Pos name_pos(X_Pos + key_str_len, Y_Pos, screen_width, 0xb0);

	Draw_Limited_Text(screen_buffer, name_pos, Name, Len);
}



AsCommander::~AsCommander()
{
	delete Left_Panel;
	delete Right_Panel;
	delete Screen_Buffer;
}


bool AsCommander::Init()
{
	SMALL_RECT srctWriteRect;
	int screen_buffer_size;

	// Get a handle to the STDOUT screen buffer to copy from and
	// create a new screen buffer to copy to.

	Std_Handle = GetStdHandle(STD_OUTPUT_HANDLE);
	Screen_Buffer_Handle = CreateConsoleScreenBuffer(
		GENERIC_READ |           // read/write access
		GENERIC_WRITE,
		FILE_SHARE_READ |
		FILE_SHARE_WRITE,        // shared
		NULL,                    // default security attributes
		CONSOLE_TEXTMODE_BUFFER, // must be TEXTMODE
		NULL);                   // reserved; must be NULL
	if (Std_Handle == INVALID_HANDLE_VALUE ||
		Screen_Buffer_Handle == INVALID_HANDLE_VALUE)
	{
		printf("CreateConsoleScreenBuffer failed - (%d)\n", GetLastError());
		return false;
	}

	// Make the new screen buffer the active screen buffer.
	if (!SetConsoleActiveScreenBuffer(Screen_Buffer_Handle))
	{
		printf("SetConsoleActiveScreenBuffer failed - (%d)\n", GetLastError());
		return false;
	}

	if (!GetConsoleScreenBufferInfo(Screen_Buffer_Handle, &Screen_Buffer_Info))
	{
		printf("GetConsoleScreenBufferInfo failed - (%d)\n", GetLastError());
		return false;
	}

	screen_buffer_size = (int)Screen_Buffer_Info.dwSize.X * (int)Screen_Buffer_Info.dwSize.Y;
	Screen_Buffer = new CHAR_INFO[screen_buffer_size];
	memset(Screen_Buffer, 0, screen_buffer_size * sizeof(CHAR_INFO));

	// Set the destination rectangle.
	srctWriteRect.Top = 10;    // top lt: row 10, col 0
	srctWriteRect.Left = 0;
	srctWriteRect.Bottom = 11; // bot. rt: row 11, col 79
	srctWriteRect.Right = 79;

	int half_width = Screen_Buffer_Info.dwSize.X / 2;
	Left_Panel = new APanel(0, 0, half_width, Screen_Buffer_Info.dwSize.Y - 2, Screen_Buffer, Screen_Buffer_Info.dwSize.X);
	Right_Panel = new APanel(half_width, 0, half_width, Screen_Buffer_Info.dwSize.Y - 2, Screen_Buffer, Screen_Buffer_Info.dwSize.X);


	Build_Menu();

	Left_Panel->Get_Directory_Files();

	return true;
}

bool AsCommander::Draw()
{
	COORD screen_buffer_pos{};

	//Show_Colors(Screen_Buffer, pos, symbol);

	Left_Panel->Draw();
	Right_Panel->Draw();

	for (int i = 0; i < 10; i++)
	{
		if (Menu_Items[i] != 0)
			Menu_Items[i]->Draw(Screen_Buffer, Screen_Buffer_Info.dwSize.X);
	}

	if (!WriteConsoleOutput(
		Screen_Buffer_Handle, // screen buffer to write to
		Screen_Buffer,        // buffer to copy from
		Screen_Buffer_Info.dwSize,     // col-row size of Screen_Buffer
		screen_buffer_pos,    // top left src cell in Screen_Buffer
		&Screen_Buffer_Info.srWindow))  // dest. screen buffer rectangle
	{
		printf("WriteConsoleOutput failed - (%d)\n", GetLastError());
		return false;
	}

	Sleep(150 * 1000); // 150 секунд программа будет "спать"

	// Restore the original active screen buffer.
	if (!SetConsoleActiveScreenBuffer(Std_Handle))
	{
		printf("SetConsoleActiveScreenBuffer failed - (%d)\n", GetLastError());
		return false;
	}
	return true;
}

void AsCommander::Add_Next_Menu_Item(int& index, int& x_pos, int x_step, const wchar_t* key, const wchar_t* name)
{
	Menu_Items[index++] = new AMenu_Item(x_pos, Screen_Buffer_Info.dwSize.Y - 1, 12, key, name);
	x_pos += x_step;

	if (index == 2)
		--x_pos;
}

void AsCommander::Build_Menu()
{
	int index = 0;
	int x_pos = 0;
	int x_step = Screen_Buffer_Info.dwSize.X / 10;

	Add_Next_Menu_Item(index, x_pos, x_step, L"1", L"Help");
	Add_Next_Menu_Item(index, x_pos, x_step, L" 2", L"UserMenu");
	Add_Next_Menu_Item(index, x_pos, x_step, L" 3", L"View");
	Add_Next_Menu_Item(index, x_pos, x_step, L" 4", L"Edit");
	Add_Next_Menu_Item(index, x_pos, x_step, L" 5", L"Copy");
	Add_Next_Menu_Item(index, x_pos, x_step, L" 6", L"RenMov");
	Add_Next_Menu_Item(index, x_pos, x_step, L" 7", L"MakeDir");
	Add_Next_Menu_Item(index, x_pos, x_step, L" 8", L"Delete");
	Add_Next_Menu_Item(index, x_pos, x_step, L" 9", L"Config");
	Add_Next_Menu_Item(index, x_pos, x_step, L" 10", L"Quit");
}