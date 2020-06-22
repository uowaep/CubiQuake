entity LinkedList_Remove(entity e, entity list, .entity entchain, .entity entparent)
{
	if(!(e.entchain || e.entparent || e == list))
		return list;

	if(list == e)
	{
		list = e.entchain;
		if(list)
			list.entparent = __NULL__;
	}
	
	if(e.entparent)
		e.entparent.entchain = e.entchain;
	if(e.entchain)
		e.entchain.entparent = e.entparent;
		
	e.entparent = __NULL__;
	e.entchain = __NULL__;
		
	return list;
}

entity LinkedList_Add(entity e, entity list, .entity entchain, .entity entparent)
{
	if(e.entchain || e.entparent || e == list)	// already in list
		return list;

	if(list)
	{
		e.entchain = list;
		list.entparent = e;
	}
	
	list = e;
	
	return list;
}

// this function :)
entity list_lastent;
entity LinkedList_Append(entity e, entity list, entity lastent, .entity entchain, .entity entparent)
{
	if(e.entchain || e.entparent || e == list)	// already in list
		return list;

	if(list)
	{
		lastent.entchain = e;
		e.entparent = lastent;
	}
	else
		list = e;
	
	list_lastent = e;
	return list;
}

float assumefalsecheckcommand(string cmd)
{
	if(!checkextension("FTE_QC_CHECKCOMMAND"))
		return FALSE;
	return checkcommand(cmd);
}

float CreateBuffer()	{	return buf_create()+1;	}
void DeleteBuffer(float handle)	{	if(!handle) return;	buf_del(handle-1);	}
float GetBufferSize(float handle)	{	return buf_getsize(handle-1);	}
void CopyBuffer(float handle_from, float handle_to)	{	buf_copy(handle_from-1, handle_to-1);	}
void SortBuffer(float handle, float sortpower, float backward)	{	buf_sort(handle-1, sortpower, backward);	}
string ImplodeBuffer(float handle, string glue)	{	return buf_implode(handle-1, glue);	}
string GetBufferString(float handle, float index)	{	return bufstr_get(handle-1, index);	}
void SetBufferString(float handle, float index, string str)	{	bufstr_set(handle-1, index, str);	}
float AddBufferString(float handle, string str, float order)	{	return bufstr_add(handle-1, str, order);	}
void FreeBufferString(float handle, float index)	{	bufstr_free(handle-1, index);	}

/*float FileOpen(string filename, float method)
{
	local float file;

	if(method == FILE_WRITE)
		filename = strtolower(filename);
		
	file = fopen(filename, method);
	
	if(method == FILE_READ)
	if(file == -1)
	if(filename != strtolower(filename))
		file = fopen(strtolower(filename), method);
		
	return file;
}*/

void Remove(entity e);
void Remove_self()	{	Remove(self);	}

string zonecpy(string dst, string src) // if dst is not null or zoned, this will cause errors (do not use in FTE)
{
	local string s = __NULL__;

	if(src != __NULL__)
		s = strzone(src);
	
	if(dst != __NULL__)
		strunzone(dst);

	return s;
}

string freezone(string zone) // if zone is not null or zoned, this will cause errors
{
	if(zone != __NULL__)
		strunzone(zone);
	
	zone = __NULL__;
	
	return zone;
}

float HasDuplicateStringInList(float buf, string s)
{
	local float count, buffersize;
	local string bstring;
	
	buffersize = GetBufferSize(buf);
	for(count = 0; count < buffersize; count++)
	{
		bstring = GetBufferString(buf, count);
		if(strtolower(s) == strtolower(bstring))
			return TRUE;
	}

	return FALSE;
}

string PrefixZerosToNumString(string numstring, float totallength)
{
	while(strlen(numstring) < totallength)
		numstring = strcat("0", numstring);
		
	return numstring;
}

string ftos_short(float f)
{
	local string s, c;

	if(f == floor(f))
		return ftos(f);

	s = sprintf("%.2f", f);

	c = substring(s, -1, 1);
	while(c == "0")
	{
		s = substring(s, 0, -2);
		c = substring(s, -1, 1);
	}

	if(c == ".")
		s = substring(s, 0, -2);
	
	return s;
}

string RemoveTrailingSpaces(string str)
{
	float len = strlen(str);
	while(substring(str, len-1, 1) == " ")
	{
		len-=1;
		str = substring(str, 0, len);
	}
	
	return str;
}

void Func_oself(entity e, void() func)
{
	local entity oself;
	oself = self;
	self = e;
	func();
	self = oself;
}

float IsAssignedFunction(void() func)
{
	if(func && func != __NULL__)
		return TRUE;
		
	return FALSE;
}

float FixAngle(float ang)
{
	if(ang > 180)
		ang -= 360;
	if(ang <= -180)
		ang += 360;
	
	return ang;
}

float AngleDifference(float angA, float angB)
{
	local float angdiff;

	angdiff = angA - angB;
	while(angdiff > 180)
		angdiff -= 360;
	while(angdiff < -180)
		angdiff += 360;
	return angdiff;
}

float PositiveValue(float num)
{
	if(num < 0)
		num*=-1;
	
	return num;
}

float PositiveAngleDifference(float angA, float angB)
{
	local float diff;

	diff = AngleDifference(angA, angB);
	if(diff < 0)
		diff = diff*-1;
		
	return diff;
}

float GetFrameForTime(float frames, float framelen)
{
	local float time_current, frame_current;

	time_current = time - floor(time/(framelen*frames))*(framelen*frames);
	frame_current = floor(time_current / framelen);
	
	return frame_current;
}

float RandomPolarity()
{
	if(random() >= 0.5)
		return 1;
	return -1;
}

float GetPolarity(float num)
{
	if(num > 0.001)
		return 1;
	if(num < -0.001)
		return -1;
	return FALSE;
}

float reverse_bitshift(float bit)
{
	return floor(log(bit + 0.5) / log(2.0)) + 1;
}

#ifndef MENU
vector EntCenter(entity e)
{
	local vector org;
	
	org = e.origin;
	org_z += (e.maxs_z + e.mins_z)*0.5;
	
	return org;
}
#endif