#include "Main.h"


int main(void)
{
	AsCommander Commander;

	if (!Commander.Init())
		return -1;

	if (!Commander.Draw())
		return -1;

	return 0;
}