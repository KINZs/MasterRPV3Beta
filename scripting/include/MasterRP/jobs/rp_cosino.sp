//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_cosino_included_
  #endinput
#endif
#define _rp_cosino_included_

//Defines:
#define MAXCOSINOZONES		5

//Euro - € dont remove this!
//€ = �

//Cosino Zones!
float CosinoZones[MAXCOSINOZONES + 1][3];
bool InCosino[MAXPLAYERS + 1] = {false,...};

//Cosino:
int CosinoBank = 0;

public void initCosino()
{

	//Commands:
	RegAdminCmd("sm_createcosinozone", Command_CreateCosinoZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removecosinozone", Command_RemoveCosinoZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listcosinozones", Command_ListCosinoZones, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipecosinozones", Command_WipeCosinoZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_setcosinobank", Command_SetCosinoBank, ADMFLAG_ROOT);

	//Timers:
	CreateTimer(0.2, CreateSQLdbCosinoZones);

	CreateTimer(0.2, CreateSQLdbCosinoBank);

	//Player Commands:
	RegConsoleCmd("sm_dice", Command_CosinoDice);

	RegConsoleCmd("sm_roulette", Command_CosinoRoulette);

	RegConsoleCmd("sm_roll", Command_CosinoRoll);

	RegConsoleCmd("sm_doubleroll", Command_CosinoDoubleRoll);

	RegConsoleCmd("sm_locatecosino", Command_LocateCosino);

	//Loop:
	for(int Z = 0; Z <= MAXCOSINOZONES; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		CosinoZones[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbCosinoZones(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `CosinoZones`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action CreateSQLdbCosinoBank(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `CosinoBank`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `Bank` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadCosinoZones(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXCOSINOZONES; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		CosinoZones[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM CosinoZones WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadCosinoZones, query);
}

public void T_DBLoadCosinoZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadCosinoZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Cosino Zones Found in DB!");

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
			CosinoZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Cosino Zones Found!");
	}
}

//Create Database:
public Action LoadCosinoBank(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM CosinoBank WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadCosinoBank, query);
}

public void T_DBLoadCosinoBank(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadCosinoBank: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Cosino Zones Found in DB, Created New Table!");

			//Declare:
			char query[512];

			//Format:
			Format(query, sizeof(query), "INSERT INTO CosinoBank (`Map`,`Bank`) VALUES ('%s',0);", ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Return:
			return;
		}

		//Override
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			CosinoBank = SQL_FetchInt(hndl, 1);
		}

		//Print:
		PrintToServer("|RP| - Cosino Bank Found!");
	}
}

public void T_DBPrintCosinoZones(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintCosinoZones: Query failed! %s", error);
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
public Action Command_CreateCosinoZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createcosinozone <id>");

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
	if(Id < 0 || Id > MAXCOSINOZONES)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createcosinozone <0-%i>", MAXCOSINOZONES);

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
	if(CosinoZones[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE CosinoZones SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO CosinoZones (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	CosinoZones[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Cosino Zones spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action Command_RemoveCosinoZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removecosinozone <id>");

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
	if(Id < 0 || Id > MAXCOSINOZONES)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removecosinozone <0-%i>", MAXCOSINOZONES);

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(CosinoZones[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	CosinoZones[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM CosinoZones WHERE ZoneId = %i AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Cosino Zones Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListCosinoZones(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Cosino Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXCOSINOZONES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM CosinoZones WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintCosinoZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeCosinoZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Cosino Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXCOSINOZONES; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM CosinoZones WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_SetCosinoBank(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setcosinobank <Amount>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sAmount[16];

	//Initialize:
	GetCmdArg(1, sAmount, sizeof(sAmount));

	//Declare:
	int Amount = StringToInt(sAmount);

	//Check:
	if(Amount < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setcosinobank <Amount>");

		//Return:
		return Plugin_Handled;
	}

	//Set:
	SetCosinoBank(Amount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have set the cosino bank to \x0732CD32#%s", IntToMoney(Amount));

	//Return:
	return Plugin_Handled;
}

public void CheckClientIsInCosino(int Client)
{

	//Declare:
	float Position[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);

	//Declare:
	float Dist = GetVectorDistance(CosinoZones[1], Position);

	//In Distance:
	if(Dist <= 155)
	{

		//Check:
		if(InCosino[Client] == false)
		{

			//Initulize:
			InCosino[Client] = true;

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have entered the cosino!");
		}

		//Declare:
		int Random = GetRandomInt(1, 7);

		//Declare:
		int BeamColor[4] = {255, 100, 100, 225};

		switch(Random)
		{

			case 1:
			{

				//Initulize:
				BeamColor[0] = 255;
				BeamColor[1] = 100;
				BeamColor[2] = 100;
				BeamColor[3] = 225;
			}

			case 2:
			{

				//Initulize:
				BeamColor[0] = 255;
				BeamColor[1] = 225;
				BeamColor[2] = 100;
				BeamColor[3] = 225;
			}

			case 3:
			{

				//Initulize:
				BeamColor[0] = 255;
				BeamColor[1] = 225;
				BeamColor[2] = 225;
				BeamColor[3] = 225;
			}

			case 4:
			{

				//Initulize:
				BeamColor[0] = 100;
				BeamColor[1] = 225;
				BeamColor[2] = 225;
				BeamColor[3] = 225;
			}

			case 5:
			{

				//Initulize:
				BeamColor[0] = 100;
				BeamColor[1] = 100;
				BeamColor[2] = 225;
				BeamColor[3] = 225;
			}

			case 6:
			{

				//Initulize:
				BeamColor[0] = 255;
				BeamColor[1] = 100;
				BeamColor[2] = 225;
				BeamColor[3] = 225;
			}

			case 7:
			{

				//Initulize:
				BeamColor[0] = 100;
				BeamColor[1] = 225;
				BeamColor[2] = 100;
				BeamColor[3] = 225;
			}
		}

		//Draw Cosino:
		DrawCosinoBeamBoxToClient(Client, Laser(), 0, 0, 66, 1.0, 1.0, 1.0, 0, 0.0, BeamColor, 0);
	}

	//In Distance:
	if(Dist > 155)
	{

		//Check:
		if(InCosino[Client] == true)
		{

			//Initulize:
			InCosino[Client] = false;

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have left the cosino!");
		}
	}
}

public void DrawCosinoBeamBoxToClient(int Client, int modelIndex, int haloIndex, int startFrame, int frameRate, float life, float width, float endWidth, int fadeLength, float amplitude, int Color[4], int speed)
{

	TE_SetupBeamPoints(CosinoZones[2], CosinoZones[3], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToClient(Client);

	TE_SetupBeamPoints(CosinoZones[2], CosinoZones[4], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToClient(Client);

	TE_SetupBeamPoints(CosinoZones[5], CosinoZones[3], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToClient(Client);

	TE_SetupBeamPoints(CosinoZones[5], CosinoZones[4], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToClient(Client);

	TE_SetupDynamicLight(CosinoZones[1], Color[0], Color[1], Color[2], 8, 100.0, 1.5, 50.0);

	TE_SendToClient(Client);
}


public bool IsClientInCosino(int Client)
{

	//Return:
	return view_as<bool>(InCosino[Client]);
}

public void SetInCosino(int Client, bool Result)
{

	//Initulize:
	InCosino[Client] = Result;
}


public int GetCosinoBank()
{

	//Return:
	return view_as<bool>(CosinoBank);
}

public void SetCosinoBank(int Amount)
{

	//Initulize:
	if(Amount == 0)
	{

		//Initulize:
		Amount = (GetServerSafeMoneyTotal() / 2);

		TakeServerSafeMoneyAll((Amount / 2));

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - The Cosino has just declared babkcuptcy and has had to take a loan out from the server!");
	}

	//Initulize:
	CosinoBank = Amount;

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "UPDATE CosinoBank SET Bank = %i WHERE Map = '%s';", CosinoBank, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public Action Command_CosinoDice(int Client, int Args)
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
	if(!InCosino[Client])
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have to be in the cosino to be able to use this command");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_dice <Amount>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sAmount[16];

	//Initialize:
	GetCmdArg(1, sAmount, sizeof(sAmount));

	//Declare:
	int Amount = StringToInt(sAmount);

	//Check:
	if(Amount < 0 || Amount > 50000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Maximun bet for dice is \x0732CD32#%s", IntToMoney(50000));

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Amount == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Bet");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetBank(Client) - Amount < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have \x0732CD32#%s\x07FFFFFF in your bank", IntToMoney(Amount));

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(CosinoBank - Amount < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - The Cosino dont have \x0732CD32#%s\x07FFFFFF", IntToMoney(Amount));

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	OnClientDiceInCosino(Client, Amount);

	//Return:
	return Plugin_Handled;
}

public void OnClientDiceInCosino(int Client, int Amount)
{

	//Declare:
	int Random = GetRandomInt(1, 12);

	//Check:
	if(Random <= 6)
	{

		//Initulize:
		SetBank(Client, (GetBank(Client) + Amount));

		//Check:
		if(GetCosinoBank() - Amount > 0)
		{

			//Set Cosino:
			SetCosinoBank(GetCosinoBank() - Amount);
		}

		//Overide:
		else
		{
			//Set Cosino:
			SetCosinoBank(0);
		}

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have won your bet of \x0732CD32#%s\x07FFFFFF!", IntToMoney(Amount));

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && InCosino[i] && Client != i)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF have won there bet of \x0732CD32#%s\x07FFFFFF!", Client, IntToMoney(Amount));
			}
		}
	}

	//Overide:
	else
	{

		//Initulize:
		SetBank(Client, (GetBank(Client) - Amount));

		//Set Cosino:
		SetCosinoBank(GetCosinoBank() + Amount);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have lost your bet of \x0732CD32#%s\x07FFFFFF!", IntToMoney(Amount));

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && InCosino[i] && Client != i)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF have lost there bet of \x0732CD32#%s\x07FFFFFF!", Client, IntToMoney(Amount));
			}
		}
	}
}

public Action Command_CosinoRoulette(int Client, int Args)
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
	if(!InCosino[Client])
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have to be in the cosino to be able to use this command");

		//Return:
		return Plugin_Handled;
	}


	//No Valid Charictors:
	if(Args != 3)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_roulette <0-36> <red\black> <Bet>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sNumber[16];

	//Initialize:
	GetCmdArg(1, sNumber, sizeof(sNumber));

	//Declare:
	int Number = StringToInt(sNumber);

	//Check:
	if(Number < 0 || Number > 36)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Number 0 to 36");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sColor[16];

	//Initialize:
	GetCmdArg(2, sColor, sizeof(sColor));

	//Check:
	if(!StrEqual(sColor, "red") && !StrEqual(sColor, "black"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only pick red or black");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sAmount[16];

	//Initialize:
	GetCmdArg(3, sAmount, sizeof(sAmount));

	//Declare:
	int Amount = StringToInt(sAmount);

	//Check:
	if(Amount < 0 || Amount > 1000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Maximun bet for dice is \x0732CD32#%s", IntToMoney(1000));

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Amount == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Bet");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetBank(Client) - Amount < 0)
	{
		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have \x0732CD32#%s\x07FFFFFF in your bank", IntToMoney(Amount));

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	OnClientDiceInRoulette(Client, Amount, Number, sColor);

	//Return:
	return Plugin_Handled;
}

public void OnClientDiceInRoulette(int Client, int Amount, int Number, char sColor[16])
{

	//Declare:
	int RandomNumber = GetRandomInt(0, 36);
	int RandomColor = GetRandomInt(1, 2);
	char ColorPicked[16];

	//Check:
	if(RandomColor == 1)
	{

		//Format:
		Format(ColorPicked, sizeof(ColorPicked), "red");
	}

	//Override:
	else
	{

		//Format:
		Format(ColorPicked, sizeof(ColorPicked), "black");
	}

	//Check:
	if(RandomNumber == Number && StrEqual(sColor, ColorPicked))
	{

		//Declare:
		Amount = Amount * 72;

		//Initulize:
		SetBank(Client, (GetBank(Client) + Amount));

		//Check:
		if(GetCosinoBank() - Amount > 0)
		{

			//Set Cosino:
			SetCosinoBank(GetCosinoBank() - Amount);
		}

		//Overide:
		else
		{
			//Set Cosino:
			SetCosinoBank(0);
		}

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Roulette #%i %s you have won \x0732CD32%s\x07FFFFFF!", Number, sColor, IntToMoney(Amount));

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && InCosino[i] && Client != i)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Roulette #%i %s have won \x0732CD32%s\x07FFFFFF!", Client, Number, sColor, IntToMoney(Amount));
			}
		}
	}

	//Check:
	if(RandomNumber == Number && !StrEqual(sColor, ColorPicked))
	{

		//Declare:
		Amount = Amount * 36;

		//Initulize:
		SetBank(Client, (GetBank(Client) + Amount));

		//Check:
		if(GetCosinoBank() - Amount > 0)
		{

			//Set Cosino:
			SetCosinoBank(GetCosinoBank() - Amount);
		}

		//Overide:
		else
		{
			//Set Cosino:
			SetCosinoBank(0);
		}

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Roulette #%i %s you have won \x0732CD32%s\x07FFFFFF!", Number, sColor, IntToMoney(Amount));

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && InCosino[i] && Client != i)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Roulette #%i %s have won \x0732CD32%s\x07FFFFFF!", Client, Number, sColor, IntToMoney(Amount));
			}
		}
	}

	//Check:
	if(RandomNumber != Number && StrEqual(sColor, ColorPicked))
	{

		//Initulize:
		SetBank(Client, (GetBank(Client) + Amount));

		//Check:
		if(GetCosinoBank() - Amount > 0)
		{

			//Set Cosino:
			SetCosinoBank(GetCosinoBank() - Amount);
		}

		//Overide:
		else
		{
			//Set Cosino:
			SetCosinoBank(0);
		}

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Roulette #%i %s you have won \x0732CD32%s\x07FFFFFF!", Number, sColor, IntToMoney(Amount));

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && InCosino[i] && Client != i)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Roulette #%i %s picked the same suit they dont win anything!", Client, Number, sColor);
			}
		}
	}


	//Overide:
	else
	{

		//Initulize:
		SetBank(Client, (GetBank(Client) - Amount));

		//Set Cosino:
		SetCosinoBank(GetCosinoBank() + Amount);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Roulette #%i %s you have lost your bet of \x0732CD32%s\x07FFFFFF!", Number, sColor, IntToMoney(Amount));

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && InCosino[i] && Client != i)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Roulette #%i %s have lost there bet of \x0732CD32#%s\x07FFFFFF!", Client, Number, sColor, IntToMoney(Amount));
			}
		}
	}
}

public Action Command_CosinoRoll(int Client, int Args)
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
	if(!InCosino[Client])
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have to be in the cosino to be able to use this command");

		//Return:
		return Plugin_Handled;
	}


	//No Valid Charictors:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_roll <1-6> <Bet>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sRoll[16];

	//Initialize:
	GetCmdArg(1, sRoll, sizeof(sRoll));

	//Declare:
	int Roll = StringToInt(sRoll);

	//Check:
	if(Roll < 1 || Roll > 6)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Number 1 to 6");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sAmount[16];

	//Initialize:
	GetCmdArg(2, sAmount, sizeof(sAmount));

	//Declare:
	int Amount = StringToInt(sAmount);

	//Check:
	if(Amount < 0 || Amount > 20000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Maximun bet for dice is \x0732CD32#%s", IntToMoney(20000));

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetBank(Client) - Amount < 0)
	{
		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have \x0732CD32#%s\x07FFFFFF in your bank", IntToMoney(Amount));

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Amount == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Bet");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	OnClientRollInCosino(Client, Roll, Amount);

	//Return:
	return Plugin_Handled;
}

public void OnClientRollInCosino(int Client, int Roll, int Amount)
{

	//Declare:
	int RandomNumber = GetRandomInt(1, 6);

	//Check:
	if(RandomNumber == Roll)
	{

		//Declare:
		Amount = Amount * 6;

		//Initulize:
		SetBank(Client, (GetBank(Client) + Amount));

		//Check:
		if(GetCosinoBank() - Amount > 0)
		{

			//Set Cosino:
			SetCosinoBank(GetCosinoBank() - Amount);
		}

		//Overide:
		else
		{
			//Set Cosino:
			SetCosinoBank(0);
		}

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Rolled #%i you have won \x0732CD32%s\x07FFFFFF!", RandomNumber, IntToMoney(Amount));

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && InCosino[i] && Client != i)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Rolled #%i have won \x0732CD32%s\x07FFFFFF!", Client, RandomNumber, IntToMoney(Amount));
			}
		}
	}

	//Overide:
	else
	{

		//Initulize:
		SetBank(Client, (GetBank(Client) - Amount));

		//Set Cosino:
		SetCosinoBank(GetCosinoBank() + Amount);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF -  Server Rolled #%i Rolled #%i you have lost your bet of \x0732CD32%s\x07FFFFFF!", RandomNumber, Roll, IntToMoney(Amount));

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && InCosino[i] && Client != i)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF -  Server Rolled #%i and \x0732CD32%N\x07FFFFFF Rolled #%i and have lost there bet of \x0732CD32#%s\x07FFFFFF!", RandomNumber, Client, Roll, IntToMoney(Amount));
			}
		}
	}
}

public Action Command_CosinoDoubleRoll(int Client, int Args)
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
	if(!InCosino[Client])
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have to be in the cosino to be able to use this command");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_doubleroll <2-12> <Bet>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sRoll[16];

	//Initialize:
	GetCmdArg(1, sRoll, sizeof(sRoll));

	//Declare:
	int Roll = StringToInt(sRoll);

	//Check:
	if(Roll < 2 || Roll > 12)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Number 2 to 12");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sAmount[16];

	//Initialize:
	GetCmdArg(2, sAmount, sizeof(sAmount));

	//Declare:
	int Amount = StringToInt(sAmount);

	//Check:
	if(Amount < 0 || Amount > 10000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Maximun bet for dice is \x0732CD32#%s", IntToMoney(20000));

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetBank(Client) - Amount < 0)
	{
		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have \x0732CD32#%s\x07FFFFFF in your bank", IntToMoney(Amount));

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Amount == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Bet");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	OnClientDoubleRollInCosino(Client, Roll, Amount);

	//Return:
	return Plugin_Handled;
}

public void OnClientDoubleRollInCosino(int Client, int Roll, int Amount)
{

	//Declare:
	int RandomNumber = GetRandomInt(2, 12);

	//Check:
	if(RandomNumber == Roll)
	{

		//Declare:
		Amount = Amount * 12;

		//Initulize:
		SetBank(Client, (GetBank(Client) + Amount));

		//Check:
		if(GetCosinoBank() - Amount > 0)
		{

			//Set Cosino:
			SetCosinoBank(GetCosinoBank() - Amount);
		}

		//Overide:
		else
		{
			//Set Cosino:
			SetCosinoBank(0);
		}

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Rolled #%i you have won \x0732CD32%s\x07FFFFFF!", RandomNumber, IntToMoney(Amount));

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && InCosino[i] && Client != i)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Rolled #%i have won \x0732CD32%s\x07FFFFFF!", Client, RandomNumber, IntToMoney(Amount));
			}
		}
	}

	//Overide:
	else
	{

		//Initulize:
		SetBank(Client, (GetBank(Client) - Amount));

		//Set Cosino:
		SetCosinoBank(GetCosinoBank() + Amount);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Server Rolled #%i your Roll Rolled #%i you have lost your bet of \x0732CD32%s\x07FFFFFF!", RandomNumber, Roll, IntToMoney(Amount));

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && InCosino[i] && Client != i)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - Server Rolled #%i and \x0732CD32%N\x07FFFFFF Rolled #%i and have lost there bet of \x0732CD32#%s\x07FFFFFF!", RandomNumber, Client, Roll, IntToMoney(Amount));
			}
		}
	}
}

public Action Command_LocateCosino(int Client, int Args)
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
	if(InCosino[Client])
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are already in the cosino!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Position[3];
	float Origin[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);
	Position[2] += 25.0;
	Origin = CosinoZones[1];
	Origin[2] += 25.0;

	//Declare:
	int BeamColor[4] = {255, 255, 255, 225};

	TE_SetupBeamPoints(Position, Origin, Laser(), 0, 0, 66, 1.0, 1.0, 1.0, 0, 0.0, BeamColor, 0);

	TE_SendToClient(Client);

	//Return:
	return Plugin_Handled;
}