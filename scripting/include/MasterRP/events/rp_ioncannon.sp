//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_Ioncannonzone_included_
  #endinput
#endif
#define _rp_Ioncannonzone_included_

//Defines:
#define MAXIONCANNONZONES		10

//Euro - € dont remove this!
//€ = �

//Random IonCannon Zones!
float IonCannonZones[MAXIONCANNONZONES + 1][3];
int IonCannonZoneTimer = 0;
int GlobalIonCannonEnt = -1;

public void initGlobalIonCannon()
{

	//Commands:
	RegAdminCmd("sm_createioncannonzone", Command_CreateIonCannonZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removeioncannonzone", Command_RemoveIonCannonZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listioncannonzones", Command_ListIonCannonZones, ADMFLAG_SLAY, " Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipeioncannonzones", Command_WipeIonCannonZones, ADMFLAG_ROOT, "Resets Ion Cannon Database");

	RegAdminCmd("sm_testioncannonzone", Command_TestIonCannonZone, ADMFLAG_ROOT, "<id> - Test IonCannon Spawn");

	//Timers:
	CreateTimer(0.2, CreateSQLdbIonCannonZones);

	//Loop:
	for(int Z = 0; Z <= MAXIONCANNONZONES; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		IonCannonZones[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbIonCannonZones(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `IonCannonZones`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 144);
}

//Create Database:
public Action LoadIonCannonZones(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXIONCANNONZONES; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		IonCannonZones[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM IonCannonZones WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadIonCannonZones, query);
}

public void T_DBLoadIonCannonZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadIonCannonZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Random IonCannon Zones Found in DB!");

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
			IonCannonZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - IonCannon Zones Found!");
	}
}

public void T_DBPrintIonCannonZones(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintIonCannonZones: Query failed! %s", error);
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
public void OnIonCannonDestroyed(int Entity)
{

	//Is Valid:
	if(IsValidEdict(Entity))
	{

		//Someone Broke the IonCannon!:
		if(GlobalIonCannonEnt == Entity)
		{

			//Initulize:
			GlobalIonCannonEnt = -1;

			//Check:
			if(IsValidAttachedEffect(GlobalIonCannonEnt))
			{

				//Remove:
				RemoveAttachedEffect(GlobalIonCannonEnt);
			}
		}
	}
}

public void initGlobalIonCannonTick()
{

	//Initulize:
	IonCannonZoneTimer++;

	//TimerCheck
	if(IonCannonZoneTimer >= GetIonCannonSpawnTimer())
	{

		//Invalid Check:
		if(GlobalIonCannonEnt == -1)
		{

			//Declare:
			int Var = GetRandomInt(0, 10);

			//Spawn:
			SpawnGlobalIonCannon(Var);

			//Initulize:
			IonCannonZoneTimer = 0;
		}

		//Initulize:
		IonCannonZoneTimer += 1;
	}
}

public int SpawnGlobalIonCannon(int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return view_as<int>(-1);
	}

	//Check:
	if(GlobalIonCannonEnt >= 0)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - There is already a IonCannon spawned on the map!");

		PrintToServer("|RP| - There is already a IonCannon spawned on the map!");

		//Return:
		return view_as<int>(-1);
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Check:
	if(TR_PointOutsideWorld(IonCannonZones[Var]))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Unable to Drop IonCannon Due to outside of world");

		PrintToServer("|RP| - Unable to Drop IonCannon Due to outside of world");

		//Return:
		return view_as<int>(-1);
	}

	//Declare:
	int Ent = CreateProp(IonCannonZones[Var], Angles, "models/Combine_Helicopter/helicopter_bomb01.mdl", true, true);

	//Set Damage:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Set Trans Effect:
	SetEntityRenderMode(Ent, RENDER_GLOW);

	//Set Color:
	SetEntityRenderColor(Ent, 255, 255, 255, 0);

	//Initulize:
	GlobalIonCannonEnt = Ent;

	//Create IonCannon Explosion:
	ExplodeGlobalIonCannonStage1();

	//Return:
	return view_as<int>(Ent);
}

public void ExplodeGlobalIonCannonStage1()
{

	//Initialize:
	int BeamColor[4] = {100, 150, 250, 255};
	float AboveOrigin[3];
	float Position[3];

	//Initulize:
	GetEntPropVector(GlobalIonCannonEnt, Prop_Send, "m_vecOrigin", Position);

	AboveOrigin[0] = Position[0];
	AboveOrigin[1] = Position[1];
	AboveOrigin[2] = Position[2] + 4000;
	Position[2] + 3000;

	//End Temp:
	TE_SetupBeamPoints(Position, AboveOrigin, Laser(), 0, 0, 66, 0.5, 1.0, 3.0, 0, 0.0, BeamColor, 0);

	//Show To Client:
	TE_SendToAll();

	//Create Custom Light:
	int Light = CreateCustomLight(GlobalIonCannonEnt, 1, 100, 100, 255, 50.0, "640", "90", "2", "1", "null");

	//Initulize:
	SetEntAttatchedEffect(GlobalIonCannonEnt, 5, Light);

	//Timer:
	CreateTimer(0.25, IonCannonStage2);
}

public Action IonCannonStage2(Handle Timer)
{

	//Initialize:
	int BeamColor[4] = {100, 150, 250, 255};
	float AboveOrigin[3];
	float Position[3];

	//Initulize:
	GetEntPropVector(GlobalIonCannonEnt, Prop_Send, "m_vecOrigin", Position);

	AboveOrigin[0] = Position[0];
	AboveOrigin[1] = Position[1];
	AboveOrigin[2] = Position[2] + 4000;
	Position[2] + 3000;

	//End Temp:
	TE_SetupBeamPoints(Position, AboveOrigin, Laser(), 0, 0, 66, 0.5, 3.0, 9.0, 0, 0.0, BeamColor, 0);

	//Show To Client:
	TE_SendToAll();

	AboveOrigin[2] -= 1000;
	Position[2] -= 1000;

	//End Temp:
	TE_SetupBeamPoints(Position, AboveOrigin, Laser(), 0, 0, 66, 0.5, 3.0, 9.0, 0, 0.0, BeamColor, 0);

	//Show To Client:
	TE_SendToAll();

	//Declare:
	int Light;

	//Initulize:
	Light = GetEntAttatchedEffect(GlobalIonCannonEnt, 5);

	//Check:
	if(IsValidEdict(Light))
	{

		//Request:
		RequestFrame(OnNextFrameKill, Light);
	}

	//Create Custom Light:
	Light = CreateCustomLight(GlobalIonCannonEnt, 1, 100, 100, 255, 50.0, "1040", "90", "2", "1", "null");

	//Initulize:
	SetEntAttatchedEffect(GlobalIonCannonEnt, 5, Light);

	//Timer:
	CreateTimer(0.25, IonCannonStage3);
}

public Action IonCannonStage3(Handle Timer)
{

	//Initialize:
	int BeamColor[4] = {100, 150, 250, 255};
	float AboveOrigin[3];
	float Position[3];

	//Initulize:
	GetEntPropVector(GlobalIonCannonEnt, Prop_Send, "m_vecOrigin", Position);

	AboveOrigin[0] = Position[0];
	AboveOrigin[1] = Position[1];
	AboveOrigin[2] = Position[2] + 4000;
	Position[2] + 3000;

	//End Temp:
	TE_SetupBeamPoints(Position, AboveOrigin, Laser(), 0, 0, 66, 0.5, 9.0, 18.0, 0, 0.0, BeamColor, 0);

	//Show To Client:
	TE_SendToAll();

	AboveOrigin[2] -= 1000;
	Position[2] -= 1000;

	//End Temp:
	TE_SetupBeamPoints(Position, AboveOrigin, Laser(), 0, 0, 66, 0.5, 9.0, 18.0, 0, 0.0, BeamColor, 0);

	//Show To Client:
	TE_SendToAll();

	AboveOrigin[2] -= 1000;
	Position[2] -= 1000;

	//End Temp:
	TE_SetupBeamPoints(Position, AboveOrigin, Laser(), 0, 0, 66, 0.5, 9.0, 18.0, 0, 0.0, BeamColor, 0);

	//Show To Client:
	TE_SendToAll();

	//Declare:
	int Light;

	//Initulize:
	Light = GetEntAttatchedEffect(GlobalIonCannonEnt, 5);

	//Check:
	if(IsValidEdict(Light))
	{

		//Request:
		RequestFrame(OnNextFrameKill, Light);
	}

	//Create Custom Light:
	Light = CreateCustomLight(GlobalIonCannonEnt, 1, 100, 100, 255, 50.0, "1640", "90", "2", "1", "null");

	//Initulize:
	SetEntAttatchedEffect(GlobalIonCannonEnt, 5, Light);

	//Timer:
	CreateTimer(0.0, IonCannonExpoding);

	//Timer:
	CreateTimer(0.125, IonCannonExpoding);

	//Timer:
	CreateTimer(0.25, IonCannonStage4);
}

public Action IonCannonStage4(Handle Timer)
{

	//Initialize:
	int BeamColor[4] = {100, 150, 250, 255};
	float AboveOrigin[3];
	float Position[3];

	//Initulize:
	GetEntPropVector(GlobalIonCannonEnt, Prop_Send, "m_vecOrigin", Position);

	AboveOrigin[0] = Position[0];
	AboveOrigin[1] = Position[1];
	AboveOrigin[2] = Position[2] + 4000;
	Position[2] + 3000;

	//End Temp:
	TE_SetupBeamPoints(Position, AboveOrigin, Laser(), 0, 0, 66, 0.5, 18.0, 24.0, 0, 0.0, BeamColor, 0);

	//Show To Client:
	TE_SendToAll();

	AboveOrigin[2] -= 1000;
	Position[2] -= 1000;

	//End Temp:
	TE_SetupBeamPoints(Position, AboveOrigin, Laser(), 0, 0, 66, 0.5, 18.0, 24.0, 0, 0.0, BeamColor, 0);

	//Show To Client:
	TE_SendToAll();

	AboveOrigin[2] -= 1000;
	Position[2] -= 1000;

	//End Temp:
	TE_SetupBeamPoints(Position, AboveOrigin, Laser(), 0, 0, 66, 0.5, 18.0, 24.0, 0, 0.0, BeamColor, 0);

	//Show To Client:
	TE_SendToAll();

	AboveOrigin[2] -= 1000;
	Position[2] -= 1000;

	//End Temp:
	TE_SetupBeamPoints(Position, AboveOrigin, Laser(), 0, 0, 66, 0.5, 18.0, 24.0, 0, 0.0, BeamColor, 0);

	//Show To Client:
	TE_SendToAll();

	//End Temp:
	TE_SetupBeamPoints(Position, AboveOrigin, Laser(), 0, 0, 66, 0.5, 18.0, 24.0, 0, 0.0, BeamColor, 0);

	//Show To Client:
	TE_SendToAll();

	//Declare:
	int Light;

	//Initulize:
	Light = GetEntAttatchedEffect(GlobalIonCannonEnt, 5);

	//Check:
	if(IsValidEdict(Light))
	{

		//Request:
		RequestFrame(OnNextFrameKill, Light);
	}

	//Create Custom Light:
	Light = CreateCustomLight(GlobalIonCannonEnt, 1, 100, 100, 255, 50.0, "2440", "90", "3", "1", "null");

	//Initulize:
	SetEntAttatchedEffect(GlobalIonCannonEnt, 5, Light);

	//Timer:
	CreateTimer(0.0, ExplodeGlobalIonCannon);
}

public Action ExplodeGlobalIonCannon(Handle Timer)
{

	//Declare:
	float Offset[3] = {0.0,...};
	float Origin[3] = {0.0,...};
	float Angles[3] = {0.0, 0.0, 0.0};

	Origin[2] += 5.0;

	//Create Fire Effect!
	CreateInfoParticleSystemOther(GlobalIonCannonEnt, "null", "citadel_shockwave", 2.0, Offset, Angles);
	CreateInfoParticleSystemOther(GlobalIonCannonEnt, "null", "aurora_shockwave", 2.0, Offset, Angles);
	CreateInfoParticleSystemOther(GlobalIonCannonEnt, "null", "citadel_shockwave_e", 2.0, Offset, Angles);

	//Initulize:
	GetEntPropVector(GlobalIonCannonEnt, Prop_Send, "m_vecOrigin", Origin);

	Origin[2] += 5.0;

	//Initulize:
	int Effect = CreateLight(GlobalIonCannonEnt, 1, 100, 180, 250, "null");

	SetEntAttatchedEffect(GlobalIonCannonEnt, 0, Effect);

	//Initulize:
	Effect = CreatePointTesla(GlobalIonCannonEnt, "null", "100 180 250");

	SetEntAttatchedEffect(GlobalIonCannonEnt, 1, Effect);

	//Declare:
	Effect = CreateEnvAr2Explosion(GlobalIonCannonEnt, "null", "sprites/plasmaember.vmt");

	SetEntAttatchedEffect(GlobalIonCannonEnt, 2, Effect);

	//Initulize:
	float Direction[3] = {-90.0,0.0,0.0};

	//Declare:
	Effect = CreateEnvShooter(GlobalIonCannonEnt, "null", Direction, 3000.0, 0.1, Direction, 1200.0, 5.0, 10.0, "materials/sprites/flare1.vmt");

	SetEntAttatchedEffect(GlobalIonCannonEnt, 3, Effect);

	//Emit Sound:
	EmitAmbientSound("ambient/explosions/explode_5.wav", Origin, SNDLEVEL_RAIDSIREN);

	//CreateDamage:
	ExplosionDamage(GlobalIonCannonEnt, GlobalIonCannonEnt, Origin, DMG_DISSOLVE);

	//TE Setup:
	TE_SetupDynamicLight(Origin, 255, 100, 10, 8, 150.0, 0.4, 50.0);

	//Send:
	TE_SendToAll();

	//Emit Sound:
	EmitAmbientSound("ambient/explosions/explode_5.wav", Origin, SNDLEVEL_RAIDSIREN);

	//Create Custom Light:
	CreateCustomLight(GlobalIonCannonEnt, 1, 100, 100, 255, 50.0, "4400", "90", "4", "1", "null");

	//Timer:
	CreateTimer(0.05, IonCannonExpoding);

	//Timer:
	CreateTimer(0.10, IonCannonExpoding);

	//Timer:
	CreateTimer(0.15, IonCannonExpoding);

	//Timer:
	CreateTimer(0.20, IonCannonExpoding);

	//Declare:
	float PlayerOrigin[3] = {0.0, 0.0, 0.0};
	float VecConnecting[3] = {0.0, 0.0, 0.0};
	float DirectionAngle[3] = {0.0, 0.0, 0.0};
	float EndPosition[3] = {0.0, 0.0, 0.0};

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(IsClientInGame(i) && IsPlayerAlive(i))
		{

			//Initulize:
			GetClientAbsOrigin(i, PlayerOrigin);

			PlayerOrigin[2] += 50.0;

			//Do Math
			MakeVectorFromPoints(Origin, PlayerOrigin, VecConnecting);

			GetVectorAngles(VecConnecting, DirectionAngle);

			//Trace:
			TR_TraceRayFilter(Origin, DirectionAngle, CONTENTS_PLAYERCLIP, RayType_Infinite, TraceRayPlayerOnly, i);

			//Initulize:
			if(TR_DidHit())
			{

				//Position:
				TR_GetEndPosition(EndPosition);

				//Check:
				if(GetVectorDistance(Origin, EndPosition) <= 8000.0)
				{

					//Shake:
					ShakeClient(i, 10.0, 50.0);
				}
			}
		}
	}
	

	//Timer:
	CreateTimer(0.25, RemoveGlobalIonCannon);
}

public Action IonCannonExpoding(Handle Timer)
{

	//Explode:
	CreateExplosion(GlobalIonCannonEnt, GlobalIonCannonEnt);

	float Position[3];

	//Initulize:
	GetEntPropVector(GlobalIonCannonEnt, Prop_Send, "m_vecOrigin", Position);

	int ent = CreateEntityByName("prop_combine_ball");

	DispatchSpawn(ent);


	TeleportEntity(ent, Position, NULL_VECTOR, NULL_VECTOR);

	

	//Accept:

	AcceptEntityInput(ent, "explode");

}

public Action RemoveGlobalIonCannon(Handle Timer)
{

	//Check:
	if(IsValidAttachedEffect(GlobalIonCannonEnt))
	{

		//Remove:
		RemoveAttachedEffect(GlobalIonCannonEnt);
	}

	//Request:
	RequestFrame(OnNextFrameKill, GlobalIonCannonEnt);

	//Initulize:
	GlobalIonCannonEnt = -1;
}

//Create Garbage Zone:
public Action Command_CreateIonCannonZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createioncannonzone <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createioncannonzone <0-10>");

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
	if(IonCannonZones[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE IonCannonZones SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO IonCannonZones (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	IonCannonZones[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 145);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created IonCannon Zones spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action Command_RemoveIonCannonZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeioncannonzone <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeioncannonzone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(IonCannonZones[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	IonCannonZones[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM IonCannonZones WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 146);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed ioncannon Zones Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListIonCannonZones(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "IonCannon Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXIONCANNONZONES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM IonCannonZones WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintIonCannonZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeIonCannonZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "IonCannon Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXIONCANNONZONES; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM IonCannonZones WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 147);
	}

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action Command_TestIonCannonZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testioncannonzone <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testIonCannonzone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//Spawn:
	SpawnGlobalIonCannon(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, IonCannonZones[Id][0], IonCannonZones[Id][1], IonCannonZones[Id][2]);

	//Return:
	return Plugin_Handled;
}
