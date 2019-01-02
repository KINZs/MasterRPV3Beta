//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_policeboss_included_
  #endinput
#endif
#define _rp_policeboss_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

#define MAXPOLICEBOSSSPAWNS	5

float PoliceBossZones[MAXPOLICEBOSSSPAWNS + 1][3];

int PoliceBossTime = 0;
Handle hPoliceBossTimer = INVALID_HANDLE;
int PoliceBoss = -1;

public void initPoliceBoss()
{

	//Commands:
	RegAdminCmd("sm_createpolicebossspawn", Command_CreatePoliceBossZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removepolicebossspawn", Command_RemovePoliceBossZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listpolicebossspawn", Command_ListPoliceBossSpawns, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipepolicebossspawn", Command_WipePoliceBossZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testpolicebossspawn", Command_TestPoliceBossZone, ADMFLAG_ROOT, "<id> - Test PoliceBoss Spawn");

	//Public Commands:
	RegConsoleCmd("sm_policeboss", Command_PoliceBoss);

	//Timers:
	CreateTimer(0.2, CreateSQLdbPoliceBossSpawns);

	//Loop:
	for(int Z = 0; Z <= MAXPOLICEBOSSSPAWNS; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		PoliceBossZones[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbPoliceBossSpawns(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `PoliceBossSpawns`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadPoliceBossSpawns(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXPOLICEBOSSSPAWNS; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		PoliceBossZones[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM PoliceBossSpawns WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadPoliceBossSpawns, query);
}

public void T_DBLoadPoliceBossSpawns(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadPoliceBossSpawns: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No PoliceBoss Zones Found in DB!");

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
			PoliceBossZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - PoliceBoss Zones Zones Found!");
	}
}

public void T_DBPrintPoliceBossSpawns(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintPoliceBossSpawns: Query failed! %s", error);
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

public void initPoliceBossTimer()
{

	//Check:
	if(PoliceBossTime > 0)
	{

		//Initulize:
		PoliceBossTime -= 1;

		//Switch:
		switch(PoliceBossTime)
		{

			//Activate PoliceBoss:
			case 1:
			{

				//Deactivate:
				DeactivatePoliceBoss();
			}

			//Activate PoliceBoss:
			case 80:
			{

				//Print:
				PrintPoliceBossMessage();
			}


			//Activate PoliceBoss:
			case 160:
			{

				//Print:
				PrintPoliceBossMessage();

				//Declare:
				float Origin[3] = {0.0, 0.0, 500.0};

				//Play Sound:
				EmitAmbientSound(JudgementWaver, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
			}


			//Activate PoliceBoss:
			case 220:
			{

				//Print:
				PrintPoliceBossMessage();
			}

			//Activate PoliceBoss:
			case 300:
			{

				//Activate:
				ActivatePoliceBoss();
			}
		}

		//Check:
		if(IsValidEdict(PoliceBoss))
		{

			//Declare:
			float ClientOrigin[3];
			float Origin[3];

			//Initulize:
			GetEntPropVector(PoliceBoss, Prop_Send, "m_vecOrigin", Origin);

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Initulize:
					GetEntPropVector(i, Prop_Send, "m_vecOrigin", ClientOrigin);

					//Declare:
					float Dist = GetVectorDistance(Origin, ClientOrigin);

					//In Distance:
					if(Dist <= 225 && IsTargetInLineOfSight(PoliceBoss, i))
					{

						//Declare:
						int Effect = GetEntAttatchedEffect(PoliceBoss, 2);

						//Check:
						if(IsValidEdict(Effect))
						{

							//Spark:
							AcceptEntityInput(Effect, "TurnOn");
						}

						//Has Shield Near By:
						if(IsShieldInDistance(i))
						{

							//Shield Forward:
							OnClientShieldDamage(i, 25.0);
						}

						//Check:
						else if(IsPlayerAlive(i))
						{

							//Check:
							if(GetClientHealth(i) - 25 <= 0)
							{

								//Damage Client:
								SDKHooks_TakeDamage(i, PoliceBoss, PoliceBoss, 25.0, DMG_DISSOLVE);
							}

							//Override:
							else
							{

								//Damage Client:
								SDKHooks_TakeDamage(i, PoliceBoss, PoliceBoss, 25.0, DMG_DISSOLVE & DMG_PREVENT_PHYSICS_FORCE);
							}
						}
					}

					//Override:
					else
					{

						//Declare:
						int Effect = GetEntAttatchedEffect(PoliceBoss, 2);

						//Check:
						if(IsValidEdict(Effect))
						{

							//Spark:
							AcceptEntityInput(Effect, "TurnOff");
						}
					}
				}
			}
		}
	}
}

public void StartPoliceBoss(int Client)
{

	//Initulize:
	PoliceBossTime = 360;

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N has activated a Police Boss in 60 seconds!", Client);
}

public void ActivatePoliceBoss()
{

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Police Boss has now been Activated!");

	//Declare:
	float Origin[3] = {0.0, 0.0, 500.0};

	//Play Sound:
	EmitAmbientSound(JudgementWaver, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);

	//Play Sound:
	EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);

	//Timer:
	hPoliceBossTimer = CreateTimer(30.0, ActiveAlarmShakeTimer, _, TIMER_REPEAT);

	//Spawn:
	initPoliceBossSpawns();

	//Shake:
	ShakeGlobal(10.0);
}

public void PrintPoliceBossMessage()
{

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - All citizens not inside a building can be shot on sight!");
}

public void DeactivatePoliceBoss()
{

	//Check:
	if(hPoliceBossTimer != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(hPoliceBossTimer);

		//Initulize:
		hPoliceBossTimer = INVALID_HANDLE;
	}

	//Check:
	if(IsValidEdict(PoliceBoss))
	{

		//Request:
		RequestFrame(OnNextFrameKill, PoliceBoss);

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - You have failed to defeat the Police Boss!");
	}
}

public void PoliceBossAlarmSound()
{

	//Declare:
	float Origin[3] = {0.0, 0.0, 500.0};

	//Play Sound:
	EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
}

public void initPoliceBossSpawns()
{

	//Print:
	//PrintToServer("|RP| - initPoliceBossSpawns()");

	//Declare:
	int Random = GetRandomInt(0, MAXPOLICEBOSSSPAWNS);

	//Check:
	if(PoliceBossZones[Random][0] != 69.0)
	{

		//Create NPCS!
		CreatePoliceBoss(Random);
	}
}

public int CreatePoliceBoss(int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return -1;
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Check:
	if(TR_PointOutsideWorld(PoliceBossZones[Var]))
	{

		//Print:
		PrintToServer("|RP| - Unable to Spawn manhack on PoliceBoss due to outside of world");

		//Return:
		return -1;
	}

	//Check:
	if(GetGame() == 1)
	{

		//Declare:
		int Ent = CreateNpcAdvisor("models/advisor.mdl", PoliceBossZones[Var], Angles, 10000);

		//Set Color:
		SetEntityRenderColor(Ent, 50, 50, 250, 255);

		//Sent Ent Render:
		//SetEntityRenderMode(Ent, RENDER_GLOW);

		//Initulize:
		int Effect = CreateEnvSmokeTrail(Ent, "null", "materials/effects/fire_cloud1.vmt", "400.0", "200.0", "200.0", "100", "30", "50", "100", "0", "50 50 255", "5");

		SetEntAttatchedEffect(Ent, 0, Effect);

		//Initulize:
		Effect = CreateLight(Ent, 1, 120, 120, 255, "null");

		SetEntAttatchedEffect(Ent, 1, Effect);

		//CreateEffect:
		Effect = CreateEnvFireExtinguisher(Ent, "null", Angles);

		SetEntAttatchedEffect(Ent, 2, Effect);

		//Spark:
		AcceptEntityInput(Effect, "TurnOff");

		//Send:
		SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", 2.5);

		//Initulize:
		PoliceBoss = Ent;

		//Print:
		//PrintToServer("|RP| - Manhack Spawned on PoliceBoss");

		//Return:
		return Ent;
	}

	//Override:
	else
	{

		//Print:
		PrintToServer("|RP| - Unable to Spawn manhack on PoliceBoss due to outside of world");
	}

	//Return:
	return -1;
}

public void OnAdvisorBossDied(int Entity, int Attacker)
{

	//Check:
	if(hPoliceBossTimer != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(hPoliceBossTimer);

		//Initulize:
		hPoliceBossTimer = INVALID_HANDLE;
	}

	//Initulize:
	PoliceBoss = -1;

	//Initulize:
	PoliceBossTime = 0;

	RemoveLockdownNPCs();
}

public Action Command_PoliceBoss(int Client, int Args)
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
	if(!IsAdmin(Client) && !IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you don't have access to this command.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(PoliceBossTime > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate another PoliceBoss whilst we're still in one!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetGlobalCrime() > 20000 && !IsAdmin(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate a PoliceBoss without the required crime on the server !");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetMetal(Client) -10000 >= 0 && GetResources(Client) - 5000 >= 0 || IsAdmin(Client))
	{

		if(!IsAdmin(Client))
		{

			//Initulize:
			SetMetal(Client, (GetMetal(Client) - 10000));
			SetResources(Client, (GetResources(Client) - 5000));
		}

		//Start:
		StartLockdown(Client);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have the required materials! 10000g of metal and 5000g of resources required!");
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_CreatePoliceBossZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createpolicebossspawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createpolicebossspawn <0-10>");

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
	if(PoliceBossZones[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE PoliceBossSpawns SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO PoliceBossSpawns (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	PoliceBossZones[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created PoliceBoss npc spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemovePoliceBossZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removepolicebossspawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removepolicebossspawn <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(PoliceBossZones[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	PoliceBossZones[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM PoliceBossSpawns WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed PoliceBoss npc Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

public Action Command_ListPoliceBossSpawns(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Police Boss Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXPOLICEBOSSSPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM PoliceBossSpawns WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintPoliceBossSpawns, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipePoliceBossZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Police Boss Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXPOLICEBOSSSPAWNS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM PoliceBossSpawns WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_TestPoliceBossZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testpolicebossspawn <id>");

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
	if(Id < 0 || Id > 5)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testpolicebossspawn <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//Spawn:
	CreatePoliceBoss(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, PoliceBossZones[Id][0], PoliceBossZones[Id][1], PoliceBossZones[Id][2]);

	//Return:
	return Plugin_Handled;
}

public bool IsPoliceBossActive()
{

	//Check:
	if(PoliceBossTime > 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public void OnPoliceBossNPCDestroyedCheck(int Entity)
{

	//Check:
	if(PoliceBoss == Entity)
	{

		//Initulize:
		PoliceBoss = -1;
	}
}

public void RemovePoliceBossNPC(int Ent)
{

	//Check:
	if(PoliceBoss == Ent)
	{

		//Initulize:
		PoliceBoss = -1;
	}
}

public bool IsValidPoliceBoss(int Ent)
{

	//Check:
	if(PoliceBoss == Ent)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}
