//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_viewmanagement_included_
  #endinput
#endif
#define _rp_viewmanagement_included_

//Main:
bool ThirdPerson[MAXPLAYERS + 1] = {false,...};
int g_Camera[MAXPLAYERS + 1] = {0,...};

public void initViewManagement()
{

	//Commands:
	RegConsoleCmd("sm_firstperson", Command_FirstPerson);

	RegConsoleCmd("sm_thirdperson", Command_ThirdPerson);

	RegConsoleCmd("sm_resetview", Command_ResetView);

	//Hook:
	HookEntityOutput("point_viewcontrol", "OnEndFollow", OnViewEnd);
}

#if defined HL2DM
public void HL2dmThirdPersonViewFix(int Client)
{

	//Check:
	if(GetThirdPersonView(Client))
	{

		//Remove VGUI Panel:
		RemoveObserverView(Client);

		//Check:
		if(GetObserverMode(Client) != 5)
		{

			//Send:
			SetEntProp(Client, Prop_Send, "m_iObserverMode", 5);
		}

		//Check:
		if(GetClientMoveType(Client) != 2 && !IsJetpackOn(Client))
		{

			//Set Proper Move Type:
			SetClientMoveType(Client, 2);
		}

		//Check:
		if(GetClientMoveType(Client) != 5 && IsJetpackOn(Client))
		{

			//Set Proper Move Type:
			SetClientMoveType(Client, 5);
		}

		//Check:
		if(GetObserverTarget(Client) != Client)
		{

			//Send:
			SetEntPropEnt(Client, Prop_Send, "m_hObserverTarget", Client);
		}
	}
}
#endif
//public OnClientPutInServer(Client)
public void ViewDefaults(int Client)
{

	//Initulize:
	g_Camera[Client] = 0;
}

//Spawn or OnClinetDisconnect(Client)
public void ResetClientViewAngle(int Client)
{

	//Is Valid:
	if(g_Camera[Client] != 0)
	{

		//Client View:
		SetClientViewEntity(Client, Client);

		//Is Valid:
		if(IsValidEdict(g_Camera[Client]))
		{

			//Accept:
			RemoveEdict(g_Camera[Client]);
		}

		//Initulize:
		g_Camera[Client] = 0;
	}
}

//Event Player Killed
public void OnClientDiedSetViewAngle(int Client)
{

	//Check:
	if(Client != -1 || IsClientInGame(Client) || IsClientConnected(Client))
	{

		//Ignore Fake Clients
		if(IsFakeClient(Client))

		{

			//Return:
			return;
		}

		//Is Valid:
		if(!ThirdPerson[Client])
		{

			//Get Ragdoll:
			int Ent = GetEntPropEnt(Client, Prop_Send, "m_hRagdoll");

			//Is Valid:	
			if(Ent > 0 && IsValidEdict(Ent))
			{

				//Is Dissolving
				if(GetEntityFlags(Ent) & FL_DISSOLVING)
				{
 				}

				//Override:
				else
				{
					//Attach View:
					SpawnCamAndAttach(Client, Ent);
				}
			}
		}
	}
}

//Attach new View Angle
public bool SpawnCamAndAttach(int Client, int Ragdoll)
{

	//Declare:
	char StrModel[64];

	//Format:
	Format(StrModel, sizeof(StrModel), "models/blackout.mdl");

	//Is Valid:
	if(!IsModelPrecached(StrModel))
	{

		//Precache:
		PrecacheModel(StrModel, true);
	}

	//Declare:
	char StrName[64];

	//Format:
	Format(StrName, sizeof(StrName), "fpd_Ragdoll%d", Client);

	//Dispatch:
	DispatchKeyValue(Ragdoll, "targetname", StrName);

	//Declare:
	int Entity = CreateEntityByName("prop_dynamic");

	//Is Valid:
	if(Entity == -1)
	{

		//Return:
		return false;
	}

	//Declare:
	char StrEntityName[64];

	//Format:
	Format(StrEntityName, sizeof(StrEntityName), "fpd_RagdollCam%d", Entity);

	//Dispatch:
	DispatchKeyValue(Entity, "targetname", StrEntityName);
	DispatchKeyValue(Entity, "parentname", StrName);
	DispatchKeyValue(Entity, "model", StrModel);
	DispatchKeyValue(Entity, "solid", "0");
	DispatchKeyValue(Entity, "rendermode", "10");
	DispatchKeyValue(Entity, "disableshadows", "1");

	//Declare:
	float angles[3];

	//Initulize:
	GetClientEyeAngles(Client, angles);

	//Declare:
	char CamTargetAngles[64];

	//Format:
	Format(CamTargetAngles, 64, "%f %f %f", angles[0], angles[1], angles[2]);

	//Dispatch:
	DispatchKeyValue(Entity, "angles", CamTargetAngles); 

	//Set Model:
	SetEntityModel(Entity, StrModel);

	//Spawn:
	DispatchSpawn(Entity);

	//Attatch:
	SetVariantString(StrName);

	//Accept:
	AcceptEntityInput(Entity, "SetParent", Entity, Entity, 0);

	// Set attachment
	SetVariantString("Eyes");

	//Accept:
	AcceptEntityInput(Entity, "SetParentAttachment", Entity, Entity, 0);

	//Accept:
	AcceptEntityInput(Entity, "TurnOn");

	//Client View:
	SetClientViewEntity(Client, Entity);

	//Initulize:
	g_Camera[Client] = Entity;

	//Return:
	return true;
}

public Action Command_FirstPerson(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(ThirdPerson[Client])
	{

		//Initulize:
		int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

		//Check:
		if(InVehicle != -1)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot use this command whilst in a Vehicle.");

			//Return:
			return Plugin_Handled;
		}

		//Initulize:
		ThirdPerson[Client] = false;

		//Send:
		SetEntPropEnt(Client, Prop_Send, "m_hObserverTarget", -1);
		SetEntProp(Client, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(Client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(Client, Prop_Send, "m_iFOV", 90);

		//Declare:
		char valor[6];

		//Get Server ConVar Value:
		GetConVarString(GetForceCameraConVar(), valor, 6);

		//Send Client ConVar:
		SendConVarValue(Client, GetForceCameraConVar(), valor);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Toggled FirstPerson!");
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already Toggled FirstPerson!");
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_ThirdPerson(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(!ThirdPerson[Client])
	{

		//Initulize:
		int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

		//Check:
		if(InVehicle != -1)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot use this command whilst in a Vehicle.");

			//Return:
			return Plugin_Handled;
		}

		//Initulize:
		ThirdPerson[Client] = true;

		//Send:
		SetEntPropEnt(Client, Prop_Send, "m_hObserverTarget", Client);
		SetEntProp(Client, Prop_Send, "m_iObserverMode", 5);
		SetEntProp(Client, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(Client, Prop_Send, "m_iFOV", 90);

		//Send Client ConVar:
		SendConVarValue(Client, GetForceCameraConVar(), "1");

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Toggled ThirdPerson!");
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already Toggled ThirdPerson!");
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_ResetView(int Client, int Args)
{

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Reset View!");

	RemoveObserverView(Client);

	//Set First Person
	SetThirdPersonView(Client, false);

	//Return:
	return Plugin_Handled;
}

public bool GetThirdPersonView(int Client)
{

	//Return:
	return view_as<bool>(ThirdPerson[Client]);
}

public void SetThirdPersonView(int Client, bool Result)
{

	//Ignore Fake Clients
	if(IsFakeClient(Client))

	{

		//Return:
		return;
	}

	//Initulize:
	ThirdPerson[Client] = Result;

	//Check:
	if(Result == true)
	{

		//Send:
		SetEntPropEnt(Client, Prop_Send, "m_hObserverTarget", Client);
		SetEntProp(Client, Prop_Send, "m_iObserverMode", 5);
		SetEntProp(Client, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(Client, Prop_Send, "m_iFOV", 90);

		//Send Client ConVar:
		SendConVarValue(Client, GetForceCameraConVar(), "1");
	}

	//Override:
	else
	{

		//Send:
		SetEntPropEnt(Client, Prop_Send, "m_hObserverTarget", -1);
		SetEntProp(Client, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(Client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(Client, Prop_Send, "m_iFOV", 90);

		//Declare:
		char valor[6];

		//Get Server ConVar Value:
		GetConVarString(GetForceCameraConVar(), valor, 6);

		//Send Client ConVar:
		SendConVarValue(Client, GetForceCameraConVar(), valor);
	}
}

//Reset:
public void ResetClientHud(int Client)
{

	//Declare:
	int hud = GetEntProp(Client, Prop_Send, "m_iHideHUD");

	//Initulize:
	hud &= ~1;
	hud &= ~256;
	hud &= ~1024;

	//Send:
	SetEntProp(Client, Prop_Send, "m_iHideHUD", hud);

	int EntEffects = GetEntProp(Client, Prop_Send, "m_fEffects");

	//Initulize:
	EntEffects &= ~32;

	//Declare:
	SetEntProp(Client, Prop_Send, "m_fEffects", EntEffects);

	//Initulize:
	SetClientViewEntity(Client, Client);

	SendConVarValue(Client, FindConVar("sv_Client_predict"), "1");
}

public bool IsClientInThirdPersonMode(int Client)
{

	//Return:
	return view_as<bool>(ThirdPerson[Client]);
}

public bool IsInView(int Client)
{

	//Initulize:
	int Ent = GetEntPropEnt(Client, Prop_Data, "m_hViewEntity");

	//Check:
	if(IsValidEdict(Ent))
	{

		//Declare:
		char ClassName[32];

		//Initulize:
		GetEdictClassname(Ent, ClassName, sizeof(ClassName));

		//Check:
		if(StrEqual(ClassName, "point_viewcontrol"))
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public void OnViewEnd(const char[] output, int caller, int activator, float delay)
{

	//Loop:
	for (int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected
		if(IsClientConnected(Client) && IsClientInGame(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			int Ent = GetEntPropEnt(Client, Prop_Data, "m_hViewEntity");

			//Check
			if(Ent == caller)
			{
				
				if(GetEntPropEnt(Ent, Prop_Data, "m_hPlayer") != Client)
				{

					//Initulize:
					SetEntPropEnt(Ent, Prop_Data, "m_hPlayer", Client);

					//Accept:
					AcceptEntityInput(Ent, "Disable");
				}
			}
		}
	}
}