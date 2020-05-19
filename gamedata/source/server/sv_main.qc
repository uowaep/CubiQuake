void SetNewParms()		{}
void SetChangeParms()	{}

void worldspawn()
{
	InitServerCubics();		// This must be called fist.	
}

void StartFrame()
{
	StartFrame_Cubics();
}