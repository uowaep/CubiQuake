void worldspawn()
{
	IGNORE_NOTHING = spawn();
	InitServerCubics();		// This must be called first.	
}

void StartFrame()
{
	StartFrame_Cubics();
}