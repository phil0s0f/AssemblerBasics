﻿#include "Main.h"


int main(void)
{
	AsCommander Commander;

	if (!Commander.Init())
		return -1;

	Commander.Run();

	

	return 0;
}