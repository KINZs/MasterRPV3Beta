//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_donator_included_
  #endinput
#endif
#define _rp_donator_included_

//Job system:
int Donator[MAXPLAYERS + 1] = {0,...};

public void initDonator()
{

	//Commands
	RegAdminCmd("sm_setstatus", Command_Donator, ADMFLAG_ROOT, "- set the a player a status!");
}

public Action Command_Donator(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "%s Usage: sm_setstatus <User> <Standart- Special> <1/0>", PREFIX);

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
	if(Player == -1)
	{

		//Print:
		CPrintToChat(Client, "%s - No matching client found!", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char arg2[32];

	//Initulize:
	GetCmdArg(2, arg2, sizeof(arg2));

	SetDonator(Player, StringToInt(arg2));

	//Print:
	CPrintToChat(Client, "%s you have just set \x0732CD32%N's\x07FFFFFF status!", PREFIX, Player);

	CPrintToChat(Player, "%s %s%N%s has just set your status!", PREFIX, COLORGREEN, Client, COLORWHITE);

	//Setup Hud:
	SetHudTextParams(-1.0, 0.015, 5.0, 255, 50, 50, 200, 0, 6.0, 0.1, 0.2);

	//Show Hud Text:
	ShowHudText(Player, 4, "%N has just set your donator status!", Client);

	//Return:
	return Plugin_Handled;
}

public int GetDonator(int Client)
{

	//Return:
	return view_as<int>(Donator[Client]);
}

public int SetDonator(int Client, int Amount)
{

	//Initulize:
	Donator[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Donator = %i WHERE STEAMID = %i;", Donator[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 12);
	}

	//Return:
	return view_as<int>(Donator[Client]);
}