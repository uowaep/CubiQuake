void SetNewParms()		{}
void SetChangeParms()	{}

void worldspawn()
{
	InitServerCubics();		// This must be called first.	
}

void StartFrame()
{
	StartFrame_Cubics();
}