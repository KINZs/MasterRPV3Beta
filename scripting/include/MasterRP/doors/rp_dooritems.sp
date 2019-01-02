//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_dooritems_included_
  #endinput
#endif
#define _rp_dooritems_included_

//Timers:
float LockTime[MAXPLAYERS + 1] = {0.0,...};
float HackTime[MAXPLAYERS + 1] = {0.0,...};
float SawTime[MAXPLAYERS + 1] = {0.0,...};
float MultiHackTime[MAXPLAYERS + 1] = {0.0,...};

public void initDoorItems()
{

	//Commands:
	RegConsoleCmd("sm_lockpick", Command_LockPick);

	RegConsoleCmd("sm_doorhack", Command_DoorHack);

	RegConsoleCmd("sm_cuffsaw", Command_CuffSaw);

	RegConsoleCmd("sm_multihack", Command_MultiHack);
}

public void SetHackItemDefaults(int Client)
{

	LockTime[Client] = GetGameTime();

	HackTime[Client] = GetGameTime();

	SawTime[Client] = GetGameTime();

	MultiHackTime[Client] = GetGameTime();
}

public void OnItemsUseLockPick(int Client, int ItemId, int Level)
{

	//Valid:
	if(LockTime[Client] <= (GetGameTime() - (60 * Level)))
	{

		//Is Combine:
		if(!IsCop(Client))
		{

			//Declare:
			int DoorEnt = GetClientAimTarget(Client, false);

			//Is Valid:
			if(DoorEnt > 1)
			{

				//Declare:
				char ClassName[255];

				//Initialize:
				GetEdictClassname(DoorEnt, ClassName, 255);

				//Is Prop Door:
				if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
				{

					//Not Admin Door:
					if(!NativeIsAdminDoor(DoorEnt))
					{

						//No Locks:
						if(GetDoorLocks(DoorEnt) < 1)
						{

							//Accept:
							AcceptEntityInput(DoorEnt, "Unlock", Client);

							AcceptEntityInput(DoorEnt, "Open", Client);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You use {olive}%s\x07FFFFFF to open this door.", GetItemName(ItemId));

							//Initialize:
							LockTime[Client] = GetGameTime();

							SetCrime(Client, (GetCrime(Client) + 600));
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This door has some additional locks!");
						}
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Door is not unlockable.");
					}
				}

				//Is Func Door:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF is a wrong prop!", ClassName);
				}
	            	}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This item can only be used by looking at a player or a door!");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't use \x0732CD32%s\x07FFFFFF while you are cop!", GetItemName(ItemId));
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only use this once every \x0732CD32%i\x07FFFFFF minutes.", Level);
	}
}

public void OnItemsUseDoorHack(int Client, int ItemId, int Level)
{

	//Valid:
	if(HackTime[Client] <= (GetGameTime() - (60 * Level)))
	{

		//Is Combine:
		if(!IsCop(Client))
		{

			//Declare:
			int DoorEnt = GetClientAimTarget(Client, false);

			//Is Valid:
			if(DoorEnt > 1)
			{

				//Declare:
				char ClassName[255];

				//Initialize:
				GetEdictClassname(DoorEnt, ClassName, 255);

				//Func:
				if(StrEqual(ClassName, "func_door"))
				{

					//Not Admin Door:
					if(!NativeIsAdminDoor(DoorEnt))
					{

						//No Locks:
						if(GetDoorLocks(DoorEnt) < 1)
						{

							//Accept:
							AcceptEntityInput(DoorEnt, "Unlock", Client);

							AcceptEntityInput(DoorEnt, "Open", Client);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You use {olive}%s\x07FFFFFF to open this door.", GetItemName(ItemId));

							//Initialize:
							HackTime[Client] = GetGameTime();

							SetCrime(Client, (GetCrime(Client) + 600));
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This door has some additional locks!");
						}
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Door is not unlockable.");
					}
				}

				//Is Func Door:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF is a wrong prop!", ClassName);
				}
	            	}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This item can only be used by looking at a player or a door!");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't use \x0732CD32%s\x07FFFFFF while you are cop!", GetItemName(ItemId));
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only use this once every \x0732CD32%i\x07FFFFFF minutes.", Level);
	}
}

public void OnClientUseItemCuffSaw(int Client, int ItemId, int Level)
{

	//Valid:
	if(SawTime[Client] <= (GetGameTime() - (60 * Level)))
	{

		//Declare:
		int Player = GetClientAimTarget(Client, true);

		//Is Actual Entity:
		if(Player > 0)
		{

			//Connected:
			if(IsClientConnected(Player) && IsClientInGame(Player))
			{

				//Is Combine:
				if(!IsCop(Client))
				{

					//Is Client Cuffed:
					if(IsCuffed(Player))
					{

						//Valid:
						if(SawTime[Player] <= (GetGameTime() - 20))
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You used a \x0732CD32%s\x07FFFFFF to uncuff \x0732CD32%N\x07FFFFFF hands!", GetItemName(ItemId), Player);

							CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF used a \x0732CD32%s\x07FFFFFF to uncuff your hands!", Client, GetItemName(ItemId));

							//Uncuff Player:
							UnCuff(Player);

							//Initialize:
							SawTime[Client] = GetGameTime();

							SawTime[Player] = GetGameTime();
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF This player has been cuffed to recently");
						}
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF is not cuffed, selected a cuffed player to use this item.", Player);
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't use \x0732CD32%s\x07FFFFFF while you are cop!", GetItemName(ItemId));
				}
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - No player selected, look at a player, then use the item again.");
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only use this once every \x0732CD32%i\x07FFFFFF minutes.", Level);
	}
}

public void OnItemsUseMultiHack(int Client, int ItemId, int Level)
{

	//Valid:
	if(MultiHackTime[Client] <= (GetGameTime() - (60 * Level)))
	{

		//Is Combine:
		if(!IsCop(Client))
		{

			//Declare:
			int Ent = GetClientAimTarget(Client, false);

			//Is Valid:
			if(Ent > 1)
			{

				//Connected:
				if(Ent <= GetMaxClients() && IsClientConnected(Ent) && IsClientInGame(Ent))
				{

					//Is Client Cuffed:
					if(IsCuffed(Ent))
					{

						//Valid:
						if(SawTime[Ent] <= (GetGameTime() - 20))
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You used a \x0732CD32%s\x07FFFFFF to uncuff \x0732CD32%N\x07FFFFFF hands!", GetItemName(ItemId), Ent);

							CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF used a \x0732CD32%s\x07FFFFFF to uncuff your hands!", Client, GetItemName(ItemId));

							//Uncuff Player:
							UnCuff(Ent);

							//Initialize:
							SawTime[Client] = GetGameTime();

							//Initialize:
							SawTime[Ent] = GetGameTime();

							MultiHackTime[Client] = GetGameTime();
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF This Ent has been cuffed to recently");
						}
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF is not cuffed, selected a cuffed player to use this item.", Ent);
					}
				}

				//Declare:
				char ClassName[255];

				//Initialize:
				GetEdictClassname(Ent, ClassName, 255);

				//Is Prop Door:
				if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
				{

					//Not Admin Door:
					if(!NativeIsAdminDoor(Ent))
					{

						//No Locks:
						if(GetDoorLocks(Ent) < 1)
						{

							//Accept:
							AcceptEntityInput(Ent, "Unlock", Client);

							AcceptEntityInput(Ent, "Open", Client);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You use {olive}%s\x07FFFFFF to open this door.", GetItemName(ItemId));

							//Initialize:
							MultiHackTime[Client] = GetGameTime();

							SetCrime(Client, (GetCrime(Client) + 600));
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This door has some additional locks!");
						}
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Door is not unlockable.");
					}
				}

				//Func:
				if(StrEqual(ClassName, "func_door"))
				{

					//Not Admin Door:
					if(!NativeIsAdminDoor(Ent))
					{

						//No Locks:
						if(GetDoorLocks(Ent) < 1)
						{

							//Accept:
							AcceptEntityInput(Ent, "Unlock", Client);

							AcceptEntityInput(Ent, "Open", Client);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You use {olive}%s\x07FFFFFF to open this door.", GetItemName(ItemId));

							//Initialize:
							MultiHackTime[Client] = GetGameTime();

							SetCrime(Client, (GetCrime(Client) + 600));
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This door has some additional locks!");
						}
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Door is not unlockable.");
					}
				}

				//Is Func Door:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF is a wrong prop!", ClassName);
				}
	            	}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This item can only be used by looking at a player or a door!");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't use \x0732CD32%s\x07FFFFFF while you are cop!", GetItemName(ItemId));
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only use this once every \x0732CD32%i\x07FFFFFF minutes.", Level);
	}
}

public Action Command_LockPick(int Client, int Args)
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
	int ItemId = FindClientItemFromItemAction(Client, 5);

	//Check:
	if(ItemId != -1)
	{

		//Declare:
		char FormatVar[64];

		//Format:
		Format(FormatVar, sizeof(FormatVar), "%s", GetItemVar(ItemId));

		//LockPick:
		OnItemsUseLockPick(Client, ItemId, StringToInt(FormatVar));

		//Return:
		return Plugin_Handled;
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have a \x0732CD32LockPick\x07FFFFFF!");

	//Return:
	return Plugin_Handled;
}

public Action Command_DoorHack(int Client, int Args)
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
	int ItemId = FindClientItemFromItemAction(Client, 6);

	//Check:
	if(ItemId != -1)
	{

		//Declare:
		char FormatVar[64];

		//Format:
		Format(FormatVar, sizeof(FormatVar), "%s", GetItemVar(ItemId));

		//LockPick:
		OnItemsUseDoorHack(Client, ItemId, StringToInt(FormatVar));

		//Return:
		return Plugin_Handled;
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have a \x0732CD32DoorHack\x07FFFFFF!");

	//Return:
	return Plugin_Handled;
}

public Action Command_CuffSaw(int Client, int Args)
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
	int ItemId = FindClientItemFromItemAction(Client, 9);

	//Check:
	if(ItemId != -1)
	{

		//Declare:
		char FormatVar[64];

		//Format:
		Format(FormatVar, sizeof(FormatVar), "%s", GetItemVar(ItemId));

		//LockPick:
		OnClientUseItemCuffSaw(Client, ItemId, StringToInt(FormatVar));

		//Return:
		return Plugin_Handled;
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have a \x0732CD32CuffSaw\x07FFFFFF!");

	//Return:
	return Plugin_Handled;
}

public Action Command_MultiHack(int Client, int Args)
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
	int ItemId = FindClientItemFromItemAction(Client, 72);

	//Check:
	if(ItemId != -1)
	{

		//Declare:
		char FormatVar[64];

		//Format:
		Format(FormatVar, sizeof(FormatVar), "%s", GetItemVar(ItemId));

		//LockPick:
		OnItemsUseMultiHack(Client, ItemId, StringToInt(FormatVar));

		//Return:
		return Plugin_Handled;
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have a \x0732CD32MultiHack\x07FFFFFF!");

	//Return:
	return Plugin_Handled;
}