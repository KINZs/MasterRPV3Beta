//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_critical_included_
  #endinput
#endif
#define _rp_critical_included_

bool IsCritical[2047] = {false,...};

//Health Manage:
public void initCriticalHealth(int Client)
{

	//Check:
	if(IsFakeClient(Client))
	{

		//Return
		return;
	}

	//Is Alive And Critical:
	if(!IsPlayerAlive(Client) && IsCritical[Client])
	{

		//Command:
		CheatCommand(Client, "r_screenoverlay", "0");

		//Initulize:
		IsCritical[Client] = false;

		//Declare:
		int Effect = GetEntAttatchedEffect(Client, 10);

		//Check:
		if(IsValidEntity(Effect))
		{

			//Accept:
			AcceptEntityInput(Effect, "kill");

			//Remove Index:
			SetEntAttatchedEffect(Client, 10, -1);
		}
	}

	//Initialize:
	int CHP = GetClientHealth(Client);

	//Is Already Critical:
	if(CHP <= 20 && IsPlayerAlive(Client))
	{
#if defined HL2DM
		//Check:
		if(IsPlayerPoisened(Client))
		{

			//Return:
			return;
		}
#endif
		//Declare:
		float Angles[3];

		//Initialize:
		GetClientEyeAngles(Client, Angles);

		//Effect:
		CreateEnvBlood(Client, "null", Angles, 1.0);

		//Check:
		if(CHP - 2 > 1)
		{

			//Play Hurt SOUND: forward to rp_talksounds.sp
			OnClientHurtSound(Client);

			//Set Client Health:
			SetEntityHealth(Client, (CHP - 2));
		}

		//Override:
		else
		{

			//Slay Client:
			ForcePlayerSuicide(Client);

			//Command:
			CheatCommand(Client, "r_screenoverlay", "0");

			//Initulize:
			IsCritical[Client] = false;

			//Declare:
			int Effect = GetEntAttatchedEffect(Client, 10);

			//Check:
			if(IsValidEntity(Effect))
			{

				//Accept:
				AcceptEntityInput(Effect, "kill");

				//Remove Index:
				SetEntAttatchedEffect(Client, 10, -1);
			}
		}
	}

	//Is Already Critical:
	if(CHP > 20 && CHP < 100)
	{

		//Enough Health:
		if((CHP + 1) > 100)
		{

			//Set Ent Health:
			SetEntityHealth(Client, 100);
		}

		//Override:
		else
		{

			//Set Ent Health:
			SetEntityHealth(Client, (CHP + 1));
		}
	}

	//Return
	return;
}

//Show Player Hud
public void ClientCriticalOverride(int Client)
{

	//Check:
	if(IsFakeClient(Client))
	{

		//Return
		return;
	}

	//Initialize:
	int CHP = GetClientHealth(Client);

	//Is Alive And Critical:
	if(!IsPlayerAlive(Client))
	{

		//Command:
		CheatCommand(Client, "r_screenoverlay", "0");

		//Initulize:
		IsCritical[Client] = false;

		//Declare:
		int Effect = GetEntAttatchedEffect(Client, 10);

		//Check:
		if(IsValidEntity(Effect))
		{

			//Accept:
			AcceptEntityInput(Effect, "kill");

			//Remove Index:
			SetEntAttatchedEffect(Client, 10, -1);
		}
	}

	//Is Already Critical:
	else if(CHP >= 20 && IsCritical[Client])
	{

		//Command:
		CheatCommand(Client, "r_screenoverlay", "0");

		//Initulize:
		IsCritical[Client] = false;

		//Declare:
		int Effect = GetEntAttatchedEffect(Client, 10);

		//Check:
		if(IsValidEntity(Effect))
		{

			//Accept:
			AcceptEntityInput(Effect, "kill");

			//Remove Index:
			SetEntAttatchedEffect(Client, 10, -1);
		}
	}

	//Is Already Critical:
	else if(CHP < 20 && IsCritical[Client] == false)
	{

		//Command:
		CheatCommand(Client, "r_screenoverlay", "effects/tp_eyefx/tpeye.vmt");

		//Declare:
		int Effect = GetEntAttatchedEffect(Client, 10);

		//Check:
		if(!IsValidEntity(Effect))
		{

			float Offset[3] = {0.0,0.0,80.0};
			Effect = CreateEnvSprite(Client, "null", "materials/bouncy/low_hp.vmt", "0.1", Offset, 255, 255, 255);

			SetEntAttatchedEffect(Client, 10, Effect);
		}

		//Initulize:
		IsCritical[Client] = true;
	}

	//Return
	return;
}

//Event Damage:
public void OnDamageCriticalCheck(int Client)
{

	//Check:
	if(IsFakeClient(Client))
	{

		//Return
		return;
	}

	//Initialize:
	int CHP = GetClientHealth(Client);

	//Is Already Critical:
	if(CHP <= 20)
	{

		//Command:
		CheatCommand(Client, "r_screenoverlay", "effects/tp_eyefx/tpeye.vmt");

		//Declare:
		int Effect = GetEntAttatchedEffect(Client, 10);

		//Check:
		if(!IsValidEntity(Effect))
		{

			float Offset[3] = {0.0,0.0,80.0};

			Effect = CreateEnvSprite(Client, "null", "materials/bouncy/low_hp.vmt", "0.1", Offset, 255, 255, 255);

			SetEntAttatchedEffect(Client, 10, Effect);
		}

		//Initulize:
		IsCritical[Client] = true;
	}

	//Return
	return;
}

public bool GetIsCritical(int Entity)
{

	//Return:
	return view_as<bool>(IsCritical[Entity]);
}

public bool SetIsCritical(int Entity, bool Result)
{

	//Inituluize:
	IsCritical[Entity] = Result;

	//Return:
	return view_as<bool>(IsCritical[Entity]);
}

public void ResetCritical(int Entity)
{

	IsCritical[Entity] = false;
}

public void ResetAllCritical()
{

	//Loop:
	for(int X = 0; X < 2047; X++)
	{

		//Inituluize:
		IsCritical[X] = false;
	}
}