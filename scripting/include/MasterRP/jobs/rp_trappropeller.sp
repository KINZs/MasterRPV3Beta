//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_trappropeller_included_
  #endinput
#endif
#define _rp_trappropeller_included_

char TrapBaseModel[256] = "models/props_c17/TrapPropeller_Engine.mdl";
char TrapPropellerModel[256] = "models/props_c17/trappropeller_blade.mdl";

public void initTrapPropeller()
{

	//Commands:
	RegConsoleCmd("sm_createtrappropeller", Command_CreateTrapPropeller);
}

//allows player to create a trap propeller
public Action Command_CreateTrapPropeller(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Position[3];
	float Angles[3] = {0.0,...};

	//Initulize:
	GetEntPropVector(Client, Prop_Data, "m_vecOrigin", Position);

	CreateTrap(Position, Angles, true);

	//Return:
	return Plugin_Handled;
}

public int CreateTrap(float Position[3], float Angles[3], bool IsOn)
{

	//Declare:
	int BaseEnt = CreateProp(Position, Angles, TrapBaseModel, false, true);

	Position[2] += 20.0;

	//Declare:
	int BladeEnt = CreateProp(Position, Angles, TrapPropellerModel, false, true);

	//Set String:
	SetVariantString("!activator");

	//Accept:
	AcceptEntityInput(BladeEnt, "SetParent", BaseEnt, BladeEnt, 0);

	//Set Owner
	SetEntPropEnt(BladeEnt, Prop_Send, "m_hOwnerEntity", BaseEnt);

	if(IsOn)
	{

		//Set Prop ClassName

		SetEntPropString(BladeEnt, Prop_Data, "m_iClassname", "RofleChopter");


		SDKHook(BladeEnt, SDKHook_StartTouch, SpinningBladeTouch);

		SDKHook(BladeEnt, SDKHook_Touch, SpinningBladeTouch);
	}

	//Set Prop ClassName

	SetEntPropString(BaseEnt, Prop_Data, "m_iClassname", "Prop_Trap_Spinning_Propeller");


	return BaseEnt;
}

public Action SpinningBladeTouch(int Entity, int OtherEntity)
{

	//InGame:
	if(OtherEntity > 0 && OtherEntity <= GetMaxClients() && IsClientInGame(OtherEntity))
	{

		//FakeClient:
		if(!IsFakeClient(OtherEntity))
		{

			//SDKHooks Forward:
			SDKHooks_TakeDamage(OtherEntity, Entity, Entity, 25.0, DMG_CLUB);
		}
	}

	//InGame:
	if(OtherEntity > GetMaxClients() && IsValidEdict(OtherEntity))
	{

		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(OtherEntity, ClassName, sizeof(ClassName));

		//Is Door:
		if(StrContains(ClassName, "npc_") != -1)
		{

			//SDKHooks Forward:
			SDKHooks_TakeDamage(OtherEntity, Entity, Entity, 25.0, DMG_CLUB);
		}
	}

	//Return:
	return Plugin_Continue;
}
