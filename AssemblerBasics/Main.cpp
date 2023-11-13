#include "Main.h"


int main(void)
{
	/*char data_array[1000];
	int key = 0;
	if (Try_Lock(&key))
	{
		int yy = 0;
	}
	else
	{
		Sleep(10);
	}*/
	Test_Command();

	AsCommander Commander;

	if (!Commander.Init())
		return -1;

	Commander.Run();

	

	return 0;
}