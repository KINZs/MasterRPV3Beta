//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_gunshopweapons_included_
  #endinput
#endif
#define _rp_gunshopweapons_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXGUNSHOPWEAPONS		2

//Definitions:
int GunShopWeapons[MAXGUNSHOPWEAPONS + 1] = {-1,...};
int GunShopWeaponsModel[MAXGUNSHOPWEAPONS + 1] = {0,...};

public void initGunShopWeapons()
{

	//Commands:
	RegAdminCmd("sm_creategunshopweapon", Command_CreateGunShopWeapon, ADMFLAG_ROOT, "<id> - Create a Gun Sho Weapon");

	RegAdminCmd("sm_savegunshopweapon", Command_SaveGunShopWeapon, ADMFLAG_ROOT, "<id> - Save a computer for hacking");

	RegAdminCmd("sm_removegunshoweapon", Command_RemoveGunShopWeapon, ADMFLAG_ROOT, "<id> - Removes a computer from the db");

	RegAdminCmd("sm_listgunshopweapons", Command_ListGunShopWeapons, ADMFLAG_SLAY, "- Lists all the computers in the database");

	//Beta
	RegAdminCmd("sm_wipegunshopweapon", Command_WipeGunShopWeapons, ADMFLAG_ROOT, "");

	//Timers:
	CreateTimer(0.2, CreateSQLdbGunShopWeapons);
}

//Create Database:
public Action CreateSQLdbGunShopWeapons(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `GunShopWeapon`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ComputerId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL, `angles` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadGunShopWeapons(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM GunShopWeapon WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadGunShopWeapons, query);

	//Declare:
	char Id2[255];
	char Path[32];
	char Buffer[255];

	//Format:
	Format(Path, sizeof(Path), "Prop_GunShop");

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Loop:
	for(int X = 0; X <= 26; X++)
	{

		//Format:
		Format(Id2, sizeof(Id2), "%i", X);

		//Load:
		FileToKeyValues(Vault, WeaponModPath);

		//Load:
		LoadString(Vault, Path, Id2, "null", Buffer);

		//Is Valid:
		if(!StrEqual(Buffer, "null", false))	
		{

			//Check:
			if(!IsModelPrecached(Buffer))
			{

				//PreCache:
				PrecacheModel(Buffer);
			}
		}
	}

	//Close:
	CloseHandle(Vault);
}

//Create Garbage Zone:
public Action Command_CreateGunShopWeapon(int Client, int Args)
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
	int Ent = CreateProp(Origin, EyeAngles, "models/weapons/w_shotgun.mdl", false, false);

	//Set ClassName:
	SetEntityClassName(Ent, "prop_Gun_Shop_Weapon");

	//Return:
	return Plugin_Handled;
}

//Save Computer:
public Action Command_SaveGunShopWeapon(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_savegunshopweapons <id>");

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
	if(!IsValidGunShopWeapon(Ent))
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
	if(StringToInt(SpawnId) < 0 || StringToInt(SpawnId) > MAXCOMPUTERS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_savegunshopweapons <0-%i>", MAXGUNSHOPWEAPONS);

		//Return:
		return Plugin_Handled;
	}

	//Spawn Already Created:
	if(IsValidEdict(GunShopWeapons[StringToInt(SpawnId)]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is already a pd computer index into the db. (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

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

	//Format:
	Format(query, sizeof(query), "INSERT INTO GunShopWeapon (`Map`,`ComputerId`,`Position`,`Angles`) VALUES ('%s',%i,'%s','%s');", ServerMap(), StringToInt(SpawnId), Position, Ang);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	GunShopWeapons[StringToInt(SpawnId)] = Ent;

	//Invincible:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Set Color:
	SetEntityRenderColor(Ent, 255, 255 ,255 , 168);

	//Set Render:
	SetEntityRenderMode(Ent, RENDER_TRANSCOLOR);

	//Set Render Ex:
	SetEntityRenderFx(Ent, RENDERFX_DISTORT);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Saved Gun Shop Weapon \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Computer:
public Action Command_RemoveGunShopWeapon(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removegunshoweapon <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Spawn Already Created:
	if(!IsValidEdict(GunShopWeapons[StringToInt(SpawnId)]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM GunShopWeapon WHERE ComputerId = %i AND Map = '%s';", StringToInt(SpawnId), ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Gun Shop Weapon (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListGunShopWeapons(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Gun Shop Weapon List: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXGUNSHOPWEAPONS + 1; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM GunShopWeapon WHERE Map = '%s' AND ComputerId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintGunShopWeapons, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeGunShopWeapons(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Gun Shop Weapon List Wiped: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 1; X < MAXGUNSHOPWEAPONS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM GunShopWeapon WHERE ComputerId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBLoadGunShopWeapons(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadGunShopWeapons: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Gun Shop Weapon Found in DB!");

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
			float Angles[3];

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

			//Create Computer:
			int Ent = CreateProp(Position, Angles, "models/weapons/w_shotgun.mdl", true, true);

			//Invincible:
			SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

			//Initulize:
			GunShopWeapons[X] = Ent;

			//Set ClassName:
			SetEntityClassName(Ent, "prop_Gun_Shop_Weapon");

			//Set Color:
			SetEntityRenderColor(Ent, 255, 255 ,255 , 168);

			//Set Render:
			SetEntityRenderMode(Ent, RENDER_TRANSCOLOR);

			//Set Render Ex:
			SetEntityRenderFx(Ent, RENDERFX_DISTORT);
		}

		//Print:
		PrintToServer("|RP| - Gun Shop Weapons Found!");
	}
}

public void T_DBPrintGunShopWeapons(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintGunShopWeapons: Query failed! %s", error);
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

//Handle Use Forward:
public void OnGunShopWeaponUse(int Client, int Ent)
{

	//Initulize:
	SetLastPressedE(Client, 0.0);
}

public bool IsValidGunShopWeapon(int Ent)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Door:
	if(StrEqual(ClassName, "prop_Gun_Shop_Weapon"))
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public void ChangeGunShopWeaponModel()
{

	//Loop:
	for(int X = 1; X < MAXGUNSHOPWEAPONS; X++)
	{

		//Check:
		if(IsValidEdict(GunShopWeapons[X]))
		{

			//Declare:
			char Id2[255];
			char Path[32];
			char Buffer[255];

			//Format:
			Format(Path, sizeof(Path), "Prop_GunShop");

			//Format:
			Format(Id2, sizeof(Id2), "%i", GunShopWeaponsModel[X]);

			//Handle:
			Handle Vault = CreateKeyValues("Vault");

			//Load:
			FileToKeyValues(Vault, WeaponModPath);

			//Load:
			LoadString(Vault, Path, Id2, "null", Buffer);

			//Is Valid:
			if(!StrEqual(Buffer, "null", false))	
			{

				//Declare:
				float Position[3];
				float Angles[3];

				//Get Prop Data:
				GetEntPropVector(GunShopWeapons[X], Prop_Send, "m_vecOrigin", Position);

				GetEntPropVector(GunShopWeapons[X], Prop_Data, "m_angRotation", Angles);

				//Set Entity Model:
				SetEntityModel(GunShopWeapons[X],  Buffer);

				//Initulize:
				GunShopWeaponsModel[X] += 1;

				if(GunShopWeaponsModel[X] > 26)
				{

					//Initulize:
					GunShopWeaponsModel[X] = 0;
				}
			}

			//Close:
			CloseHandle(Vault);
		}
	}
}