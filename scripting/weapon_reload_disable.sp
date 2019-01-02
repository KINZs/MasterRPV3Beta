#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <customguns>

//Plugin Info:
public Plugin myinfo =
{
	name = "weapon_reload_disable",
	author = "Master(D)",
	description = "CustomGuns Extension",
	url = "",
	version = "00.00.01",
};

public void OnPluginStart()
{
	//Loop@
	for(int i= 1 ; i <= GetMaxClients(); i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
		{
			SDKHook(i, SDKHook_WeaponEquip, OnWeaponEquipt);
		}
	}
}

//Public Void OnClientPutInServer(int Client)
public void OnClientPostAdminCheck(int Client)
{

	//Check
	if(!IsFakeClient(Client))
	{
	
 		SDKHook(Client, SDKHook_WeaponEquip, OnWeaponEquipt);
	}
}

public Action OnWeaponEquipt(int client, int weapon)
{

	char ClassName2[32];
	GetEntityClassname(weapon, ClassName2, sizeof(ClassName2));

	PrintToServer("Client %N Switched to %s", client, ClassName2);
	if(StrEqual(ClassName2, "weapon_gauss") || StrEqual(ClassName2, "weapon_plasmagun") || StrEqual(ClassName2, "weapon_laser") || StrEqual(ClassName2, "weapon_superplasmagun"))
	{

		//Hook Weapon:
		SDKHook(weapon, SDKHook_Reload, OnReload);
	}
	
	return Plugin_Continue;
}

public Action OnReload(int weapon)
{
	return Plugin_Handled;
}
