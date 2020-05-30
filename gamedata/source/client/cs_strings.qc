string	hudstring_editor_tool;
string	hudstring_editor_toolsize;
string	hudstring_editor_cubictype;
string	hudstring_editor_cubicshape;
string	hudstring_editor_cubicrotation;
string	hudstring_editor_chunkconnectionfit[6];
string	hudstring_editor_chunkgroupsize[6];
//string	hudstring_editor_chunkconnectiontype[6];
string	hudstring_editor_chunkconnectionflags[6];
string	hudstring_editor_prefabzone;
string	hudstring_editor_prefabchance;
string	hudstring_editor_prefabchunkflags;
string	hudstring_editor_totalcubics;

void InitializeStrings()
{
	int count;
	
	hudstring_editor_tool = (string)memalloc(64);
	hudstring_editor_toolsize = (string)memalloc(64);	
	hudstring_editor_cubictype = (string)memalloc(64);
	hudstring_editor_cubicshape = (string)memalloc(64);
	hudstring_editor_cubicrotation = (string)memalloc(64);
	
	for(count = 0; count < 6; count++)
	{
		hudstring_editor_chunkconnectionfit[count] = (string)memalloc(64);
		hudstring_editor_chunkgroupsize[count] = (string)memalloc(64);
//		hudstring_editor_chunkconnectiontype[count] = (string)memalloc(64);
		hudstring_editor_chunkconnectionflags[count] = (string)memalloc(64);
	}
	
	hudstring_editor_prefabzone = (string)memalloc(64);	
	hudstring_editor_prefabchance = (string)memalloc(64);		
	hudstring_editor_prefabchunkflags = (string)memalloc(64);	
	hudstring_editor_totalcubics = (string)memalloc(64);		
}

/*void SetString(string memstr, int val)
{
	int count;
	string s = itos(val);
	int len = strlen(s);
	for(count = 0; count < len; count++)
		memstr[count] = '0'+stoi(substring(s, count, 1));
	memstr[count] = 0;
}*/