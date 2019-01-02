#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <customguns>

int GrenadeAmmo[MAXPLAYERS + 1];

//Plugin Info:
public Plugin myinfo =
{
	name = "Ammo Extension for CustomGuns",
	author = "Master(D)",
	description = "CustomGuns Extension",
	url = "",
	version = "00.00.01",
};

public void OnPluginStart()
{

	for(int i= 1 ; i <= GetMaxClients(); i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
			SDKHook(i, SDKHook_WeaponSwitch, OnWeaponSwitch);
			GrenadeAmmo[i] = 0;
		}
	}
}

//Public Void OnClientPutInServer(int Client)
public void OnClientPostAdminCheck(int Client)
{
		GrenadeAmmo[Client] = 0;
 		SDKHook(Client, SDKHook_WeaponSwitch, OnWeaponSwitch);
}

//EventDeath Farward:
public Action EventDeath_Forward(Event event, const char [] name, bool dontBroadcast)
{

	//Initialize:
	//int Client = GetClientOfUserId(event.GetInt(Event, "userid"));

	//int Attacker = GetClientOfUserId(event.GetInt(Event, "attacker"));
}

//EventDeath Farward:
public Action Eventspawn_Forward(Event event, const char [] name, bool dontBroadcast)
{

	//Initialize:
	//int Client = GetClientOfUserId(event.GetInt(Event, "userid"));
}

public Action OnWeaponSwitch(int Client, int weapon)
{

	char ClassName[32];
	GetEntityClassname(weapon, ClassName, sizeof(ClassName));

	PrintToServer("Client %N switched to %s", Client, ClassName);

	if(StrEqual(ClassName, "weapon_plasmagun") || StrEqual(ClassName, "weapon_gauss") || StrEqual(ClassName, "weapon_laser") || StrEqual(ClassName, "weapon_superplasmagun"))
	{
	

		PrintToServer("is custom");
		
		//Check:
		if(GrenadeAmmo[Client] < 1)
		{

			//Declare:
			//int Ammo = getWeaponAmmo(Client);
			int Ammo = getGrenadeAmmo(Client);
			
			SetAmmo(Client, "weapon_flag", 0);
			
			setWeaponAmmo(Client, 0, "weapon_flag");
			
			//Initulize:
			GrenadeAmmo[Client] = Ammo;
			
			PrintToServer("ammo = %i", Ammo);
		}
	}

	//Override:
	else if(GrenadeAmmo[Client] > 0)
	{
	
		//Add Ammo:
		AddAmmo(Client, "weapon_flag", GrenadeAmmo[Client], 10);
			
		PrintToServer("ammo = %i", GrenadeAmmo[Client]);
		
		//Initialize:
		GrenadeAmmo[Client] = 0;
	}
	
	
	return Plugin_Continue;
}

public Action OnWeaponEquip(client, weapon)
{

	char ClassName2[32];
	GetEntityClassname(weapon, ClassName2, sizeof(ClassName2));

	PrintToServer("Client %N equipted to %s", client, ClassName2);
	
	return Plugin_Continue;
}

public void AddAmmo(int Client, const char[] Name, int Amount, int MaxAmmo)
{

	//Declare:
	int Ent = HasClientWeapon(Client, Name);

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Declare:
		int offset_ammo = FindDataMapInfo(Client, "m_iAmmo");

		int iPrimary = GetEntProp(Ent, Prop_Data, "m_iPrimaryAmmoType");

		int iAmmo = offset_ammo + (iPrimary * 4);

		int CurrentAmmo = GetEntData(Client, iAmmo, 4);

		//Full Click
		if(iAmmo != MaxAmmo)
		{

			//Check
			if(CurrentAmmo + Amount > MaxAmmo)
			{

				//Set Ammo:
				SetEntData(Client, iAmmo, MaxAmmo, 4, true);
			}

			//Override:
			else
			{

				//Set Ammo:
				SetEntData(Client, iAmmo, CurrentAmmo + Amount, 4, true);
			}
		}
	}
}

public void SetAmmo(int Client, const char[] Name, int Amount)
{

	//Declare:
	int Ent = HasClientWeapon(Client, Name);

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Declare:
		int offset_ammo = FindDataMapInfo(Client, "m_iAmmo");

		int iPrimary = GetEntProp(Ent, Prop_Data, "m_iPrimaryAmmoType");

		int iAmmo = offset_ammo + (iPrimary * 4);

		//Set Ammo:
		SetEntData(Client, iAmmo, Amount, 4, true);
	}
}
public int GetAmmo(int Client, const char[] Name)
{

	//Declare:
	int Ent = HasClientWeapon(Client, Name);

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Declare:
		int offset_ammo = FindDataMapInfo(Client, "m_iAmmo");

		int iPrimary = GetEntProp(Ent, Prop_Data, "m_iPrimaryAmmoType");

		int iAmmo = offset_ammo + (iPrimary * 4);

		return GetEntData(Client, iAmmo, 4);
	}
	
	return -1;
}

public int HasClientWeapon(int Client, const char[] WeaponName)
{

	//Declare:
	int MaxGuns = 64;
	int WeaponOffset = FindSendPropInfo("CHL2MP_Player", "m_hMyWeapons");

	//Loop:
	for(int X = 0; X < MaxGuns; X = (X + 4))
	{

		//Declare:
		int WeaponId = GetEntDataEnt2(Client, (WeaponOffset + X));

		//Is Valid:
		if(WeaponId > 0)
		{

			//Declare:
			char ClassName[32];

			//Initialize:
			GetEdictClassname(WeaponId, ClassName, sizeof(ClassName));

			//Is Valid:
			if(StrEqual(ClassName, WeaponName))
			{

				//Return:
				return WeaponId;

			}
		}
	}

	//Return:
	return -1;
}

stock int getGrenadeAmmo(int Client)
{

	int Weapon = HasClientWeapon(Client, "weapon_flag");

	if(IsValidEdict(Weapon))
	{

		return GetEntProp(Weapon, Prop_Send, "m_iClip1");
	}
	
	return -1;
}
