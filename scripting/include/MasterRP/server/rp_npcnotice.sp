//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_NpcNotice_included_
  #endinput
#endif
#define _rp_NpcNotice_included_

char NpcNotice[2047][255];

public void initNpcNotice()
{

	//Clean map entitys:
	for(int X = 0; X < 2047; X++)
	{

		//Initialize:
		NpcNotice[X] = "null";
	}

	//Commands:
	RegAdminCmd("sm_setnpcnotice", Command_SetNpcNotice, ADMFLAG_SLAY, "<text> - Sets the Npc Notice of this enity");

	RegAdminCmd("sm_removenpcnotice", Command_RemNpcNotice, ADMFLAG_SLAY, "<No Arg> - remove the Npc Notice of this entity");

	//Timer:
	CreateTimer(0.2, CreateSQLdbNpcNotice);
}

public void ResetEntNpcNotice()
{

	//Clean map entitys:
	for(int X = 0; X < 2047; X++)
	{

		//Initialize:
		NpcNotice[X] = "null";
	}
}

//Create Database:
public Action CreateSQLdbNpcNotice(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `NpcNotice`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `NpcType` int(12) NULL, `NpcId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Name` varchar(255) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadNpcNotice(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM NpcNotice WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadNpcNotice, query);
}


public void T_DBLoadNpcNotice(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadNpcNotice: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No NpcNotices Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int Id = 0;
		int Type = 0;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Type = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Id = SQL_FetchInt(hndl, 2);

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, NpcNotice[GetNpcEnt(Type, Id)], sizeof(NpcNotice[]));
		}

		//Print:
		PrintToServer("|RP| - Npc Notice Loaded!");
	}
}

//NpcNotice:
public Action Command_SetNpcNotice(int Client, int Args)
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
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Ent < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-NpcNotice|\x07FFFFFF - Invalid Entity.");

		//Return:
		return Plugin_Handled;	
	}

	//NPC Check:
	if(!IsValidNpc(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-NpcNotice|\x07FFFFFF - Invalid Npc.");

		//Return:
		return Plugin_Handled;	
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-NpcNotice|\x07FFFFFF - Usage: sm_npcnotice <text>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[255];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Initulize:
	SetNpcNotice(GetNpcType(Ent), GetNpcId(Ent), Arg1);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-NpcNotice|\x07FFFFFF - You have Set \x0732CD32#%s\x07FFFFFF on #%i!", Arg1, Ent);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemNpcNotice(int Client, int Args)
{

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Ent <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-NpcNotice|\x07FFFFFF - Invalid Entity.");

		//Return:
		return Plugin_Handled;	
	}

	//NPC Check:
	if(!IsValidNpc(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-NpcNotice|\x07FFFFFF - Invalid Npc.");

		//Return:
		return Plugin_Handled;	
	}

	//Spawn Already Created:
	if(StrEqual(NpcNotice[Ent], "null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-NpcNotice|\x07FFFFFF - Npc #%i Has Name!", Ent);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	RemoveNpcNotice(GetNpcType(Ent), GetNpcId(Ent));

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-NpcNotice|\x07FFFFFF - NpcNotice \x0732CD32#%i\x07FFFFFF has been deleted from database", Ent);

	//Return:
	return Plugin_Handled;
}

public Action NpcHud(int Client, int Ent, float NoticeInterval)
{

	//Declare:
	char FormatMessage[512];

	//Declare:
	int len = 0;

	//Notice:
	if(!StrEqual(GetNpcNotice(Ent), "null"))
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Notice:\n%s", GetNpcNotice(Ent));
	}

	//Notice:
	if(GetNpcType(Ent) == 1)
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nDouble Press 'E' to Quick Deposit!");
	}

	//Notice:
	if(GetNpcType(Ent) == 4)
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nDouble Press 'E' to Quick Sell Drugs!");
	}

	//Notice:
	if(GetNpcType(Ent) == 7)
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nPress 'E' to select a job!");
	}

	if(len > 0)
	{

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

char GetNpcNotice(int Ent)
{

	//Return:
	return NpcNotice[Ent];
}

public void SetNpcNotice(int Type, int Id, const char[] Str)
{

	//Declare:
	char query[512];

	//Spawn Already Created:
	if(!StrEqual(NpcNotice[GetNpcEnt(Type, Id)], "null"))
	{

		//Format:
		Format(query, sizeof(query), "UPDATE NpcNotice SET Name = '%s' WHERE NpcType = %i AND NpcId = %i AND Map = '%s';", Str, Type, Id, ServerMap());
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO NpcNotice (`Map`,`NpcType`,`NpcId`,`Name`) VALUES ('%s',%i,%i,'%s');", ServerMap(), Type, Id, Str);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Format:
	Format(NpcNotice[GetNpcEnt(Type, Id)], sizeof(NpcNotice[]), "%s", Str);
}

public void RemoveNpcNotice(int Type, int Id)
{

	//Initialize:
	NpcNotice[GetNpcEnt(Type, Id)] = "null";

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM NpcNotice WHERE NpcType = %i AND NpcId = %i AND Map = '%s';", Type, Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}
