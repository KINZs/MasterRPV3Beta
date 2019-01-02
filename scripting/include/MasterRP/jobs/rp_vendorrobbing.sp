//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendorrobbing_included_
  #endinput
#endif
#define _rp_vendorrobbing_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXNPCS			30

//Misc:
int VendorRobEnt[MAXPLAYERS + 1] = {-1,...};
int VendorRobCash[MAXPLAYERS + 1] = {0,...};
int VendorRobTimer[MAXNPCS + 1] = {0,...};

public void initVendorRobbing()
{

	//Loop:
	for(int X = 0; X <= MAXNPCS; X++)
	{

		//Is Valid:
		if(VendorRobTimer[X] > 0)
		{

			//Initulize:
			VendorRobTimer[X] -= 1;
		}
	}
}

public Action BeginVendorRob(int Client, int Ent, const char[] Name, int NPCCash, int Id)
{

	//Is In Time:
	if(GetLastPressedE(Client) < (GetGameTime() - 1.5))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - Press \x0732CD32<<Shift>>\x07FFFFFF Again to rob the Vendor!");

		//Initulize:
		SetLastPressedE(Client, GetGameTime());
	}

	//Cuffed:
	else if(IsCuffed(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You are cuffed you can't robbing!");

		//Return:
		return Plugin_Continue;
	}

	//In Critical:
	else if(GetIsCritical(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You are in Critical Health!");

		//Return:
		return Plugin_Continue;
	}

	//Is Robbing:
	else if(VendorRobCash[Client] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You are already robbing!");

		//Return:
		return Plugin_Continue;
	}

	//Is Robbing:
	else if(GetEnergy(Client) < 15)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You don't have enough energy to rob this \x0732CD32%s\x07FFFFFF!", Name);

		//Return:
		return Plugin_Continue;
	}

	//Ready:
	else if(VendorRobTimer[Id] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - This \x0732CD32%s\x07FFFFFF has been robbed too recently, (\x0732CD32%i\x07FFFFFF) Seconds left!", Name, VendorRobTimer[Id]);

		//Return:
		return Plugin_Continue;
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - Prevent crime, do not start it!");

		//Return:
		return Plugin_Continue;
	}

	//Override:
	else
	{

		//Initulize:
		SetEnergy(Client, (GetEnergy(Client) - 15));

		//Is Valid:
		if(IsAdmin(Client) || StrContains(GetJob(Client), "Street Thug", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1)
		{

			//Initialize:
			SetJobExperience(Client, (GetJobExperience(Client) + 4));
		}

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is Robbing a \x0732CD32%s\x07FFFFFF!", Client, Name);

		//Initialize:
		VendorRobEnt[Client] = Ent;

		//Save:
		VendorRobTimer[Id] = GetRobTime();

		//Start:
		VendorRobCash[Client] = NPCCash;

		//Add Crime:
		SetCrime(Client, (GetCrime(Client) + 150));

		//Timer:
		CreateTimer(1.0, BeginRobberyVendor, Client, TIMER_REPEAT);
	}

	//Return:
	return Plugin_Continue;
}

public Action BeginRobberyVendor(Handle Timer, any Client)
{

	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client) || !IsValidEdict(VendorRobEnt[Client]))
	{

		//Initulize:
		VendorRobCash[Client] = 0;

		VendorRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}
	//Cleared:
	if(VendorRobCash[Client] < 1 || !IsPlayerAlive(Client))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF Stopped robbing an NPC!", Client);

		//Initulize:
		VendorRobCash[Client] = 0;

		VendorRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Position[3];

	//Initulize:
	GetEntPropVector(VendorRobEnt[Client], Prop_Send, "m_vecOrigin", Position);

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	float Dist = GetVectorDistance(Position, ClientOrigin);

	//Too Far Away:
	if(Dist >= 250)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize:
		VendorRobCash[Client] = 0;

		VendorRobEnt[Client] = -1;

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
		VendorRobCash[Client] = 0;

		VendorRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	VendorRobCash[Client] -= Random;

	//Initialize:
	SetCash(Client, (GetCash(Client) + Random));

	//Initialize:
	SetCrime(Client, (GetCrime(Client) + (Random + Random)));

	//Set Menu State:
	CashState(Client, Random);

	//Dynamic Vendor Robbing:
	BeginRobbingVendorToSafe(Client, Random);

	//Return:
	return Plugin_Handled;
}

public bool IsClientRobbingCashFromVendor(int Client)
{

	//Check:
	if(VendorRobCash[Client] > 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}