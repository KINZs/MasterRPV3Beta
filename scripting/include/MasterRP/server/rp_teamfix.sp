//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_teamfix_included_
  #endinput
#endif
#define _rp_teamfix_included_

//ManageTeams:
public void initManageClientTeam()
{

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected: only set team when client is fully connected and joined the server
		if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client) && IsLoaded(Client))
		{

			//Prevent model setting when player is dead. also prevents bug!
			if(IsPlayerAlive(Client) && !IsFakeClient(Client))
			{

				//Client Team Fix Plugin:
				OnManageClientTeam(Client);

				//Init Random Cough Sound:
				initCough(Client);
			}

			//Check Health
			initCriticalHealth(Client);
		}
	}
}

//ManageTeams:
public void OnManageClientTeam(int Client)
{

	//Declare: save players sequance to stop animation spam
	int Sequence = GetEntProp(Client, Prop_Send, "m_nSequence");

	//Change Team:
	ChangeClientTeamInt(Client);

	//Set Model:
	SetClientModelInt(Client);

	//Declare:
	SetEntProp(Client, Prop_Send, "m_nSequence", Sequence);

}

public void ChangeClientTeamInt(int Client)
{

	//Ignore Fake Clients
	if(IsFakeClient(Client))

	{

		//Return:
		return;
	}

	//Declare:
	int LifeState = GetEntProp(Client, Prop_Send, "m_lifeState");

	//Send:
	SetEntProp(Client, Prop_Send, "m_lifeState", 2);

	//Check:
	if(GetGame() == 1)
	{

		//Check: // unsure if this works in other games extra teams, as team 1 is normally used for spectator
		if(!IsCop(Client) && (IsAdmin(Client) || GetDonator(Client) > 0)) 
		{

			//Initulize:
			ChangeClientTeamEx(Client, 3);

			ChangeClientTeam(Client, 3);

			ChangeClientTeamEx(Client, 1);
		}

		//Is Client Cop: //dont remove the else or causes bug!
		else if(IsCop(Client))
		{

			//Initulize:
			ChangeClientTeamEx(Client, 2);

			ChangeClientTeam(Client, 2);
		}

		//Override:
		else
		{

			//Initulize:
			ChangeClientTeamEx(Client, 3);

			ChangeClientTeam(Client, 3);
		}
	}

	//Override: // Multi game includes:
	else
	{

		//Is Client Cop:
		if(IsCop(Client))
		{

			//Initulize:
			ChangeClientTeamEx(Client, 2);
#if defined DEFAULT
			ChangeClientTeam(Client, 2);
#endif
#if defined CSS
			CS_SwitchTeam(Client, 2);
#endif
#if defined CSGO
			CS_SwitchTeam(Client, 2);
#endif
#if defined TF2
			TF2_ChangeClientTeam(Client, TFTeam_Red);
#endif
#if defined TF2BETA
			TF2_ChangeClientTeam(Client, TFTeam_Red);
#endif
#if defined L4D
			ChangeClientTeam(Client, 2);
#endif
#if defined L4D2
			ChangeClientTeam(Client, 2);
#endif
		}

		//Override:
		else
		{

			//Initulize:
			ChangeClientTeamEx(Client, 3);
#if defined DEFAULT
			ChangeClientTeam(Client, 3);
#endif
#if defined CSS
			CS_SwitchTeam(Client, 3);
#endif
#if defined CSGO
			CS_SwitchTeam(Client, 3);
#endif
#if defined TF2
			TF2_ChangeClientTeam(Client, TFTeam_Blue);
#endif
#if defined TF2BETA
			TF2_ChangeClientTeam(Client, TFTeam_Blue);
#endif
#if defined L4D
			ChangeClientTeam(Client, 3);
#endif
#if defined L4D2
			ChangeClientTeam(Client, 3);
#endif
		}
	}

	//Send:
	SetEntProp(Client, Prop_Send, "m_lifeState", LifeState);
}

public void SetClientModelInt(int Client)
{

	//Declare:
	char ModelName[256];

	//Initialize:
	GetEntPropString(Client, Prop_Data, "m_ModelName", ModelName, 128);

	//Is PreCached:
	if(!IsModelPrecached(GetModel(Client)))
	{

		//PreCache:
		PrecacheModel(GetModel(Client));
	}

	//Check:
	if(!StrEqual(GetModel(Client), ModelName))
	{

		//Initialize:
		SetEntityModel(Client, GetModel(Client));
	}
}