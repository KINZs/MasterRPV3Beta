//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_anomalyzone_included_
  #endinput
#endif
#define _rp_anomalyzone_included_

//Defines:
#define MAXANOMALYZONES		10

//Euro - € dont remove this!
//€ = �

//Random Anomaly Zones!
float AnomalyZones[MAXANOMALYZONES + 1][3];
int AnomalyZoneTimer = 0;
int AnomalyExposeTimer = -1;
int GlobalAnomalyEnt = -1;
int GlobalAnomalyType = -1;
int GlobalAnomalyActivate = -1;

public void initGlobalAnomaly()
{

	//Commands:
	RegAdminCmd("sm_createanomalyzone", Command_CreateAnomalyZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removeanomalyzone", Command_RemoveAnomalyZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listanomalyzones", Command_ListAnomalyZones, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipeanomalyzones", Command_WipeAnomalyZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testanomalyzone", Command_TestAnomalyZone, ADMFLAG_ROOT, "<id> - Test Anomaly Spawn");

	//Timers:
	CreateTimer(0.2, CreateSQLdbAnomalyZones);

	//Loop:
	for(int Z = 0; Z <= MAXANOMALYZONES; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		AnomalyZones[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbAnomalyZones(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `AnomalyZones`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 140);
}

//Create Database:
public Action LoadAnomalyZones(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXANOMALYZONES; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		AnomalyZones[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM AnomalyZones WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadAnomalyZones, query);
}

public void T_DBLoadAnomalyZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadAnomalyZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Random Anomaly Zones Found in DB!");

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
			AnomalyZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Anomaly Zones Found!");
	}
}

public void T_DBPrintAnomalyZones(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintAnomalyZones: Query failed! %s", error);
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
public void OnAnomalyDestroyed(int Entity)
{

	//Is Valid:
	if(IsValidEdict(Entity))
	{

		//Someone Broke the Anomaly!:
		if(GlobalAnomalyEnt == Entity)
		{

			//Check:
			if(IsValidAttachedEffect(GlobalAnomalyEnt))
			{

				//Remove:
				RemoveAttachedEffect(GlobalAnomalyEnt);
			}

			//Initulize:
			GlobalAnomalyEnt = -1;

			GlobalAnomalyActivate = -1;

			GlobalAnomalyType = -1;

			AnomalyExposeTimer = -1;
		}
	}
}

public void initGlobalAnomalyTick()
{

	//Is Global Anomaly!
	if(GlobalAnomalyEnt != -1)
	{

		//Check:
		if(AnomalyExposeTimer == 0)
		{

			//Create Anomaly Explosion:
			ExplodeGlobalAnomaly(GlobalAnomalyEnt);
		}

		//Check:
		if(AnomalyExposeTimer >= 0)
		{

			//Initulize:
			AnomalyExposeTimer += 1;

			//Declare:
			float Origin[3];

			//Get Prop Data:
			GetEntPropVector(GlobalAnomalyEnt, Prop_Send, "m_vecOrigin", Origin);

			//Declare:
			float ClientOrigin[3];
			float Angles[3];
			float Push[3];

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{


					//Initialize:
					GetEntPropVector(i, Prop_Send, "m_vecOrigin", ClientOrigin);

					//Declare:
					float Dist = GetVectorDistance(ClientOrigin, Origin);

					//In Distance:
					if(Dist <= 300)
					{

						//Initulize:
						GetAngleBetweenEntities(GlobalAnomalyEnt, i, Angles);

						//Initulize:
						GetPushBetweenEntitiesCustomAng(GlobalAnomalyEnt, Angles, -500.0, Push);

						//Teleport:
						TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, Push);
					}
				}
			}

			//Switch:
			switch(GlobalAnomalyType)
			{

				case 1:
				{

					//Create Damage:
					ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, Origin, DMG_RADIATION);
				}

				case 2:
				{

					//Create Damage:
					ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, Origin, DMG_SLASH);
				}

				case 3:
				{

					//Active Check:
					if(GlobalAnomalyActivate > 0)
					{

						//Create Damage:
						ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, Origin, DMG_BURN);

						GlobalAnomalyActivate -= 1;
					}

					//Remove Fire Effect:
					if(GlobalAnomalyActivate == 0)
					{

						//Initulize:
						GlobalAnomalyActivate = -1;

						//Declare:
						int EntSlot = GetEntAttatchedEffect(GlobalAnomalyEnt, 1);

						//Check:
						if(IsValidEntity(EntSlot))
						{

							//Request:
							RequestFrame(OnNextFrameKill, EntSlot);
						}

						//Declare:
						EntSlot = GetEntAttatchedEffect(GlobalAnomalyEnt, 2);

						//Check:
						if(IsValidEntity(EntSlot))
						{

							//Request:
							RequestFrame(OnNextFrameKill, EntSlot);
						}
					}
				}

				case 4:
				{

					//Create Damage:
					ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, Origin, DMG_DISSOLVE|DMG_RADIATION);
				}

				case 5:
				{

					//Create Damage:
					ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, Origin, DMG_DISSOLVE);
				}

				case 6:
				{

					//Create Damage:
					ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, Origin, DMG_DISSOLVE);
				}

				case 7:
				{

					//Create Damage:
					ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, Origin, DMG_SONIC);
				}
			}
		}

		//Check:
		if(AnomalyExposeTimer >= 120)
		{

			//Remove Anomaly:
			RemoveGlobalAnomaly(GlobalAnomalyEnt);
		}
	}

	//Initulize:
	AnomalyZoneTimer++;

	//TimerCheck
	if(AnomalyZoneTimer >= GetAnomalySpawnTimer())
	{

		//Initulize:
		AnomalyZoneTimer = 0;

		//Invalid Check:
		if(GlobalAnomalyEnt == -1)
		{

			//Declare:
			int Var = GetRandomInt(0, 10);

			//Initulize:
			GlobalAnomalyType = GetRandomInt(1, 5);

			//Spawn:
			SpawnGlobalAnomaly(Var);

			//Initulize:
			AnomalyExposeTimer = 0;

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Check:
					if(IsAdmin(i) || IsCop(i) || StrEqual(GetJob(i), "Scientist") || StrEqual(GetJob(i), "Fire Fighter"))
					{

						//Print:
						CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - A Anomaly has been dropped!");
					}
				}
			}
		}

		//Override!:
		else
		{

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Check:
					if(IsAdmin(i) || IsCop(i) || StrEqual(GetJob(i), "Scientist") || StrEqual(GetJob(i), "Fire Fighter"))
					{

						//Print:
						CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - There is already a Anomaly spawned on the map!");
					}
				}
			}
		}
	}
}

//Runs 10 frames a second
public void intAnomalyEffectTimer(int Timer)
{

	//Is Global Anomaly!
	if(GlobalAnomalyEnt != -1)
	{

		//Declare:
		float AnomalyOrigin[3] = {0.0, 0.0, 0.0};

		float AnomalyAngles[3] = {0.0, 0.0, 0.0};

		//Initulize:
		GetEntPropVector(GlobalAnomalyEnt, Prop_Data, "m_vecOrigin", AnomalyOrigin);

		//Check:
		if(AnomalyExposeTimer >= 0)
		{

			//Switch:
			switch(GlobalAnomalyType)
			{

				case 1:
				{

					//Declare:
					float Offset[3] = {0.0, 0.0, 0.0};
					float Angles2[3] = {0.0, 0.0, 0.0};

					//Create Fire Effect!
					CreateInfoParticleSystemOther(GlobalAnomalyEnt, "null", "water_splash_01", 0.1, Offset, Angles2);
				}

				case 2:
				{

					//Declare:
					float Offset[3] = {0.0, 0.0, 0.0};
					float Angles2[3] = {0.0, 0.0, 0.0};

					//Create Fire Effect!
					CreateInfoParticleSystemOther(GlobalAnomalyEnt, "null", "blood_impact_red_01", 0.1, Offset, Angles2);
				}

				case 3:
				{

					//Temp Ent:
					TE_SetupEnergySplash(AnomalyOrigin, AnomalyAngles, true);

					//Show To Client:
					TE_SendToAll();

					//DetectPlayer:
					OnFireDetectPlayer(GlobalAnomalyEnt, AnomalyOrigin);
				}

				case 4:
				{

					//Declare:
					float Offset[3] = {0.0, 0.0, 0.0};
					float Angles2[3] = {0.0, 0.0, 0.0};

					//Create Fire Effect!
					CreateInfoParticleSystemOther(GlobalAnomalyEnt, "null", "vortigaunt_hand_glow", 0.1, Offset, Angles2);
				}

				case 5:
				{

					//Declare:
					int Random = GetRandomInt(0, 5);
					int EntSlot = GetEntAttatchedEffect(GlobalAnomalyEnt, Random);

					//Check:
					if(IsValidEntity(EntSlot))
					{

						//Accept:
						AcceptEntityInput(EntSlot, "DoSpark");
					}


					//TE Setup:

					TE_SetupDynamicLight(AnomalyOrigin, 40, 120, 200, 8, 175.0, 0.2, 120.0);



					//Send:

					TE_SendToAll();
				}

				case 6:
				{

					//Declare:
					int Ent = CreateDynamicProp(AnomalyOrigin, AnomalyAngles, "models/gibs/hgibs.mdl", true);

					//Is Player:
					SetEntityRenderColor(Ent, 0, 0, 0, 255);

					//Set String:
					SetVariantString("!activator");

					//Accept:
					AcceptEntityInput(Ent, "SetParent", GlobalAnomalyEnt, Ent, 0);

					//Dessolve:
					EntityDissolve(Ent, 2);


					//TE Setup:

					TE_SetupDynamicLight(AnomalyOrigin, 40, 120, 200, 8, 175.0, 0.2, 120.0);



					//Send:

					TE_SendToAll();
				}

				case 7:
				{

					//Declare:
					int Random = GetRandomInt(1, 7);

					//Declare:
					int Color[4] = {200,...};

					switch(Random)
					{

						case 1:
						{

							//Initulize:
							Color[0] = 255;
							Color[1] = 100;
							Color[2] = 100;
						}

						case 2:
						{

							//Initulize:
							Color[0] = 255;
							Color[1] = 225;
							Color[2] = 100;
						}

						case 3:
						{

							//Initulize:
							Color[0] = 255;
							Color[1] = 225;
							Color[2] = 225;
						}

						case 4:
						{

							//Initulize:
							Color[0] = 100;
							Color[1] = 225;
							Color[2] = 225;
						}

						case 5:
						{

							//Initulize:
							Color[0] = 100;
							Color[1] = 100;
							Color[2] = 225;
						}

						case 6:
						{

							//Initulize:
							Color[0] = 255;
							Color[1] = 100;
							Color[2] = 225;
						}

						case 7:
						{

							//Initulize:
							Color[0] = 100;
							Color[1] = 225;
							Color[2] = 100;
						}
					}


					//TE Setup:

					TE_SetupDynamicLight(AnomalyOrigin, Color[0], Color[1], Color[2], 8, 175.0, 0.2, 120.0);



					//Send:

					TE_SendToAll();

					//Declare:
					float Offset[3] = {0.0, 0.0, 0.0};
					float Angles2[3] = {0.0, 0.0, 0.0};

					//Create Fire Effect!
					CreateInfoParticleSystemOther(GlobalAnomalyEnt, "null", "vortigaunt_hand_glow", 0.1, Offset, Angles2);

					//Declare:
					int EntSlot = GetEntAttatchedEffect(GlobalAnomalyEnt, 0);

					//Check:
					if(IsValidEntity(EntSlot))
					{

						//Set Color:
						SetEntityRenderColor(EntSlot, Color[0], Color[1], Color[2], Color[3]);

						//Declare:
						float RandomSize = GetRandomFloat(0.4, 0.6);

						//Send:

						SetEntPropFloat(EntSlot, Prop_Send, "m_flModelScale", RandomSize);

					}

				}
			}
		}

		//Declare:
		int Random = GetRandomInt(1, 10);

		//Check:
		if(Random > 5)
		{

			//Randomize Loc:
			AnomalyOrigin[0] += GetRandomFloat(-30.0, 30.0);
			AnomalyOrigin[1] += GetRandomFloat(-30.0, 30.0);
			AnomalyOrigin[2] += GetRandomFloat(-20.0, 20.0);

			//Check:
			if(!TR_PointOutsideWorld(AnomalyOrigin))
			{

				//Switch:
				switch(GlobalAnomalyType)
				{

					case 1:
					{

						//Teleport:
						TeleportEntity(GlobalAnomalyEnt, AnomalyOrigin, NULL_VECTOR, NULL_VECTOR);
					}

					case 2:
					{

						//Teleport:
						TeleportEntity(GlobalAnomalyEnt, AnomalyOrigin, NULL_VECTOR, NULL_VECTOR);
					}

					case 3:
					{

						//Teleport:
						TeleportEntity(GlobalAnomalyEnt, AnomalyOrigin, NULL_VECTOR, NULL_VECTOR);
					}

					case 4:
					{

						//Teleport:
						TeleportEntity(GlobalAnomalyEnt, AnomalyOrigin, NULL_VECTOR, NULL_VECTOR);
					}

					case 5:
					{

						//Teleport:
						TeleportEntity(GlobalAnomalyEnt, AnomalyOrigin, NULL_VECTOR, NULL_VECTOR);
					}

					case 6:
					{

						//Teleport:
						TeleportEntity(GlobalAnomalyEnt, AnomalyOrigin, NULL_VECTOR, NULL_VECTOR);
					}

					case 7:
					{

						//Teleport:
						TeleportEntity(GlobalAnomalyEnt, AnomalyOrigin, NULL_VECTOR, NULL_VECTOR);
					}
				}
			}
		}
	}
}

public void ExplodeGlobalAnomaly(int Ent)
{

	//Declare:
	float Origin[3] = {0.0, 0.0, 0.0};
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", Origin);

	//Create Portal:
	int PortalEffect = CreateDynamicProp(Origin, Angles, "models/effects/portalrift.mdl", true);

	SetEntAttatchedEffect(Ent, 9, PortalEffect);

	//Switch:
	switch(GlobalAnomalyType)
	{

		case 1:
		{

			//Initulize Effects:
			int Effect = CreateLight(Ent, 1, 20, 20, 255, "null");

			SetEntAttatchedEffect(Ent, 0, Effect);
		}

		case 2:
		{

			//Initulize Effects:
			int Effect = CreateLight(Ent, 1, 255, 20, 20, "null");

			SetEntAttatchedEffect(Ent, 0, Effect);
		}

		case 3:
		{

			//Initulize Effects:
			int Effect = CreateEnvSteam(Ent, "null", "255 255 50", "255", "1", "20", "50", "15", "1", "15", "25", "20");

			SetEntAttatchedEffect(Ent, 0, Effect);

			//Initulize:
			Angles[0] = 180.0;

			//Teleport:
			TeleportEntity(Effect, NULL_VECTOR, Angles, NULL_VECTOR);
		}

		case 4:
		{

			//Initulize Effects:
			int Effect = CreateEnvSteam(Ent, "null", "255 255 50", "255", "1", "20", "50", "15", "1", "15", "25", "20");

			SetEntAttatchedEffect(Ent, 0, Effect);

			//Initulize:
			Angles[0] = 180.0;

			//Teleport:
			TeleportEntity(Effect, NULL_VECTOR, Angles, NULL_VECTOR);

			//Initulize Effects:
			Effect = CreateLight(Ent, 1, 120, 180, 120, "null");

			SetEntAttatchedEffect(Ent, 1, Effect);
		}

		case 5:
		{

			//Initulize Effects:
			int Effect = CreatePointTesla(Ent, "null", "50 50 250");

			SetEntAttatchedEffect(Ent, 0, Effect);

			//Initulize Effects:
			Effect = CreatePointTesla(Ent, "null", "50 250 250");

			SetEntAttatchedEffect(Ent, 1, Effect);

			//Initulize Effects:
			Effect = CreatePointTesla(Ent, "null", "250 250 50");

			SetEntAttatchedEffect(Ent, 2, Effect);

			//Initulize Effects:
			Effect = CreatePointTesla(Ent, "null", "250 50 250");

			SetEntAttatchedEffect(Ent, 3, Effect);

			//Initulize Effects:
			Effect = CreatePointTesla(Ent, "null", "50 250 50");

			SetEntAttatchedEffect(Ent, 4, Effect);

			//Initulize Effects:
			Effect = CreatePointTesla(Ent, "null", "250 250 250");

			SetEntAttatchedEffect(Ent, 5, Effect);

			//Initulize Effects:
			Effect = CreateLight(Ent, 1, 120, 180, 120, "null");

			SetEntAttatchedEffect(Ent, 10, Effect);
		}

		case 6:
		{

			//Initulize Effects:
			int Effect = CreateEnvSteam(Ent, "null", "255 255 50", "255", "1", "20", "50", "15", "1", "15", "25", "20");

			SetEntAttatchedEffect(Ent, 0, Effect);
		}

		case 7:
		{

			//Declare:
			int Effect = CreateProp(Origin, Angles, "models/effects/combineball.mdl", true, false);

			SetEntAttatchedEffect(Ent, 0, Effect);

			//Set String:
			SetVariantString("!activator");

			//Accept:
			AcceptEntityInput(Effect, "SetParent", Ent, Effect, 0);

			//Set Trans Effect:
			SetEntityRenderMode(Effect, RENDER_GLOW);

			//Set Render Ex:
			SetEntityRenderFx(Effect, RENDERFX_DISTORT);
		}
	}
}

public void OnFireDetectPlayer(int Ent, float Origin[3])
{

	//Declare:
	float PlayerOrigin[3];

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Initulize:
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", PlayerOrigin);

			//Declare:
			float Dist = GetVectorDistance(Origin, PlayerOrigin);

			//Is Player In Range:
			if(Dist < 250)
			{

				//Initulize:
				GlobalAnomalyActivate = 8;

				//Declare:
				int EntSlot = GetEntAttatchedEffect(GlobalAnomalyEnt, 1);

				//Check:
				if(!IsValidEntity(EntSlot))
				{

					//Initulize Effects:
					int Effect = CreateEnvFire(Ent, "null", "200", "700", "0", "Natural");

					SetEntAttatchedEffect(Ent, 1, Effect);

					//Initulize Effects:
					Effect = CreateLight(Ent, 1, 250, 20, 20, "null");

					SetEntAttatchedEffect(Ent, 2, Effect);
				}
			}
		}
	}
}

public void RemoveGlobalAnomaly(int Ent)
{

	//Check:
	if(IsValidAttachedEffect(GlobalAnomalyEnt))
	{

		//Remove:
		RemoveAttachedEffect(GlobalAnomalyEnt);
	}

	//Request:
	RequestFrame(OnNextFrameKill, GlobalAnomalyEnt);

	//Initulize:
	GlobalAnomalyEnt = -1;

	AnomalyExposeTimer = -1;

	GlobalAnomalyType = -1;
}

//Use Handle:
public void OnGlobalAnomalyUse(int Client, int Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

	}
}

public void OnPlayerPickUpAnomaly(int Client)
{

	//Declare:
	float AnomalyOrigin[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetEntPropVector(GlobalAnomalyEnt, Prop_Data, "m_vecOrigin", AnomalyOrigin);

	//Switch:
	switch(GlobalAnomalyType)
	{

		case 1:
		{

			//Create Damage:
			ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, AnomalyOrigin, DMG_RADIATION);
		}

		case 2:
		{

			//Create Damage:
			ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, AnomalyOrigin, DMG_SLASH);
		}

		case 3:
		{

			//Create Damage:
			ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, AnomalyOrigin, DMG_BURN);
		}

		case 4:
		{

			//Create Damage:
			ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, AnomalyOrigin, DMG_DISSOLVE|DMG_RADIATION);
		}

		case 5:
		{

			//Create Damage:
			ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, AnomalyOrigin, DMG_DISSOLVE);
		}

		case 6:
		{

			//Create Damage:
			ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, AnomalyOrigin, DMG_DISSOLVE);
		}

		case 7:
		{

			//Create Damage:
			ExplosionDamage(GlobalAnomalyEnt, GlobalAnomalyEnt, AnomalyOrigin, DMG_SONIC);
		}
	}
}

public int SpawnGlobalAnomaly(int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return view_as<int>(-1);
	}

	//Check:
	if(GlobalAnomalyEnt > 0)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - There is already a Anomaly spawned on the map!");

		PrintToServer("|RP| - There is already a Anomaly spawned on the map!");

		//Return:
		return view_as<int>(-1);
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	Angles[1] = GetRandomFloat(0.0, 360.0);

	//Check:
	if(TR_PointOutsideWorld(AnomalyZones[Var]))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Unable to Drop Anomaly Due to outside of world");

		PrintToServer("|RP| - Unable to Drop Anomaly Due to outside of world");

		//Return:
		return view_as<int>(-1);
	}

	//Declare:
	int Ent = CreateProp(AnomalyZones[Var], Angles, "models/Combine_Helicopter/helicopter_bomb01.mdl", true, false);

	//Set Damage:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Set Trans Effect:
	SetEntityRenderMode(Ent, RENDER_GLOW);

	//Set Color:
	SetEntityRenderColor(Ent, 255, 255, 255, 0);

	//Initulize:
	GlobalAnomalyEnt = Ent;

	//Return:
	return view_as<int>(Ent);
}

//Create Anomaly Zone:
public Action Command_CreateAnomalyZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createAnomalyzone <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createAnomalyzone <0-10>");

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
	if(AnomalyZones[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE AnomalyZones SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO AnomalyZones (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	AnomalyZones[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 141);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Anomaly Zones spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Anomaly Zone:
public Action Command_RemoveAnomalyZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeAnomalyzone <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeAnomalyzone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(AnomalyZones[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	AnomalyZones[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM AnomalyZones WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 142);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Anomaly Zones Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Anomaly Spawns:
public Action Command_ListAnomalyZones(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Anomaly Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXANOMALYZONES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM AnomalyZones WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintAnomalyZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeAnomalyZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Anomaly Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXANOMALYZONES; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM AnomalyZones WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 143);
	}

	//Return:
	return Plugin_Handled;
}

//Test Anomaly Zone:
public Action Command_TestAnomalyZone(int Client, int Args)
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
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testanomalyzone <id> <type>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testanomalyzone <0-10> <type>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char TypeId[32];

	//Initialize:
	GetCmdArg(2, TypeId, sizeof(TypeId));

	//Declare:
	int Type = StringToInt(TypeId);

	//Check:
	if(Type < 1 || Type > 7)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testanomalyzone <Id> <1-7>");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	GlobalAnomalyType = Type;

	AnomalyExposeTimer = 0;

	//Spawn:
	SpawnGlobalAnomaly(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, AnomalyZones[Id][0], AnomalyZones[Id][1], AnomalyZones[Id][2]);

	//Return:
	return Plugin_Handled;
}

public bool IsEntityGlobalAnomaly(int Ent)
{

	//Not Valid Ent:
	if(Ent != -1 && Ent > 0 && IsValidEdict(Ent))
	{

		//Found Anomaly!
		if(GlobalAnomalyEnt == Ent)
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public int GetGlobalAnomalyEnt()
{

	//Return:
	return view_as<int>(GlobalAnomalyEnt);
}

public void SetGlobalAnomalyEnt(int Ent)
{

	//Initulize:
	GlobalAnomalyEnt = Ent;
}