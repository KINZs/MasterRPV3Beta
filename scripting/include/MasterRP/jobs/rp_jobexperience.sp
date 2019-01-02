//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_jobexperience_included_
  #endinput
#endif
#define _rp_jobexperience_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

//Job system:
int JobExperience[MAXPLAYERS + 1] = {0,...};

public void initJobExperience()
{

	//Commands:
	RegAdminCmd("sm_setjobexperience", Command_SetJobExperience, ADMFLAG_ROOT, "- <Name> <Experience #> - Sets the Job Experience of the Client");

	//Timer:
	CreateTimer(0.2, CreateSQLdbJobExperience);
}

//Create Database:
public Action CreateSQLdbJobExperience(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `JobExperience`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) NULL, `Job` varchar(32) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Experience` int(11) NULL);");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public void LoadExperience(int Client)
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `JobExperience` WHERE STEAMID = %i AND Job = '%s';", SteamIdToInt(Client), GetJob(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_LoadJobsExperienceCallBack, query, conuserid);
}

public void T_LoadJobsExperienceCallBack(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Jobs] T_LoadJobsExperienceCallBack: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Print:
		//PrintToConsole(Client, "|RP| Loading player Job Experience...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Declare:
			InsertJobExperience(Client, 0);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			JobExperience[Client] = SQL_FetchInt(hndl, 2);

			//Print:
			//PrintToConsole(Client, "|RP| player Job Experience loaded.");
		}
	}
}

public Action InsertJobExperience(int Client, int Amount)
{

	//Declare:
	char query[255];

	//Sql String:
	Format(query, sizeof(query), "INSERT INTO JobExperience (`STEAMID`,`Job`,`Experience`) VALUES (%i,'%s',0);", SteamIdToInt(Client), GetJob(Client), Amount);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//CPrint:
	//PrintToConsole(Client, "|RP| Created new player Job Experience Table %s.", GetJob(Client));
}

public int GetJobExperience(int Client)
{

	//Return:
	return JobExperience[Client];
}

public void SetJobExperience(int Client, int Amount)
{

	//Initulize:
	JobExperience[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Format:
		Format(query, sizeof(query), "SELECT * FROM `JobExperience` WHERE STEAMID = %i AND Job = '%s';", SteamIdToInt(Client), GetJob(Client));

		//Declare:
		Handle hQuery = SQL_Query(GetGlobalSQL(), query);

		//Is Valid Query:
		if(hQuery)
		{

			//Restart SQL:
			SQL_Rewind(hQuery);

			//Not Player:
			if(!SQL_GetRowCount(hQuery))
			{

				//Create New Table:
				InsertJobExperience(Client, Amount);

				//Return:
				return;
			}
		}

		//Close:
		CloseHandle(hQuery);

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Jobs SET Experience = %i WHERE STEAMID = %i;", JobExperience[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}


public Action Command_SetJobExperience(int Client, int Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setjobexperience <Name> <Experience #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int Amount = StringToInt(Arg2);

	//Action:
	SetJobExperience(Player, Amount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's Job Experience to \x0732CD32%i", Player, Amount);

	//Not Client:
	if(Client != Player)
	{

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Job Experience to \x0732CD32%i", Client, Amount);
	}
#if defined DEBUG
	//Logging:
	LogMessage("\"%N\" set the Job Experience of \"%N\" to %i", Client, Player, Amount);
#endif
	//Return:
	return Plugin_Handled;
}

