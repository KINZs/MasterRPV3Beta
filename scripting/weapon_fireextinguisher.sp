#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <customguns>


#define CLASSNAME "weapon_fireextinguisher"


int ExtinguisherEnt[MAXPLAYERS + 1] = -1;

public Plugin myinfo =

{

	name = "Weapon_FireExtinguisher",
	author = "Master(D)",
	description = "CustomGuns Weapon_FireExtinguisher Extension",
	version = "00.00.01",
	url = ""

};


public void CG_OnHolster(int Client, int weapon, int switchingTo)
{
	char sWeapon[32];
	GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));

	if(StrEqual(sWeapon, CLASSNAME))
	{
		if(IsValidEdict(ExtinguisherEnt[Client]) && ExtinguisherEnt[Client] > GetMaxClients())
		{
			//Accept:
			AcceptEntityInput(ExtinguisherEnt[Client], "Kill");
		}
		ExtinguisherEnt[Client] = -1;
	}
}



public void OnClientPostAdminCheck(int Client)
{
	if(IsValidEdict(ExtinguisherEnt[Client]) && ExtinguisherEnt[Client] > GetMaxClients())
	{
		//Accept:
		AcceptEntityInput(ExtinguisherEnt[Client], "Kill");
	}
	ExtinguisherEnt[Client] = -1;
}


//Disconnect:
public OnClientDisconnect(Client)
{
	if(IsValidEdict(ExtinguisherEnt[Client]) && ExtinguisherEnt[Client] > GetMaxClients())
	{

		//Accept:
		AcceptEntityInput(ExtinguisherEnt[Client], "Kill");
	}
	ExtinguisherEnt[Client] = -1;
}

public void CG_OnPrimaryAttack(int client, int weapon)
{

	char ClassName[32];
	GetEntityClassname(weapon, ClassName, sizeof(ClassName));
	if(StrEqual(ClassName, CLASSNAME))
	{

		CG_PlayActivity(weapon, ACT_VM_SECONDARYATTACK);
		
		CG_SetNextPrimaryAttack(weapon, GetGameTime() + 1);
		CG_SetNextSecondaryAttack(weapon, GetGameTime() + 1);

		EmitGameSoundToAll("Weapon_FireExtinguisher.Single", weapon);

		if(!IsValidEdict(ExtinguisherEnt[client]))
		{

			float ang[3];

			GetClientEyeAngles(client, ang);

			ExtinguisherEnt[client] = CreateEnvFireExtinguisher(client, client, "null", ang);
		}
	}

}

public Action OnPlayerRunCmd(int Client, int &Buttons, int &impulse, float vel[3], float angles[3])
{

	int Weapon = GetEntPropEnt(Client, Prop_Data, "m_hActiveWeapon");

	if(Client == 0 || Weapon == 0)

	{

		return Plugin_Handled;

	}

	char ClassName[32];
	GetClientWeapon(Client, ClassName, sizeof(ClassName));
	

	if(StrEqual(ClassName, CLASSNAME))
	{
		if(!(Buttons & IN_ATTACK2))
		{
			if(IsValidEdict(ExtinguisherEnt[Client]) && ExtinguisherEnt[Client] > GetMaxClients())
			{

				//Stop Charge Sound:
				StopExtinguisherSound(Weapon);

				//Accept:
				AcceptEntityInput(ExtinguisherEnt[Client], "Kill");
			}
			ExtinguisherEnt[Client] = -1;
		}
	}
	
	return Plugin_Continue;
}

void StopExtinguisherSound(int weapon)
{
	StopSound(weapon, SNDCHAN_WEAPON, "ambient/wind/wind_hit2.wav");
}


public int CreateEnvFireExtinguisher(int Ent, int Client, char[] Attachment, float Angles[3])
{

	//Declare:
	int Extinguisher = CreateEntityByName("env_steam");

	//Check:
	if(IsValidEdict(Extinguisher) && IsValidEdict(Extinguisher))
	{

		//Dispatch:
		DispatchKeyValue(Extinguisher, "SpawnFlags", "1");

		DispatchKeyValue(Extinguisher, "Type", "0");

		DispatchKeyValue(Extinguisher, "InitialState", "1");

		DispatchKeyValue(Extinguisher, "Spreadspeed", "20");

		DispatchKeyValue(Extinguisher, "Speed", "800");

		DispatchKeyValue(Extinguisher, "Startsize", "30");

		DispatchKeyValue(Extinguisher, "EndSize", "250");

		DispatchKeyValue(Extinguisher, "Rate", "40");

		DispatchKeyValue(Extinguisher, "JetLength", "200");

		DispatchKeyValue(Extinguisher, "RenderColor", "120 120 255");

		DispatchKeyValue(Extinguisher, "RenderAmt", "250");

		//Set Owner
		SetEntPropEnt(Extinguisher, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Extinguisher);

		//Declare:
		float Position[3];

		//Initulize:
		CG_GetShootPosition(Client, Position, 12.0, 8.0, -3.0);
		
		//Teleport:
		TeleportEntity(Extinguisher, Position, Angles, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Extinguisher, "SetParent", Ent, Extinguisher, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Extinguisher, "SetParentAttachment", Extinguisher, Extinguisher, 0);
		}

		//Spark:
		AcceptEntityInput(Extinguisher, "TurnOn");

		//Return:
		return Extinguisher;
	}

	//Return:
	return -1;
}

