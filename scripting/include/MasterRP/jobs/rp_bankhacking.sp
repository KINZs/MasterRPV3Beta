//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bankhacking_included_
  #endinput
#endif
#define _rp_bankhacking_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

#define MAXNPCS			30

int BankHackEnt[MAXPLAYERS + 1] = {-1,...};
int BankHackCash[MAXPLAYERS + 1] = {0,...};
int BankHackTimer[MAXNPCS + 1] = {0,...};

public void initBankHacking()
{

	//Loop:
	for(int X = 1; X <= MAXNPCS; X++)
	{

		//Is Valid:
		if(BankHackTimer[X] > 0)
		{

			//Initulize:
			BankHackTimer[X] -= 1;
		}
	}
}

public void BeginBankHack(int Client, int Ent, const char[] Name, int NPCCash, int Id)
{

	//Is In Time:
	if(GetLastPressedE(Client) < (GetGameTime() - 1.5))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - Press \x0732CD32<<Shift>>\x07FFFFFF Again to Start Hacking the Banker!");

		//Initulize:
		SetLastPressedE(Client, GetGameTime());
	}

	//Cuffed:
	else if(IsCuffed(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You are cuffed you can't start hacking!");

		//Return:
		return;
	}

	//In Critical:
	else if(GetIsCritical(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - you are in Critical Health!");

		//Return:
		return;
	}

	//Is Hacking:
	else if(BankHackCash[Client] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You are already hacking!");

		//Return:
		return;
	}

	//Is Hacking:
	else if(GetEnergy(Client) < 15)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You don't have enough energy to Hack this \x0732CD32%s\x07FFFFFF!", Name);

		//Return:
		return;
	}

	//Ready:
	else if(BankHackTimer[Id] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - This \x0732CD32%s\x07FFFFFF has been Hacked too recently, (\x0732CD32%i\x07FFFFFF) Seconds left!", Name, BankHackTimer[Id]);

		//Return:
		return;
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - Prevent crime, do not start it!");

		//Return:
		return;
	}

	//Override:
	else
	{

		//Initulize:
		SetEnergy(Client, (GetEnergy(Client) - 15));

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 10));

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is Hacking a \x0732CD32%s\x07FFFFFF!", Client, Name);

		//Initialize:
		BankHackEnt[Client] = Ent;

		//Save:
		BankHackTimer[Id] = GetHackTime();

		//Start:
		BankHackCash[Client] = NPCCash;

		//Add Crime:
		SetCrime(Client, (GetCrime(Client) + 150));

		//Timer:
		CreateTimer(1.0, BeginHackBank, Client, TIMER_REPEAT);
	}
}

public Action BeginHackBank(Handle Timer, any Client)
{

	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client) || !IsValidEdict(BankHackEnt[Client]))
	{

		//Initulize::
		BankHackCash[Client] = 0;

		BankHackEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return;
		return Plugin_Handled;
	}

	//Cleared:
	if(BankHackCash[Client] < 1 || !IsPlayerAlive(Client))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF Stopped Hacking an NPC!", Client);

		//Initulize::
		BankHackCash[Client] = 0;

		BankHackEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Position[3];

	//Initulize:
	GetEntPropVector(BankHackEnt[Client], Prop_Send, "m_vecOrigin", Position);

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	float Dist = GetVectorDistance(Position, ClientOrigin);

	//Too Far Away:
	if(Dist >= 250)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize::
		BankHackCash[Client] = 0;

		BankHackEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "SELECT * FROM `Player` ORDER BY RANDOM() LIMIT 1;");

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_LoadRandomPlayer2, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public void T_LoadRandomPlayer2(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Banking] T_LoadRandomPlayer: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Declare:
			char query[255];

			//Declare:
			int SteamId = SQL_FetchInt(hndl, 0);

			//Database Field Loading INTEGER:
			int OldBank = SQL_FetchInt(hndl, 4);

			//Declare:
			int Random = 0;

			//Is Valid:
			if(StrContains(GetJob(Client), "Street Thug", false) != -1 || IsAdmin(Client))
			{

				//Initulize:
				Random = GetRandomInt(5, 10);
			}

			//Override:
			else
			{

				//Initulize:
				Random = GetRandomInt(2, 5);
			}

			//Initulize:
			BankHackCash[Client] -= Random;

			//Initialize:
			SetCash(Client, (GetCash(Client) + Random));

			//Initialize:
			SetCrime(Client, (GetCrime(Client) + (Random + Random)));

			//Set Menu State:
			CashState(Client, Random);

			//Declare:
			int NewBank = 0;

			//Check:
			if((OldBank - Random) > 0)
			{

				//Initialize:
				NewBank = (OldBank - Random);
			}

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Is Valid:
					if(SteamId == SteamIdToInt(i))
					{

						//Initialize:
						SetBank(i, NewBank);

						//Set Menu State:
						BankState(i, (Random *= -1));

						//Print
						OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Cash has been stolen from your bank account!");
					}
				}
			}

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Player SET Bank = %i WHERE STEAMID = %i;", NewBank, SteamId);

			//Update Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}
	}
}

public bool IsClientHackingCashFromBank(int Client)
{

	//Check:
	if(BankHackCash[Client] > 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}
