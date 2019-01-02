//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_dhooksplayer_included_
  #endinput
#endif
#define _rp_dhooksplayer_included_

public void initDHooksPlayer()
{

}

public void initResetDhooksPlayer()
{

}

//Global Forward:
public void DHooksCallBack(int Client)
{

	//Pre Hook Types:
	//Client Hooking:
 	DHookEntity(hPreChangeTeam, false, Client);

	//Client Hooking:
 	DHookEntity(hPreEventKilled, false, Client);

	//Client Hooking:
 	DHookEntity(hPreSpawn, false, Client);

	//Client Hooking:
 	DHookEntity(hPreGiveNamedItem, false, Client);

	//Client Hooking:
 	DHookEntity(hPreWeaponEquip, false, Client);

	//Client Hooking:
 	DHookEntity(hPreWeaponDrop, false, Client);

	//Client Hooking:
 	DHookEntity(hPreDeathSound, false, Client);

	//Client Hooking:
 	DHookEntity(hPreThink, false, Client);

	//Client Hooking:
 	DHookEntity(hPreStartObserverMode, false, Client);

	//Client Hooking:
 	DHookEntity(hPreGetInVehicle, false, Client);

	//Client Hooking:
 	DHookEntity(hPreLeaveVehicle, false, Client);

	//Post Hook Types:
	//Client Hooking:
 	DHookEntity(hPostSpawn, true, Client);

	//Client Hooking:
 	DHookEntity(hPostThinkPost, true, Client);

	//Client Hooking:
 	DHookEntity(hPostWeaponEquip, true, Client);
}

// bool CMultiplayRules::ClientConnected(edict_t * pEntity, char const*, char const*, int)
public MRESReturn OnPreClientConnected(Handle hReturn, Handle hParams)
{

	//Declare:
	int Client = DHookGetParam(hParams, 1);

	//Check:
	if(GetModSetup() == false)
	{

		//Kick Player
		KickClient(Client, "You have Kicked from this server\nReason: %s", "Please wait for the server to setup");
	}

	//Return:
        return MRES_Ignored;
}

// void CHL2MPRules::ClientDisconnected(edict_t * pClient)
public MRESReturn OnPreClientDisconnected(Handle hParams)
{

	//Declare:
	int Client = DHookGetParam(hParams, 1);

	//Disconnect Message:
	OnClientDisconnectMessage(Client);

	//Save:
	DBSave(Client);

	//Disconnect Talkzone:
	initdisconnectphone(Client);

	//Remove Sleeping:
	ResetSleeping(Client);

	//Remove Sleeping:
	ResetCritical(Client);

	//SaveSpawnedItems:
	SaveSpawnedItemForward(Client, true);

	//Update Last Stats:
	UpdateLastStats(Client);

	//Reset Jetpack:
	StopJetPack(Client);

	//Remvove Money Safes:
	RemoveMoneySafeOnDisconnect(Client);

	//Reset Jump:
	initDefaultDoubleJump(Client);

	//Reset View Angle
	ResetClientViewAngle(Client);

	//Check:
	if(IsClientInGame(Client))
	{

		//Initulize:
		int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

		//Check:
		if(InVehicle != -1)
		{

			//Exit:
			ExitVehicle(Client, InVehicle, false);
		}
	}

	//Check:
	if(IsValidEdict(GetPlayerVehicle(Client)))
	{

		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(GetPlayerVehicle(Client), ClassName, sizeof(ClassName));

		//Override:
		if(!StrEqual(ClassName, "prop_vehicle_damaged"))
		{

			//Declare:
			int Driver = GetEntPropEnt(GetPlayerVehicle(Client), Prop_Send, "m_hPlayer");

			//Check:
			if(Driver == -1)
			{

				//Exit:
				ExitVehicle(Driver, GetPlayerVehicle(Client), false);
			}
		}

		//Accept:
		AcceptEntityInput(GetPlayerVehicle(Client), "kill");

		//Initulize:
		SetPlayerVehicle(Client, -1);
	}

	//Set Hit:
	SetHit(Client, 0);

	//Default Vehicle:
	SetPlayerVehicle(Client, -1);

	//Set Load State:
	SetIsLoaded(Client, false);

	//Set Out of Cosino:
	SetInCosino(Client, false);

	//Return:
        return MRES_Ignored;
}

public MRESReturn OnClientPreSpawn(int Client, Handle hParams)
{

	//Check:
	if(IsValidAttachedEffect(Client))
	{

		//Remove:
		RemoveAttachedEffect(Client);
	}

	//Reset Critical:
	ResetCritical(Client);

	//Reset View Angle
	ResetClientViewAngle(Client);

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnClientPreEventKilled(int Client, Handle hParams, int &Attacker, int &Inflictor, int &Weapon, float &Damage, int &DamageType, const float DamageForce[3], const float DamagePosition[3])
{

	//Clear Drug Tick:
	ResetDrugs(Client);

	//Hangup Phone:
	OnCliedDiedHangUp(Client);

	//Reset Critical:
	ResetCritical(Client);

	//Remove Sleeping:
	ResetSleeping(Client);

	//Reset Protection to prevent bugs:
	RemoveProtectTimer(Client);

	//Remove Health Sprite!
	ClientCriticalOverride(Client);

	//Check:
	if(IsValidAttachedEffect(Client))
	{

		//Remove:
		RemoveAttachedEffect(Client);
	}

	//Declare:
	int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Has Driver:
	if(InVehicle != -1)
	{

		//Exit Car:
		ExitVehicle(Client, InVehicle, false);
	}

	//Timer
	CreateTimer(0.0, PostClientEventKilled, Client);

	//Return:
	return MRES_Ignored;
}

public Action PostClientEventKilled(Handle Timer, any Client)
{

	//Check:
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Check:
		if(IsValidEdict(GetPlayerHatEnt(Client)))
		{

			//Declare:
			int RagDoll = GetEntPropEnt(Client, Prop_Send, "m_hRagdoll");
			int Flags = GetEntityFlags(RagDoll);

			//Button Used:
			if(Flags &= FL_DISSOLVING)
			{

				//Dissolve:
				EntityDissolve(GetPlayerHatEnt(Client), 3);
			}

			//Override:
			else
			{

				//Remove Player Hat:
				OnClientDiedThrowPhysHat(Client);
			}
		}

		//Set First Person Death
		OnClientDiedSetViewAngle(Client);

		//Command:
		CheatCommand(Client, "r_screenoverlay", "debug/yuv.vmt");

		//Fix Team Score:
		SetTeamScore(3,0);
		SetTeamScore(2,0);
		SetTeamScore(1,0);
	}
}

public MRESReturn OnClientPreChangeTeam(int Client, Handle hParams, int Team)
{

	//Check:
	if(!IsCop(Client) && (IsAdmin(Client) || GetDonator(Client) > 0) && Team != 3) 
	{

		//Initulize:
		ChangeClientTeamEx(Client, 3);

		DHookSetParam(hParams, 1, 3);
	}

	//Is Client Cop:
	else if(IsCop(Client) && Team != 2)
	{

		//Initulize:
		DHookSetParam(hParams, 1, 2);
	}

	//Override:
	else if(Team != 3)
	{

		//Initulize:
		DHookSetParam(hParams, 1, 3);
	}

	//Return:
	return MRES_Override;
}

public MRESReturn OnPreClientGiveNamedItem(int Client, Handle hReturn, Handle hParams, const char[] WeaponName, int Weapon, int Unknown)
{

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, GetWeaponModPath());

	//Get Value
	int IsCustomGuns = LoadInteger(Vault, WeaponName, "CustomGuns", 1);

	//Close:
	CloseHandle(Vault);

	//Check Is Not a Custom Gun:
	if(IsCustomGuns == 0)
	{

		//Check:
		if(CanClientWeaponEquip(Client) == false)
		{

			//Set Return:
			DHookSetReturn(hReturn, 0);

			//Return:
			return MRES_Supercede;
		}
	}

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreClientWeaponEquip(int Client, Handle hParams, int Weapon)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Weapon, ClassName, sizeof(ClassName));

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, GetWeaponModPath());

	//Get Value
	int IsCustomGuns = LoadInteger(Vault, ClassName, "CustomGuns", 1);

	//Close:
	CloseHandle(Vault);

	//Print:
	//PrintToConsole(Client, "|RP| - %N Weapon = %s, Index = %i, Custom = %i!", Client, ClassName, Weapon, CustomGuns);

	//Check Is Not a Custom Gun:
	if(IsCustomGuns == 0)
	{

		//Check:
		if(CanClientWeaponEquip(Client) == false)
		{

			//Remove Clean:
			RemoveWeapon(Weapon);

			//Return:
			return MRES_Supercede;
		}
	}

	//Valid Check:
	if(StrContains(ClassName, "weapon_physcannon", false) != -1)
	{

		//Add Extra Slots:
		if(GetItemAmount(Client, 306) > 0)
		{

			//Set Color:
			SetEntityRenderColor(Weapon, 100, 100, 255, 255);

			//Set Effect:
			SetEntityRenderMode(Weapon, RENDER_GLOW);
		}
	}
#if defined HL2DM
	//Valid Check:
	if(StrContains(ClassName, "weapon_golden357", false) != -1)
	{

		//Set Color:
		SetEntityRenderColor(Weapon, 255, 255, 150, 255);

		//Set Effect:
		SetEntityRenderMode(Weapon, RENDER_GLOW);
	}
#endif
	//Send:
	SetEntPropEnt(Weapon, Prop_Data, "m_hOwner", Client);
	SetEntPropEnt(Weapon, Prop_Data, "m_hOwnerEntity", Client);

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreClientWeaponDrop(int Client, Handle hParams)
{

	//Check:
	if(!IsCop(Client) || (IsCop(Client) && !IsCopWeaponDropDisabled()))
	{

		//Declare:
		char ClientWeapon[32];

		//Get Entity Info:
		GetClientWeapon(Client, ClientWeapon, sizeof(ClientWeapon));

		//Loose Weapon:
		//int Weapon = WeaponDrop(Client, ClientWeapon, 2);
		WeaponDrop(Client, ClientWeapon, 2);

		//Print:
		//PrintToServer("|RP| - %N Weapon %s = Index = %i!", Client, ClientWeapon, Weapon);
	}

	//Return:
	return MRES_Supercede;
}

public MRESReturn OnClientPreDeathSound(int Client, Handle hParams, int &Attacker, int &Inflictor, int &Weapon, float &fDamage, int &DamageType, const float DamageForce[3], const float DamagePosition[3])
{

	//Check:
	if(IsLoaded(Client) == false)
	{

		//Return:
		return MRES_Supercede;
	}
#if defined HL2DM
	//Declare:
	char DeathSound[128] = "Null";

	int Random = -1;

	//IsCop:
	if(IsCop(Client))
	{

		//Is Elite Combine!
		if(StrContains(GetModel(Client), "combine", false) != -1)
		{

			//Declare:
			Random = GetRandomInt(1, 4);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "npc/combine_soldier/die%i.wav", Random);

		}

		//Override:
		else
		{

			//Declare:
			Random = GetRandomInt(1, 4);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "npc/metropolice/die%i.wav", Random);
		}
	}

	//Override:
	else
	{

		//Is Female:
		if(StrContains(GetModel(Client), "female", false) != -1)
		{

			//Initialize:
			Random = GetRandomInt(1, 2);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/npc/female01/ow0%i.wav", Random);
		}

		//Is Female:
		if(StrContains(GetModel(Client), "male", false) != -1)
		{

			//Initialize:
			Random = GetRandomInt(1, 2);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/npc/male01/ow0%i.wav", Random);
		}

		//Is Alyx!
		if(StrContains(GetModel(Client), "alyx", false) != -1)
		{

			//Initialize:
			Random = GetRandomInt(4, 8);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/npc/alyx/hurt0%i.wav", Random);
		}

		//Is Barney!
		if(StrContains(GetModel(Client), "barney", false) != -1)
		{

			//Initialize:
			Random = GetRandomInt(1, 9);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/npc/barney/ba_pain0%i.wav", Random);
		}

		//Is Monk!
		if(StrContains(GetModel(Client), "monk", false) != -1)
		{

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/ravenholm/monk_death07.wav");
		}

		//Is Gman!
		if(StrContains(GetModel(Client), "kleiner", false) != -1)
		{

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/k_lab/kl_ahhhh.wav");
		}

		//Is Gman!
		if(StrContains(GetModel(Client), "gman", false) != -1)
		{

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/citadel/gman_exit10.wav");
		}


		//Is Breen!
		if(StrContains(GetModel(Client), "breen", false) != -1)
		{

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/citadel/br_ohshit.wav");
		}

		//Override:
		else if(StrEqual(DeathSound, "Null"))
		{

			//Initialize:
			Random = GetRandomInt(1, 2);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/npc/male01/ow0%i.wav", Random);
		}
	}

	//Check:
	if(DamageType == DMG_FALL)
	{

		//Initialize:
		Random = GetRandomInt(1, 3); if(Random == 2) Random = 3;

		//Format:
		Format(DeathSound, sizeof(DeathSound), "Player/pl_fallpain%i.wav", Random);
	}

	//Check:
	if(DamageType == DMG_DROWN)
	{

		//Initialize:
		Random = GetRandomInt(1, 3);

		//Format:
		Format(DeathSound, sizeof(DeathSound), "Player/pl_drown%i.wav", Random);
	}

	//Check:
	if(DamageType == DMG_DROWN)
	{

		//Initialize:
		Random = GetRandomInt(1, 3);

		//Format:
		Format(DeathSound, sizeof(DeathSound), "Player/pl_drown%i.wav", Random);
	}

	//Print:
	//PrintToServer("|RP| - %N DeathSound %s !", Client, DeathSound);

	//Check:
	if(!StrEqual(DeathSound, "Null"))
	{

		//Declare
		float vecPos[3];

		//Initulize:
		GetClientAbsOrigin(Client, vecPos);

		//Is Precached:
		if(IsSoundPrecached(DeathSound)) PrecacheSound(DeathSound);

		//Emit Sound:
		EmitSoundToAll(DeathSound, Client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, SNDPITCH_NORMAL, -1, vecPos, NULL_VECTOR, true, 0.0);
	}

	//Check:
	if(DamageType == DMG_DISSOLVE)
	{

		//Declare
		float vecPos[3];

		//Initulize:
		GetClientAbsOrigin(Client, vecPos);

		//Initialize:
		Random = GetRandomInt(5, 9);

		//Format:
		Format(DeathSound, sizeof(DeathSound), "ambient/energy/zap%i.wav", Random);

		//Is Precached:
		if(IsSoundPrecached(DeathSound)) PrecacheSound(DeathSound);

		//Emit Sound:
		EmitSoundToAll(DeathSound, Client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, SNDPITCH_NORMAL, -1, vecPos, NULL_VECTOR, true, 0.0);
	}
#endif
	ClientCriticalOverride(Client);

	//Return:
	return MRES_Supercede;
}

public MRESReturn OnPreClientStartTouch(int Client, Handle hParams, int OtherEntity)
{

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreClientTouch(int Client, Handle hParams, int OtherEntity)
{

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreClientEndTouch(int Client, Handle hParams, int OtherEntity)
{

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnClientPreThinkPre(int Client, Handle hParams)
{

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreClientStartObserverMode(int Client, Handle hReturn, Handle hParams, int Mode, bool Result)
{

	//Set Return:
	DHookSetReturn(hReturn, Result);

	//Return:
	return MRES_Supercede;
}

public MRESReturn OnClientGetInVehicle(int Client, bool Result, Handle hParams)
{

	if(GetThirdPersonView(Client))
	{

		//Initulize:
		SetThirdPersonView(Client, false);

		//Print:
		PrintToConsole(Client, "|RP| - Set Back To First Person");
	}

	//Return:
	return OnClientGetInVehicleForward(Client);
}

public MRESReturn OnClientLeaveVehicle(int Client, Handle hParams)
{

	//Declare:
	int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Return:
	return OnClientLeaveVehicleForward(Client, InVehicle);
}

public MRESReturn OnClientPostSpawn(int Client, Handle hParams)
{

	//Check:
	if(IsLoaded(Client))
	{

		//Is Cuffed:
		if(IsCuffed(Client))
		{

			//Cuff:
			Cuff(Client);

			//Jail:
			JailClient(Client, Client);
		}

		//Override:
		else
		{

			//Spawn Client:
			InitSpawnPos(Client, 1);

			//Setup Roleplay Job:
			SetupRoleplayJob(Client);
		}
	}

	//Timer
	CreateTimer(0.1, PostClientSpawned, Client);

	//Reset Overlay:
	ResetClientOverlay(Client);

	//Set Score:
	SetClientHours(Client);

	//Return:
	return MRES_Ignored;
}

public Action PostClientSpawned(Handle Timer, any Client)
{

	//Check:
	if(!StrEqual(GetHatModel(Client), "null"))
	{

		//Create Hat:
		CreateHat(Client, GetHatModel(Client));
	}

	//Start Spawn Protection:
	StartSpawnProtect(Client);

	//Create Player Trail Effects:
	CreatePlayerTrails(Client);
}

public MRESReturn OnClientPostThinkPost(int Client, Handle hParams)
{
#if defined HL2DM
	//Is Client Cuffed:
	if(IsCuffed(Client) || GetIsCritical(Client) || IsSleeping(Client) > 0)
	{

		//Set Suit:
		SetEntPropFloat(Client, Prop_Send, "m_flSuitPower", 0.0);

		SetEntPropFloat(Client, Prop_Data, "m_flSuitPowerLoad", 0.0);
	}
#endif
	//Doublejump Check:
	OnClientPostThinkDoubleJumpCheck(Client);

	//Fix Client View:
	OnClientPostThinkPostVehicleViewFix(Client);

	//Return:
	return MRES_Ignored; 
}

public MRESReturn OnPostClientWeaponEquip(int Client, Handle hParams, int Weapon)
{

	//Set Ammo!
	SetEquipAmmo(Client, Weapon);

	//Return:
	return MRES_Ignored;
}
