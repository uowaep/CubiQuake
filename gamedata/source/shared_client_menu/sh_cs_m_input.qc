void IncreaseInputStates()
{
	for(int keynum = 0; keynum < numinputkeys; keynum++)
	{
		if(player_input[keynum])
			player_input[keynum] = 2;
	}
}