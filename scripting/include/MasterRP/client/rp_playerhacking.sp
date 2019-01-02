//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_playerhacking_included_
  #endinput
#endif
#define _rp_playerhacking_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Misc:
int Hacking[MAXPLAYERS + 1];
int PlayerHackCash[MAXPLAYERS + 1] = {0,...};
int PlayerHackTime[MAXPLAYERS + 1] = {0,...};

public void initPlayerHacking()
{

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Is Valid:
			if(PlayerHackTime[Client] > 0)
			{

				//Initulize:
				PlayerHackTime[Client] -= 1;
			}
		}
	}
}

public void PlayerRobbingDefaults(int Client)
{

	//Initulize:
	PlayerHackTime[Client] = 0;

	PlayerHackCash[Client] = 0;

	Hacking[Client] = 0;
}

public Action BeginPlayerHacking(int Client, int Player, int HackCash3)
{

	//Is In Time:
	if(GetLastPressedE(Client) < (GetGameTime() - 1.5))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - Press \x0732CD32<<Shift>>\x07FFFFFF Again to start Hacking!");

		//Initulize:
		SetLastPressedE(Client, GetGameTime());
	}

	//Cuffed:
	else if(IsCuffed(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You are cuffed you can't Start Hacking!");

		//Return:
		return Plugin_Continue;
	}

	//In Critical:
	else if(GetIsCritical(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You are in Critical Health!");

		//Return:
		return Plugin_Continue;
	}

	//Is Playering:
	else if(PlayerHackCash[Client] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You are already Hacking!");

		//Return:
		return Plugin_Continue;
	}

	//Is Playering:
	else if(GetEnergy(Client) < 15)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You don't have enough energy to Hack \x0732CD32%N\x07FFFFFF!", Player);

		//Return:
		return Plugin_Continue;
	}

	//Ready:
	else if(PlayerHackTime[Player] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has been Hacked too recently, (\x0732CD32%i\x07FFFFFF) Seconds left!", Player, PlayerHackTime[Player]);

		//Return:
		return Plugin_Continue;
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - Prevent crime, do not start it!");

		//Return:
		return Plugin_Continue;
	}

	//Override:
	else
	{

		//Initulize:
		SetEnergy(Client, (GetEnergy(Client) - 15));

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 15));

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is Hacking \x0732CD32%N\x07FFFFFF!", Client, Player);

		//Save:
		PlayerHackTime[Player] = GetPlayerHackTime();

		//Start:
		PlayerHackCash[Client] = HackCash3;

		//Initulize:
		Hacking[Client] = -1;

		//Add Crime:
		SetCrime(Client, (GetCrime(Client) + 150));

		//Timer:
		CreateTimer(1.0, PlayerHackingTimer, Client, TIMER_REPEAT);
	}

	//Return:
	return Plugin_Continue;
}

public Action PlayerHackingTimer(Handle Timer, any Client)
{

	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client)) return Plugin_Handled;

	//Cleared:
	if(PlayerHackCash[Client] < 1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is Getting away!", Client);

		//Initulize::
		PlayerHackCash[Client] = 0;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Cleared:
	if(!IsPlayerAlive(Client))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF Has been killed!", Client);

		//Initulize::
		PlayerHackCash[Client] = 0;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float PlayerOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientAbsOrigin(Hacking[Client], PlayerOrigin);

	float Dist = GetVectorDistance(PlayerOrigin, ClientOrigin);

	//Too Far Away:
	if(Dist >= 250)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize::
		PlayerHackCash[Client] = 0;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Random = GetRandomInt(2, 10);

	//Initulize:
	if((GetCash(Hacking[Client]) - Random) > 0)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF has Hacked \x0732CD32%N\x07FFFFFF of all there cash!", Client, Hacking[Client]);

		//Initulize::
		PlayerHackCash[Client] = 0;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	PlayerHackCash[Client] -= Random;

	//Initialize:
	SetCash(Hacking[Client], (GetCash(Hacking[Client]) - Random));

	//Initialize:
	SetCash(Client, (GetCash(Client) + Random));

	//Initialize:
	SetCrime(Client, (GetCrime(Client) + (Random * Random)));

	//Set Menu State:
	CashState(Client, Random);

	//Return:
	return Plugin_Handled;
}

public bool IsClientHackingPlayer(int Client)
{

	//Check:
	if(PlayerHackCash[Client] > 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}