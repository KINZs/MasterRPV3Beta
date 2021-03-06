//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npc_included_
  #endinput
#endif
#define _rp_npc_included_

#define NPCTYPES		15
#define MAXNPCS			30

int NpcId[2047] = {-1,...};
int NpcType[2047] = {-1,...};
int NpcEnt[NPCTYPES][MAXNPCS];
float NpcEntPosition[NPCTYPES][MAXNPCS][3];

public void initnpc()
{

	//NPC Management:
	RegAdminCmd("sm_createnpc", Command_CreateNpc, ADMFLAG_ROOT, "<id> <NPC> <type> - Types: 0 = Job Lister, 1 = Banker, 2 = Vendor");

	RegAdminCmd("sm_removenpc", Command_RemoveNpc, ADMFLAG_ROOT, "<id> - Removes an NPC from the database");

	RegAdminCmd("sm_npclist", Command_ListNPCs, ADMFLAG_SLAY, "- Lists all the NPCs in the database");

	RegAdminCmd("sm_npcwho", Command_NPCWho, ADMFLAG_SLAY, "- Lists all the NPCs in the database");

	CreateTimer(0.4, CreateSQLdbNpc);
}

//Create Database:
public Action CreateSQLdbNpc(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Npcs`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `NpcId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `NpcType` int(12) NULL, `Npc` varchar(32) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `Model` varchar(255) NOT NULL, `Position` varchar(64) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `Angle` varchar(64) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadNpcs(Handle Timer)
{

	//Loop:
	for(int X = 0; X < NPCTYPES; X++) for(int Y = 0; Y < MAXNPCS; Y++)
	{

		//Initulize:
		NpcEnt[X][Y] = -1;

		//Loop:
		for(int Z = 0; Z <= 2; Z++)
		{

			//Initulize:
			NpcEntPosition[X][Y][Z] = 0.0;
		}
	}

	//Loop:
	for(int X = 0; X < 2047; X++)
	{

		//Initulize:
		NpcId[X] = -1;

		NpcType[X] = -1;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Npcs WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadNpcs, query);
}

public void T_DBLoadNpcs(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadNpcs: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Npcs Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0;
		int Type = 0;
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Type = SQL_FetchInt(hndl, 2);

			//Declare:
			char Dump[3][64];
			char Npc[64];
			char Model[255];
			float Position[3];
			float Angles[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Npc, sizeof(Npc));

			//Database Field Loading String:
			SQL_FetchString(hndl, 4, Model, sizeof(Model));

			//Database Field Loading String:
			SQL_FetchString(hndl, 5, Buffer, sizeof(Buffer));

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 6, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Angles[Y] = StringToFloat(Dump[Y]);
			}

			//Create NPC:
			CreateNpcFromSQL(X, Type, Npc, Model, Position, Angles);
		}

		//Print:
		PrintToServer("|RP| - Npcs Loaded!");
	}
}

public Action CreateNpcFromSQL(int Id, int Type, const char[] Npc, const char[] Model, float Position[3], float Angles[3])
{

	//Declare:
	char sNpc[64];

	//Format:
	Format(sNpc, sizeof(sNpc), "npc_%s", Npc);	

	//Initialize:
	int NPC = CreateEntityByName(sNpc);

	//Is Valid:
	if(NPC > 0)
	{

		//Spawn & Send:
		DispatchSpawn(NPC);

		//Check:
		if(!IsModelPrecached(Model)) PrecacheModel(Model);

		if(!StrEqual(Model, "null"))
		{

			//Set Model
        		SetEntityModel(NPC, Model);
		}

		//Initialize:
		NpcId[NPC] = Id;

		NpcType[NPC] = Type;

		//Teleport:
		TeleportEntity(NPC, Position, Angles, NULL_VECTOR);

		//Check Is Vendor:
		if(Type == 2)
		{

			float Offset[3] = {0.0,0.0,80.0};
			int Effect = CreateEnvSprite(NPC, "null", "materials/bouncy/merchant_buy.vmt", "0.2", Offset, 255, 255, 255);

			SetEntAttatchedEffect(NPC, 10, Effect);
		}

		//Check Is Hardware Store:
		if(Type == 6)
		{

			//Server DHooks:
			OnVendorHardWareStoreHook(NPC);
		}

		//Initulize:
		NpcEnt[Type][Id] = NPC;
		NpcEntPosition[Type][Id] = Position;

		//Set NPC Health:
		SetEntProp(NPC, Prop_Data, "m_iHealth", 9999999);

		//Invincible:
		SetEntProp(NPC, Prop_Data, "m_takedamage", 0, 1);

		//Debris:
		int Collision = GetEntSendPropOffs(NPC, "m_CollisionGroup");
		SetEntData(NPC, Collision, 1, 1, true);

		//Switch:
		switch(Type)
		{

			case 1:
			{

				//Set do default classname
				SetEntityClassName(NPC, "npc_Banker");

			}

			case 2:
			{

				//Set do default classname
				SetEntityClassName(NPC, "npc_Vendor");

			}

			case 3:
			{

				//Set do default classname
				SetEntityClassName(NPC, "npc_Cop_Employer");

			}

			case 4:
			{

				//Set do default classname
				SetEntityClassName(NPC, "npc_Drug");

			}

			case 5:
			{

				//Set do default classname
				SetEntityClassName(NPC, "npc_Experience_Trader");

			}

			case 6:
			{

				//Set do default classname
				SetEntityClassName(NPC, "npc_Hardware_Store");

			}

			case 7:
			{

				//Set do default classname
				SetEntityClassName(NPC, "npc_Employer");

			}

			case 8:
			{

				//Set do default classname
				SetEntityClassName(NPC, "npc_Lottery");

			}

			case 9:
			{

				//Set do default classname
				SetEntityClassName(NPC, "npc_Vendor_Cars");

			}

			case 10:
			{

				//Set do default classname
				SetEntityClassName(NPC, "npc_Re_Sell");

			}
		}
	}
}

//Create NPC:
public Action Command_CreateNpc(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(Args < 3)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createnpc <id> <NPC> <type> <opt model>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char Npc[64];
	char sType[64];
	char Model[255];

	//Initialize:
	GetCmdArg(1, sId, 32);

	GetCmdArg(2, Npc, 64);

	GetCmdArg(3, sType, 64);

	//Is Valid:
	if(Args == 4)
	{

		//Initialize:
		GetCmdArg(4, Model, 255);
	}

	//Override
	else
	{

		//Format:
		Format(Model, sizeof(Model), "null");
	}

	//Declare:
	int Id = StringToInt(sId);

	int Type = StringToInt(sType);

	//Is Valid:
	if(Id < 0 || Id > MAXNPCS && Type < 0 && Type > NPCTYPES)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createnpc <0 - %i <NPC> <0 - %i> <opt model>", MAXNPCS, NPCTYPES);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = -1;

	//Loop:
	for(int X = 0; X < 2047; X++)
	{

		//Check:
		if(NpcId[X] == Id && NpcType[X] == Type)
		{

			//Initulize:
			Ent = X;

			//Break:
			break;
		}
	}

	//Declare:
	float fOrigin[3];
	float fAngles[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Data, "m_vecOrigin", fOrigin);

	GetEntPropVector(Client, Prop_Data, "m_angRotation", fAngles);

	//Declare:
	char query[512];
	char Position[64];
	char Angles[64];

	//Sql String:
	Format(Angles, sizeof(Angles), "%f^%f^%f", fAngles[0], fAngles[1], fAngles[2]);

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", fOrigin[0], fOrigin[1], fOrigin[2]);

	//Found NPC:
	if(Ent > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Updated Id #%i Type #%i Npc <%s> Model <%s> Pos <%s> Ang <%s>", Id, Type, Npc, Model, Position, Angles);

		//Format:
		Format(query, sizeof(query), "UPDATE Npcs SET Position = '%s', Angle = '%s', Npc = '%s', Model = '%s' WHERE Map = '%s' AND NpcId = %i AND NpcType = %i;", Position, Angles, Npc, Model, ServerMap(), Id, Type);

		//Teleport:
		TeleportEntity(Ent, fOrigin, fAngles, NULL_VECTOR);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Id #%i Type #%i Npc <%s> Model <%s> Pos <%s> Ang <%s>", Id, Type, Npc, Model, Position, Angles);

		//Create NPC:
		CreateNpcFromSQL(Id, Type, Npc, Model, fOrigin, fAngles);

		//Format:
		Format(query, sizeof(query), "INSERT INTO Npcs (`Map`,`NpcId`,`NpcType`,`Npc`,`Model`,`Position`,`Angle`) VALUES ('%s',%i,%i,'%s','%s','%s','%s');", ServerMap(), Id, Type, Npc, Model, Position, Angles);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Return:
	return Plugin_Handled;
}

//Create NPC:
public Action Command_RemoveNpc(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removenpc <id> <type>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sType[64];

	//Initialize:
	GetCmdArg(1, sId, 32);

	GetCmdArg(2, sType, 64);

	//Declare:
	int Id = StringToInt(sId);

	int Type = StringToInt(sType);

	//Is Valid:
	if(Id < 0 || Id > MAXNPCS && Type < 0 && Type > NPCTYPES)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createnpc <0 - %i <NPC> <0 - %i> <opt model>", MAXNPCS, NPCTYPES);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = -1;

	//Loop:
	for(int X = 0; X < 2047; X++)
	{

		//Check:
		if(NpcId[X] == Id && NpcType[X] == Type)
		{

			//Initulize:
			Ent = X;

			//Break:
			break;
		}
	}

	//Found NPC:
	if(Ent > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Npc Id #%i Type #%i", Id, Type);

		//Declare:
		char query[512];

		//Format:
		Format(query, sizeof(query), "DELETE FROM Npcs WHERE NpcId = %i AND NpcType = %i AND Map = '%s';", Id, Type, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Unable to find npc #%i Type #%i", Id, Type);
	}

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListNPCs(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Npc List: %s", ServerMap());

	PrintToConsole(Client, "Type 1 = Banker");

	PrintToConsole(Client, "Type 2 = Vendor");

	PrintToConsole(Client, "Type 3 = Cop Employer");

	PrintToConsole(Client, "Type 4 = Drug Buyer");

	PrintToConsole(Client, "Type 5 = Trade Experience");

	PrintToConsole(Client, "Type 6 = Hardware Buyer");

	PrintToConsole(Client, "Type 7 = Job Employers");

	PrintToConsole(Client, "Type 8 = Lottery NPC");

	PrintToConsole(Client, "Type 9 = vendor car NPC");

	PrintToConsole(Client, "Type 10 = Re Sell NPC");

	//Declare:
	char query[512];

	//Loop:
	for(int Type = 0; Type <= NPCTYPES; Type++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM Npcs WHERE Map = '%s' AND NpcType = %i;", ServerMap(), Type);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintNpcs, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintNpcs(Handle owner, Handle hndl, const char[] error, any data)
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
	if(hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBPrintThumpers: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int SpawnId = 0;
		int SpawnType = 0;
		char Npc[64];
		char Model[64];
		char Position[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			SpawnType = SQL_FetchInt(hndl, 2);

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Npc, 64);

			//Database Field Loading String:
			SQL_FetchString(hndl, 4, Model, 64);

			//Database Field Loading String:
			SQL_FetchString(hndl, 5, Position, 64);

			//Print:
			PrintToConsole(Client, "%i: Type %i <%s> Model <%s> Position <%s>", SpawnId, SpawnType, Npc, Model, Position);
		}
	}
}

//Remove NPC:
public Action Command_NPCWho(int Client, int Args)
{

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Ent > 0)
	{

		//Check Is NPC:
		if(IsValidNpc(Ent))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - NPC Id: #\x0732CD32%i\x07FFFFFF NPC Type: #\x0732CD32%i", NpcId[Ent], NpcType[Ent]);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid static npc");
		}
	}

	//Return:
	return Plugin_Handled;
}

public void intNpc()
{

	//Declare:
	float ClientOrigin[3] = {0.0, 0.0, 0.0};
	int ColorNpcDrug[4] = {120, 255, 120, 255};
	float EntOrigin[3] = {0.0, 0.0, 0.0};

	//Loop:
	for(int X = 0; X < NPCTYPES; X++) for(int Y = 0; Y < MAXNPCS; Y++)
	{

		//Check:
		if(IsValidEdict(NpcEnt[X][Y]))
		{

			//Drug NPC:
			if(X == 4)
			{

				//Loop:
				for(int i = 1; i <= GetMaxClients(); i++)
				{

					//Initulize:
					EntOrigin = NpcEntPosition[X][Y];

					//Connected:
					if(IsClientConnected(i) && IsClientInGame(i))
					{

						//Setup Drug Tracer:
						if(GetHarvest(i) > 0 || GetMeth(i) > 0 || GetCocain(i) > 0 || GetPills(i) > 0 || GetRice(i) > 0 || GetResources(i) > 0)
						{

							//Initulize:
							GetEntPropVector(i, Prop_Data, "m_vecOrigin", ClientOrigin);

							//Initialize:
							float Dist = GetVectorDistance(EntOrigin, ClientOrigin);

							//In Distance:
							if(Dist <= 800)
							{

								//Initulize:
								EntOrigin[2] += 2.5;

								//Show To Client:
								TE_SetupBeamRingPoint(EntOrigin, 1.0, 120.0, Laser(), Sprite(), 0, 20, 1.5, 3.0, 0.75, ColorNpcDrug, 7, 0);
								//TE_SetupBeamRingPoint(EntOrigin, 1.0, 200.0, Laser(), Sprite(), 0, 20, 1.5, 3.0, 0.5, ColorNpcDrug, 7, 0);
								//TE_SetupBeamRingPoint(EntOrigin, 1.0, 30.0, Laser(), Sprite(), 0, 10, 0.7, 10.0, 0.5, ColorNpcDrug, 10, 0);

								//End Temp:
								TE_SendToClient(i);

								//Print:
								//PrintToServer("|RP| - npc edict id = %i, Npc Type = %i, Npc Id = %i, Player = %i, %f %f %f", NpcEnt[X][Y], X, Y, i, EntOrigin[0], EntOrigin[1], EntOrigin[2]);
							}

							//Print:
							//PrintToServer("|RP| - npc edict id = %i, Npc Id = %i, Npc Type = %i", NpcEnt[X][Y], X, Y, i);
						}
					}
				}
			}
		}
	}
}

public bool IsValidNpc(int Ent)
{

	if(NpcId[Ent] > -1 || NpcType[Ent] > -1)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public int GetNpcType(int Ent)
{

	//Return:
	return NpcType[Ent];
}

public int GetNpcId(int Ent)
{

	//Return:
	return NpcId[Ent];
}

public int GetNpcEnt(int Type, int Id)
{

	//Return:
	return NpcEnt[Type][Id];
}