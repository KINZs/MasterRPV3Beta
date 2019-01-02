//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_garbagezone_included_
  #endinput
#endif
#define _rp_garbagezone_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Defines:
#define MAXGARBAGE		50
#define MAXGARBAGEZONESINGLE	20
#define MAXGARBAGEZONE		10

//Garbage system:
float GarbageZones[MAXGARBAGEZONE + 1][3];
float GarbageCansZones[MAXGARBAGEZONE + 1][3];
float GarbageZoneSingle[MAXGARBAGEZONESINGLE + 1][3];
char GarbageCanModel[255] = "models/props_junk/trashdumpster02.mdl";
char GarbageModel[255] = "models/sal/trash/binbag.mdl";

//Misc:
int TrashCanEnt[MAXPLAYERS + 1] = {-1,...};

public void initGarbageZone()
{

	//Commands:
	RegAdminCmd("sm_creategarbagezone", Command_CreateGarbageZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removegarbagezone", Command_RemoveGarbageZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listgarbagezone", Command_ListGarbageZone, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta:
	RegAdminCmd("sm_wipegarbagezones", Command_WipeGarbageZone, ADMFLAG_ROOT, "");

	//Commands:
	RegAdminCmd("sm_creategarbagecan", Command_CreateGarbageCan, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_savegarbagecan", Command_SaveGarbageCan, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removegarbagecan", Command_RemoveGarbageCan, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listgarbagecan", Command_ListGarbageCans, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta:
	RegAdminCmd("sm_wipegarbagezones", Command_WipeGarbageZone, ADMFLAG_ROOT, "");

	//Commands:
	RegAdminCmd("sm_creategarbagezonesingle", Command_CreateGarbageZoneSingle, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removegarbagezonesingle", Command_RemoveGarbageZoneSingle, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listgarbagezonesingle", Command_ListGarbageZoneSingle, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipegarbagezonesingle", Command_WipeGarbageZoneSingles, ADMFLAG_ROOT, "");

	RegConsoleCmd("sm_locatetrashcan", Command_LocateTrashCan);

	//Loop:
	for(int Z = 0; Z <= 10; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		GarbageZones[Z][i] = 69.0;

		GarbageCansZones[Z][i] = 69.0;
	}

	//Loop:
	for(int Z = 0; Z <= MAXGARBAGEZONESINGLE; Z++)
	{

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			GarbageZoneSingle[Z][i] = 69.0;
		}
	}

	//PreCache Model
	PrecacheModel("models/props_junk/popcan01a.mdl");

	PrecacheModel("models/props_junk/garbage_takeoutcarton001a.mdl");

	PrecacheModel("models/props_junk/garbage_bag001a.mdl");

	PrecacheModel("models/props_junk/garbage_plasticbottle003a.mdl");

	PrecacheModel("models/props_junk/garbage_metalcan001a.mdl");

	PrecacheModel("models/props_junk/cardboard_box004a.mdl");

	PrecacheModel(GarbageModel);

	//Timer
	CreateTimer(0.2, CreateSQLdbGarbageZone);

	CreateTimer(0.2, CreateSQLdbGarbageCans);
}

public void ResetGarbage()
{

	//Loop:
	for(int Z = 0; Z <= MAXGARBAGEZONE; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		GarbageZones[Z][i] = 69.0;

		GarbageCansZones[Z][i] = 69.0;
	}

	//Loop:
	for(int Z = 0; Z <= MAXGARBAGEZONESINGLE; Z++)
	{

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			GarbageZoneSingle[Z][i] = 69.0;
		}
	}
}

public void initMapGarbageCans()
{

	//Declare:
	char ModelName[128];

	//Declare:
	int Ent = -1;

	//Switch:
	while ((Ent = FindEntityByClassname(Ent, "prop_physics")) > 0)
	{

		//Initialize:
		GetEntPropString(Ent, Prop_Data, "m_ModelName", ModelName, 128);

		//Is Garbage Can:
		if(StrContains(ModelName, GarbageCanModel, false) != -1)
		{

			//Added Effect:
			int Effect = CreateLight(Ent, 1, 120, 255, 120, "null");

			SetEntAttatchedEffect(Ent, 0, Effect);

			//Set Trans Effect:
			SetEntityRenderMode(Ent, RENDER_GLOW);

			//Set Color:
			SetEntityRenderColor(Ent, 120, 255, 120, 145);

			//Set Prop ClassName
			SetEntityClassName(Ent, "prop_Garbage_Can");
		}
	}
}

//Create Database:
public Action CreateSQLdbGarbageZone(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `GarbageZone`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(64) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 1);
}

//Create Database:
public Action CreateSQLdbGarbageCans(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `TrashCan`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `PropId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(64) NULL, `Angles` varchar(64) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 1);
}

//Create Database:
public Action CreateSQLdbGarbageZoneSingle(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `GarbageZoneSingle`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public void initGarbage()
{

	//Declare:
	int GarbageOnMap = GetGarbageOnMap();

	//Loop:
	for(int Z = 0; Z <= 10; Z++)
	{

		//Check:
		if(GarbageZones[Z][0] != 69.0)
		{

			//Anti Spam
			if(GarbageOnMap < MAXGARBAGE)
			{

				//Declare:
				int Random = GetRandomInt(1, 2);

				//Loop:
				for(int R = 1; R <= Random; R++)
				{

					//Spawner:
					SpawnGarbageInZone(Z);
				}
			}

			//Check
			else
			{

				//Stop:
				break;
			}
		}
	}

	//Loop:
	for(int Z = 0; Z <= MAXGARBAGEZONESINGLE; Z++)
	{

		//Check:
		if(GarbageZoneSingle[Z][0] != 69.0)
		{

			//Anti Spam
			if(GarbageOnMap < MAXGARBAGE)
			{

				//Declare:
				int Random = GetRandomInt(1, 2);

				if(Random == 1)
				{

					//Spawner:
					SpawnGarbageSingle(Z);
				}
			}

			//Override:
			else
			{

				//Stop:
				break;
			}
		}
	}

	//Print:
	if(GarbageOnMap >= MAXGARBAGE)
	{

		//Loop:
		for(int Client = 1; Client < GetMaxClients(); Client++)
		{

			//Connected:
			if(IsClientConnected(Client) && IsClientInGame(Client))
			{

				//Check:
				if(StrEqual(GetJob(Client), "Street Sweeper"))
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - The server is full of Garbage!");
				}
			}
		}
	}
}

//Create Database:
public Action LoadGarbageZone(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM GarbageZone WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadGarbageZones, query, 3);
}

//Create Database:
public Action LoadGarbageCans(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM TrashCan WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadGarbageCans, query, 4);
}

//Create Database:
public Action LoadGarbageZoneSingle(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXGARBAGEZONESINGLE; Z++)
	{

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			GarbageZoneSingle[Z][i] = 69.0;
		}
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM GarbageZoneSingle WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadGarbageZoneSingle, query);
}

//PlayerMenu Handle:
public int HandleEmptyGarbageCan(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			int Ent = GetMenuTarget(Client);

			//Is In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Check:
				if(StrEqual(GetJob(Client), "Street Sweeper") || IsAdmin(Client))
				{

					//Declare:
					char info[255];

					//Get Menu Info:
					menu.GetItem(Parameter, info, sizeof(info));

					//Initialize:
					int Result = StringToInt(info);

					//Button Selected:
					if(Result == 0)
					{

						//Declare:
						bool InUse = false;

						//Loop:
						for(int Y = 1; Y < GetMaxClients(); Y++)
						{

							//Return:
							if(IsClientInGame(Y) && IsClientConnected(Y))
							{

								//Someone Already Reycling?
								if(TrashCanEnt[Y] == Ent)
								{

									//Initulize:
									InUse = true;
								}
							}
						}

						//Is Client Recycling:
						if(TrashCanEnt[Client] == -1 && InUse == false)
						{

							//Has Energy:
							if(GetEnergy(Client) >= 35)
							{

								//Declare:
								float EntOrigin[3];
								float GarbageOrigin[3];
								int GarbageCount = 0;

								//Initialize:
								GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", EntOrigin);

								//Declare:
								int Props = -1;

								//Switch:
								while ((Props = FindEntityByClassname(Props, "prop_Garbage")) > 0)
								{

									//Initialize:
									GetEntPropVector(Props, Prop_Send, "m_vecOrigin", GarbageOrigin);

									//Declare:
									float Dist = GetVectorDistance(EntOrigin, GarbageOrigin);

									//In Distance:
									if(Dist <= 150)
									{

										//Remove:
										//AcceptEntityInput(Props, "Kill");
										EntityDissolve(Props, 1);

										//Initulize:
										GarbageCount += 1;
									}
								}

								//Declare:
								Props = -1;

								//Switch:
								while ((Props = FindEntityByClassname(Props, "prop_Player_Garbage")) > 0)
								{

									//Initialize:
									GetEntPropVector(Props, Prop_Send, "m_vecOrigin", GarbageOrigin);

									//Declare:
									float Dist = GetVectorDistance(EntOrigin, GarbageOrigin);

									//In Distance:
									if(Dist <= 150)
									{

										//Remove:
										//AcceptEntityInput(Props, "Kill");
										EntityDissolve(Props, 1);

										//Initulize:
										GarbageCount += 1;
									}
								}

								//No Barbage:
								if(GarbageCount == 0)
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There was no Garbage in this dumpster!");
								}

								//Override:
								else
								{

									//Declare
									int AddCash = (GarbageCount * 20);

									//Set Menu State:
									CashState(Client, AddCash);

									// Dynamic Economy!
									TakeServerSafeMoneyAll(AddCash);

									//Initulize:
									SetCash(Client, (GetCash(Client) + AddCash));

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have recycled %i props and earned â‚¬%i.", GarbageCount, AddCash);

									//Initialize:
									SetEnergy(Client, (GetEnergy(Client) - 35));

									//Set Color:
									SetEntityRenderColor(Ent, 255, 50, 50, 145);

									//Timer:
									CreateTimer(2.50, OnTrashCanRecycleColorTimer, Ent);
								}
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Dont have enough energy to Recycle!");
							}
						}

						//Check:
						else if(InUse == true)
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Someone is already using this trash can to recyle!");
						}

						//Override:
						else	
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are reycling you can't empty this trash can!");
						}
					}

					//Button Selected:
					if(Result == 1)
					{

						//Start:
						BeginReycle(Client, Ent);
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you need to be a 'Street Sweeper' todo this job!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you need to be closer to the Trash Can in order to recycle props!");
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

public Action OnTrashCanRecycleColorTimer(Handle Timer, any Ent)
{

	if(IsValidEdict(Ent))
	{

		//Set Color:
		SetEntityRenderColor(Ent, 120, 255, 120, 145);
	}
}
public Action OnGarbageCanUse(int Client, int Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Valid Job:
		if(StrContains(GetJob(Client), "Street Sweeper", false) != -1 || StrContains(GetJob(Client), "Root Admin", false) != -1 || StrEqual(GetJob(Client), "Admin", false))
		{

			//Draw:
			DrawGarbageCanMenu(Client, Ent);
		}
	}

	//Return:
	return Plugin_Handled;
}

public void DrawGarbageCanMenu(int Client, int Ent)
{

	//Handle:
	Menu menu = CreateMenu(HandleEmptyGarbageCan);

	//Menu Title:
	menu.SetTitle("Would you like to empty\nGarbage can, you gain experience\nfrom emptying the Garbage!");

	//Menu Button:
	menu.AddItem("0", "Empty Garbage");

	//Menu Button:
	menu.AddItem("1", "Reycle Inventory Trash");

	//Set Exit Button:
	menu.ExitButton =  false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");

	//Initulize:
	SetMenuTarget(Client, Ent);
}

public int SpawnGarbage(int Client, int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 1800)
	{

		//Return:
		return view_as<int>(-1);
	}

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Check:
	if(IsValidEntity(Ent))
	{

		//Declare:
		float ClientOrigin[3];
		float GarbageOrigin[3];
		float EyeAngles[3];
		char ModelName[256];

		//Check:
		if(Var == 1)
		{

			//Declare:
			int Roll = GetRandomInt(0, 2);

			if(Roll == 0)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_takeoutcarton001a.mdl";
			}

			if(Roll == 1)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_bag001a.mdl";
			}

			if(Roll == 2)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_metalcan001a.mdl";
			}
		}

		//Check:
		if(Var == 2)
		{

			//Initulize:
			ModelName = "models/props_junk/popcan01a.mdl";
		}

		//Check:
		if(Var == 3)
		{

			//Initulize:
			ModelName = "models/props_junk/garbage_plasticbottle003a.mdl";
		}

		//Check:
		if(Var == 4)
		{

			//Initulize:
			ModelName = "models/props_junk/garbage_plasticbottle003a.mdl";
		}

		//Dispatch:
		DispatchKeyValue(Ent, "physdamagescale", "0.0");

		DispatchKeyValue(Ent, "model", ModelName);

		//Spawn:
		DispatchSpawn(Ent);

		//Initialize:
		GetClientAbsOrigin(Client, ClientOrigin);

		GetClientEyeAngles(Client, EyeAngles);

		//Initialize:
		GarbageOrigin[0] = (ClientOrigin[0] + (FloatMul(50.0, Cosine(DegToRad(EyeAngles[1])))));

		GarbageOrigin[1] = (ClientOrigin[1] + (FloatMul(50.0, Sine(DegToRad(EyeAngles[1])))));

		GarbageOrigin[2] = (ClientOrigin[2] + 100);

		//Teleport:
		TeleportEntity(Ent, GarbageOrigin, NULL_VECTOR, NULL_VECTOR);

		//Set Prop ClassName
		SetEntityClassName(Ent, "prop_Player_Garbage");

		//Return:
		return view_as<int>(Ent);
	}

	//Return:
	return view_as<int>(-1);
}

public int SpawnGarbageSingle(int ZoneId)
{

	//Declare:
	int  Ent = CreateEntityByName("prop_physics_override");

	//Check:
	if(IsValidEntity(Ent))
	{

		//Declare:
		char ModelName[256];

		//Declare:
		int Roll = GetRandomInt(1, 4);

		//Check:
		if(Roll == 1)
		{

			//Declare:
			Roll = GetRandomInt(0, 2);

			if(Roll == 0)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_takeoutcarton001a.mdl";
			}

			if(Roll == 1)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_bag001a.mdl";
			}

			if(Roll == 2)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_metalcan001a.mdl";
			}
		}

		//Check:
		if(Roll == 2)
		{

			//Initulize:
			ModelName = "models/props_junk/popcan01a.mdl";
		}

		//Check:
		if(Roll == 3)
		{

			//Initulize:
			ModelName = "models/props_junk/garbage_plasticbottle003a.mdl";
		}

		//Check:
		if(Roll == 4)
		{

			//Initulize:
			ModelName = "models/props_junk/garbage_plasticbottle003a.mdl";
		}

		//Dispatch:
		DispatchKeyValue(Ent, "physdamagescale", "0.0");

		DispatchKeyValue(Ent, "model", ModelName);

		//Spawn:
		DispatchSpawn(Ent);

		//Declare:
		float Position[3]; 
		float Angles[3] = {0.0, 0.0, 0.0};

		//Initulize:
		Angles[1] = GetRandomFloat(0.0, 360.0);
		Position[0] = GarbageZoneSingle[ZoneId][0] + GetRandomFloat(-40.0, 40.0);
		Position[1] = GarbageZoneSingle[ZoneId][1] + GetRandomFloat(-40.0, 40.0);
		Position[2] = GarbageZoneSingle[ZoneId][2] + GetRandomFloat(-5.0, 5.0);

		//Teleport:
		TeleportEntity(Ent, Position, Angles, NULL_VECTOR);

		//Set Prop ClassName
		SetEntityClassName(Ent, "prop_Player_Garbage");

		float ModelScale = GetRandomFloat(1.00, 1.15);

		//Send:

		SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);


		//Return:
		return view_as<int>(Ent);
	}

	//Return:
	return view_as<int>(-1);
}

public int SpawnGarbageInZone(int ZoneId)
{

	//Declare:
	int  Ent = CreateEntityByName("prop_physics_override");

	//Check:
	if(IsValidEntity(Ent))
	{

		//Declare:
		char ModelName[256];

		//Initulize:
		ModelName = GarbageModel;

		//Dispatch:
		DispatchKeyValue(Ent, "physdamagescale", "0.0");

		DispatchKeyValue(Ent, "model", ModelName);

		//Spawn:
		DispatchSpawn(Ent);

		//Declare:
		float Position[3]; 
		float Angles[3] = {0.0, 0.0, 0.0};

		//Initulize:
		Angles[1] = GetRandomFloat(0.0, 360.0);
		Position[0] = GarbageZones[ZoneId][0] + GetRandomFloat(-40.0, 40.0);
		Position[1] = GarbageZones[ZoneId][1] + GetRandomFloat(-40.0, 40.0);
		Position[2] = GarbageZones[ZoneId][2] + GetRandomFloat(-5.0, 5.0);

		//Teleport:
		TeleportEntity(Ent, Position, Angles, NULL_VECTOR);

		//Set Prop ClassName
		SetEntityClassName(Ent, "prop_Garbage");

		float ModelScale = GetRandomFloat(1.00, 1.15);

		//Send:

		SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);


		//Return:
		return view_as<int>(Ent);
	}

	//Return:
	return view_as<int>(-1);
}

public int SpawnGarbageCustom(float Position[3])
{

	//Declare:
	int  Ent = CreateEntityByName("prop_physics_override");

	//Check:
	if(IsValidEntity(Ent))
	{

		//Declare:
		char ModelName[256];

		//Declare:
		int Roll = GetRandomInt(1, 4);

		//Check:
		if(Roll == 1)
		{

			//Declare:
			Roll = GetRandomInt(0, 2);

			if(Roll == 0)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_takeoutcarton001a.mdl";
			}

			if(Roll == 1)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_bag001a.mdl";
			}

			if(Roll == 2)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_metalcan001a.mdl";
			}
		}

		//Check:
		if(Roll == 2)
		{

			//Initulize:
			ModelName = "models/props_junk/popcan01a.mdl";
		}

		//Check:
		if(Roll == 3)
		{

			//Initulize:
			ModelName = "models/props_junk/garbage_plasticbottle003a.mdl";
		}

		//Check:
		if(Roll == 4)
		{

			//Initulize:
			ModelName = "models/props_junk/garbage_plasticbottle003a.mdl";
		}

		//Dispatch:
		DispatchKeyValue(Ent, "physdamagescale", "0.0");

		DispatchKeyValue(Ent, "model", ModelName);

		//Spawn:
		DispatchSpawn(Ent);

		//Declare:
		float Angles[3] = {0.0, 0.0, 0.0};

		//Initulize:
		Angles[1] = GetRandomFloat(0.0, 360.0);
		Position[0] = Position[0] + GetRandomFloat(-40.0, 40.0);
		Position[1] = Position[1] + GetRandomFloat(-40.0, 40.0);
		Position[2] = Position[2] + GetRandomFloat(-5.0, 5.0);

		//Teleport:
		TeleportEntity(Ent, Position, Angles, NULL_VECTOR);

		//Set Prop ClassName
		SetEntityClassName(Ent, "prop_Player_Garbage");

		float ModelScale = GetRandomFloat(1.00, 1.15);

		//Send:

		SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);


		//Return:
		return view_as<int>(Ent);
	}

	//Return:
	return view_as<int>(-1);
}

//Create Garbage Zone:
public Action Command_CreateGarbageZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_creategarbagezone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	char query[255];
	char Position[128];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
	
	//Spawn Already Created:
	if(GarbageZones[StringToInt(ZoneId)][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE GarbageZone SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), StringToInt(ZoneId));
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO GarbageZone (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	GarbageZones[StringToInt(ZoneId)] = ClientOrigin;

	//Override:
	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 6);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created spawn \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", ZoneId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action Command_RemoveGarbageZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removegarbagezone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//No Zone:
	if(GarbageZones[StringToInt(ZoneId)][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	GarbageZones[StringToInt(ZoneId)][0] = 69.0;

	//Declare:
	char query[255];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM GarbageZone WHERE ZoneId = %i  AND Map = '%s';", StringToInt(ZoneId), ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 7);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Garbage Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListGarbageZone(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Garbage Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXGARBAGEZONE; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM GarbageZone WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintGarbageZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Beta:
public Action Command_WipeGarbageZone(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Garbage Spawns Wiped: %s", ServerMap());

	//Declare:
	char buffer[255];

	//Loop:
	for(int X = 1; X < MAXGARBAGEZONE; X++)
	{

		//Sql String:
		Format(buffer, sizeof(buffer), "DELETE FROM GarbageZone WHERE ZoneId = %i;", X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer, 8);
	}

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action Command_CreateGarbageCan(int Client, int Args)
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

	//Spawn Prop
	int Ent = CreateProp(Origin, EyeAngles, GarbageCanModel, false, false);

	//Added Effect:
	int Effect = CreateLight(Ent, 1, 120, 255, 120, "null");

	SetEntAttatchedEffect(Ent, 0, Effect);

	//Set Trans Effect:
	SetEntityRenderMode(Ent, RENDER_GLOW);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Garbage_Can");

	//Set Color:
	SetEntityRenderColor(Ent, 120, 255, 120, 145);

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action Command_SaveGarbageCan(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_creategarbagecan <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

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
	if(!StrEqual(ClassName, "prop_Garbage_Can"))
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
	if(GarbageCansZones[StringToInt(ZoneId)][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE TrashCan SET Position = '%s', Angles = '%s' WHERE Map = '%s' AND PropId = %i;", Position, Ang, ServerMap(), StringToInt(ZoneId));
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO TrashCan (`Map`,`PropId`,`Position`,`Angles`) VALUES ('%s',%i,'%s','%s');", ServerMap(), StringToInt(ZoneId), Position, Ang);
	}

	//Accept:
	AcceptEntityInput(Ent, "disablemotion", Ent);

	//Initulize:
	GarbageCansZones[StringToInt(ZoneId)] = Origin;

	//Override:
	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 8);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created spawn \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", ZoneId, Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action Command_RemoveGarbageCan(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removegarbagecan <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//No Zone:
	if(GarbageCansZones[StringToInt(ZoneId)][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	GarbageCansZones[StringToInt(ZoneId)][0] = 69.0;

	//Declare:
	char query[255];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM TrashCan WHERE PropId = %i  AND Map = '%s';", StringToInt(ZoneId), ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 10);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Garbage Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListGarbageCans(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Garbage Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXGARBAGEZONE; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM TrashCan WHERE Map = '%s' AND PropId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintGarbageCans, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Beta:
public Action Command_WipeGarbageCan(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Garbage Spawns Wiped: %s", ServerMap());

	//Declare:
	char buffer[255];

	//Loop:
	for(int X = 1; X < MAXGARBAGEZONE; X++)
	{

		//Sql String:
		Format(buffer, sizeof(buffer), "DELETE FROM TrashCan WHERE PropId = %i;", X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer, 11);
	}

	//Return:
	return Plugin_Handled;
}


public Action Command_CreateGarbageZoneSingle(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_creategarbagezonesingle <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_creategarbagezonesingle <0-%i>", MAXGARBAGEZONESINGLE);

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
	if(GarbageZoneSingle[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE GarbageZoneSingle SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO GarbageZoneSingle (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	GarbageZoneSingle[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Zombie npc spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemoveGarbageZoneSingle(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removegarbagezonesingle <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removegarbagezonesingle <0-%i>", MAXGARBAGEZONESINGLE);

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(GarbageZoneSingle[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	GarbageZoneSingle[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM GarbageZoneSingle WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Zombie npc Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

public Action Command_ListGarbageZoneSingle(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Zombie Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXGARBAGEZONESINGLE; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM GarbageZoneSingle WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintGarbageZoneSingle, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeGarbageZoneSingles(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Zombie Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXGARBAGEZONESINGLE; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM GarbageZoneSingle WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}


public void T_DBLoadGarbageZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadGarbageZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Garbage Zones Found in DB!");

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
			GarbageZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Garbage Zones Loaded!");
	}
}

public int T_DBLoadGarbageCans(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadGarbageCans: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Garbage Cans Found in DB!");

			//Return:
			return;
		}

		//Declare:
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

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

			//Create:
			CreateGarbageCan(Origin, Angles);
		}

		//Print:
		PrintToServer("|RP| - Garbage Cans Loaded!");
	}
}

public int CreateGarbageCan(float Origin[3], float Angles[3])
{

	//Spawn Prop
	int Ent = CreateProp(Origin, Angles, GarbageCanModel, false, true);

	//Added Effect:
	int Effect = CreateLight(Ent, 1, 120, 255, 120, "null");

	SetEntAttatchedEffect(Ent, 0, Effect);

	//Set Trans Effect:
	SetEntityRenderMode(Ent, RENDER_GLOW);

	//Set Color:
	SetEntityRenderColor(Ent, 120, 255, 120, 145);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Garbage_Can");

	//Return:
	return view_as<int>(Ent);
}

public void T_DBPrintGarbageZones(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintGarbageZones: Query failed! %s", error);
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
			SQL_FetchString(hndl,2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", ZoneId, Buffer);
		}
	}
}

public void T_DBPrintGarbageCans(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintGarbageCan: Query failed! %s", error);
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
			SQL_FetchString(hndl,2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", ZoneId, Buffer);
		}
	}
}


public void T_DBLoadGarbageZoneSingle(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadGarbageZoneSingle: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Zombie Zones Found in DB!");

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
			GarbageZoneSingle[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Zombie Zones Found!");
	}
}

public void T_DBPrintGarbageZoneSingle(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintGarbageZoneSingle: Query failed! %s", error);
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


public int GetGarbageOnMap()
{

	//Declare:
	int iEnts = 0;

	//Clean map entitys:
	for(int Ent = 0; Ent < 2047; Ent++)
	{

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char ClassName[32];

			//Get Entity Info:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Prop Garbage Can:
			if(StrEqual(ClassName, "prop_Garbage") || StrEqual(ClassName, "prop_Player_Garbage"))
			{

				//Initulize:
				iEnts += 1;
			}
		}
	}

	//Return:
	return iEnts;
}

public void PropTrashCanHud(int Client, int Ent, float NoticeInterval)
{

	//Check:
	if(!StrEqual(GetJob(Client), "Street Sweeper") && !IsAdmin(Client))
	{

		//Return:
		return;
	}

	//Declare:
	int iEnt = -1;
	float EntOrigin[3];
	float GarbageOrigin[3];
	int GarbageCount = 0;

	//Initialize:
	GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", EntOrigin);

	//Switch:
	while ((iEnt = FindEntityByClassname(iEnt, "prop_Garbage")) != -1)
	{

		//Initialize:
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", GarbageOrigin);

		//Declare:
		float Dist = GetVectorDistance(EntOrigin, GarbageOrigin);

		//In Distance:
		if(Dist <= 150)
		{

			//Initialize:
			GarbageCount += 1;
		}
	}

	iEnt = -1;

	//Switch:
	while ((iEnt = FindEntityByClassname(iEnt, "prop_Player_Garbage")) != -1)
	{

		//Initialize:
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", GarbageOrigin);

		//Declare:
		float Dist = GetVectorDistance(EntOrigin, GarbageOrigin);

		//In Distance:
		if(Dist <= 150)
		{

			//Initialize:
			GarbageCount += 1;
		}
	}

	//Declare:
	char FormatMessage[1024];

	//Check:
	if(GarbageCount > 0)
	{

		//Format:
		Format(FormatMessage, sizeof(FormatMessage), "Trash Can:\nPress 'e' to Empty the trash can\nCollect: %s", IntToMoney(GarbageCount * 20));
	}

	//Override:
	else
	{


		//Format:
		Format(FormatMessage, sizeof(FormatMessage), "Trash Can:\nPress 'e' to Empty the trash can\nNo Trash!");
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

public void OnPlayerGarbageUse(int Client, int Ent)
{

	//Declare:
	int ItemId = 466;

	//Save:
	SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) + 1));

	//Request:
	RequestFrame(OnNextFrameKill, Ent);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - You have picked up trash!");
}

public void OnItemsUseTrash(int Client, int ItemId)
{

	//Forward:
	OnClientRecycleTrashInInventory(Client);
}

public void OnClientRecycleTrashInInventory(int Client)
{

	//Declare:
	int iEnt = -1;
	float EntOrigin[3];
	float GarbageOrigin[3];

	//Initialize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", EntOrigin);

	//Switch:
	while ((iEnt = FindEntityByClassname(iEnt, "prop_Garbage_Can")) != -1)
	{

		//Initialize:
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", GarbageOrigin);

		//Declare:
		float Dist = GetVectorDistance(EntOrigin, GarbageOrigin);

		//In Distance:
		if(Dist <= 150)
		{

			//Start:
			BeginReycle(Client, iEnt);

			//Stop:
			break;
		}

		//Check:
		else
		{

			//Print:
			OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - you need to be within distance of a Garbage Can to recycle your trash!");

			//Stop:
			break;
		}
	}
}

public Action BeginReycle(int Client, int Ent)
{

	//In Critical:
	if(GetIsCritical(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are in Critical Health!");

		//Return:
		return Plugin_Continue;
	}

	//Is Robbing:
	else if(TrashCanEnt[Client] != -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are already robbing!");

		//Return:
		return Plugin_Continue;
	}

	//Is Robbing:
	else if(GetEnergy(Client) < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have enough energy to reycle any trash!");

		//Return:
		return Plugin_Continue;
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't do this action!");

		//Return:
		return Plugin_Continue;
	}

	//Override:
	else
	{

		//Initulize:
		SetEnergy(Client, (GetEnergy(Client) - 2));

		//Initialize:
		TrashCanEnt[Client] = Ent;

		//Timer:
		CreateTimer(0.5, BeginTrashRecycle, Client, TIMER_REPEAT);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have started recycling trash!");
	}

	//Return:
	return Plugin_Continue;
}

public Action BeginTrashRecycle(Handle Timer, any Client)
{

	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client) || !IsValidEdict(TrashCanEnt[Client]))
	{

		//Initulize:
		TrashCanEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Is Robbing:
	else if(GetEnergy(Client) < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have enough energy to continue recycling!");

		//Return:
		return Plugin_Continue;
	}

	//Declare:
	int ItemId = 466;

	//Cleared:
	if(GetItemAmount(Client, ItemId) == 0 || !IsPlayerAlive(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you don't have anymore trash to recycle!");

		//Initulize:
		TrashCanEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Position[3];

	//Initulize:
	GetEntPropVector(TrashCanEnt[Client], Prop_Send, "m_vecOrigin", Position);

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	float Dist = GetVectorDistance(Position, ClientOrigin);

	//Too Far Away:
	if(Dist >= 250)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have moved too far away to recycle the trash can!");

		//Initulize:
		TrashCanEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	Position[2] += 70.0;

	//Spawn Garbage and desolve:
	EntityDissolve(SpawnGarbageCustom(Position), 1);

	//Declare
	int AddCash = 20;

	//Set Menu State:
	CashState(Client, AddCash);

	// Dynamic Economy!
	TakeServerSafeMoneyAll(AddCash);

	//Initulize:
	SetCash(Client, (GetCash(Client) + AddCash));

	//Save:
	SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

	//Initialize:
	SetEnergy(Client, (GetEnergy(Client) - 2));

	//Return:
	return Plugin_Handled;
}
public Action Command_LocateTrashCan(int Client, int Args)
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
	float Position[3];
	float Origin[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);
	Position[2] += 25.0;


	//Declare:
	float LastDistance = 0.0;
	int FindEnt = -1;
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Garbage_Can")) != -1)
	{

		//Initialize:
		GetEntPropVector(Props, Prop_Send, "m_vecOrigin", Origin);

		//Declare:
		float Dist = GetVectorDistance(Position, Origin);

		//In Distance:
		if(Dist <= LastDistance || LastDistance == 0.0)
		{

			//Initulize:
			LastDistance = Dist;
			FindEnt = Props;
		}
	}

	//Initialize:
	GetEntPropVector(FindEnt, Prop_Send, "m_vecOrigin", Origin);

	//Declare:
	int BeamColor[4] = {255, 255, 255, 225};

	TE_SetupBeamPoints(Position, Origin, Laser(), 0, 0, 66, 1.0, 1.0, 1.0, 0, 0.0, BeamColor, 0);

	TE_SendToClient(Client);

	//Return:
	return Plugin_Handled;
}