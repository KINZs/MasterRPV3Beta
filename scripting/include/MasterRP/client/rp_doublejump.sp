//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_doublejump_included_
  #endinput
#endif
#define _rp_doublejump_included_

//Double - Jump:
int LastButtons[MAXPLAYERS + 1] = {0,...};
int LastFlags[MAXPLAYERS + 1] = {0,...};
int PreThinkJump[MAXPLAYERS + 1] = {0,...};
int Jump[MAXPLAYERS + 1] = {0,...};
int JumpEffect[MAXPLAYERS + 1] = {0,...};
bool DoubleJumpEnabled[MAXPLAYERS + 1] = {true,...};

public void initDoubleJump()
{

	//Commands:
	RegConsoleCmd("sm_doublejump", Command_DoubleJump);

	RegConsoleCmd("sm_jumpmenu", Command_DoubleJumpMenu);
}

public void initDefaultDoubleJump(int Client)
{

	//Default:
	LastButtons[Client] = 0;
	LastFlags[Client] = 0;
	PreThinkJump[Client] = 0;
	Jump[Client] = 0;
	JumpEffect[Client] = 0;
	DoubleJumpEnabled[Client] = true;
}

public void OnClientRunCmdDoubleJumpCheck(int Client)
{

	//Check:
	int fCurFlags = GetEntityFlags(Client);	
	int fCurButtons	= GetClientButtons(Client);

	if(LastFlags[Client] & FL_ONGROUND)
	{
		if (!(fCurFlags & FL_ONGROUND) && !(LastButtons[Client] & IN_JUMP) && fCurButtons & IN_JUMP) 
		{

			//Pre Dubble Jump
			Jump[Client] = 1;			
		}
	}

	else if(!(LastButtons[Client] & IN_JUMP) && fCurButtons & IN_JUMP)
	{
		//if(0 <= Jump[Client] <= 1)
		if(Jump[Client] == 1 && PreThinkJump[Client] == 0)
		{

			//Jump:
			OnClientDoubleJump(Client);
		}
	}

	LastFlags[Client] = fCurFlags;				
	LastButtons[Client] = fCurButtons;
}

public void OnClientDoubleJump(int Client)
{

	//Check:
	if(!DoubleJumpEnabled[Client]) return;

	//Initulize:
	Jump[Client]++;

	PreThinkJump[Client] = 1;

	//Declare:
	float Push[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Data, "m_vecVelocity", Push);

	//Boost Client:
	Push[2] = 250.0;

	//Teleport:
	TeleportEntity(Client, NULL_VECTOR, NULL_VECTOR, Push);


	//Effect:
	OnClientDoubleJumpEffect(Client);
}

public void OnClientDoubleJumpEffect(int Client)
{

	//Declare:
	float Origin[3];
 
	//Initulize:
	GetClientAbsOrigin(Client, Origin);

	//Emit:
	EmitAmbientSound("roleplay/regen.mp3", Origin, Client, SNDLEVEL_NORMAL);

	if(JumpEffect[Client] > 0)
	{

		//Switch:
		switch(JumpEffect[Client])
		{

			//Energy Splash:
			case 1:
			{

	
			//Temp Ent:

				TE_SetupEnergySplash(Origin, NULL_VECTOR, true);



				//Send:

				TE_SendToAll();
			}
			//Red Ring:
			case 2:
			{

				//Declare:
				int Color[4] = {255, 50, 50, 255};

				//Show To Client:
				//TE_SetupBeamRingPoint(Origin, 1.0, 30.0, Laser(), Sprite(), 0, 10, 0.7, 10.0, 0.5, Color, 10, 0);
				TE_SetupBeamRingPoint(Origin, 10.0, 40.0, Laser(), Sprite(), 0, 20, 0.65, 3.0, 0.5, Color, 7, 0);

				//Send:

				TE_SendToAll();

	
			//Temp Ent:

				TE_SetupEnergySplash(Origin, NULL_VECTOR, true);



				//Send:

				TE_SendToAll();
			}

			//Green Ring:
			case 3:
			{

				//Declare:
				int Color[4] = {50, 255, 50, 255};

				//Show To Client:
				//TE_SetupBeamRingPoint(Origin, 1.0, 30.0, Laser(), Sprite(), 0, 10, 0.7, 10.0, 0.5, Color, 10, 0);
				TE_SetupBeamRingPoint(Origin, 10.0, 40.0, Laser(), Sprite(), 0, 20, 0.65, 3.0, 0.5, Color, 7, 0);

				//Send:

				TE_SendToAll();

	
			//Temp Ent:

				TE_SetupEnergySplash(Origin, NULL_VECTOR, true);



				//Send:

				TE_SendToAll();
			}

			//blue Ring:
			case 4:
			{

				//Declare:
				int Color[4] = {50, 50, 255, 255};

				//Show To Client:
				//TE_SetupBeamRingPoint(Origin, 1.0, 30.0, Laser(), Sprite(), 0, 10, 0.7, 10.0, 0.5, Color, 10, 0);
				TE_SetupBeamRingPoint(Origin, 10.0, 40.0, Laser(), Sprite(), 0, 20, 0.65, 3.0, 0.5, Color, 7, 0);

				//Send:

				TE_SendToAll();

	
			//Temp Ent:

				TE_SetupEnergySplash(Origin, NULL_VECTOR, true);



				//Send:

				TE_SendToAll();
			}

			//Yellow Ring:
			case 5:
			{

				//Declare:
				int Color[4] = {255, 150, 50, 255};

				//Show To Client:
				//TE_SetupBeamRingPoint(Origin, 1.0, 30.0, Laser(), Sprite(), 0, 10, 0.7, 10.0, 0.5, Color, 10, 0);
				TE_SetupBeamRingPoint(Origin, 10.0, 40.0, Laser(), Sprite(), 0, 20, 0.65, 3.0, 0.5, Color, 7, 0);

				//Send:

				TE_SendToAll();

	
			//Temp Ent:

				TE_SetupEnergySplash(Origin, NULL_VECTOR, true);



				//Send:

				TE_SendToAll();
			}

			//Admin Ring:
			case 20:
			{

				//Create Effect:
				//int Ent = CreateProp(Position, Angles, "models/effects/combineball.mdl", true, false);
				int Ent = CreateDynamicProp(Origin, view_as<float>({90.0,0.0,0.0}), "models/effects/combineball.mdl", true);


				//Send:
				SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", 1.5);

				//Timer:
				CreateTimer(0.0, RemoveGibs, Ent);
			}
		}
	}
}

public Action Command_DoubleJump(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");
	}

	//Is Colsole:
	if(!IsAdmin(Client) && GetDonator(Client) == 0 && !HasItemTypeInInventory(Client, 61))
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you dont have access to this menu!");
	}

	//Override:
	else
	{

		//Is Valid:
		if(DoubleJumpEnabled[Client] == false)
		{

			//Set DoubleJump Status:
			DoubleJumpEnabled[Client] = true;

			//Print:
			CPrintToChat(Client, "%s Double Jump is now %sEnabled.", PREFIX, COLORGREEN);
		}

		//Override:
		else if(DoubleJumpEnabled[Client] == true)
		{

			//Set DoubleJump Status:
			DoubleJumpEnabled[Client] = false;

			//Print:
			CPrintToChat(Client, "%s Double Jump is now %sDisabled.", PREFIX, COLORGREEN);
		}

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Settings SET DoubleJump = %i WHERE STEAMID = %i;", boolToint(DoubleJumpEnabled[Client]), SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_DoubleJumpMenu(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");
	}

	//Is Colsole:
	if(!IsAdmin(Client) && GetDonator(Client) == 0 && !HasItemTypeInInventory(Client, 61))
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you dont have access to this menu!");
	}

	//Override:
	else
	{

		//Show Menu:
		DoubleJumpMenu(Client);
	}

	//Return:
	return Plugin_Handled;
}

public void DoubleJumpMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleDoubleJumpMenu);

	//Menu Title:
	menu.SetTitle("DoubleJump Settings Menu");

	//Declare:
	char State[128];

	//Format:
	Format(State, sizeof(State), "DoubleJump is %s", DoubleJumpEnabled[Client] ? "Enabled" : "Disabled");

	//Menu Button:
	menu.AddItem("0", State);

	//Menu Button:
	menu.AddItem("1", "DoubleJump Effect");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-JetPack|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//Handle:
public int HandleDoubleJumpMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[32];
			char display[255];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info), _, display, sizeof(display));

			//Declare:
			int Result = StringToInt(info);

			//Button Selected:
			if(Result == 0)
			{

				//Is Valid:
				if(DoubleJumpEnabled[Client] == false)
				{

					//Set DoubleJump Status:
					DoubleJumpEnabled[Client] = true;

					//Print:
					CPrintToChat(Client, "%s Double Jump is now %sEnabled.", PREFIX, COLORGREEN);
				}

				//Override:
				else if(DoubleJumpEnabled[Client] == true)
				{

					//Set DoubleJump Status:
					DoubleJumpEnabled[Client] = false;

					//Print:
					CPrintToChat(Client, "%s Double Jump is now %sDisabled.", PREFIX, COLORGREEN);
				}

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Settings SET DoubleJump = %i WHERE STEAMID = %i;", boolToint(DoubleJumpEnabled[Client]), SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
			}

			//Button Selected:
			if(Result == 1)
			{

				//Show Menu:
				DoubleJumpEffectMenu(Client);
			}

			//Initulize:
			JetPackEffect[Client] = Result;
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

public void DoubleJumpEffectMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleDoubleJumpEffectMenu);

	//Menu Title:
	menu.SetTitle("What Effect had would you like to put on?");

	//Check:
	if(IsAdmin(Client) || GetDonator(Client))
	{

		//Menu Button:
		menu.AddItem("0", "Normal");

		//Menu Button:
		menu.AddItem("1", "Energy Splash");

		//Menu Button:
		menu.AddItem("2", "Red Ring");

		//Menu Button:
		menu.AddItem("3", "Green Ring");

		//Menu Button:
		menu.AddItem("4", "Blue Ring");

		//Menu Button:
		menu.AddItem("5", "Yellow Ring");

		//Check:
		if(IsAdmin(Client))
		{

			//Menu Button:
			menu.AddItem("20", "Tesla Spark");
		}

		//Set Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);
	}

	//Has DoubleJump In Inventory:
	else if(HasItemTypeInInventory(Client, 61))
	{
/*
		//HasItem:
		if(GetItemAmount(Client, 379))
		{

			//Menu Button:
			menu.AddItem("1", "Normal");
		}
*/
		//Set Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);
	}

	//Override:
	else
	{

		//Close:
		delete menu;
	}
}

//Handle:
public int HandleDoubleJumpEffectMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[32];
			char display[255];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info), _, display, sizeof(display));

			//Declare:
			int Result = StringToInt(info);

			//Initulize:
			JumpEffect[Client] = Result;

			//Print:
			CPrintToChat(Client, "%s Your new JetPack DoubleJump is a %s%s!", PREFIX, COLORGREEN, display);

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET DoubleJumpEffect = %i WHERE STEAMID = %i;", JumpEffect[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
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
public void OnClientPostThinkDoubleJumpCheck(int Client)
{

	//Declare:
	int OnGround = GetEntityFlags(Client);

	//Check Has Jumped!
	if(OnGround & FL_ONGROUND && GetJump(Client) != 0)
	{

		//Initulize:
		SetJump(Client, 0);

		SetPreThinkJump(Client, 0);
	}
}

public int GetPreThinkJump(int Client)
{

	//Return:
	return PreThinkJump[Client];
}

public int SetPreThinkJump(int Client, int Result)
{

	//Initulize::
	PreThinkJump[Client] = Result;
}

public int GetJump(int Client)
{

	//Return:
	return Jump[Client];
}

public int SetJump(int Client, int Result)
{

	//Initulize::
	Jump[Client] = Result;
}

public int GetJumpEnabled(int Client)
{

	//Return:
	return DoubleJumpEnabled[Client];
}

public int SetJumpEnabled(int Client, bool Result)
{

	//Initulize::
	DoubleJumpEnabled[Client] = Result;

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE Settings SET DoubleJump = %i WHERE STEAMID = %i;", boolToint(DoubleJumpEnabled[Client]), SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public int GetJumpEffect(int Client)
{

	//Return:
	return JumpEffect[Client];
}

public int SetJumpEffect(int Client, int Result)
{

	//Initulize::
	JumpEffect[Client] = Result;

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE Settings SET DoubleJumpEffect = %i WHERE STEAMID = %i;", JumpEffect[Client], SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}