﻿#include <windows.h>
#include <stdio.h>

struct SPos
{
	SPos(unsigned short x_pos, unsigned short y_pos, unsigned short screen_width, unsigned short len)
		: X_Pos(x_pos), Y_Pos(y_pos), Screen_Width(screen_width), Len(len)
	{
	}

	unsigned short X_Pos;
	unsigned short Y_Pos;
	unsigned short Screen_Width;
	unsigned short Len;
};

extern "C" int Make_Sum(int one_value, int another_value);
extern "C" void Draw_Line_Horizontal(CHAR_INFO * screen_buffer, SPos pos, CHAR_INFO symbol);
extern "C" void Show_Colors(CHAR_INFO * screen_buffer, SPos pos, CHAR_INFO symbol);

int main(void)
{

	HANDLE std_handle, screen_buffer_handle;
	SMALL_RECT srctWriteRect;
	CONSOLE_SCREEN_BUFFER_INFO screen_buffer_info{};
	CHAR_INFO* screen_buffer;
	COORD screen_buffer_pos{};
	int screen_buffer_size;

	// Get a handle to the STDOUT screen buffer to copy from and
	// create a new screen buffer to copy to.

	std_handle = GetStdHandle(STD_OUTPUT_HANDLE);
	screen_buffer_handle = CreateConsoleScreenBuffer(
		GENERIC_READ |           // read/write access
		GENERIC_WRITE,
		FILE_SHARE_READ |
		FILE_SHARE_WRITE,        // shared
		NULL,                    // default security attributes
		CONSOLE_TEXTMODE_BUFFER, // must be TEXTMODE
		NULL);                   // reserved; must be NULL
	if (std_handle == INVALID_HANDLE_VALUE ||
		screen_buffer_handle == INVALID_HANDLE_VALUE)
	{
		printf("CreateConsoleScreenBuffer failed - (%d)\n", GetLastError());
		return 1;
	}

	// Make the new screen buffer the active screen buffer.
	if (!SetConsoleActiveScreenBuffer(screen_buffer_handle))
	{
		printf("SetConsoleActiveScreenBuffer failed - (%d)\n", GetLastError());
		return 1;
	}

	if (!GetConsoleScreenBufferInfo(screen_buffer_handle, &screen_buffer_info))
	{
		printf("GetConsoleScreenBufferInfo failed - (%d)\n", GetLastError());
		return 1;
	}

	screen_buffer_size = (int)screen_buffer_info.dwSize.X * (int)screen_buffer_info.dwSize.Y;
	screen_buffer = new CHAR_INFO[screen_buffer_size];
	memset(screen_buffer, 0, screen_buffer_size * sizeof(CHAR_INFO));

	// Set the destination rectangle.
	srctWriteRect.Top = 10;    // top lt: row 10, col 0
	srctWriteRect.Left = 0;
	srctWriteRect.Bottom = 11; // bot. rt: row 11, col 79
	srctWriteRect.Right = 79;

	//screen_buffer[0].Char.UnicodeChar = L'W';
	//screen_buffer[0].Attributes = 0x50;

	CHAR_INFO symbol{};
	symbol.Char.UnicodeChar = L'-';
	symbol.Attributes = 0x1b;
	SPos pos(2, 1, screen_buffer_info.dwSize.X, 10);

	Draw_Line_Horizontal(screen_buffer, pos, symbol);
	//Show_Colors(screen_buffer, pos, symbol);

	if (!WriteConsoleOutput(
		screen_buffer_handle, // screen buffer to write to
		screen_buffer,        // buffer to copy from
		screen_buffer_info.dwSize,     // col-row size of screen_buffer
		screen_buffer_pos,    // top left src cell in screen_buffer
		&screen_buffer_info.srWindow))  // dest. screen buffer rectangle
	{
		printf("WriteConsoleOutput failed - (%d)\n", GetLastError());
		return 1;
	}

	Sleep(150 *1000); // 150 секунд программа будет "спать"

	// Restore the original active screen buffer.
	if (!SetConsoleActiveScreenBuffer(std_handle))
	{
		printf("SetConsoleActiveScreenBuffer failed - (%d)\n", GetLastError());
		return 1;
	}

	return 0;
}