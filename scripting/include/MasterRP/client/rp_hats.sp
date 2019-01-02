//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_hats_included_
  #endinput
#endif
#define _rp_hats_included_

//Hats:
int PlayerHat[MAXPLAYERS + 1] = {-1,...};
char HatModel[MAXPLAYERS + 1][255];

public void initHats()
{

	//Commands:
	RegConsoleCmd("sm_hatmenu", Command_HatMenu);

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Initulize:
		PlayerHat[i] = -1;

		HatModel[i] = "null";
	}
}

public void OnClientDiedThrowPhysHat(int Client)
{

	//Is Valid:
	if(IsValidEntity(PlayerHat[Client]))
	{

		//Declare:
		char ModelName[128];

		//Initialize:
		GetEntPropString(PlayerHat[Client], Prop_Data, "m_ModelName", ModelName, 128);

		//Check:
		if(StrEqual(ModelName, "models/barneyhelmet.mdl") || StrEqual(ModelName, "models/barneyhelmet_faceplate.mdl"))
		{

			//Return:
			return;
		}

		//Declare:
		float Origin[3];

		//Get Prop Data:
		GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Origin);
		Origin[2] += 45;

		//Declare:
		float Angels[3];

		//Initulize:
		GetEntPropVector(Client, Prop_Data, "m_angRotation", Angels);

		//Declare:
		int Ent2 = CreateProp(Origin, Angels, ModelName, true, false);

		//Set Offset:
		if(StrEqual(ModelName, "models/headcrabclassic.mdl") || StrEqual(ModelName, "models/headcrabblack.mdl"))
		{

			//Initulize:
			Ent2 = CreateEntityByName("monster_generic");
		}

		//Override:
		else
		{

			//Initulize:
			Ent2 = CreateEntityByName("prop_dynamic_override");
		}

		//Check:
		if(Ent2 > 0)
		{

			//Set Offset:
			if(StrEqual(ModelName, "models/props_lab/dogobject_wood_crate001a_damagedmax.mdl"))
			{

				//Send:

				SetEntPropFloat(Ent2, Prop_Send, "m_flModelScale", 0.4);


				//Is Player:
				SetEntityRenderColor(Ent2, 50, 255, 50, 128);

				//Set Render:
				SetEntityRenderMode(Ent2, RENDER_TRANSCOLOR);

				//Set Render Ex:
				SetEntityRenderFx(Ent2, RENDERFX_DISTORT);
			}

			//Set ClassName:
			SetEntPropString(Ent2, Prop_Data, "m_iClassname", "player_hat_Throw");

			//Declare:
			float Velocity[3];

			//Calculate Just Behind the Player:
			GetPushBetweenEntities(PlayerHat[Client], 100.0, Velocity);

			//Teleport:
		   	TeleportEntity(Ent2, Origin, Angels, Velocity);

			//Declare:
			int Flags = GetEntProp(Ent2, Prop_Data, "m_iEFlags");

			//Send:
			SetEntProp(Ent2, Prop_Data, "m_iEFlags", Flags|EFL_NO_PHYSCANNON_INTERACTION);

			//Timer:
			CreateTimer(5.0, RemovePlayerHatAfterDeath, Ent2);

			//Print:
			//PrintToServer("|RP| - Recreated hat after death");
		}

		//Request
		RequestFrame(OnNextFrameKill, PlayerHat[Client]);
	}

	//Initulize:
	SetPlayerHatEnt(Client, -1);
}

//Spawn Timer:
public Action RemovePlayerHatAfterDeath(Handle Timer, any Ent)
{

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Accept Entity Input:
		//AcceptEntityInput(Ent, "Kill");

		//Dessolve:
		EntityDissolve(Ent, 1);
	}
}

public int CreateHat(int Client, char Model[255])
{

	//Is Valid:
	if(IsValidEdict(GetPlayerHatEnt(Client)))
	{

		//Request:
		RequestFrame(OnNextFrameKill, GetPlayerHatEnt(Client));
	}

	//Declare:
	int iModel = -1;

	//Set Offset:
	if(StrEqual(Model, "models/headcrabclassic.mdl") || StrEqual(Model, "models/headcrabblack.mdl"))
	{

		//Initulize:
		iModel = CreateEntityByName("monster_generic");
	}

	//Override:
	else
	{

		//Initulize:
		iModel = CreateEntityByName("prop_dynamic_override");
	}

	//Is Valid:
	if(IsValidEdict(iModel))
	{

		//Is PreCached:
		if(!IsModelPrecached(Model)) PrecacheModel(Model);

		//Dispatch:
		DispatchKeyValue(iModel, "model", Model);

		DispatchKeyValue(iModel, "solid", "0");

		//Set Owner
		SetEntPropEnt(iModel, Prop_Send, "m_hOwnerEntity", Client);

		//Invincible:
		SetEntProp(iModel, Prop_Data, "m_takedamage", 0, 1);

		//Spawn:
		DispatchSpawn(iModel);

		//Set ClassName:
		SetEntPropString(iModel, Prop_Data, "m_iClassname", "player_hat");

		//Declare:
		char Name[32];

		//Format:
		Format(Name, sizeof(Name), "PlayerHat_%i", Client);

		//Dispatch:
		DispatchKeyValue(iModel, "targetname", Name);

		//Accept:
		AcceptEntityInput(iModel, "TurnOn", Client, Client, 0);

		//Declare:
		float Pos[3];
		float Offset[3];
		float Angle[3];

		//Initulize:
		GetEntPropVector(iModel, Prop_Send, "m_vecOrigin", Pos);

		//Get Data:
		GetHatOffset(Offset, Angle, Model);

		//Match:
		Pos[2] += Offset[2];
		Pos[0] += Offset[0];
		Pos[1] += Offset[1];

		//Teleport:
		TeleportEntity(iModel, Pos, Angle, NULL_VECTOR);

		//SDKHOOK:
		SDKHook(iModel, SDKHook_SetTransmit, OnHatShouldTransmit);

		//Initulize:
		SetPlayerHatEnt(Client, iModel);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(iModel, "SetParent", Client, iModel, 0);

		//Attach:
		SetVariantString("Eyes");

		//Accept:
		AcceptEntityInput(iModel, "SetParentAttachment", iModel , iModel, 0);

		//Set Offset:
		if(StrEqual(Model, "models/props_junk/watermelon01.mdl"))
		{

			//Send:

			SetEntPropFloat(iModel, Prop_Send, "m_flModelScale", 1.2);

		}

		//Set Offset:
		if(StrEqual(Model, "models/props_lab/dogobject_wood_crate001a_damagedmax.mdl"))
		{

			//Send:

			SetEntPropFloat(iModel, Prop_Send, "m_flModelScale", 0.4);


			//Is Player:
			SetEntityRenderColor(iModel, 50, 255, 50, 128);

			//Set Render:
			SetEntityRenderMode(iModel, RENDER_TRANSCOLOR);

			//Set Render Ex:
			SetEntityRenderFx(iModel, RENDERFX_DISTORT);

			//Loop:
			for(int i = 0; i <= 2; i++)
			{

				//Switch:
				if(GetPlayerTrail(Client, i) == 28)
				{

					//Set ClassName:
					SetEntPropString(iModel, Prop_Data, "m_iClassname", "prop_Rotate");
				}
			}
		}

		//Set Offset:
		if(StrEqual(Model, "models/gibs/agibs.mdl"))
		{

			//Send:

			SetEntPropFloat(iModel, Prop_Send, "m_flModelScale", 1.5);


			//Is Player:
			SetEntityRenderColor(iModel, 50, 50, 50, 255);
		}

		//Set Offset:
		if(StrEqual(Model, "models/perftest/loader.mdl"))
		{

			//Send:

			SetEntPropFloat(iModel, Prop_Send, "m_flModelScale", 0.1);

		}

		//Damage Hook:
		SDKHook(iModel, SDKHook_OnTakeDamage, OnHatTakeDamage);

		//Return:
		return view_as<int>(iModel);
	}

	//Return:
	return -1;
}

//Event Damage:
public Action OnHatTakeDamage(int Entity, int &attacker, int &inflictor, float &damage, int &damageType)
{

	//Declare:
	int Client = GetOwnerOfHatEnt(Entity);

	//Initulize:
	Entity = Client;

	//Return:
	return Plugin_Changed;
}

public void GetHatOffset(float Offset[3], float Angle[3], char Model[255])
{

	//Match:
	Angle[2] = 0.0;
	Angle[0] = 0.0;
	Angle[1] = 0.0;

	//Set Offset:
	if(StrEqual(Model, "models/props_junk/sawblade001a.mdl"))
	{

		//Match:
		Offset[2] = 3.0;
		Offset[0] = -5.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_combine/combine_mine01.mdl"))
	{

		//Match:
		Offset[2] = 2.0;
		Offset[0] = -5.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_c17/tv_monitor01.mdl"))
	{

		//Match:
		Offset[2] = 1.0;
		Offset[0] = -5.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_c17/lampshade001a.mdl"))
	{

		//Match:
		Offset[2] = 1.0;
		Offset[0] = -4.5;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/headcrabclassic.mdl"))
	{

		//Match:
		Offset[2] = 3.0;
		Offset[0] = 2.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_lab/monitor01a.mdl"))
	{

		//Match:
		Offset[2] = 2.0;
		Offset[0] = 1.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_junk/trafficcone001a.mdl"))
	{

		//Match:
		Offset[2] = 14.0;
		Offset[0] = -4.5;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/gmod_tower/headcrabhat.mdl"))
	{

		//Match:
		Offset[2] = 5.5;
		Offset[0] = -3.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_junk/watermelon01.mdl"))
	{

		//Match:
		Offset[2] = 0.0;
		Offset[0] = 0.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_lab/bewaredog.mdl"))
	{

		//Match:
		Offset[2] = -7.0;
		Offset[0] = -4.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_lab/labpart.mdl"))
	{

		//Match:
		Offset[2] = 0.0;
		Offset[0] = 0.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/barneyhelmet_faceplate.mdl"))
	{

		//Match:
		Offset[2] = 0.0;
		Offset[0] = -2.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/barneyhelmet.mdl"))
	{

		//Match:
		Offset[2] = 0.0;
		Offset[0] = -2.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_lab/dogobject_wood_crate001a_damagedmax.mdl"))
	{

		//Match:
		Offset[2] = 0.0;
		Offset[0] = 0.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/gibs/agibs.mdl"))
	{

		//Match:
		Offset[2] = 0.0;
		Offset[0] = 0.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/gibs/scanner_gib05.mdl"))
	{

		//Match:
		Offset[2] = 0.0;
		Offset[0] = -4.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/perftest/loader.mdl"))
	{

		//Match:
		Offset[2] = 7.0;
		Offset[0] = -2.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/headcrabblack.mdl"))
	{

		//Match:
		Offset[2] = 5.5;
		Offset[0] = -3.0;
		Offset[1] = 0.0;
	}
}

public Action Command_HatMenu(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");
	}

	//Is Colsole:
	if(!IsAdmin(Client) && GetDonator(Client) == 0)
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you dont have access to this menu!");
	}

	//Override:
	else
	{

		//Show Menu:
		DrawHatMenu(Client);
	}

	//Return:
	return Plugin_Handled;
}

public void DrawHatMenu(int Client)
{

	//Declare:
	char display[32];

	//Handle:
	Menu menu = CreateMenu(HandleHatMenu);

	//Menu Title:
	menu.SetTitle("What had would you like to put on?");

	//Menu Button:
	menu.AddItem("Remove", "Remove Hat");

	//Format:
	Format(display, sizeof(display), "Sawblade Hat");

	//Menu Button:
	menu.AddItem("models/props_junk/sawblade001a.mdl", display);

	//Format:
	Format(display, sizeof(display), "Combine Mine Hat");

	//Menu Button:
	menu.AddItem("models/props_combine/combine_mine01.mdl", display);

	//Format:
	Format(display, sizeof(display), "TV Monitor Hat");

	//Menu Button:
	menu.AddItem("models/props_c17/tv_monitor01.mdl", display);

	//Format:
	Format(display, sizeof(display), "lamp Shade Hat");

	//Menu Button:
	menu.AddItem("models/props_c17/lampshade001a.mdl", display);

	//Format:
	Format(display, sizeof(display), "HeadCrab Hat ");

	//Menu Button:
	menu.AddItem("models/headcrabblack.mdl", display);

	//Format:
	Format(display, sizeof(display), "Black HeadCrab Hat");

	//Menu Button:
	menu.AddItem("models/headcrabclassic.mdl", display);

	//Format:
	Format(display, sizeof(display), "Monitor Hat");

	//Menu Button:
	menu.AddItem("models/props_lab/monitor01a.mdl", display);

	//Format:
	Format(display, sizeof(display), "Traffic cone Hat");

	//Menu Button:
	menu.AddItem("models/props_junk/trafficcone001a.mdl", display);

	//Format:
	Format(display, sizeof(display), "Water melon Hat");

	//Menu Button:
	menu.AddItem("models/props_junk/watermelon01.mdl", display);

	//Format:
	Format(display, sizeof(display), "Beware of dog");

	//Menu Button:
	menu.AddItem("models/props_lab/bewaredog.mdl", display);

	//Format:
	Format(display, sizeof(display), "Lab Part Hat");

	//Menu Button:
	menu.AddItem("models/props_lab/labpart.mdl", display);

	//Format:
	Format(display, sizeof(display), "Police Hat");

	//Menu Button:
	menu.AddItem("models/barneyhelmet_faceplate.mdl", display);

	//Format:
	Format(display, sizeof(display), "Barney Hat");

	//Menu Button:
	menu.AddItem("models/barneyhelmet.mdl", display);

	//Format:
	Format(display, sizeof(display), "Box Head");

	//Menu Button:
	menu.AddItem("models/props_lab/dogobject_wood_crate001a_damagedmax.mdl", display);

	//Format:
	Format(display, sizeof(display), "Skull Head");

	//Menu Button:
	menu.AddItem("models/gibs/agibs.mdl", display);

	//Format:
	Format(display, sizeof(display), "Scanner Head");

	//Menu Button:
	menu.AddItem("models/gibs/scanner_gib05.mdl", display);

	//Format:
	Format(display, sizeof(display), "Loader Head");

	//Menu Button:
	menu.AddItem("models/perftest/loader.mdl", display);

	//Menu Button:
	menu.AddItem("Back", "Back");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Hat|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public int HandleHatMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[255];
			char display[255];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info), _, display, sizeof(display));

			//Set Model:
			if(StrEqual(info, HatModel[Client]))
			{

				//Print:
				CPrintToChat(Client, "%s This hat is already on your head!", PREFIX);
			}

			//Set Model:
			else if(StrEqual(info,  "Remove"))
			{

				//Check:
				if(IsValidEdict(PlayerHat[Client]))
				{

					//Request
					RequestFrame(OnNextFrameKill, PlayerHat[Client]);

					//Initulize:
					PlayerHat[Client] = -1;

					//Print:
					CPrintToChat(Client, "%s You have removed your hat!", PREFIX);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "%s You don't have a hat!", PREFIX);
				}
			}

			//Set Model:
			else if(StrEqual(info,  "Back"))
			{

				//Back To Main Settings Menu:
				ClientSettingsMenu(Client);
			}

			//Override:
			else
			{

				//Save In DB:
				SaveHatModel(Client, info);

				//Create Hat:
				CreateHat(Client, info);

				//Print:
				CPrintToChat(Client, "%s Your new hat is a %s%s!", PREFIX, COLORGREEN, display);
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

public Action OnHatShouldTransmit(int Ent, int Client)
{

	//Connected:
	if(Ent > 0 && IsValidEdict(Ent))
	{

		//Check:
		if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client) && IsClientInGame(Client))
		{

			if(GetObserverMode(Client) == 5 || GetViewWearables(Client))
				return Plugin_Continue;

			if(GetObserverMode(Client) == 4 && GetObserverTarget(Client) >= 0)
					if(Ent == PlayerHat[GetObserverTarget(Client)])
						return Plugin_Handled;

			if(Ent == PlayerHat[Client])
				return Plugin_Handled;
		}
	}

	//Return:
	return Plugin_Continue;
}

public void SaveHatModel(int Client, char info[255])
{

	//Format:
	Format(HatModel[Client], sizeof(HatModel[]), "%s", info);

	//Declare:
	char query[512];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE LastStats SET Hat = '%s' WHERE STEAMID = %i;", info, SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 13);
}

char GetHatModel(int Client)
{

	//Return:
	return view_as<char>(HatModel[Client]);
}

public void SetHatModel(int Client, char info[255])
{

	//Format:
	Format(HatModel[Client], sizeof(HatModel[]), "%s", info);

	//Declare:
	char query[512];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE LastStats SET Hat = '%s' WHERE STEAMID = %i;", info, SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 14);
}

public void SetHatModelFx(int Client, char info[255])
{

	//Format:
	Format(HatModel[Client], sizeof(HatModel[]), "%s", info);
}

public void RemoveHatModel(int Client)
{

	//Format:
	Format(HatModel[Client], sizeof(HatModel[]), "null");

	//Declare:
	char query[512];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE LastStats SET Hat = '%s' WHERE STEAMID = %i;", "null", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 15);
}

public int GetPlayerHatEnt(int Client)
{

	//Return:
	return view_as<int>(PlayerHat[Client]);
}

public int GetOwnerOfHatEnt(int Entity)
{

	//Declare:
	int Result = -1;

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Check:
		if(Entity == PlayerHat[i])
		{

			//Initulize:
			Result = i;

			//Stop:
			break;
		}
	}

	//Return:
	return view_as<int>(Result);
}

public int SetPlayerHatEnt(int Client, int Ent)
{

	//Initulize:
	PlayerHat[Client] = Ent;

	//Return:
	return view_as<int>(PlayerHat[Client]);
}
