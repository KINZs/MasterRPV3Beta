//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bankrobbing_included_
  #endinput
#endif
#define _rp_bankrobbing_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

#define MAXNPCS			30

int BankRobEnt[MAXPLAYERS + 1] = {-1,...};
int BankBankRobTimer[MAXPLAYERS + 1] = {0,...};
int BankRobTimer[MAXNPCS + 1] = {0,...};

public void initBankRobbing()
{

	//Loop:
	for(int X = 1; X <= MAXNPCS; X++)
	{

		//Is Valid:
		if(BankRobTimer[X] > 0)
		{

			//Initulize:
			BankRobTimer[X] -= 1;
		}
	}
}

public void BeginBankRob(int Client, int Ent, const char[] Name, int NPCCash, int Id)
{

	//Is In Time:
	if(GetLastPressedE(Client) > GetGameTime())
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - Press \x0732CD32<<Shift>>\x07FFFFFF Again to rob the Banker!");

		//Initulize:
		SetLastPressedE(Client, GetGameTime() + 1.5);
	}

	//Cuffed:
	else if(IsCuffed(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You are cuffed you can't robbing!");

		//Return:
		return;
	}

	//In Critical:
	else if(GetIsCritical(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You are in Critical Health");

		//Return:
		return;
	}

	//Is Robbing:
	else if(BankBankRobTimer[Client] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You are already robbing!");

		//Return:
		return;
	}

	//Is Robbing:
	else if(GetEnergy(Client) < 15)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You don't have enough energy to rob this \x0732CD32%s\x07FFFFFF!", Name);

		//Return:
		return;
	}

	//Ready:
	else if(BankRobTimer[Id] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - This \x0732CD32%s\x07FFFFFF has been robbed too recently, (\x0732CD32%i\x07FFFFFF) Seconds left!", Name, BankRobTimer[Id]);

		//Return:
		return;
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - Prevent crime, do not start it!");

		//Return:
		return;
	}

	//Override:
	else
	{

		//Initulize:
		SetEnergy(Client, (GetEnergy(Client) - 15));

		//Start:
		BankBankRobTimer[Client] = NPCCash;

		//Is Valid:
		if(IsAdmin(Client) || StrContains(GetJob(Client), "Street Thug", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1)
		{

			//Initialize:
			SetJobExperience(Client, (GetJobExperience(Client) + 6));

			//Start:
			BankBankRobTimer[Client] += 200;
		}

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is Robbing a \x0732CD32%s\x07FFFFFF!", Client, Name);

		//Initialize:
		BankRobEnt[Client] = Ent;

		//Save:
		BankRobTimer[Id] = GetRobTime();

		//Add Crime:
		SetCrime(Client, (GetCrime(Client) + 150));

		//Timer:
		CreateTimer(1.0, BeginRobberyBank, Client, TIMER_REPEAT);
	}
}

public Action BeginRobberyBank(Handle Timer, any Client)
{

	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client) || !IsValidEdict(BankHackEnt[Client]))
	{

		//Initulize:
		BankBankRobTimer[Client] = 0;

		BankRobEnt[Client] = -1;

		//Return:
		return Plugin_Handled;
	}

	//Cleared:
	if(BankBankRobTimer[Client] < 1 || !IsPlayerAlive(Client))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF Stopped robbing an NPC!", Client);

		//Initulize:
		BankBankRobTimer[Client] = 0;

		BankRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Position[3];

	//Initulize:
	GetEntPropVector(BankRobEnt[Client], Prop_Send, "m_vecOrigin", Position);

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
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize:
		BankBankRobTimer[Client] = 0;

		BankRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Random;

	//Is Valid:
	if(StrContains(GetJob(Client), "Robber", false) != -1 || IsAdmin(Client))
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

	//Check:
	if(GetServerSafeMoneyTotal() < 1000)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize:
		BankBankRobTimer[Client] = 0;

		BankRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	BankBankRobTimer[Client] -= Random;

	//Initialize:
	SetCash(Client, (GetCash(Client) + Random));

	//Initialize:
	SetCrime(Client, (GetCrime(Client) + (Random + Random)));

	//Set Menu State:
	CashState(Client, Random);

	//Dynamic Vendor Robbing:
	BeginRobbingBankToSafe(Client, Random);

	//Return:
	return Plugin_Handled;
}

public bool IsClientRobbingCashFromBank(int Client)
{

	//Check:
	if(BankBankRobTimer[Client] > 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}