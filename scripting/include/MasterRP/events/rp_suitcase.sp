//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_suitcase_included_
  #endinput
#endif
#define _rp_suitcase_included_

//Defines:
#define MAXSUITCASEZONES		10

//Euro - € dont remove this!
//€ = �

//SuitCase!
float SuitCaseZones[MAXSUITCASEZONES + 1][3];
int SuitCaseTimer = 0;
int SuitCaseEnt = -1;

public void initSuitCase()
{

	//Commands:
	RegAdminCmd("sm_createsuitcasezone", CommandCreateSuitCaseZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removesuitcasezone", CommandRemoveSuitCaseZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listsuitcasezone", CommandListSuitCases, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipesuitcasezones", Command_WipeSuitCaseZone, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testsuitcasezone", CommandTestSuitCaseZone, ADMFLAG_ROOT, "<id> - Test SuitCase Spawn");

	//Timers:
	CreateTimer(0.2, CreateSQLdbSuitCaseZone);

	//PreCache Model
	PrecacheModel("models/props_c17/briefcase001a.mdl");

	//Loop:
	for(int Z = 0; Z <= MAXSUITCASEZONES; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		SuitCaseZones[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbSuitCaseZone(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `SuitCase`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadSuitCaseZone(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXSUITCASEZONES; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		SuitCaseZones[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM SuitCase WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadSuitCaseZones, query);
}

public void T_DBLoadSuitCaseZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadSuitCaseZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No SuitCase Zones Found in DB!");

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
			SuitCaseZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - SuitCase Zones Found!");
	}
}

public void T_DBPrintSuitCaseZones(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintSuitCaseZones: Query failed! %s", error);
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

// remove players from Vehicles before they are destroyed or the server will crash!
public void OnSuitCaseDestroyed(int Entity)
{

	//Is Valid:
	if(IsValidEdict(Entity))
	{

		//Someone Broke the SuitCase:
		if(SuitCaseEnt == Entity)
		{

			//Initulize:
			SuitCaseEnt = -1;
		}
	}
}

public void initSuitCaseTick()
{

	//Initulize:
	SuitCaseTimer++;

	//TimerCheck
	if(SuitCaseTimer >= GetSuitCaseDropTimer())
	{

		//Initulize:
		SuitCaseTimer = 0;

		//Invalid Check:
		if(SuitCaseEnt == -1)
		{

			//Declare:
			int Var = GetRandomInt(0, 10);

			SpawnNPCToDropOffSuitCase(Var);

			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - A suitcase has been dropped!");
		}

		//Override:
		else
		{

			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - There is already a suitcase spawned on the map!");
		}
	}
}

//Use Handle:
public Action OnSuitCaseUse(int Client, int Ent)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected
		if(IsClientConnected(i) && IsClientInGame(i) && i != Client)
		{

			//Print:
			CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - The SuitCase has been found by \x0732CD32%N\x07FFFFFF!", Client);
		}
	}

	//Random:
	int Random = GetRandomInt(1, 10);
	int R = 0;

	//Declare:
	R = GetRandomInt(1000, 5000);
	SetCash(Client, (GetCash(Client) + R));

	//Print
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have found \x0732CD32%s!", IntToMoney(R));

	if(Random == 1)
	{

		//Save:
		SaveItem(Client, 10, (GetItemAmount(Client, 1) + 10));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have found a %s pack!", GetItemName(1));
	}

	if(Random == 2)
	{

		//Declare:
		R = 500;

		//Initulize:
		SetResources(Client, (GetResources(Client) + R));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found %ig of combine Resources!", R);
	}

	if(Random == 3)
	{

		//Declare:
		R = 500;

		//Initulize:
		SetHarvest(Client, (GetHarvest(Client) + R));

		//Initulize:
		SetCrime(Client, (GetCrime(Client) + R));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found %ig of Harvest!", R);
	}

	if(Random == 4)
	{

		//Declare:
		R = 50;

		//Initulize:
		SetCocain(Client, (GetCocain(Client) + R));

		//Initulize:
		SetCrime(Client, (GetCrime(Client) + (R * 30)));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found %ig of Cocain!", R);
	}

	if(Random == 5)
	{

		//Declare:
		R = 50;

		//Initulize:
		SetPills(Client, (GetPills(Client) + R));

		//Initulize:
		SetCrime(Client, (GetCrime(Client) + (R * 10)));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found %i of Pills!", R);
	}

	if(Random == 6)
	{

		//Declare:
		R = 50;

		//Initulize:
		SetMeth(Client, (GetMeth(Client) + R));

		//Initulize:
		SetCrime(Client, (GetCrime(Client) + (R * 10)));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found %i of Meth!", R);
	}

	if(Random == 7)
	{

		//Declare:
		R = GetRandomInt(211, 215);

		//Save:
		SaveItem(Client, R, (GetItemAmount(Client, R) + 1));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have found a %s!", GetItemName(R));
	}

	if(Random == 8)
	{

		//SDKHooks Forward:
		SDKHooks_TakeDamage(Client, SuitCaseEnt, SuitCaseEnt, 95.0, (1 << 17));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have found a used needle!");
	}

	if(Random == 9)
	{

		//Declare:
		R = GetRandomInt(55, 56);

		//Save:
		SaveItem(Client, R, (GetItemAmount(Client, R) + 10));

		//SDKHooks Forward:
		SDKHooks_TakeDamage(Client, SuitCaseEnt, SuitCaseEnt, 95.0, (1 << 17));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have found 10x of %s!", GetItemName(R));
	}

	if(Random == 10)
	{

		//Declare:
		R = 2500;

		//Initulize:
		SetRice(Client, (GetRice(Client) + R));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found %ig of Rice!", R);
	}

	//Request:
	RequestFrame(OnNextFrameKill, SuitCaseEnt);

	//Initulize:
	SuitCaseEnt = -1;
}

public void SpawnNPCToDropOffSuitCase(int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return;
	}

	//Check:
	if(SuitCaseEnt > 0)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - There is already a SuitCase spawned on the map!");

		PrintToServer("|RP| - There is already a SuitCase spawned on the map!");

		//Return:
		return;
	}

	//Check:
	if(TR_PointOutsideWorld(SuitCaseZones[Var]))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Unable to Drop Supply SuitCase Due to outside of world");

		PrintToServer("|RP| - Unable to Drop Supply SuitCase Due to outside of world");

		//Return:
		return;
	}

	//Declare:
	char NpcSound[5][255];
	char Npc[5][32];
	int R = GetRandomInt(0, 4);

	//Select Item
	switch(R)
	{

		case 0:
		{

			//Format:
			Format(NpcSound[R], sizeof(NpcSound[]), "vo/gman_misc/gman_riseshine.wav");
			Format(Npc[R], sizeof(Npc[]), "npc_gman");
		}

		case 1:
		{

			//Format:
			Format(NpcSound[R], sizeof(NpcSound[]), "vo/eli_lab/al_havefun.wav");
			Format(Npc[R], sizeof(Npc[]), "npc_alyx");
		}

		case 2:
		{

			//Format:
			Format(NpcSound[R], sizeof(NpcSound[]), "vo/citadel/mo_nouse.wav");
			Format(Npc[R], sizeof(Npc[]), "npc_mossman");
		}

		case 3:
		{

			//Format:
			Format(NpcSound[R], sizeof(NpcSound[]), "vo/citadel/br_justhurry.wav");
			Format(Npc[R], sizeof(Npc[]), "npc_breen");
		}

		case 4:
		{

			//Format:
			Format(NpcSound[R], sizeof(NpcSound[]), "vo/trainyard/ba_thatbeer02.wav");
			Format(Npc[R], sizeof(Npc[]), "npc_barney");
		}
	}

	//Initialize:
	int NPC = CreateEntityByName(Npc[R]);

	//Is Valid:
	if(NPC > 0)
	{

		//Check:
		if(R == 3)
		{

			//Timer:
			CreateTimer(2.0, BreenSoundEffect, NPC);
		}

		//Spawn & Send:
		DispatchSpawn(NPC);

		//Declare:
		float Angles[3] = {0.0, 0.0, 0.0};

		//Initulize:
		Angles[1] = GetRandomFloat(0.0, 360.0);

		//Set Damage:
		SetEntProp(NPC, Prop_Data, "m_takedamage", 0, 1);

		//Set NPC Health:
		SetEntProp(NPC, Prop_Data, "m_iHealth", 5000);

		//Invincible:
		SetEntProp(NPC, Prop_Data, "m_takedamage", 0, 1);

		//Debris:
		int Collision = GetEntSendPropOffs(NPC, "m_CollisionGroup");
		SetEntData(NPC, Collision, 1, 1, true);

		//Teleport:
		TeleportEntity(NPC, SuitCaseZones[Var], Angles, NULL_VECTOR);

		//Is Precached:
		if(IsSoundPrecached(NpcSound[R])) PrecacheSound(NpcSound[R]);

		//Play Sound:
		EmitAmbientSound(NpcSound[R], SuitCaseZones[Var], NPC, SOUND_FROM_PLAYER, SNDLEVEL_RAIDSIREN);

		//Declare:
		int Tesla = -1;

		//Initulize:
		Tesla = CreatePointTesla(NPC, "chest", "50 250 50");

		//Timer:
		CreateTimer(1.0, RemoveSpawnEffect, Tesla);

		//Spawn:
		CreateTimer(4.5, SpawnSuitCaseTimer, Var);

		//Timer:
		CreateTimer(5.5, OnRemoveNPC, NPC);

		//Timer:
		CreateTimer(6.0, RemoveSpawnEffect, NPC);
	}
}

//Remove Effect:
public Action BreenSoundEffect(Handle Timer, any NPC)
{

	//Not Valid Ent:
	if(IsValidEdict(NPC))
	{

		//Declare:
		float Position[3];
		char Sound[255] = "vo/citadel/br_ohshit.wav";

		//Initulize:
		GetEntPropVector(NPC, Prop_Send, "m_vecOrigin", Position);

		//Is Precached:
		if(IsSoundPrecached(Sound)) PrecacheSound(Sound);

		//Play Sound:
		EmitAmbientSound(Sound, Position, NPC, SOUND_FROM_PLAYER, SNDLEVEL_RAIDSIREN);
	}
}

//Remove Effect:
public Action OnRemoveNPC(Handle Timer, any NPC)
{

	//Not Valid Ent:
	if(IsValidEdict(NPC))
	{

		//Declare:
		int Tesla = -1;

		//Initulize:
		Tesla = CreatePointTesla(NPC, "chest", "50 250 50");

		//Timer:
		CreateTimer(1.0, RemoveSpawnEffect, Tesla);
	}
}

//Remove Effect:
public Action SpawnSuitCaseTimer(Handle Timer, any Var)
{

	//Is Valid:
	SpawnSuitCase(Var);
}

public int SpawnSuitCase(int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return view_as<int>(-1);
	}

	//Check:
	if(SuitCaseEnt > 0)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - There is already a SuitCase spawned on the map!");

		PrintToServer("|RP| - There is already a SuitCase spawned on the map!");

		//Return:
		return view_as<int>(-1);
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	Angles[1] = GetRandomFloat(0.0, 360.0);

	//Declare:
	float Origin[3];

	Origin[0] = SuitCaseZones[Var][0];

	Origin[1] = SuitCaseZones[Var][1];

	Origin[2] = SuitCaseZones[Var][2] + 20.0;

	//Check:
	if(TR_PointOutsideWorld(Origin))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Unable to Drop Supply SuitCase Due to outside of world");

		PrintToServer("|RP| - Unable to Drop Supply SuitCase Due to outside of world");

		//Return:
		return view_as<int>(-1);
	}

	//Declare:
	int Ent = CreateProp(Origin, Angles, "models/props_c17/briefcase001a.mdl", true, false);

	//Set Damage:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_SuitCase");

	//Initulize:
	SuitCaseEnt = Ent;

	//Return:
	return view_as<int>(Ent);
}

//Create Garbage Zone:
public Action CommandCreateSuitCaseZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createsuitcase <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createsuitcase <0-10>");

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
	if(SuitCaseZones[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE SuitCase SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO SuitCase (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	SuitCaseZones[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created SuitCase spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action CommandRemoveSuitCaseZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removesuitcase <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removesuitcase <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(SuitCaseZones[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	SuitCaseZones[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM SuitCase WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed SuitCase Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action CommandListSuitCases(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "SuitCase Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXSUITCASEZONES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM SuitCase WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintSuitCaseZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeSuitCaseZone(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "SuitCase Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXSUITCASEZONES; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM SuitCase WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action CommandTestSuitCaseZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testsuitcasezone <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testsuitcasezone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//Spawn:
	SpawnNPCToDropOffSuitCase(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, SuitCaseZones[Id][0], SuitCaseZones[Id][1], SuitCaseZones[Id][2]);

	//Return:
	return Plugin_Handled;
}

//Use Handle:
public bool IsSuitCase(int Ent)
{

	//Not Valid Ent:
	if(Ent != -1 && Ent > 0 && IsValidEdict(Ent))
	{

		//Found SuitCase!
		if(SuitCaseEnt == Ent)
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public int GetSuitCaseEnt()
{

	//Return:
	return view_as<int>(SuitCaseEnt);
}

public void SetSuitCaseEnt(int Ent)
{

	//Initulize:
	SuitCaseEnt = Ent;
}