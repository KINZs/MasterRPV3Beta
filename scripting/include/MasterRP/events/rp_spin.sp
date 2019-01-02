//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_spin_included_
  #endinput
#endif
#define _rp_spin_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

public void initSpin()
{

	//Commands:
	RegConsoleCmd("sm_spin", Command_Spin);

	//Timers:
	CreateTimer(0.2, CreateSQLdbSpin);
}

//Create Database:
public Action CreateSQLdbSpin(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Spin`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) NULL PRIMARY KEY,");

	len += Format(query[len], sizeof(query)-len, " `LastSpin` int(12) NOT NULL DEFAULT 0);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public Action Command_Spin(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	DBLoadSpin(Client);

	//Return:
	return Plugin_Handled;
}

//Load:
public Action DBLoadSpinTest(int Client)
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Spin WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadSpinCallbackTest, query, conuserid);
}

public int T_DBLoadSpinCallbackTest(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[T_DBLoadSpinCallbackTest] T_DBLoadCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Insert Player Stats:
			InsertPlayerSpin(Client);
		}
	}

	//Close:
	CloseHandle(hndl);
}

public Action InsertPlayerSpin(int Client)
{

	//Declare:
	char buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "INSERT INTO Spin (`STEAMID`,`LastSpin`) VALUES (%i,0);", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer, 53);

	//CPrint:
	PrintToConsole(Client, "|RP| Created new player Spin.");
}

//Load:
public Action DBLoadSpin(int Client)
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Spin WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadSpinCallback, query, conuserid);
}

public int T_DBLoadSpinCallback(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Player] T_DBLoadCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			int LastSpin = SQL_FetchInt(hndl, 1);

			if(LastSpin < GetTime())
			{

				//Declare:
				int len = 0;
				char query[3072];

				//Sql Strings:
				len += Format(query[len], sizeof(query)-len, "UPDATE Spin SET LastSpin = %i", (GetTime() + 86400));

				len += Format(query[len], sizeof(query)-len, " WHERE STEAMID = %i;", SteamIdToInt(Client)); //86400

				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 540);

				//Spin:
				Spin(Client);
			}

			//Overide:
			else
			{

				//Declare:
				int Result = LastSpin - GetTime();
				//int Days = Result / 86400;
				Result %= 86400;
				int Hours = Result / 3600;
				Result %= 3600;
				int Minutes = Result / 60;
				Result %= 60;
				int Seconds = Result;

				//Has Hours:
				if(Hours != 0)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your Spin isn't ready please wait another %i hours and %i minutes and %i seconds.", Hours, Minutes, Seconds);
				}

				//Has Minutes:
				else if(Minutes != 0)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your Spin isn't ready please wait another %i minutes and %i seconds.", Minutes, Seconds);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your Spin isn't ready please wait another %i seconds.", Seconds);
				}
			}
		}
	}

	//Close:
	CloseHandle(hndl);
}

public void Spin(int Client)
{

	//Random:
	int Random = GetRandomInt(0, 100);
	int R = 0;

	if(Random == 0)
	{

		//Declare:
		R = GetRandomInt(45, 54);

		//Save:
		SaveItem(Client, R, (GetItemAmount(Client, 234) + R));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have won \x0732CD32€%s!", GetItemName(R));
	}

	if(Random >= 1 && Random < 2)
	{

		//Declare:
		R = GetRandomInt(12000, 24000);

		SetBank(Client, (GetBank(Client) + R));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have won \x0732CD32%s!", IntToMoney(R));
	}

	if(Random >= 2 && Random < 5)
	{

		//Declare:
		R = GetRandomInt(2000, 12000);

		SetBank(Client, (GetBank(Client) + R));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have won \x0732CD32%s!", IntToMoney(R));
	}

	if(Random >= 5 && Random < 10)
	{

		//Declare:
		R = GetRandomInt(2, 5);

		//Save:
		SaveItem(Client, R, (GetItemAmount(Client, 234) + R));

		//Save:
		SaveItem(Client, R, (GetItemAmount(Client, 235) + R));

		//Save:
		SaveItem(Client, R, (GetItemAmount(Client, 236) + R));

		//Save:
		SaveItem(Client, R, (GetItemAmount(Client, 237) + R));

		//Save:
		SaveItem(Client, R, (GetItemAmount(Client, 280) + R));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have won %i planting supplies!", R);
	}

	if(Random >= 10 && Random < 15)
	{

		//Declare:
		R = 5000;

		//Initulize:
		SetResources(Client, (GetResources(Client) + R));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have won %ig combine Resources!", R);
	}

	if(Random >= 15 && Random < 20)
	{

		//Declare:
		R = GetRandomInt(1, 11);

		if(R == 7) R = 1;

		int Amount = GetRandomInt(5, 20);

		//Save:
		SaveItem(Client, R, (GetItemAmount(Client, R) + Amount));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have won %ix of %s!", Amount, GetItemName(R));
	}

	if(Random >= 20 && Random < 30)
	{

		//Declare:
		R = GetRandomInt(500, 2000);

		//Initulize:
		SetHarvest(Client, (GetHarvest(Client) + R));

		//Initulize:
		SetCrime(Client, (GetCrime(Client) + R));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have won %ig of Harvest!", R);
	}

	if(Random >= 20 && Random < 25)
	{

		//Declare:
		R = GetRandomInt(200, 800);

		//Initulize:
		SetCocain(Client, (GetCocain(Client) + R));

		//Initulize:
		SetCrime(Client, (GetCrime(Client) + (R * 30)));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have won %ig of Cocain!", R);
	}

	if(Random >= 25 && Random < 30)
	{

		//Declare:
		R = GetRandomInt(2, 5);

		//Save:
		SaveItem(Client, 238, (GetItemAmount(Client, 238) + R));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have won %ix of %s!", R, GetItemName(238));
	}

	if(Random >= 35 && Random < 40)
	{

		//Declare:
		R = GetRandomInt(287, 292);

		int Amount = GetRandomInt(5, 20);

		if(R == 7) R = 1;

		//Save
		SaveItem(Client, R, (GetItemAmount(Client, R) + Amount));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have won %ix of %s!", Amount, GetItemName(R));
	}

	if(Random >= 45 && Random < 50)
	{

		//Declare:
		R = GetRandomInt(457, 462);

		int Amount = GetRandomInt(5, 20);

		if(R == 7) R = 1;

		//Save
		SaveItem(Client, R, (GetItemAmount(Client, R) + Amount));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have won %ix of %s!", Amount, GetItemName(R));
	}

	if(Random >= 55 && Random < 60)
	{

		//Declare:
		int Amount = GetRandomInt(2, 5);

		//Save
		SaveItem(Client, 238, (GetItemAmount(Client, 238) + Amount));

		//Save
		SaveItem(Client, 323, (GetItemAmount(Client, 323) + (Amount * 5)));

		//Save
		SaveItem(Client, 328, (GetItemAmount(Client, 328) + (Amount * 2)));

		//Save
		SaveItem(Client, 464, (GetItemAmount(Client, 464) + 1));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have won a printing pack!", Amount, GetItemName(R));
	}

	if(Random >= 65 && Random < 68)
	{

		//Declare:
		int Amount = GetRandomInt(2, 5);

		//Save
		SaveItem(Client, 239, (GetItemAmount(Client, 239) + Amount));

		//Save
		SaveItem(Client, 324, (GetItemAmount(Client, 324) + (Amount * 5)));

		//Save
		SaveItem(Client, 330, (GetItemAmount(Client, 330) + (Amount * 2)));

		//Save
		SaveItem(Client, 465, (GetItemAmount(Client, 465) + 1));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have won a better printing pack!", Amount, GetItemName(R));
	}

	if(Random >= 68 && Random < 70)
	{

		//Declare:
		int Amount = GetRandomInt(1, 3);

		//Save
		SaveItem(Client, 240, (GetItemAmount(Client, 240) + Amount));

		//Save
		SaveItem(Client, 323, (GetItemAmount(Client, 323) + (Amount * 5)));

		//Save
		SaveItem(Client, 328, (GetItemAmount(Client, 328) + (Amount * 2)));

		//Save
		SaveItem(Client, 465, (GetItemAmount(Client, 465) + Amount));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have won a Master printing pack!", Amount, GetItemName(R));
	}

	if(Random >= 70 && Random <= 75)
	{

		//Slay Client:
		ForcePlayerSuicide(Client);

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have been slayed!");

		//
	}

	if(Random >= 70 && Random <= 75)
	{

	}
}
