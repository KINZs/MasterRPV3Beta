//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_playermenu_included_
  #endinput
#endif
#define _rp_playermenu_included_

//Euro - � dont remove this!
//€ = �

float JobCooldown[MAXPLAYERS + 1] = {0.0,...};

public Action DrawPlayerMenu(int Client, int Player)
{

	//Initulize:
	SetMenuTarget(Client, Player);

	//Handle:
	Menu menu = CreateMenu(HandlePlayer);

	//Declare:
	char title[256]; Format(title, sizeof(title), "Choose an option:\n\n%N", Player);

	//Menu Title:
	menu.SetTitle(title);

	//Menu Button:
	menu.AddItem("0", "Give a Gift");

	//Menu Button:
	menu.AddItem("1", "Your Actons");

	//Menu Button:
	menu.AddItem("2", "Use Player");

	//Check:
	if(IsClientInTrading(Client))
	{

		//Menu Button:
		menu.AddItem("3", "Trade Items for Cash");
	}

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Action|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public int HandlePlayer(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		int Ent = GetMenuTarget(Client);

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Connected:
			if(IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Show Give Menu:
				DrawPlayerGive(Client, Ent);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player");
			}
		}

		//Button Selected:
		else if(Result == 1)
		{

			//Connected:
			if(IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Show Menu:
				DrawHandleMenu(Client, Ent);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player");
			}
		}

		//Button Selected:
		else if(Result == 2)
		{

			//Handle:
			menu = CreateMenu(HandlePlayerBuy);

			//Declare:
			char PlayerName[32];

			//Initialize:
			GetClientName(Ent, PlayerName, sizeof(PlayerName));

			//Menu Title:
			menu.SetTitle("Select a button: (%s)", PlayerName);

			//Teacher:
			if(StrEqual(GetJob(Ent), "Principal", false) || IsAdmin(Ent))
			{

				//Menu Button:
				//menu.AddItem("2", "Learn...");
			}

			//Teacher:
			if(StrEqual(GetJob(Ent), "Bank Administrative Officer", false) || IsAdmin(Ent))
			{

				//Menu Button:
				menu.AddItem("3", "Deopsit Cash...");

				//Menu Button:
				menu.AddItem("4", "Transfer To Player...");
			}

			//Override
			else
			{
				//Menu Button:
				menu.AddItem("0", "Buy Items...");
			}

			//Menu Button:
			menu.AddItem("1", "Back");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Button Selected:
		else if(Result == 3)
		{

			//Forward: rp_trading.sp
			OnClientTradeMenu(Client, Ent);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

public Action DrawPlayerGive(int Client, int Player)
{

	//Declare:
	char PlayerName[64];

	//Initialize:
	GetClientName(Player, PlayerName, sizeof(PlayerName));

	//Handle:
	Menu menu = CreateMenu(HandleGivePlayer);

	//Menu Title:
	menu.SetTitle("Select a button: (%s)", PlayerName);

	//Menu Button:
	menu.AddItem("0", "Give Cash");

	menu.AddItem("1", "Give Item");

	menu.AddItem("2", "Back");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//PlayerMenu Handle:
public int HandleGivePlayer(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Button Selected:
		if(Parameter == 0)
		{

			//Draw Menu:
			DrawGiveCashMenu(Client, GetMenuTarget(Client));
		}

		//Button Selected:
		if(Parameter == 1)
		{

			//Initialize:
			SetIsGiving(Client, true);

			//Draw Menu:
			Inventory(Client);
		}

		//Button Selected:
		if(Parameter == 2)
		{

			//Show Menu:
			DrawPlayerMenu(Client, GetMenuTarget(Client));
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

public Action DrawGiveCashMenu(int Client, int Player)
{

	//Declare:
	char display[32];
	char info[32];

	//Convert:
	IntToString(GetCash(Client), info, sizeof(info));

	//Handle:
	Menu menu = CreateMenu(HandleGiveCash);

	//Declare:
	char title[256]; Format(title, sizeof(title), "How much cash would you like\nto give %N?", Player);

	//Menu Title:
	menu.SetTitle(title);

	//Format:
	Format(display, sizeof(display), "All (€%i)", GetCash(Client));

	//Menu Button:
	menu.AddItem(info, display);

	//Menu Button:
	menu.AddItem("1", "1");

	//Menu Button:
	menu.AddItem("2", "2");

	//Menu Button:
	menu.AddItem("5", "5");

	//Menu Button:
	menu.AddItem("10", "10");

	//Menu Button:
	menu.AddItem("25", "25");

	//Menu Button:
	menu.AddItem("50", "50");

	//Menu Button:
	menu.AddItem("100", "100");

	//Menu Button:
	menu.AddItem("250", "250");

	//Menu Button:
	menu.AddItem("500", "500");

	//Menu Button:
	menu.AddItem("1000", "1000");

	//Menu Button:
	menu.AddItem("2500", "2500");

	//Menu Button:
	menu.AddItem("5000", "5000");

	//Menu Button:
	menu.AddItem("10000", "10000");

	//Menu Button:
	menu.AddItem("100000", "100000");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

public int HandleGiveCash(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		int Ent = GetMenuTarget(Client);

		//Connected:
		if(Ent > 0 && Client != Ent && IsClientConnected(Ent) && IsClientInGame(Ent))
		{

			//To Far Away:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				char info[32];

				//Get Menu Info:	
				menu.GetItem(Parameter, info, sizeof(info));

				//Initialize:				
				int Amount = StringToInt(info);

				//Has Enough Cash:
				if(GetCash(Client) - Amount >= 0 && GetCash(Client) != 0)
				{

					//Initialize:
					SetCash(Client, (GetCash(Client) - Amount));

		            		SetCash(Ent, (GetCash(Ent) + Amount));

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You gave \x0732CD32€%i\x07FFFFFF to \x0732CD32%N", Amount, Ent);

					CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - You recieve \x0732CD32€%i\x07FFFFFF from \x0732CD32%N", Amount, Client);

					//Set Menu State:
					CashState(Client, Amount);

					CashState(Ent, Amount);

					//Draw Menu:
					DrawGiveCashMenu(Client, Ent);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have that much Cash with you!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are to far away from this player, move clooser..");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player.");
		}
	}


	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

public Action DrawHandleMenu(int Client, int Player)
{

	//Declare:
	char PlayerName[64];

	//Initialize:
	GetClientName(Player, PlayerName, sizeof(PlayerName));

	//Handle:
	Menu menu = CreateMenu(HandleYourActions);

	//Is Combine and Player Is Cuffed:
	if(IsCop(Client) || IsAdmin(Client))
	{

		//Is Cuffed
		if(IsCuffed(Player))
		{

			//Menu Button:
			menu.AddItem("0", "Jail");

			//Menu Button:
			menu.AddItem("1", "Catch");

			//Menu Button:
			menu.AddItem("2", "Offer Bail");

			//Menu Button:
			menu.AddItem("3", "Force Feed");

			//Menu Button:
			menu.AddItem("4", "Release Player");

			//Menu Button:
			menu.AddItem("5", "Search Player");

			//Check If player is in jail!
			if(IsClientInJailSell(Player) || IsClientInJail(Player))
			{

				//Menu Button:
				menu.AddItem("10", "Send to Execut");

				//Menu Button:
				menu.AddItem("11", "Send to Fire Pit");

				//Menu Button:
				menu.AddItem("7", "VIP Jail");
			}
		}

		//Is Medic:
		if(StrContains(GetJob(Client), "Medic", false) != -1 || IsAdmin(Client))
		{

			//Menu Button:
			menu.AddItem("6 100", "Heal Player");
		}
	}

	//Is Medic:
	if(StrContains(GetJob(Client), "Brain Surgeon", false) != -1)
	{

		//Menu Button:
		menu.AddItem("6 60", "Heal");
	}

	//Is Medic:
	if(StrContains(GetJob(Client), "Bounty Hunter", false) != -1)
	{

		//Menu Button:
		menu.AddItem("12", "Order Hit");
	}

	//Is In Gang:
	if(!StrEqual(GetGang(Client), "null", false))
	{

		//Check:
		if(IsOwnerOfGang(Client, GetGang(Client)))
		{

			//Menu Button:
			menu.AddItem("13", "Invite to gang");

			//Is Medic:
			if(StrContains(GetGang(Client), GetGang(Player), false) != -1)
			{

				//Menu Button:
				menu.AddItem("14", "Kick out of gang");
			}
		}

		//Declare:
		int GangLevel = GetGangLevel(Client, GetGang(Client));

		if(GangLevel >= 10 && !IsCop(Player))
		{

			//Menu Button:
			menu.AddItem("15", "Dope some crime");
		}

		if(GangLevel >= 15)
		{

			//Menu Button:
			menu.AddItem("16", "Poison Player");
		}
	}

	//Menu Button:
	menu.AddItem("9", "Back");

	//Menu Title:
	menu.SetTitle("Select a button: (%s)", PlayerName);

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//PlayerMenu Handle:
public int HandleYourActions(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];
		char Buffer[2][64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Explode:
		ExplodeString(info, " ", Buffer, 2, 64);

		//Initialize:
		int Result = StringToInt(Buffer[0]);

		//Declare:
		int Ent = GetMenuTarget(Client);

		//Button Selected:
		if(Result == 0 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Jail Player:
			JailClient(Ent, Client);
		}

		//Button Selected:
		if(Result == 1 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Not Grabbed:
			if(GetGrabbed(Client) == -1)
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Grabbed \x0732CD32%N\x07FFFFFF.", Ent);

				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Grabbed you.", Client);

				//Initialize:
				SetGrabbed(Client, Ent);

				//Timer:
				CreateTimer(0.1, Pusher, Client);

				//Set Speed:
				SetEntitySpeed(Ent, 1.0);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You let go \x0732CD32%N\x07FFFFFF.", Ent);

				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF let you go.", Client);

				//Initialize:
				SetGrabbed(Client, -1);

				//Set Speed:
				SetEntitySpeed(Ent, 0.4);
			}
		}

		//Button Selected:
		if(Result == 2 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Check:
			if(GetPostCrime(Ent) == 0)
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Player has no Post Crime to Calculate bail from!");
			}

			//Override:
			else
			{

				//Initulize::
				SetMenuTarget(Ent, Client);

				//Handle:
				menu = CreateMenu(HandlePlayerBribe);

				//Title:
				menu.SetTitle("%N\nHas gave you the option\nof offering a brite\nto release you from jail\n\nYour Answer...", Client);

				//Declare:
				char Bribe[32];

				//Format:
				Format(Bribe, sizeof(Bribe), "%i", (GetPostCrime(Ent) / 10));

				//Declare:
				char Bribe2[32];

				//Format:
				Format(Bribe2, sizeof(Bribe2), "%s", IntToMoney((GetPostCrime(Ent) / 10)));

				//Menu Button:
				menu.AddItem(Bribe, Bribe2);

				menu.AddItem("0", "no I wont pay");

				//Set Exit Button:
				menu.ExitButton = false;

				//Show Menu:
				menu.Display(Ent, 30);

				//Print:
				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have offered a bail to \x0732CD32%N\x07FFFFFF!", Ent);
			}
		}

		//Button Selected:
		if(Result == 3 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Declare:
			char PlayerName[32];

			//Initialize:
			GetClientName(Ent, PlayerName, 32);

			//Enough Hunger:
			if(GetHunger(Ent) < 100.0)
			{

				//Declare:
				char ClientName[32];

				//Initialize:
				GetClientName(Client, ClientName, 32);

				//Enough Hunger:
				if(GetHunger(Ent) >= 80.0)
				{

					//Initialize:
					SetHunger(Ent, 100.0);
				}

				//Override:
				else
				{

					//Initialize:
					SetHunger(Ent, (GetHunger(Ent) + 15.0));
				}

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You forced feaded \x0732CD32%s\x07FFFFFF.", PlayerName);

				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF forced feaded you.", ClientName);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF is full, you cannot feed him anymore.", PlayerName);
			}
		}

		//Button Selected:
		if(Result == 5 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent) == true)
		{

			//Has Harvest:
			if(GetHarvest(Ent) > 0 || GetMeth(Ent) > 0 || GetPills(Ent) > 0 || GetResources(Ent) > 0 || GetCocain(Ent) > 0)
			{

				//Declare:
				int AddCash = GetHarvest(Ent) + GetMeth(Ent) + (GetPills(Ent) * 5) + GetResources(Ent) + (GetCocain(Ent) * 10);

				//Initulize:
				SetHarvest(Ent, 0);

				SetMeth(Ent, 0);

				SetCocain(Ent, 0);

				SetPills(Ent, 0);

				SetResources(Ent, 0);

				SetBank(Client, (GetBank(Client) + AddCash));

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Has Drugs on them! €\x0732CD32%i\01 reward!", Ent, AddCash);

				//Print:
				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - You have been busted for drugs!");

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Hasn't got any Drugs on them.", Ent);

				//Print:
				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - You have been searched but nothing was found!");
			}
		}

		//Button Selected:
		if(Result == 4 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has released you from jail.", Ent);

			CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - you have released \x0732CD32%N\x07FFFFFF from jail.", Client);

			//Free Player:
			AutoFree(Ent);
		}

		//Button Selected:
		if(Result == 6)
		{

			//Initialize:
			int ClientHealHP = StringToInt(Buffer[1]);

			//Declare:
			int ClientHP = GetClientHealth(Ent);

			//Is In Time:
			if(JobCooldown[Client] < (GetGameTime() - 30))
			{

				//Healing Rage:
  				if(ClientHP < 100 && !(ClientHP > 100))
				{

					//Has Energy:
					if(GetEnergy(Client) >= 15)
					{

						//In Critical:
						if(ClientHP <= 20)
						{

							//Initialize:
							SetJobExperience(Client, (GetJobExperience(Client) + 10));
						}

						//Low HP:
						if(ClientHP <= 60 && ClientHP > 20)
						{

							//Initialize:
							SetJobExperience(Client, (GetJobExperience(Client) + 5));
						}

						//Override:
						else
						{

							//Initialize:
							SetJobExperience(Client, (GetJobExperience(Client) + 3));
						}

						//Initulize:
						SetEnergy(Client, (GetEnergy(Client) - 15));

						//To Much Health:
						if(ClientHP + ClientHealHP > 100)
						{

							//Set Health:
							SetEntityHealth(Ent, 100);
						}

						//Override:
						else
						{

							//Set Health:
							SetEntityHealth(Ent, (ClientHP + ClientHealHP));
						}

						//Initulize:
						JobCooldown[Client] = GetGameTime();

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have healed \x0732CD32%N\x07FFFFFF for \x0732CD32%i\x07FFFFFFHP.", Ent, ClientHealHP);

						CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has healed you for +\x0732CD32%i\x07FFFFFFHP.", Client, ClientHealHP);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have enough energy to heal \x0732CD32%N\x07FFFFFF.", Ent);
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF already has perfect health.", Ent);
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have done this job too recently!");
			}
		}

		//Button Selected:
		if(Result == 10 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Sent Client To Execute:
			Execute(Ent, Client);
		}

		//Button Selected:
		if(Result == 11 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Sent Client To FirePit:
			FirePit(Ent, Client);
		}

		//Button Selected:
		if(Result == 12)
		{

			//Show Menu:
			DrawPlayerHitMenu(Client, Ent);
		}

		//Button Selected:
		if(Result == 13)
		{

			//Initulize: // forward to rp_gangsystem.sp
			OnInvitePlayerToGang(Client, Ent);
		}

		//Button Selected:
		if(Result == 14)
		{

			//Initulize: // forward to rp_gangsystem.sp
			OnPlayerKickMemberOutOfGang(Client, Ent);
		}

		//Button Selected:
		if(Result == 15)
		{

			//Initulize: // forward to rp_gangsystem.sp
			OnPlayerGangDropCrime(Client, Ent);
		}

		//Button Selected:
		if(Result == 16)
		{

			//Initulize: // forward to rp_gangsystem.sp
			OnPlayerGangPoison(Client, Ent);
		}

		//Button Selected:
		if(Result == 9)
		{

			//Show Menu:
			DrawPlayerMenu(Client, Ent);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

//PlayerMenu Handle:
public int HandlePlayerBribe(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Declare:
		int Ent = GetMenuTarget(Client);

		//Button Selected:
		if(Result != 0)
		{

			//Connected:
			if(Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Has Enough Cash:
				if(GetBank(Client) >= Result)
				{

					//Initulize:
					SetBank(Client, (GetBank(Client) - Result));

					SetBank(Ent, (GetBank(Ent) + Result));

					//Set Menu State:
					BankState(Client, Result);

					BankState(Ent, Result);

					//Uncuff Client:
					AutoFree(Ent);

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are released from jail!");

					CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has took your offer of \x0732CD32€%i\x07FFFFFF!", Client, Result);

					//Play Sound:
					EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have that much Cash with you!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player.");
			}
		}

		//Override
		else
		{

			//Connected:
			if(Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have turned down \x0732CD32%N\x07FFFFFF's offer!", Ent);

				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has turned down your offer!", Client);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player.");
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

//PlayerMenu Handle:
public int HandleUsePlayer(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 1)
		{

			//Show Menu:
			DrawPlayerMenu(Client, GetMenuTarget(Client));
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

//PlayerMenu Handle:
public int HandlePlayerBuy(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		int Ent = GetMenuTarget(Client);

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Show Menu:
			PlayerBuyMenu(Client);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Show Menu:
			DrawPlayerMenu(Client, Ent);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Show Menu:
			//DrawHelpMenu(Client);
		}

		//Button Selected:
		if(Result == 3)
		{

			//Initulize:
			SetMenuTarget(Client, Ent);

			//Show Menu:
			DrawDepositMenu(Client);
		}

		//Button Selected:
		if(Result == 4)
		{

			//Show Menu:
			DrawTransactMenu(Client);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

public void DrawPlayerHitMenu(int Client, int Ent)
{

	//Handle:
	Menu menu = CreateMenu(HandlePlayerHitMenu);

	//Menu Title:
	menu.SetTitle("Who would you like to put a Hit on?");

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(!IsClientInGame(i))
		{

			//Initialize:
			continue;
		}

		//Declare:
		char name[65];
		char ID[25];

		//Initialize:
		GetClientName(i, name, sizeof(name));

		//Convert:
		IntToString(i, ID, sizeof(ID));

		//Menu Button:
		menu.AddItem(ID, name);
	}

	//Allow Back Track:
	menu.ExitBackButton = false;

	//Set Exit Button:
	menu.ExitButton = true;

	//Show Menu:
	menu.Display(Client, 20);

	//Initulize:
	SetMenuTarget(Client, Ent);
}

//PlayerMenu Handle:
public int HandlePlayerHitMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[255];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Player = StringToInt(info);

		//Invalid Name:
		if(Player == -1)
		{

			//Print:
			PrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Could not find Player");
		}

		//Override:
		else if(GetHit(Player) > 0)
		{

			//Print:
			PrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Already has a Hit on them", Player);
		}

		//Override:
		else if(IsCop(Player))
		{

			//Print:
			PrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't put a Hit on a cop!");
		}

		//Override:
		else
		{

			//Initulize:
			SetTargetPlayer(Client, Player);

			//Show Menu:
			DrawHitAmountMenu(Client);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

public void DrawHitAmountMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandlePlayerHitAmountMenu);

	//Menu Title:
	menu.SetTitle("Who would you like to put a Hit on?\nthe bounty hunter will charge 25%fee");

	//Menu Button:
	menu.AddItem("750", "750");

	//Menu Button:
	menu.AddItem("1000", "1000");

	//Menu Button:
	menu.AddItem("1500", "1500");

	//Menu Button:
	menu.AddItem("2000", "2000");

	//Menu Button:
	menu.AddItem("4000", "4000");

	//Menu Button:
	menu.AddItem("10000", "10000");

	//Allow Back Track:
	menu.ExitBackButton = false;

	//Set Exit Button:
	menu.ExitButton = true;

	//Show Menu:
	menu.Display(Client, 20);
}

//PlayerMenu Handle:
public int HandlePlayerHitAmountMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[255];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Can Transact:
		if(GetCash(Client) - Amount > 0)
		{

			//Initialize:
			int HitAmount = RoundFloat(float(Amount) * 0.75);

			int OtherAmount = RoundFloat(float(Amount) * 0.25);

			int BountyHunter = GetMenuTarget(Client);

			//Initialize:
			SetBank(BountyHunter, (GetBank(BountyHunter) + OtherAmount));

			//Initialize:
			SetBank(Client, (GetBank(Client) - Amount));

			//Set Menu State:
			BankState(Client, Amount);

			int Player = GetTargetPlayer(Client);

			//Add Player Hit:
			SetHit(Player, HitAmount);

			//Print:
			CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - %N Has set a Hit on you!", Client);

			//Print:
			CPrintToChat(BountyHunter, "\x07FF4040|RP|\x07FFFFFF - %N Has set a Hit on %N!", Client, Player);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have set Hit on %N!", Player);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}
