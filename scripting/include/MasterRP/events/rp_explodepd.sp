//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_explodepd_included_
  #endinput
#endif
#define _rp_explodepd_included_

//Defines:
#define MAXFINDBOMBZONES		5

//models/props_c17/suitcase001a.mdl

//Euro - € dont remove this!
//€ = �

float FindBombZone[MAXFINDBOMBZONES + 1][3];
int FindBombEnt[MAXFINDBOMBZONES + 1] = -1;
int ExplodePdTimer = 0;
int ExplodePdAvaiableTimer = -1;

float PdBombZone[MAXFINDBOMBZONES + 1][3];
int PdBombEnt[MAXFINDBOMBZONES + 1] = {-1,...};
bool PdBombEntArmed[MAXFINDBOMBZONES + 1] = {false,...};

public void initExplodePd()
{

	//Commands:
	RegAdminCmd("sm_createfindbomb", Command_CreateFindBomb, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_createfindbombzone", Command_CreateFindBombZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removefindbombzones", Command_RemoveFindBombZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listfindbombzones", Command_Listfindbombzones, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipefindbombzones", Command_WipeFindBombZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testfindbombzone", Command_TestFindBombZone, ADMFLAG_ROOT, "<id> - Test find bomb Spawn");

	//Commands:
	RegAdminCmd("sm_createpdbomb", Command_CreatePdBomb, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_savepdbombzone", Command_SavePdBombZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removepdbombzones", Command_RemovePdBombZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listpdbombzones", Command_ListPdBombzones, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipepdbombzones", Command_WipePdBombZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testpdbombzone", Command_TestPdBombZone, ADMFLAG_ROOT, "<id> - Test find bomb Spawn");

	RegAdminCmd("sm_pdexplodeevent", Command_StartPdExplodeEvent, ADMFLAG_ROOT, "");

	//Timers:
	CreateTimer(0.2, CreateSQLdbFindBombZone);

	//Timers:
	CreateTimer(0.2, CreateSQLdbPdBombZone);

	//PreCache Model
	PrecacheModel("models/props_c17/suitcase001a.mdl");

	//Loop:
	for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		FindBombZone[Z][i] = 69.0;

		//Initulize:
		PdBombZone[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbFindBombZone(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `FindBomb`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action CreateSQLdbPdBombZone(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `PdBomb`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(64) NULL, `Angles` varchar(64) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadFindBombZone(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		FindBombZone[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM FindBomb WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadFindBombZones, query);
}

public void T_DBLoadFindBombZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadFindBombZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Find Bomb Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0; 
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			char Dump[3][64];
			float Position[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			FindBombZone[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Find Bomb Zones Found!");
	}
}
public void T_DBLoadFindBomb(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadFindBomb: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Find Bomb Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0; 
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			char Dump[3][64];
			float Position[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Declare:
			float Angles[3] = {0.0,...};

			//Initulize:
			Angles[2] = GetRandomFloat(0.0, 360.0);

			//Create Bomb:
			CreateFindBombEnt(X, Position, Angles);
		}

		//Print:
		PrintToServer("|RP| - Find Bomb Zones Found!");
	}
}

public void T_DBPrintFindBombZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Declare:
	int Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBPrintFindBombZones: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int ZoneId = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ZoneId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", ZoneId, Buffer);
		}
	}
}

//Create Database:
public Action LoadPdBombZone(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		PdBombZone[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM PdBomb WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadPdBombZones, query);
}

public void T_DBLoadPdBombZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadPdBombZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Pd Bomb Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0; 
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			char Dump[3][64];
			float Origin[3];
			float Angles[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Origin[Y] = StringToFloat(Dump[Y]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Angles[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			PdBombZone[X] = Origin;
		}

		//Print:
		PrintToServer("|RP| - Pd Bomb Zones Found!");
	}
}

public void T_DBLoadPdBomb(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadPdBomb: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Pd Bomb Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0; 
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			char Dump[3][64];
			float Origin[3];
			float Angles[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Origin[Y] = StringToFloat(Dump[Y]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Angles[Y] = StringToFloat(Dump[Y]);
			}

			if(IsPdBombIndexFree(X))
			{

				//Initulize:
				int Ent = CreatePdBombEnt(X, Origin, Angles);

				//Accept:
				AcceptEntityInput(Ent, "disablemotion", Ent);

				//Set Move:
				SetEntityMoveType(Ent, MOVETYPE_CUSTOM);
			}

			//Override:
			else
			{

				//Print:
				PrintToServer("|RP| - Bomb Already attached to index!");
			}
		}

		//Print:
		PrintToServer("|RP| - Pd Bomb Zones Found!");
	}
}

public void T_DBPrintPdBombZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Declare:
	int Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBPrintPdBombZones: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int ZoneId = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ZoneId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", ZoneId, Buffer);
		}
	}
}

//Create Garbage Zone:
public Action Command_CreateFindBomb(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Create:
	CreateFindBombEnt(-1, Origin, EyeAngles);

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action Command_CreateFindBombZone(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createfindbombzone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > MAXFINDBOMBZONES)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createfindbombzone <0-%i>", MAXFINDBOMBZONES);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	char query[512];
	char Position[128];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
	
	//Spawn Already Created:
	if(FindBombZone[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE FindBomb SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO FindBomb (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	FindBombZone[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Find Bomb spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action Command_RemoveFindBombZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removefindbombzones <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > MAXFINDBOMBZONES)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removefindbombzones <0-%i>", MAXFINDBOMBZONES);

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(FindBombZone[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	FindBombZone[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM FindBomb WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed  Find Bomb Spawn (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_Listfindbombzones(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Find Bomb Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXFINDBOMBZONES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM FindBomb WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintFindBombZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeFindBombZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Find Bomb Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXFINDBOMBZONES; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM FindBomb WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action Command_TestFindBombZone(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testFindBombzone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testFindBombzone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, FindBombZone[Id][0], FindBombZone[Id][1], FindBombZone[Id][2]);

	//Return:
	return Plugin_Handled;
}

public int CreateFindBombEnt(int X, float Origin[3], float EyeAngles[3])
{

	//Spawn Prop
	int Ent = CreateProp(Origin, EyeAngles, "models/props_c17/suitcase001a.mdl", false, false);

	//Set Trans Effect:
	SetEntityRenderMode(Ent, RENDER_GLOW);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Find_Bomb");

	if(X != -1) FindBombEnt[X] = Ent;

	//Return:
	return view_as<int>(Ent);
}

public int CreatePdBombEnt(int X, float Origin[3], float EyeAngles[3])
{

	//Spawn Prop
	int Ent = CreateProp(Origin, EyeAngles, "models/props_c17/suitcase001a.mdl", false, false);

	//Set Trans Effect:
	SetEntityRenderMode(Ent, RENDER_GLOW);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_PD_Bomb");

	//Set Color:
	SetEntityRenderColor(Ent, 255, 120, 120, 145);

	if(X != -1) PdBombEnt[X] = Ent;

	//Client Hooking:
 	DHookEntity(hPreTouch, false, Ent);

	//Return:
	return view_as<int>(Ent);
}

//Create Garbage Zone:
public Action Command_CreatePdBomb(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Create:
	CreatePdBombEnt(-1, Origin, EyeAngles);

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action Command_SavePdBombZone(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createpdbombzone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > MAXFINDBOMBZONES)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createpdbombzone <0-%i>", MAXFINDBOMBZONES);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Check:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Prop Garbage Can:
	if(!StrEqual(ClassName, "prop_PD_Bomb"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop %s", ClassName);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Origin[3];
	float Angles[3]; 

	//Initluze:
	GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", Origin);

	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles);

	//Declare:
	char query[512];
	char Position[128];
	char Ang[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", Origin[0], Origin[1], Origin[2]);

	//Sql String:
	Format(Ang, sizeof(Ang), "%f^%f^%f", Angles[0], Angles[1], Angles[2]);

	//Spawn Already Created:
	if(PdBombZone[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE PdBomb SET Position = '%s', Angles = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, Ang, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO PdBomb (`Map`,`ZoneId`,`Position`,`Angles`) VALUES ('%s',%i,'%s','%s');", ServerMap(), StringToInt(ZoneId), Position, Ang);
	}

	//Initulize:
	PdBombZone[StringToInt(ZoneId)] = PdBombZone[Id];

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Pd Bomb spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, PdBombZone[Id][0], PdBombZone[Id][1], PdBombZone[Id][2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action Command_RemovePdBombZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removepdbombzones <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > MAXFINDBOMBZONES)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removepdbombzones <0-%i>", MAXFINDBOMBZONES);

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(PdBombZone[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	PdBombZone[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM PdBomb WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed  Pd Bomb Spawn (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListPdBombzones(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Pd Bomb Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXFINDBOMBZONES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM PdBomb WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintPdBombZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipePdBombZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Pd Bomb Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXFINDBOMBZONES; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM PdBomb WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action Command_TestPdBombZone(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testpdbombzone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testpdbombzone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, PdBombZone[Id][0], PdBombZone[Id][1], PdBombZone[Id][2]);

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action Command_StartPdExplodeEvent(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(IsPdExplodeJobAvaiable())
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can only start one of this type of event at a time!");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	ExplodePdTimer = GetExplodePdTimerDuration();

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Event has been started!");

	//Return:
	return Plugin_Handled;
}

//init every sec:
public void initExplodePdTick()
{

	//Initulize:
	ExplodePdTimer++;

	//TimerCheck
	if(ExplodePdTimer >= GetExplodePdTimerDuration())
	{

		//Initulize:
		ExplodePdTimer = 0; // restart timer:

		ExplodePdAvaiableTimer = 240;

		//Declare:
		char query[512];

		//Loop:
		for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++)
		{

			//Initulize:
			PdBombEntArmed[Z] = false;
		}

		//Format:
		Format(query, sizeof(query), "SELECT * FROM FindBomb WHERE Map = '%s';", ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBLoadFindBomb, query);

		//Format:
		Format(query, sizeof(query), "SELECT * FROM PdBomb WHERE Map = '%s';", ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBLoadPdBomb, query);
	}

	if(ExplodePdAvaiableTimer >= 0)
	{

		if(ExplodePdAvaiableTimer == 0)
		{

			//Check if all bombs have been planted forward:
			OnCheckIfPlayersPlantedAllBombs();
		}

		//Initulize:
		ExplodePdAvaiableTimer -= 1;

		//Declare:
		float EntOrigin[3];

		//Loop:
		for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++)
		{

			//Check:
			if(FindBombEnt[Z] > 0 && IsValidEdict(FindBombEnt[Z]))
			{

				//Initulize:
				GetEntPropVector(PdBombEnt[Z], Prop_Send, "m_vecOrigin", EntOrigin);

				//Show CrimeHud:
				ShowIllegalItemToCops(EntOrigin);
			}
		}
	}
}

public void OnCheckIfPlayersPlantedAllBombs()
{

	//Delare:
	int Armed = GetPdBombsArmed();

	//Check:
	if(Armed == MAXFINDBOMBZONES + 1)
	{

		//Declare: 
		float Timer = 0.0;

		//Loop:
		for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++)
		{

			//Check:
			if(IsValidEdict(PdBombEnt[Z]))
			{

				//Initulize:
				Timer += 0.2;

				//Timers:
				CreateTimer(Timer, SeperateBombExplosions, Z);
			}

			//Check:
			if(FindBombEnt[Z] > GetMaxClients() && IsValidEdict(FindBombEnt[Z]))
			{

				//Request:
				RequestFrame(OnNextFrameKill, FindBombEnt[Z]);

				//Initulize:
				FindBombEnt[Z] = -1;
			}
		}

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - The Police Department has been blown up!");
	}

	//Override: // Remove all bombs:
	else
	{

		//Loop:
		for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++)
		{

			//Check:
			if(PdBombEnt[Z] > GetMaxClients() && IsValidEdict(PdBombEnt[Z]))
			{

				//Request:
				RequestFrame(OnNextFrameKill, PdBombEnt[Z]);

				//Initulize:
				PdBombEnt[Z] = -1;

				PdBombEntArmed[Z] = false;
			}

			//Check:
			if(FindBombEnt[Z] > GetMaxClients() && IsValidEdict(FindBombEnt[Z]))
			{

				//Request:
				RequestFrame(OnNextFrameKill, FindBombEnt[Z]);

				//Initulize:
				FindBombEnt[Z] = -1;
			}
		}

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - not all %i bombs was planted successfully!", MAXFINDBOMBZONES + 1);
	}
}

public Action SeperateBombExplosions(Handle Timer, any Data)
{

	//Print:
	//PrintToServer("|RP| - explode data %i, ent = %i!", Data, PdBombEnt[Data]);

	//Check:
	if(IsValidEdict(PdBombEnt[Data]))
	{

		//Declare:
		float Origin[3];

		//Get Prop Data:
		GetEntPropVector(PdBombEnt[Data], Prop_Send, "m_vecOrigin", Origin);

		//Emit Sound:
		EmitAmbientSound("ambient/explosions/explode_5.wav", Origin, SNDLEVEL_RAIDSIREN);

		//Temp Ent:
		TE_SetupExplosion(Origin, Smoke(), 10.0, 1, 0, 100, 5000);

		//Send:
		TE_SendToAll();

		//Temp Ent:
		TE_SetupExplosion(Origin, Explode(), 5.0, 1, 0, 600, 5000);

		//Send:
		TE_SendToAll();

		//TE Setup:
		TE_SetupDynamicLight(Origin, 255, 100, 10, 8, 150.0, 0.4, 50.0);

		//Send:
		TE_SendToAll();

		//Declare:
		float Angles[3];
		float Offset[3] = {0.0, 0.0, 2.0};

		//Get Prop Data:
		GetEntPropVector(PdBombEnt[Data], Prop_Data, "m_angRotation", Angles);

		//Create Fire Effect!
		CreateInfoParticleSystemOther(PdBombEnt[Data], "null", "Fire_Large_01", 0.2, Offset, Angles);

		//TE Setup:
		TE_SetupDynamicLight(Origin, 255, 100, 10, 8, 150.0, 0.4, 50.0);

		//Send:
		TE_SendToAll();

		//CreateDamage:
		ExplosionDamage(PdBombEnt[Data], PdBombEnt[Data], Origin, DMG_BURN);

		//Set Color:
		SetEntityRenderColor(PdBombEnt[Data], 255, 120, 120, 145);

		//Timers:
		CreateTimer(0.5, RemoveExplodedPdBomb, Data);
	}
}

public Action RemoveExplodedPdBomb(Handle Timer, any Data)
{

	//Check:
	if(IsValidEdict(PdBombEnt[Data]))
	{

		//Request:
		RequestFrame(OnNextFrameKill, PdBombEnt[Data]);

		//Initulize:
		PdBombEnt[Data] = -1;

		PdBombEntArmed[Data] = false;
	}
}

public void OnFindBombDestroyed(int Entity)
{

	//Check If Timer is Running:
	if(IsPdExplodeJobAvaiable())
	{

		//Declare:
		int X = GetFindBombIndex(Entity);
		char query[256];

		//Format:
		Format(query, sizeof(query), "SELECT * FROM FindBomb WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBLoadFindBomb, query);

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Bomb has been respawned!");
	}

	//Override:
	else
	{

		//Declare:
		int X = GetFindBombIndex(Entity);

		if(X != -1)
		{

			//Initulize:
			FindBombEnt[X] = -1;
		}
	}
}

//Use Handle:
public Action OnFindBombUse(int Client, int Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Check:
		if(IsCop(Client) || IsAdmin(Client))
		{

			//Is In Time:
			if((GetLastPressedE(Client) > (GetGameTime() - 1.5)))
			{

				//Valid: have used hacktime as normal players wont be using this function
				if(GetDoorHackTime(Client) <= (GetGameTime() - 60))
				{

					//Initulize: 
					SetDoorHackTime(Client, GetGameTime());

					//Declare:
					int Amount = 500;

					//Initialize:
					SetBank(Client, (Bank[Client] + Amount));

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have disposed of this bomb you have earned %s!", IntToMoney(Amount));

					//Set Menu State:
					BankState(Client, Amount);

					//Play Sound:
					EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

					//Initulize:
					SetLastPressedE(Client, 0.0);

					//Request:
					RequestFrame(OnNextFrameKill, Ent);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Please wait up to 1 minute cooldown!");

					//Initulize:
					SetLastPressedE(Client, GetGameTime());
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-|\x07FFFFFF - Press \x0732CD32'use'\x07FFFFFF again to distroy this bomb!");

				//Initulize:
				SetLastPressedE(Client, GetGameTime());
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have to place the bomb in the police department!");
		}
	}
}

public bool IsValidPdBomb(int Ent)
{

	//Loop:
	for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++)
	{

		if(PdBombEnt[Z] == Ent)
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public bool IsValidFindBomb(int Ent)
{

	//Loop:
	for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++)
	{

		if(FindBombEnt[Z] == Ent)
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public bool IsPdBombIndexFree(int Result)
{

	if(!IsValidEdict(PdBombEnt[Result]))
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}

public int GetPdBombIndex(int Ent)
{

	//Loop:
	for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++)
	{

		if(PdBombEnt[Z] == Ent)
		{

			//Return:
			return view_as<int>(Z);
		}
	}

	//Return:
	return view_as<int>(-1);
}

public int GetFindBombIndex(int Ent)
{

	//Loop:
	for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++)
	{

		if(FindBombEnt[Z] == Ent)
		{

			//Return:
			return view_as<int>(Z);
		}
	}

	//Return:
	return view_as<int>(-1);
}

public int GetPdBombsArmed()
{

	//Declare:
	int Result = 0;

	//Loop:
	for(int Z = 0; Z <= MAXFINDBOMBZONES; Z++)
	{

		//Check:
		if(PdBombEntArmed[Z] == true)
		{

			//Initulize:
			Result += 1;
		}
	}

	//Return:
	return view_as<int>(Result);
}

public bool IsPdExplodeJobAvaiable()
{

	//Check:
	if(ExplodePdAvaiableTimer > 0)
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}

public int GetPdExplodeTimeLeft()
{

	//Return:
	return view_as<int>(ExplodePdAvaiableTimer);
}


//On Client Attempt To Sell Item:
public bool OnPreHandlePdBombTouch(int Ent, int OtherEnt)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(OtherEnt, ClassName, sizeof(ClassName));

	//Prop Battery:
	if(StrEqual(ClassName, "prop_Find_Bomb"))
	{


		//Declare:
		int X = GetPdBombIndex(Ent);

		//Check:
		if(PdBombEntArmed[X] == false)
		{

			//GetOwner Before Spawn:

			int Owner = GetEntPropEnt(OtherEnt, Prop_Data, "m_hOwnerEntity");

			//Connected:
			if(Owner > 0 && Owner <= GetMaxClients() && IsClientConnected(Owner) && IsClientInGame(Owner))
			{

				//Check Is Cop:
				if(!IsCop(Owner))
				{

					//Initulize:
					PdBombEntArmed[X] = true;

					//Request:
					RequestFrame(OnNextFrameKill, OtherEnt);

					//Print:
					CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF %i bomb(s) have been armed at the police department", GetPdBombsArmed());

					//SetBank:
					SetBank(Owner, (GetBank(Owner) + 2000));

					//Print:
					CPrintToChat(Owner, "\x07FF4040|RP|\x07FFFFFF You have earned %s for arming the bomb", IntToMoney(2000));

					//Set Color:
					SetEntityRenderColor(Ent, 120, 255, 120, 255);

					//Return:
					return true;
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Owner, "\x07FF4040|RP|\x07FFFFFF You need to distroy the bomb not arm it!");
				}
			}
		}
	}

	//Return:
	return false;
}