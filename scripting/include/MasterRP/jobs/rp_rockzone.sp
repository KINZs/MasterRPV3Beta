//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_rockzone_included_
  #endinput
#endif
#define _rp_rockzone_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXROCKS			5

//Definitions:
int RockEnt[MAXROCKS + 1] = {-1,...};
int RockResources[MAXROCKS + 1] = {0,...};

public void initRockZones()
{

	//Commands:
	RegAdminCmd("sm_createrock", Command_CreateRock, ADMFLAG_ROOT, "<id> - Create a rock for mining");

	RegAdminCmd("sm_saverock", Command_SaveRock, ADMFLAG_ROOT, "<id> - Save a rock for mining");

	RegAdminCmd("sm_removerock", Command_RemoveRock, ADMFLAG_ROOT, "<id> - Removes a rock from the db");

	RegAdminCmd("sm_listrocks", Command_ListRocks, ADMFLAG_SLAY, "- Lists all the rocks in the database");

	//Beta
	RegAdminCmd("sm_wiperocks", Command_WipeRocks, ADMFLAG_ROOT, "");

	//Timers:
	CreateTimer(0.2, CreateSQLdbRocks);
}

public void initRockResources()
{

	//Loop:
	for(int X = 0; X <= MAXROCKS; X++)
	{

		//Check:
		if(IsValidEdict(RockEnt[X]))
		{

			//Check:
			if(RockResources[X] < 1500)
			{

				//Declare:
				int Amount = GetRandomInt(25, 60);

				//Check:
				if(RockResources[X] + Amount > 1500)
				{

					//Initulize:
					RockResources[X] = 1500;
				}

				//Override:
				{

					//Initulize:
					RockResources[X] += Amount;
				}
			}
		}
	}
}

//Create Database:
public Action CreateSQLdbRocks(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `RockZones`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `RockId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Model` varchar(128) NOT NULL, `Position` varchar(32) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `angles` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadRockZone(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM RockZones WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadRockZones, query);
}

//Create Garbage Zone:
public Action Command_CreateRock(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Useage: - sm_createrock <Model>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char modelname[255];

	//Initulize:
	GetCmdArg(1, modelname, sizeof(modelname));

	if(!IsModelPrecached(modelname)) PrecacheModel(modelname, true);

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

	//Spawn Prop
	int Ent = CreateEntityByName("prop_physics_override");

	DispatchKeyValue(Ent, "physdamagescale", "0.0");

	DispatchKeyValue(Ent, "model", modelname);

	DispatchSpawn(Ent);

	//Teleport:
	TeleportEntity(Ent, Origin, EyeAngles, NULL_VECTOR);

	//Set Physics:
	SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);   

	//Set ClassName:
	SetEntityClassName(Ent, "prop_Rock");

	//Return:
	return Plugin_Handled;
}

//Save:
public Action Command_SaveRock(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_saverocks <id>");

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

	//Prop Garbage Can:
	if(!IsValidRock(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Check:
	if(StringToInt(SpawnId) < 0 || StringToInt(SpawnId) > MAXROCKS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_saverocks <0-%i>", MAXROCKS);

		//Return:
		return Plugin_Handled;
	}

	//Spawn Already Created:
	if(IsValidEdict(RockEnt[StringToInt(SpawnId)]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is already a Rock index into the db. (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Origin[3];
	float Angles[3];
	char ModelName[128];

	//Initluze:
	GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", Origin);

	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles);

	GetEntPropString(Ent, Prop_Data, "m_ModelName", ModelName, sizeof(ModelName));

	//Declare:
	char query[512];
	char Position[128];
	char Ang[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", Origin[0], Origin[1], Origin[2]);

	//Sql String:
	Format(Ang, sizeof(Ang), "%f^%f^%f", Angles[0], Angles[1], Angles[2]);

	//Format:
	Format(query, sizeof(query), "INSERT INTO RockZones (`Map`,`RockId`,`Model`,`Position`,`Angles`) VALUES ('%s',%i,'%s','%s','%s');", ServerMap(), StringToInt(SpawnId), ModelName, Position, Ang);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	RockEnt[StringToInt(SpawnId)] = Ent;

	//Set Health:
	SetEntProp(Ent, Prop_Data, "m_iHealth", 500);

	//MaxHealth:
	SetEntProp(Ent, Prop_Data, "m_iMaxHealth", 500);

	//Invincible:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnRockTakeDamage);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Saved Rock \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove:
public Action Command_RemoveRock(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removerock <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Spawn Already Created:
	if(!IsValidEdict(RockEnt[StringToInt(SpawnId)]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM RockZones WHERE RockId = %i AND Map = '%s';", StringToInt(SpawnId), ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Rock (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListRocks(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Rock Zones List: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXROCKS + 1; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM RockZones WHERE Map = '%s' AND RockId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintRocks, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeRocks(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Rock List Wiped: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 1; X < MAXROCKS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM RockZones WHERE RockId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBLoadRockZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadRockZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Rocks Found in DB!");

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
			char Model[128];
			float Position[3];
			float Angles[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Model, 128);

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 4, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Angles[Y] = StringToFloat(Dump[Y]);
			}

			//Create:
			int Ent = CreateProp(Position, Angles, Model, false, true);

			//Set Health:
			SetEntProp(Ent, Prop_Data, "m_iHealth", 500);

			//MaxHealth:
			SetEntProp(Ent, Prop_Data, "m_iMaxHealth", 1500);

			//Invincible:
			SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

			//Damage Hook:
			SDKHook(Ent, SDKHook_OnTakeDamage, OnRockTakeDamage);

			//Initulize:
			RockEnt[X] = Ent;

			//Set ClassName:
			SetEntityClassName(Ent, "prop_Rock");
		}

		//Print:
		PrintToServer("|RP| - Rock Found!");
	}
}

public void T_DBPrintRocks(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintRocks: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int SpawnId = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", SpawnId, Buffer);
		}
	}
}

public bool IsValidRock(int Ent)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Door:
	if(StrEqual(ClassName, "prop_Rock"))
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

//Event Damage:
public Action OnRockTakeDamage(int Entity, int &Attacker, int &Inflictor, float &Damage, int &DamageType)
{

	//Check:
	if(Attacker > 0 && Attacker <= GetMaxClients())
	{

		//Declare:
		char WeaponName[32];

		//Initulize;
		GetClientWeapon(Attacker, WeaponName, sizeof(WeaponName));

		//Is Stun Stick:
		if(StrEqual(WeaponName, GetArrestWeapon(), false) || StrEqual(WeaponName, GetRepairWeapon(), false))
		{

			//Declare:
			float Origin[3];
			float Position[3];

			//Get Prop Data:
			GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", Position);

			GetClientAbsOrigin(Attacker, Origin);

			//Declare:
			float Dist = GetVectorDistance(Position, Origin);

			//In Distance:	
			if(Dist <= 150)
			{

				//Loop:
				for(int X = 0; X < MAXROCKS; X++)
				{

					//Valid:
					if(RockEnt[X] == Entity)
					{

						//Check:
						if(RockResources[X] == 0)
						{

							//Print:
							CPrintToChat(Attacker, "\x07FF4040|RP|\x07FFFFFF - This rock has no more resources!");
						}

						//Override:
						else
						{

							//Declare:
							int Amount = RoundFloat(Damage / 2);

							//Check:
							if(RockResources[X] - Amount < 0)
							{

								//Initulize:
								SetResources(Attacker, (GetResources(Attacker) + RockResources[X]));

								RockResources[X] = 0;
							}

							//Override:
							else
							{

								//Initulize:
								SetResources(Attacker, (GetResources(Attacker) + Amount));

								RockResources[X] -= Amount;
							}
						}
					}
				}
			}
		}

		//Initulize:
		Damage = 0.0;

		//Return:
		return Plugin_Changed;
	}

	//Health:
	int Health = GetEntProp(Entity, Prop_Data, "m_iHealth");

	//Check:
	if(Health - RoundFloat(Damage) <= 0)
	{

		//Health:
		SetEntProp(Entity, Prop_Data, "m_iHealth", 1500);
	}

	//Initulize:
	Damage = 0.0;

	//Return:
	return Plugin_Changed;
}

public void RockHud(int Client, int Entity, float NoticeInterval)
{

	//Loop:
	for(int X = 0; X < MAXROCKS; X++)
	{

		//Valid:
		if(RockEnt[X] == Entity)
		{

			//Declare:
			char FormatMessage[255];

			//Check:
			if(RockResources[X] == 0)
			{

				//Format:
				Format(FormatMessage, sizeof(FormatMessage), "Rock:\nResources: Non Avaiable!");
			}

			//Override:
			else
			{

				//Format:
				Format(FormatMessage, sizeof(FormatMessage), "Rock:\nResources %i!", RockResources[X]);
			}

			//Declare:
			float Pos[2] = {-1.0, -0.805};
			int Color[4];

			//Initulize:
			Color[0] = GetEntityHudColor(Client, 0);
			Color[1] = GetEntityHudColor(Client, 1);
			Color[2] = GetEntityHudColor(Client, 2);
			Color[3] = 255;

			//Check:
			if(GetGame() == 2 || GetGame() == 3)
			{

				//Show Hud Text:
				CSGOShowHudTextEx(Client, 1, Pos, Color, Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
			}

			//Override:
			else
			{

				//Show Hud Text:
				ShowHudTextEx(Client, 1, Pos, Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
			}
		}
	}
}