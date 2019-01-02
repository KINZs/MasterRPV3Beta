//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_forwards_included_
  #endinput
#endif
#define _rp_forwards_included_
#if defined HL2DM
//Sprint Bit Device:
#define SUIT_SPRINT_DEVICE	0x00000001
#endif

//MasterRP Forwards:
Handle ChatForward = INVALID_HANDLE;
Handle CvarForward = INVALID_HANDLE;

//Anti Spam:
int PrethinkBuffer[MAXPLAYERS + 1] = {0,...};
int ForceSwitch[MAXPLAYERS + 1] = {0,...};

//Map Running
bool MapRunning = false;
bool ModSetup = false;
bool CustomGuns = false;

//Plugin Info:
public Plugin myinfo =
{
	name = "Realistic Roleplay mod",
	author = "Master(D)",
	description = "Main Plugin",
	version = MAINVERSION,
	url = ""
};

char MainVersion()
{

	//Declare:
	char info[64];

	//Format:
	Format(info, sizeof(info), "%s", MAINVERSION);

	//Return:
	return info;
}

//Initation:
public void OnPluginStart()
{

	//Print Server If Plugin Start:
	PrintToConsole(0, "|RolePlay| Core Successfully Loaded (v%s)!", MainVersion());

	//Setup Sql Connection:
	initSQL();

	//Check What game we are running!
	initGameFolder();

	//DHooks Init
	initDHooks();

	//SDK Init
	initSDKTools();

	initWeaponMod();

	initDHooksPlayer();

	OnPluginStartRP_Native();

	InitPrecache();

	//Spawn Plugin:
	initSpawn();

	initCvar();

	initStock();

	initMoneySafe();

	initServerMoneySafe();

	initNoKillZone();

	initForwards();

	initRandomCrate();

	initPoliceDoors();

	initVipDoors();

	initAdminDoors();

	initFireFighterDoors();

	initPublicDoors();

	initJail();

	initCrime();

	initTalkZone();

	initDonator();

	initLight();

	initHudTicker();

	initJobMenu();

	initJobHelper();

	initGarbageZone();

	initJobSetup();

	initJobSytem();

	initPlayer();

	initTalkSounds();

	initSleeping();

	initnpc();

	initVendorBuy();

	initPrinters();

	initPlants();

	initMeths();

	initPills();

	initCocain();

	initRice();

	initBomb();

	initGunLab();

	initMicrowave();

	initShield();

	initFireBomb();

	initGenerator();

	initBitCoinMine();

	initPropaneTank();

	initPhosphoruTank();

	initSodiumTub();

	initHcAcidTub();

	initAcetoneCan();

	initSeeds();

	initLamp();

	initErythroxylum();

	initBenzocaine();

	initBattery();

	initToulene();

	initSAcidTub();

	initAmmonia();

	initBong();

	initSmokeBomb();

	initWaterBomb();

	initPlasmaBomb();

	initFireExtinguisher();

	initItems();

	initItemList();

	initSpawnedItems();

	initDoors();

	initDoorSystem();

	initDoorAutoOpen();

	initNotice();

	initNpcNotice();

	initSaveDrugs();

	initCarMod();

	initCopCar();

	initProps();

	initHats();

	initJetPack();

	initPlayerTrails();

	initDoubleJump();

	initSettings();

	initLastStats();

	initGlobalBomb();

	initGlobalFire();

	initGlobalAnomaly();

	initGlobalIonCannon();

	initTrapPropeller();

	initVendorDrugBuy();

	initBank();

	initLottery();

	initViewManagement();

	initVendorVehicle();

	initComputerHacking();

	initPdComputer();

	initSpin();

	initSuitCase();

	initExplodePd();

	initGangSystem();

	initCosino();

	initTrading();

	initMarketPlace();

	initDoorItems();

	initGunShopWeapons();

	initRockZones();

	initPrisonPod();

	initJobExperience();
#if defined HL2DM
	//Setup Gameplay:
	InitHL2MP();

	//Dynamic:
	initThumpers();

	initLockdown();

	initPoliceBoss();

	initAntLionBoss();

	initAntLion();

	initVortigaunt();

	initZombie();
//hl2 npcs
	initNpcAntLionGuard();

	initNpcAntLion();

	initNpcichthyosaur();

	initNpcHelicopter();

	initNpcDynamic();

	initNpcVortigaunt();

	initNpcDog();

	initNpcStrider();

	initNpcMetroPolice();

	initNpcZombie();

	initNpcPoisonZombie();

	initNpcHeadCrab();

	initNpcHeadCrabFast();

	initNpcHeadCrabBlack();

	initNpcTurretFloor();

	initNpcAdvisor();

	initNpcCrabSynth();

	initNpcManHack();

	initNpcFastZombie();

	initNpcScanner();

	initNpcRollerMine();

	initNpcCombineSuperSoldier();

	initNpcVortigauntSlave();

	initNpcDogPet();
#endif
}

//Initation:
public void initForwards()
{

	//Handle Forwards:
	ChatForward = CreateGlobalForward("OnClientChat", ET_Event, Param_Cell, Param_Cell, Param_String, Param_Cell);

	CvarForward = CreateGlobalForward("OnCvarChange", ET_Event, Param_String, Param_String, Param_Cell);

	//Command Listener:
	AddCommandListener(CommandSay, "say_team"); //rp_talkzone.sp

	AddCommandListener(CommandSay, "say"); //rp_talkzone.sp

	//Event Hooking:
	HookEvent("player_team", StopEventTeam_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_spawn", StopEvent_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_disconnect", StopEvent_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_connect", StopEvent_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("server_cvar", ServerCvarEvent_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_death", EventPlayerDeath_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_changename", EventChangeName_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_connect_client", StopEvent_Forward, EventHookMode_Pre);

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Client Hooking:
			DHooksCallBack(Client); //rp_dhooksplayer.sp

			//SDKHooks:
			SDKHooksCallBack(Client);
		}
	}
}

//Initation:
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)

{



	//Forward Functions to rp_native.sp
	//OnAskPluginLoad2();
#if defined HL2DM
	//Initulize:
	CustomGuns = true;
#endif
}


//Initation:
public void OnMapStart()
{

	//Initulize:
	MapRunning = true;

	ModSetup = false;

	//Precache:
	PrecacheItems();

	//Server DHooks:
	HookGameRules();
#if defined HL2DM
	//Change Team Name:
	ReplaceTeamName();
#endif
	//Precache:
	initStockCache();

	initMapFix();

	ResetDropped();

	ResetAllCritical();

	ResetEffects();

	ResetCopDoors();

	ResetAdminDoors();

	ResetVipDoors();

	ResetPublicDoors();

	ResetFireFighterDoors();

	ResetEntNotice();

	ResetEntNpcNotice();

	ResetSpawns();

	ResetGarbage();

	initMapGarbageCans();

	ResetWeaponsOnMapChange();

	initResetDhooksPlayer();

	OnMapStart_Scanner();

	OnMapStart_ResetDoorSystem();

	initUnlocker();

	//SQL Load:
	CreateTimer(0.5, LoadRemoveMapProps);

	CreateTimer(0.6, LoadSpawnPoints);

	CreateTimer(0.7, LoadNoKillZone);

	CreateTimer(0.9, LoadRandomCrateZone);

	CreateTimer(1.0, LoadCopDoors);

	CreateTimer(1.1, LoadJail);

	CreateTimer(1.2, LoadGarbageZone);

	CreateTimer(1.3, LoadNpcs);

	CreateTimer(1.4, LoadItemlist);

	CreateTimer(1.5, LoadNpcSpawns);

	CreateTimer(1.6, LoadDoorMainOwners);

	CreateTimer(1.7, LoadDoorLocks);

	CreateTimer(1.8, LoadDoorPrices);

	CreateTimer(1.9, LoadNotice);

	CreateTimer(2.0, LoadNoticeName);

	CreateTimer(2.1, LoadNoticeDesc);

	CreateTimer(2.2, LoadMainDoors);

	CreateTimer(2.4, LoadDoorLocked);

	CreateTimer(2.5, LoadGarbageCans);

	CreateTimer(2.6, LoadVipDoors);

	CreateTimer(2.7, LoadAdminDoors);

	CreateTimer(2.8, LoadFireFighterDoors);

	CreateTimer(2.9, LoadPublicDoors);

	CreateTimer(3.0, LoadBombZones);

	CreateTimer(3.1, LoadFireZones);

	CreateTimer(3.2, LoadAnomalyZones);

	CreateTimer(3.9, LoadIonCannonZones);

	CreateTimer(4.0, LoadNpcNotice);

	CreateTimer(4.1, LoadServerMoneySafe);

	CreateTimer(4.2, CheckLotteryWinners);

	CreateTimer(4.3, LoadVendorCarSpawn);

	CreateTimer(4.4, LoadComputers);

	CreateTimer(4.5, LoadDoorAutoOpen);

	CreateTimer(4.6, LoadSuitCaseZone);

	CreateTimer(4.7, LoadCopCarSpawn);

	CreateTimer(4.8, LoadFindBombZone);

	CreateTimer(4.9, LoadPdBombZone);

	CreateTimer(5.0, LoadPdComputers);

	CreateTimer(5.1, LoadCosinoZones);

	CreateTimer(5.2, LoadCosinoBank);

	CreateTimer(5.3, LoadTradingZones);

	CreateTimer(5.4, LoadGunShopWeapons);

	CreateTimer(5.5, LoadVipClaimDoors);

	CreateTimer(5.6, LoadRockZone);

	CreateTimer(5.7, LoadPrisonPodSpawn);
#if defined HL2DM
	CreateTimer(3.3, LoadLockdownNPCSpawnZones);

	CreateTimer(3.4, LoadPoliceBossSpawns);

	CreateTimer(3.5, LoadAntLionBossSpawn);

	CreateTimer(3.6, LoadAntLionSpawn);

	CreateTimer(3.7, LoadVortigauntSpawn);

	CreateTimer(3.8, LoadZombieSpawn);

	CreateTimer(0.8, LoadThumper);
#endif

	CreateTimer(7.5, SetModStatus);
}

public Action SetModStatus(Handle Timer)
{

	//Initulize:
	ModSetup = true;

	//Print:
	PrintToServer("|RP| - Players can now join the server");
}

//Initation:
public void OnMapEnd()
{

	//Initulize:
	MapRunning = false;

	ModSetup = false;

	//Remove All Weapons!
	RemoveWeaponsOnMap();
}

public void OnGameFrame()
{


	//Declare:
	int Ent = -1;

	//Switch:
	while ((Ent = FindEntityByClassname(Ent, "RofleChopter")) > 0)
	{

		//Initulize:
		RotateRofleChopter(Ent, 10.0); //rp_jetpack.sp
	}

	//Initulize:
	Ent = -1;

	//Switch:
	while ((Ent = FindEntityByClassname(Ent, "prop_Rotate")) > 0)
	{

		//Initulize:
		AddRotateEntity(Ent, 1, 10.0); //rp_stock.sp
	}
}

//Remove any unwanted weapns:
public void initMapFix()
{

	//Declare:
	char ClassName[32];

	//Loop:
	for(int Ent = GetMaxClients(); Ent < 2047; Ent++)
	{

		//Valid:
		if(Ent > GetMaxClients() && (IsValidEdict(Ent) || IsValidEntity(Ent)))
		{

			//Get Entity Info:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Is Roleplay Map:
			if(StrContains(ClassName, "weapon_", false) == 0)
			{

				//Request:
				RequestFrame(OnNextFrameKill, Ent);
			}

			//Is Roleplay Map:
			if(StrContains(ClassName, "npc_", false) == 0)
			{

				//Init:
				SetOnMapStartRelationship(Ent, ClassName);
			}

			//Is Roleplay Map:
			if(StrContains(ClassName, "func_breakable_surf", false) == 0)
			{

				//Set Prop ClassName
				SetEntityClassName(Ent, "func_brush");

				//Invincible:
				SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

			}
		}
	}
}

public Action OnPlayerRunCmd(int Client, int &Buttons, int &impulse, float vel[3], float angles[3], int &Weapon)
{

	//Ignore Fake Clients
	if(IsFakeClient(Client))

	{

		//Return:
		return Plugin_Handled;
	}

	//Check
	if((!IsClientNotMoving(Buttons) || Buttons & IN_USE) && IsProtected(Client))
	{

		//Forward to rp_spawnprotection.sp
		SpawnProtect(Client, false);
	}

	//Check:
	if(GetIsPlayerAfk(Client))
	{

		//Check:
		if(CheckClientAfkStatus(Client))
		{

			//Forward to rp_afkmanage.sp
			ResetPlayerAfk(Client);
		}
	}

	//Set new view Angles:
	SetClientCurrentEyeAngle(Client, angles);
#if defined HL2DM
	//Fast Respawn
	if(!IsPlayerAlive(Client))

	{


		//Declare:
		int iButton = (Buttons & ~IN_SCORE)
;
		float DeathTime = GetEntPropFloat(Client, Prop_Send, "m_flDeathTime");


		//Check:
		if(iButton && (GetGameTime() >= (DeathTime + 0.2)))

		{


			//Spawn:
			DispatchSpawn(Client);

			//Return:
			return Plugin_Continue;

		}

	}
#endif
	//Is Alive:
	if(IsPlayerAlive(Client))
	{
#if defined HL2DM
		//Third Person View Fix:
		HL2dmThirdPersonViewFix(Client); 

		//Fix Shotgun:
		HL2dmButtonFix(Client, Buttons, impulse, vel, angles, Weapon);
#endif
		//Check:
		if(ForceSwitch[Client])
		{

			//Initulize:
			Weapon = GetEntPropEnt(Client, Prop_Send, "m_hLastWeapon");

			ForceSwitch[Client]--;

			//Check:
			if(Weapon == -1)
			{

				//Initulize:
				Weapon = 0;
			}
		}

		//Is Client Cuffed:
		if(IsCuffed(Client) || IsSleeping(Client) > -1)
		{

			//Button Preventsion:
			Buttons &= ~IN_ATTACK;

			Buttons &= ~IN_ATTACK2;

			//Is Client Cuffed:
			if(IsSleeping(Client) > -1)
			{

				//Button Preventsion:
				Buttons &= ~IN_USE;

				Buttons &= ~IN_JUMP;

				Buttons &= ~IN_DUCK;
			}
		}

		//Is Blocking
		else if(GetBlockE(Client) == 1)
		{

			//Prevent Action:
			Buttons &= ~IN_USE;

			//Can Unblock:
			if(GetUnBlockE(Client) == 0)
			{

				//Timer:
				CreateTimer(10.0, UnLockUse, Client);

				//Initialize:
				SetUnBlockE(Client, 1);
			}
		}

		//Button Used:
		else if(Buttons & IN_USE)
		{

			//Buffer
			if(PrethinkBuffer[Client] == 0)
			{

				//Initialize:
				PrethinkBuffer[Client] = 1;

				//Return:
				return OnClientUse(Client);
			}
		}

		//Button Used:
		else if(Buttons & IN_SPEED)
		{

			//Buffer
			if(PrethinkBuffer[Client] == 0)
			{

				//Initialize:
				PrethinkBuffer[Client] = 1;

				//Return:
				return OnClientShift(Client);
			}
#if defined HL2DM
			//Is Admin Or Cop:
			if(IsCop(Client) || IsAdmin(Client))
			{

				//Check IsClient Using Suit:
				if(GetClientActiveDevices(Client) & SUIT_SPRINT_DEVICE) 
				{

					//Send:
					SetEntPropFloat(Client, Prop_Data, "m_flSuitPowerLoad", 0.0);

					RemoveClientActiveDevices(Client, SUIT_SPRINT_DEVICE);
				}
			}
#endif
		}

		//Button Used:
		else if(Buttons & IN_ATTACK2)
		{

			//Buffer
			if(PrethinkBuffer[Client] == 0)
			{

				//Initialize:
				PrethinkBuffer[Client] = 1;

				//Return:
				return OnClientAttack2(Client); //rp_forwards.sp;
			}
		}

		//Override:
		else
		{

			//Initialize:
			PrethinkBuffer[Client] = 0;
		}

		
		OnClientRunCmdDoubleJumpCheck(Client); //rp_doublejump.sp

		//Return:
		return (impulse == 100 && IsCuffed(Client)) ? Plugin_Handled : Plugin_Changed;
	}

	//Return:
	return Plugin_Continue;
}

//Handle Chat:
public Action CommandSay(int Client, const char[] Command,int Argc)
{

	//Declare:
	char Text[256];
	bool IsTeamOnly = false;

	//Not Police Officer:
	if(StrEqual(Command, "say_team"))
	{

		IsTeamOnly = true;
	}

	//Get Args
	GetCmdArgString(Text, sizeof(Text));

	//Strip All Quoats:
	StripQuotes(Text);

	//Trip String:
	TrimString(Text);

	//Is Admin Command:
	if(Text[0] == '/')
	{

		//Return:
		return Plugin_Handled;
	}

	//Start Forward:
	Call_StartForward(ChatForward);

	//Get Users:
	Call_PushCell(Client);

	//Get Headshot:
	Call_PushCell(IsTeamOnly);

	//Get Weapon:
	Call_PushString(Text);

	//Get Users:
	Call_PushCell(sizeof(Text));

	//Finnish Forward:
	Call_Finish();

	//Return:
	return Plugin_Handled;
}

//EventDeath Farward:
public Action EventPlayerDeath_Forward(Event event, const  char[] name, bool dontBroadcast)
{

	//Get Users:
	int Client = GetClientOfUserId(event.GetInt("userid"));

	//Ignore Unconnected Players
	if(IsFakeClient(Client))

	{

		//Check:
		if(!IsLoaded(Client))
		{

			//Set Broadcast:
			SetEventBroadcast(event, true);

			//Close:
			delete event;

			//Return:
			return Plugin_Handled;
		}
	}

	//Override:
	else
	{

		//Get Users:
		int Attacker = GetClientOfUserId(event.GetInt("attacker"));

		//Check:
		if(IsLoaded(Client) == true)
		{

			//Drop All Drugs:
			OnClientDropAllDrugs(Client);

			//Initulize:
			if(Attacker > 0 && Attacker <= GetMaxClients())
			{

				//Set Score:
				SetClientHours(Client);

				SetClientHours(Attacker);

				//Intulize:
				if(!IsCop(Attacker))
				{

					//Check:
					if(!IsCop(Client) || (IsCop(Client) && IsCopMoneyDropDisabled()))
					{

						//Drop Money:
						OnClientDropMoney(Client);
					}

					//Client doesn't have a bounty so add crime to attacker:
					if(GetBounty(Client) == 0)
					{

						//Set Crime:
						SetCrime(Attacker, (GetCrime(Attacker) + 1000));
					}
				}
			}

			//Override:
			else
			{

				//Drop Money:
				OnClientDropMoney(Client);
			}
		}

		//Check:
		OnPlayerKilledGangCheck(Client, Attacker);

		//Died!
		ClientCriticalOverride(Client);

		//Check Player Bounty:
		OnClientDiedCheckBounty(Client, Attacker);

		//Respawn Timer:
		StartClientRespawn(Client);

		//Check:
		if(IsInView(Client))
		{

			//Initulize:
			SetClientViewEntity(Client, Client);

			//Declare:
			int Flags = GetEntityFlags(Client);

			//Set Flags:
			SetEntityFlags(Client, (Flags &~ FL_FROZEN));
		}
	}

	//Return:
	return Plugin_Continue;
}
//EventDeath Farward:
public Action EventChangeName_Forward(Event event, const  char[] name, bool dontBroadcast)
{

	//Get Users:
	int Client = GetClientOfUserId(event.GetInt("userid"));

	//Ignore Fake Clients
	if(IsFakeClient(Client))

	{

		//Set Broadcast:
		SetEventBroadcast(event, true);

		//Close:
		delete event;

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char NewName[32];
	char OldName[32];

	//Initialize:
	event.GetString("newname", NewName, sizeof(NewName));

	event.GetString("oldname", OldName, sizeof(OldName));

	//Anti Spam
	if(!StrEqual(NewName, OldName))
	{

		//Is Admin:
		if(IsAdmin(Client))
		{

			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Admin {olive}%s\x07FFFFFF changed there name to {olive}%s\x07FFFFFF.", OldName, NewName);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Player \x0732CD32%s\x07FFFFFF changed there name to \x0732CD32%s\x07FFFFFF.", OldName, NewName);
		}

		//Declare:
		char query[255];
		char ClientName[32];

		//Remove Harmfull Strings:
		SQL_EscapeString(GetGlobalSQL(), NewName, ClientName, sizeof(ClientName));

		//Format:
		Format(query, sizeof(query), "UPDATE Player SET NAME = '%s' WHERE STEAMID = %i;", ClientName, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Update:
		UpdateLotteryWinnerTable(Client, ClientName);

		//CPrint:
		PrintToConsole(Client, "|RP| Player Name Updated.");
	}

	//Set Broadcast:
	SetEventBroadcast(event, true);

	//Close:
	delete event;

	//Return:
	return Plugin_Handled;
}

//Event Player Disconnect:
public Action StopEvent_Forward(Event event, const char[] name, bool dontBroadcast)
{

	//Set Broadcast:
	SetEventBroadcast(event, true);

	//Close:
	delete event;

	//Return:
	return Plugin_Handled;
}

//Event Player Disconnect:
public Action StopEventTeam_Forward(Event event, const char[] name, bool dontBroadcast)
{
#if defined HL2DM
	//Get Users:
	int Client = GetClientOfUserId(event.GetInt("userid"));

	//Initulize:
	initGravGunSwitchFix(Client);
#endif
	//Set Broadcast:
	SetEventBroadcast(event, true);

	//Close:
	delete event;

	//Return:
	return Plugin_Handled;
}

//Event Player Disconnect:
public Action ServerCvarEvent_Forward(Event event, const char[] name, bool dontBroadcast)
{

	//Start Forward:
	Call_StartForward(CvarForward);

	//Declare:
	char CvarName[255];
	char CvarValue[255];

	//Initialize:
	event.GetString("cvarname", CvarName, sizeof(CvarName));

	event.GetString("cvarvalue", CvarValue, sizeof(CvarValue));

	//Get NewName:
	Call_PushString(CvarName);

	//Get OldName:
	Call_PushString(CvarValue);

	//Finnish Forward:
	Call_Finish();

	//Set Broadcast:
	SetEventBroadcast(event, true);

	//Close:
	delete event;

	//Return:
	return Plugin_Handled;
}

public Action OnClientUse(int Client)
{

	//Initulize:
	if(OnVehicleUse(Client) == true)
	{

		//Return:
		return Plugin_Changed;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Declare:
	int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Check:
	if(InVehicle != -1)
	{

		//Initulize:
		Ent = GetClientAimTargetInVehicle(Client);

		//CPrint:
		//PrintToConsole(Client, "|RP| - New Enity = %i", Ent);
	}

	//Not Valid Ent:
	if(Ent > 0 && IsValidEdict(Ent))
	{

		//Not Valid Ent:
		if(Ent > 0 && Ent <= GetMaxClients() && IsClientConnected(Ent) && IsClientInGame(Ent) && !LookingAtWall(Client))
		{

			//Handle Player:
			DrawPlayerMenu(Client, Ent);

			//Check:
			if((IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
			{

				//Handle Grab:
				OnPlayerGrab(Client, Ent);

				//Return:
				return Plugin_Changed;
			}
		}

		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(Ent, ClassName, sizeof(ClassName));

		//Is Func Door:
		if(StrEqual(ClassName, "func_door"))
		{

			//Is Cop With Admin Override:
			if(NativeIsPublicDoor(Ent) && IsInDistance(Client, Ent) && !GetDoorLocked(Ent))
			{

				//Handle Door:
				OnPublicDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Is Cop With Admin Override:
			if((IsCop(Client) || IsAdmin(Client)) && NativeIsCopDoor(Ent))
			{

				//Handle Door:
				OnCopDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Vip Claimed Doors:
			if(IsOwnsVipDoor(Client, Ent))
			{

				//Handle Door:
				OnVipDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Vip Doors:
			if((GetDonator(Client) > 0) && NativeIsVipDoor(Ent))
			{

				//Handle Door:
				OnVipDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Admin Doors:
			if((IsAdmin(Client)) && NativeIsAdminDoor(Ent))
			{

				//Handle Crate:
				OnAdminDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Admin Doors:
			if((StrEqual(GetJob(Client), "Fire Fighter")) && NativeIsFireFighterDoor(Ent))
			{

				//Handle Crate:
				OnFireFighterDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Declare:
			int GangDoor = GetGangBaseDoor(Client);

			//Is Client Owner of door or has key:
			if(!IsCop(Client) && GangDoor > 0 && (GangDoor == Ent || GangDoor == GetMainDoorOwner(Ent)))
			{

				//Handle Door:
				OnClientDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Is Client Owner of door or has key:
			if(GetMainDoorOwner(Ent) == SteamIdToInt(Client) || HasDoorKeys(Ent, Client) || HasDoorKeys(GetMainDoorId(Ent), Client) || GetMainDoorOwner(GetMainDoorId(Ent)) == SteamIdToInt(Client))
			{

				//Handle Door:
				OnClientDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}
		}

		//Is Prop Door:
		if(StrEqual(ClassName, "prop_door_rotating"))
		{

			//Check:
			OnClientCheckDoorSpam(Client, Ent);

			//Return:
			return Plugin_Changed;
		}

		//Check:
		if(!LookingAtWall(Client) && IsInDistance(Client, Ent))
		{
#if defined HL2DM
			//Prop Thumper:
			if(StrEqual(ClassName, "prop_Thumper"))
			{

				//Handle Thumper:
				OnThumperUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}
#endif
			//Prop Random Crate:
			if(StrEqual(ClassName, "prop_Random_Crate"))
			{

				//Handle Crate:
				OnCrateUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Garbage Can:
			if(StrEqual(ClassName, "prop_Garbage_Can"))
			{

				//Handle Trash Can:
				OnGarbageCanUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Is Valid Sleeping Couch:
			if(IsValidCouch(Ent, ClassName))
			{

				//Handle Couch:
				OnCouchUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Money Printer:
			if(StrEqual(ClassName, "prop_Money_Printer"))
			{

				//Handle Printer:
				OnPrinterUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Plant Drug:
			if(StrEqual(ClassName, "prop_Plant_Drug"))
			{

				//Handle Plant:
				OnPlantUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Kitchen Meth:
			if(StrEqual(ClassName, "prop_Kitchen_Meth"))
			{

				//Handle Plant:
				OnMethUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Kitchen Meth:
			if(StrEqual(ClassName, "prop_Kitchen_Pills"))
			{

				//Handle Plant:
				OnPillsUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Kitchen Meth:
			if(StrEqual(ClassName, "prop_Kitchen_Cocain"))
			{

				//Handle Plant:
				OnCocainUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Plant Rice:
			if(StrEqual(ClassName, "prop_Plant_Rice"))
			{

				//Handle Plant:
				OnRiceUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Bomb:
			if(StrEqual(ClassName, "prop_Bomb"))
			{

				//Handle Bomb:
				OnBombUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Gun Lab:
			if(StrEqual(ClassName, "prop_Gun_Lab"))
			{

				//Handle Plant:
				OnGunLabUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Microwave:
			if(StrEqual(ClassName, "prop_Microwave"))
			{

				//Handle Plant:
				OnMicrowaveUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Shield:
			if(StrEqual(ClassName, "prop_Shield"))
			{

				//Handle Plant:
				OnShieldUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Fire Bomb:
			if(StrEqual(ClassName, "prop_Fire_Bomb"))
			{

				//Handle Plant:
				OnFireBombUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}
	
			//Prop Generator:
			if(StrEqual(ClassName, "prop_Generator"))
			{

				//Handle Plant:
				OnGeneratorUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop BitCoin Mine:
			if(StrEqual(ClassName, "prop_BitCoin_Mine"))
			{

				//Handle Plant:
				OnBitCoinMineUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Propane Tank:
			if(StrEqual(ClassName, "prop_Propane_Tank"))
			{

				//Handle Plant:
				OnPropaneTankUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Phosphoru Tank:
			if(StrEqual(ClassName, "prop_Phosphoru_Tank"))
			{

				//Handle Phosphoru Tank:
				OnPhosphoruTankUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Drug Lamp:
			if(StrEqual(ClassName, "prop_Drug_Lamp"))
			{

				//Handle Light:
				OnLampUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//prop Drug Bong:
			if(StrEqual(ClassName, "prop_Drug_Bong"))
			{

				//Handle Light:
				OnBongUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//prop Smoke Bomb:
			if(StrEqual(ClassName, "prop_Smoke_Bomb"))
			{

				//Handle Light:
				OnSmokeBombUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//prop Water Bomb:
			if(StrEqual(ClassName, "prop_Water_Bomb"))
			{

				//Handle Light:
				OnWaterBombUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//prop Plasma Bomb:
			if(StrEqual(ClassName, "prop_Plasma_Bomb"))
			{

				//Handle Light:
				OnPlasmaBombUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//prop Fire Extinguisher:
			if(StrEqual(ClassName, "prop_Fire_Extinguisher"))
			{

				//Handle Light:
				OnFireExtinguisherUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Prop Weapon:
			if(StrContains(ClassName, "weapon_", false) == 0)
			{

				//Handle Weapon:
				OnWeaponUse(Client, Ent, ClassName);

				//Return:
				return Plugin_Changed;
			}

			//prop Money Safe:
			if(StrEqual(ClassName, "prop_Money_Safe"))
			{

				//Handle Money Safe:
				OnMoneySafeUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//prop Money Safe:
			if(StrEqual(ClassName, "prop_Server_Money_Safe"))
			{

				//Handle Money Safe:
				OnServerMoneySafeUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//prop Money Safe:
			if(StrEqual(ClassName, "prop_Find_Bomb"))
			{

				//Handle Find Bomb:
				OnFindBombUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//prop Player Garbage:
			if(StrEqual(ClassName, "prop_Player_Garbage") && (IsAdmin(Client) || StrContains(GetJob(Client), "Street Sweeper", false) != -1))
			{

				//Handle Money Safe:
				OnPlayerGarbageUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Is Global Bomb:
			if(StrEqual(ClassName, "prop_Bomb_global"))
			{

				//Handle Global Bomb:
				OnGlobalBombUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//prop Suit Case:
			if(StrEqual(ClassName, "prop_SuitCase"))
			{

				//Handle SuitCase:
				OnSuitCaseUse(Client, Ent);

				//Return:
				return Plugin_Changed;
			}

			//Banker:
			if(StrEqual(ClassName, "npc_Banker"))
			{

				//Show Menu:
				DrawBankMenu(Client, Ent); //rp_bank.sp

				//Return:
				return Plugin_Changed;
			}

			//Vendor:
			if(StrEqual(ClassName, "npc_Vendor"))
			{

				//Declare:
				int Id = GetNpcId(Ent);

				//Show Menu:
				VendorMenuBuy(Client, Id, Ent); //rp_vendorbuy.sp

				//Return:
				return Plugin_Changed;
			}

			//Cop Employer:
			if(StrEqual(ClassName, "npc_Cop_Employer"))
			{

				//Show Menu:
				CopRankingMenu(Client); //rp_copranking.sp

				//Return:
				return Plugin_Changed;
			}

			//Drugs:
			if(StrEqual(ClassName, "npc_Drug"))
			{

				//Show Menu:
				VendorDrugSell(Client, Ent); //rp_vendorresell.sp

				//Return:
				return Plugin_Changed;
			}

			//Drugs:
			if(StrEqual(ClassName, "npc_Experience_Trader"))
			{

				//Show Menu:
				ExperienceMenu(Client); //rp_vendorexptrade.sp

				//Return:
				return Plugin_Changed;
			}

			//Hardware Store NPC:
			if(StrEqual(ClassName, "npc_Hardware_Store"))
			{

				//Show Menu: rp_vendorhardware.sp

				//Return:
				return Plugin_Changed;
			}

			//Employer:
			if(StrEqual(ClassName, "npc_Employer"))
			{

				//Show Menu:
				JobMenu(Client, 0); // rp_jobmenu.sp

				//Return:
				return Plugin_Changed;
			}

			//Lottery:
			if(StrEqual(ClassName, "npc_Lottery"))
			{

				//Show Menu:
				VendorMenuLottery(Client); // rp_lottery.sp

				//Return:
				return Plugin_Changed;
			}

			//Vendor Cars:
			if(StrEqual(ClassName, "npc_Vendor_Cars"))
			{

				//Declare:
				int Id = GetNpcId(Ent);

				//Show Menu:
				VendorVehicles(Client, Id, Ent); // rp_vendorcars.sp

				//Return:
				return Plugin_Changed;
			}

			//Re Sell:
			if(StrEqual(ClassName, "npc_Re_Sell"))
			{

				//Show Menu:
				VendorMenuReSellSelectVendor(Client, Ent); //rp_vendorresell.sp

				//Return:
				return Plugin_Changed;
			}

			//Prop Weed:
			if(StrEqual(ClassName, "prop_Weed_Bag"))
			{

				//Handle Dropped Drug:
				OnClientPickUpWeedBag(Client, Ent); //rp_dropped.sp

				//Return:
				return Plugin_Changed;
			}

			//Prop Pills:
			if(StrEqual(ClassName, "prop_Pill_Jar"))
			{

				//Handle Dropped Meth:
				OnClientPickUpPills(Client, Ent); //rp_dropped.sp

				//Return:
				return Plugin_Changed;
			}

			//Prop Meth:
			if(StrEqual(ClassName, "prop_Meth_Bag"))
			{

				//Handle Dropped Meth:
				OnClientPickUpMeth(Client, Ent); //rp_dropped.sp

				//Return:
				return Plugin_Changed;
			}

			//Prop Cocain:
			if(StrEqual(ClassName, "prop_Cocain_Bag"))
			{

				//Handle Dropped Meth:
				OnClientPickUpCocain(Client, Ent); //rp_dropped.sp

				//Return:
				return Plugin_Changed;
			}

			//Prop Money:
			if(StrEqual(ClassName, "prop_Money"))
			{

				//Handle Money:
				OnClientPickUpMoney(Client, Ent); //rp_dropped.sp

				//Return:
				return Plugin_Changed;
			}

			//Prop Resources:
			if(StrEqual(ClassName, "prop_Resources"))
			{

				//Handle Dropped Meth:
				OnClientPickUpResources(Client, Ent); //rp_dropped.sp

				//Return:
				return Plugin_Changed;
			}

			//Prop Resources:
			if(StrEqual(ClassName, "prop_Metal"))
			{

				//Handle Dropped Meth:
				OnClientPickUpMetal(Client, Ent); //rp_dropped.sp

				//Return:
				return Plugin_Changed;
			}

			//prop Dropped Item:
			if(StrEqual(ClassName, "prop_Dropped_Item"))
			{

				//Handle Dropped Item:
				OnClientPickUpItem(Client, Ent); //rp_items.sp

				//Return:
				return Plugin_Changed;
			}

			//prop Computer:
			if(StrEqual(ClassName, "prop_Computer"))
			{

				//Handle ComputerUse:
				OnComputerUse(Client, Ent); //rp_computer.sp

				//Return:
				return Plugin_Changed;
			}

			//prop Computer:
			if(StrEqual(ClassName, "prop_Pd_Computer"))
			{

				//Handle ComputerUse:
				OnPdComputerUse(Client, Ent); //rp_Pdcomputer.sp

				//Return:
				return Plugin_Changed;
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public Action OnClientShift(int Client)
{

	//Declare:
	int Ent = GetClientAimTarget(Client, false); 

	//Not Valid Ent:
	if(Ent != -1 && Ent > 0 && IsValidEdict(Ent))
	{

		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(Ent, ClassName, sizeof(ClassName));

		//Not Valid Ent:
		if(Ent > 0 && Ent <= GetMaxClients() && IsClientConnected(Ent) && IsClientInGame(Ent) && !IsFakeClient(Ent))
		{

			//Is Prop Door:
			if(!LookingAtWall(Client) && IsInDistance(Client, Ent) && (StrEqual(GetJob(Client), "Hacker") || IsAdmin(Client) || StrContains(GetJob(Client), "Crime Lord", false) != -1))
			{

				//Begin Player Hack:
				BeginPlayerHacking(Client, Ent, GetPlayerHackCash());

				//Return:
				return Plugin_Changed;
			}
		}

		//Check:
		if(!LookingAtWall(Client) && IsInDistance(Client, Ent))
		{

			//Is Func Door:
			if(StrEqual(ClassName, "func_door"))
			{

				//Is Admin Or Cop:
				if((IsCop(Client) || IsAdmin(Client)) && NativeIsCopDoor(Ent))
				{

					//Handle Crate:
					OnCopDoorPropShift(Client, Ent); //rp_copdoors.sp

					//Return:
					return Plugin_Changed;
				}
			}

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Is Admin Or Cop:
				if((IsCop(Client) || IsAdmin(Client)) && NativeIsCopDoor(Ent))
				{

					//Handle Crate:
					OnCopDoorPropShift(Client, Ent); //rp_copdoors.sp

					//Return:
					return Plugin_Changed;
				}

				//Is public door:
				if(NativeIsPublicDoor(Ent) && !GetDoorLocked(Ent))
				{

					//Handle Crate:
					OnPublicDoorPropShift(Client, Ent); //rp_publicdoors.sp

					//Return:
					return Plugin_Changed;
				}

				//Is Donator:
				if((GetDonator(Client) > 0) && NativeIsVipDoor(Ent))
				{

					//Handle Crate:
					OnVipDoorPropShift(Client, Ent); //rp_vipdoors.sp

					//Return:
					return Plugin_Changed;
				}

				//Vip Claimed Doors:
				if(IsOwnsVipDoor(Client, Ent))
				{

					//Handle Crate:
					OnVipDoorPropShift(Client, Ent); //rp_vipdoors.sp

					//Return:
					return Plugin_Changed;
				}

				//Fire Fighter Doors:
				if((StrEqual(GetJob(Client), "Fire Fighter")) && NativeIsFireFighterDoor(Ent))
				{

					//Handle Crate:
					OnFireFighterDoorPropShift(Client, Ent); //rp_firefighterdoors.sp

					//Return:
					return Plugin_Changed;
				}

				//Admin Doors:
				if((IsAdmin(Client)) && NativeIsAdminDoor(Ent))
				{

					//Handle Crate:
					OnAdminDoorPropShift(Client, Ent); //rp_admindoors.sp

					//Return:
					return Plugin_Changed;
				}

				//Declare:
				int GangDoor = GetGangBaseDoor(Client);

				//Is Client Owner of door or has key:
				if(!IsCop(Client) && GangDoor > 0 && (GangDoor == Ent || GangDoor == GetMainDoorOwner(Ent)))
				{

					//Handle Crate:
					OnClientDoorPropShift(Client, Ent); //rp_doorsystem.sp

					//Return:
					return Plugin_Changed;
				}

				//Is Client Owner of door or has key:
				if(GetMainDoorOwner(Ent) == SteamIdToInt(Client) || HasDoorKeys(Ent, Client) || HasDoorKeys(GetMainDoorId(Ent), Client) || GetMainDoorOwner(GetMainDoorId(Ent)) == SteamIdToInt(Client))
				{

					//Handle Crate:
					OnClientDoorPropShift(Client, Ent); //rp_doorsystem.sp

					//Return:
					return Plugin_Changed;
				}
			}

			//prop Money Safe:
			if(StrEqual(ClassName, "prop_Money_Safe") && (StrEqual(GetJob(Client), "Robber") || IsAdmin(Client) || StrContains(GetJob(Client), "Crime Lord", false) != -1))
			{

				//Handle Money Safe:
				OnMoneySafeRob(Client, Ent); //rp_moneysafe.sp

				//Return:
				return Plugin_Changed;
			}

			//prop Money Safe:
			if(StrEqual(ClassName, "prop_Server_Money_Safe") && (StrEqual(GetJob(Client), "Robber") || IsAdmin(Client) || StrContains(GetJob(Client), "Crime Lord", false) != -1))
			{

				//Handle Money Safe:
				OnServerMoneySafeRob(Client, Ent); //rp_serversafe.sp

				//Return:
				return Plugin_Changed;
			}

			//Prop Vehicle...
			if(StrContains(ClassName, "prop_vehicle", false) != -1 && GetPlayerVehicle(Client) == Ent && !StrEqual(ClassName, "prop_vehicle_damaged"))
			{

				//Handle Plant:
				OnVehicleShift(Client, Ent); //rp_carmod.sp

				//Return:
				return Plugin_Changed;
			}

			//Prop Vehicle...
			if(IsCop(Client) || IsAdmin(Client))
			{

				//Check:
				if(IsValidCopCar(Ent))
				{

					//Handle Plant:
					OnCopVehicleShift(Client, Ent); //rp_copcars.sp

					//Return:
					return Plugin_Changed;
				}

				//Check:
				if(IsValidPrisonPod(Ent))
				{

					//Handle Plant:
					OnVehiclePrisonPodShift(Client, Ent); //rp_prisonpod.sp

					//Return:
					return Plugin_Changed;
				}
			}

			//Prop Generator:
			if(StrEqual(ClassName, "prop_Generator"))
			{

				//Handle Plant:
				OnGeneratorShift(Client, Ent); //rp_generator.sp

				//Return:
				return Plugin_Changed;
			}

			//Prop Computer:
			if(StrEqual(ClassName, "prop_Computer") && (StrEqual(GetJob(Client), "Hacker") || IsAdmin(Client) || StrContains(GetJob(Client), "Crime Lord", false) != -1))
			{

				//Begin Bank Hack:
				BeginComputerHack(Client, Ent); //rp_computer.sp
			}

			//Prop Thumper:
			if(StrEqual(ClassName, "prop_Thumper"))
			{

				//Begin Bank Hack:
				BeginThumperRob(Client, Ent); //rp_thumper.sp
			}

			//Banker:
			if(StrEqual(ClassName, "npc_Banker"))
			{

				//Declare:
				int Id = GetNpcId(Ent);

				//Is Valid:
				if(StrEqual(GetJob(Client), "Hacker") || IsAdmin(Client) || StrContains(GetJob(Client), "Crime Lord", false) != -1)
				{

					//Begin Bank Hack:
					BeginBankHack(Client, Ent, "Banker", GetHackBankAmount(), Id); //rp_bankhacking.sp
				}

				//Override:
				else
				{

					//Begin Bank Rob:
					BeginBankRob(Client, Ent, "Banker", GetRobBankAmount(), Id); //rp_bankrobbing.sp
				}

				//Return:
				return Plugin_Changed;
			}

			//Vendor:
			if(StrEqual(ClassName, "npc_Vendor"))
			{

				//Declare:
				int Id = GetNpcId(Ent);

				//Begin Vendor Rob:
				BeginVendorRob(Client, Ent, "Vendor", GetRobVendorAmount(), Id); //rp_vendorrobbing.sp

				//Return:
				return Plugin_Changed;
			}

			//Banker:
			if(StrEqual(ClassName, "npc_Employer"))
			{

				//Empoyer NPC:
				if(StrEqual(GetJob(Client), "Robber") || IsAdmin(Client) || StrContains(GetJob(Client), "Crime Lord", false) != -1)
				{

					//Declare:
					int Id = GetNpcId(Ent);

					//Begin Vendor Rob:
					BeginEmployerRob(Client, Ent, "Employer", GetRobVendorAmount(), Id); //rp_employrobbing.sp

					//Return:
					return Plugin_Changed;
				}
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public Action OnClientAttack2(int Client)
{

	//Declare:
	char ClassName[32];

	//Get Client Weapon:
	GetClientWeapon(Client, ClassName, sizeof(ClassName));

	//Is Prop Door:
	if(StrEqual(ClassName, GetRepairWeapon()) || StrEqual(ClassName, GetArrestWeapon()))
	{

		//Declare:
		int Ent = GetClientAimTarget(Client, false); 

		//Not Valid Ent:
		if(Ent <= GetMaxClients() && Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent))
		{

			//Handle Push Player:
			OnClientPushPlayer(Client, Ent); //rp_jail.sp

			//Return:
			return Plugin_Changed;
		}

		//Not Valid Ent:
		if(Ent > GetMaxClients() && IsValidEdict(Ent))
		{

			//Is Prop Door:
			if(IsValidDoor(Ent) && IsInDistance(Client, Ent))
			{

				//Handle Door Knock:
				OnClientKnockPropDoor(Ent); //rp_doormisc.sp

				//Return:
				return Plugin_Changed;
			}

			//Get Entity Info:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Is Roleplay Map:
			if(StrContains(ClassName, "npc_", false) == 0 && !IsValidNpc(Ent))
			{

				//Handle Push Player:
				OnClientPushPlayer(Client, Ent); //rp_jail.sp

				//Return:
				return Plugin_Changed;
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

//Public Void OnClientPutInServer(int Client)
public void OnClientPostAdminCheck(int Client)
{

	//Ignore Fake Clients
	if(IsFakeClient(Client))

	{

		//Set Defaults: set to prevent server crash and index problems
		OnClientConnectSetDefaults(Client); //rp_defaults.sp

		//SDKHooks:
		SDKHooksCallBack(Client);

		//Return:
		return;
	}

	//Declare:
	char SteamID[32];

	//Initulize:
	GetClientAuthId(Client, AuthId_Steam3, SteamID, 32);

	//Check to see if player has spoofed his steamid
	if(StrEqual(SteamID, "STEAM_ID_STOP_IGNORING_RETVALS"))  
	{

		//Kick Player
		KickClient(Client, "You have kicked from this server\nReason: %s", "SteamId Spoofing");
	}

	//LoadItems:
	CreateTimer(0.2, OnClientPostAdminCheck_PreLoad, Client); //rp_forward.sp

	//Set Defaults:
	OnClientConnectSetDefaults(Client); //rp_defaults.sp

	//Server DHooks:
	DHooksCallBack(Client); //rp_dhooksplayer.sp

	//SDKHooks:
	SDKHooksCallBack(Client);
}

//Create SQLite Database:
public Action OnClientPostAdminCheck_PreLoad(Handle Timer, any Client)
{

	//Connected:
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Connect Message:
		OnClientConnectMessage(Client); //rp_forwardmessages.sp

		//Load Player Stats:
		DBLoad(Client); //rp_player.sp

		//Load Player Inventory:
		LoadItems(Client); // rp_items.sp

		//Load Door Keys;
		DBLoadKeys(Client); //rp_doorsystem.sp
		DBLoadOwner(Client);

		//Load Player Drugs:
		DBLoadDrugs(Client); //rp_savedrugs.sp

		//Load Spawned Items:
		DBLoadSpawnedItems(Client); //rp_spawneditems.sp

		//Load Settings:
		LoadPlayerSettings(Client); //rp_settings.sp

		//Root Admin Connected:
		OnRootAdminConnect(Client); //rp_stocks.sp

		//Load Money Safe:
		DBLoadMoneySafe(Client); //rp_moneysafe.sp
	}

	//Connected:
	else if(IsClientConnected(Client))
	{

		//LoadItems:
		CreateTimer(0.1, OnClientPostAdminCheck_PreLoad, Client);
	}
}

public bool IsMapRunning()
{

	//Return:
	return MapRunning;
}

public void SDKHooksCallBack(int Client)
{

	//Damage Hook:
	SDKHook(Client, SDKHook_OnTakeDamage, OnClientTakeDamage);
}

//Event Damage:
public Action OnClientTakeDamage(int Client, int &Attacker, int &Inflictor, float &Damage, int &DamageType)
{

	//Check:
	if(Attacker > GetMaxClients() && IsValidEntity(Attacker))
	{

		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(Attacker, ClassName, sizeof(ClassName));
#if defined HL2DM
		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_AntlionGuard", false) == 0)
		{

			//Forward SDKHOOK:
			OnAntLionGuardDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is AntLion:
		if(StrContains(ClassName, "npc_Antlion", false) == 0)
		{

			//Forward SDKHOOK:
			OnAntLionDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Helicopter:
		if(StrContains(ClassName, "npc_Helicopter", false) == 0)
		{

			//Forward SDKHOOK:
			OnHelicopterDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Vortigaunt:
		if(StrContains(ClassName, "npc_Vortigaunt", false) == 0)
		{

			//Forward SDKHOOK:
			OnVortigauntDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Strider:
		if(StrContains(ClassName, "npc_Strider", false) == 0)
		{

			//Forward SDKHOOK:
			OnStriderDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Metro Police:
		if(StrContains(ClassName, "npc_MetroPolice", false) == 0)
		{

			//Forward SDKHOOK:
			OnMetroPoliceDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Zombie:
		if(StrContains(ClassName, "npc_Zombie", false) == 0)
		{

			//Forward SDKHOOK:
			OnZombieDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Fast Zombie:
		if(StrContains(ClassName, "npc_FastZombie", false) == 0)
		{

			//Forward SDKHOOK:
			OnFastZombieDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Poison Zombie:
		if(StrContains(ClassName, "npc_PoisonZombie", false) == 0)
		{

			//Forward SDKHOOK:
			OnPoisonZombieDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Headcrab:
		if(StrContains(ClassName, "npc_Headcrab", false) == 0)
		{

			//Forward SDKHOOK:
			OnHeadCrabDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Headcrab Fast:
		if(StrContains(ClassName, "npc_HeadcrabFast", false) == 0)
		{

			//Forward SDKHOOK:
			OnHeadCrabFastDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Headcrab Black:
		if(StrContains(ClassName, "npc_HeadcrabBlack", false) == 0)
		{

			//Forward SDKHOOK:
			OnHeadCrabBlackDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Advisor:
		if(StrContains(ClassName, "npc_Advisor", false) == 0)
		{

			//Forward SDKHOOK:
			OnAdvisorDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Man Hack:
		if(StrContains(ClassName, "npc_Manhack", false) == 0)
		{

			//Forward SDKHOOK:
			OnManHackDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Man Hack:
		if(StrContains(ClassName, "npc_RollerMine", false) == 0)
		{

			//Forward SDKHOOK:
			OnRollerMineDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Combine Super Soldier:
		if(StrContains(ClassName, "npc_CombineSuperSoldier", false) == 0)
		{

			//Forward SDKHOOK:
			OnCombineSuperSoldierDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Combine Scanner:
		if(StrContains(ClassName, "npc_Scanner", false) == 0)
		{

			//Forward SDKHOOK:
			OnScannerDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Vortigaunt Slave:
		if(StrContains(ClassName, "npc_VortigauntSlave", false) == 0)
		{

			//Forward SDKHOOK:
			OnVortigauntSlaveDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}
#endif

		//Print:
		//PrintToServer("|RP| SDKHOOKS OnTakeDamage - Attacker Inded = %i, Attacker ClassName = %s damage = %f", Attacker, ClassName, Damage);
	}

	//Convert if Player Has Suit:
	if(DamageType == DMG_FALL || DamageType == DMG_DROWN)
	{

		//Declare:
		float Armor = float(GetClientArmor(Client));

		//Has No Armor:
		if(Armor == 0.0)
		{

			//Initialize:
			Damage = FloatMul(Damage, GetRandomFloat(0.50, 1.50));
		}

		//Has Armor:
		else if((Armor - Damage) < 1 && (Armor != 0.0))
		{

			//Set Armor:
			SetEntityArmor(Client, 0);

			//Initialize:
			Damage = FloatMul(Damage, GetRandomFloat(0.25, 0.75));
		}

		//Has Armor With Right Damage to armor value:
		else if((Armor - Damage) > 1.0)
		{

			//Set Armor:
			SetEntityArmor(Client, RoundToNearest((Armor - Damage)));

			//Initialize:
			Damage = FloatMul(Damage, GetRandomFloat(0.25, 0.75));
		}

		//Override:
		else
		{
			//Set Armor:
			SetEntityArmor(Client, 0);
		}

		//Shake Client:
		ShakeClient(Client, 2.5, (Damage/4.0));
	}

	//Check:
	if(DamageType & DMG_VEHICLE)
	{

		//Declare:
		char ClassName[30];

		//Initulize:
		GetEdictClassname(Inflictor, ClassName, sizeof(ClassName));

		//Is Vehicle:
		if (StrEqual("prop_vehicle_driveable", ClassName, false))
		{

			//Declare
			int Driver = GetEntPropEnt(Inflictor, Prop_Send, "m_hPlayer");

			//Check:
			if(Driver != -1)
			{

				//Initulize:
				Damage *= 2.0;
				
				Attacker = Driver;
			}
		}
	}

	//Is Player:
	if(Attacker != Client && Client != 0 && Attacker != 0 && Client > 0 && Client < MaxClients && Attacker > 0 && Attacker < MaxClients)
	{

		//Handle Player Cuff:
		OnClientCuffCheck(Client, Attacker, Damage);

		//Cop Kill:
		if(IsCop(Client) && IsCop(Attacker) && IsCopKillDisabled() == 1)
		{

			//Initialize:
			Damage = 0.0;

			//Damage:
			DamageType = 0;
		}

		//Is Client Cuffed:
		if(!IsCop(Attacker))
		{

			//Declare:
			int Health = GetClientHealth(Client);

			//Check:
			if(Health - RoundFloat(Damage) <= 0)
			{

				//Initialize:
				Damage = float(Health);
			}

			//Set Crime:
			SetCrime(Attacker, (GetCrime(Attacker) + RoundFloat(Damage * 2)));
		}
	}

	//Is Damage Coming From Kitchen?:
	if(DamageType == DMG_BURN)
	{

		//Declare:
		int Ent = FindAttachedPropFromEnt(Inflictor);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char ClassName[32];

			//Get Entity Info:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Prop Kitchen:
			if(StrEqual(ClassName, "prop_Kitchen_Meth") || StrEqual(ClassName, "prop_Kitchen_Pills") || StrEqual(ClassName, "prop_Kitchen_Cocain"))
			{

				//Initialize:
				Damage = 0.0;
			}

			//Override
			else
			{

				//Initialize:
				Damage = GetRandomFloat(1.0, 5.0);
			}
		}

		//Initialize:
		Damage = GetRandomFloat(1.0, 5.0);
	}

	//GodeMode:
	if(GetIsNokill(Client) || IsProtected(Client) || GetGodMode(Client) || (IsPhysDamageDisabled() == 1 && DamageType == DMG_CRUSH))
	{

		//Initialize:
		Damage = 0.0;

		//Damage:
		DamageType = 0;
	}

	//Has Shield Near By:
	if(IsShieldInDistance(Client))
	{

		//Shield Forward:
		OnClientShieldDamage(Client, Damage);

		//Initialize:
		Damage = 0.0;

		//Damage:
		DamageType = 0;
	}

	//Check Ciritical:
	OnDamageCriticalCheck(Client);

	//Initialize:
	int ClientHealth = GetClientHealth(Client);

	//Check:
	if(float(ClientHealth) - Damage <= 0.0)
	{

		//Forward:
		OnClientDied(Client, Attacker, Inflictor, DamageType);
	}

	//Return:
	return Plugin_Changed;
}

public Action OnClientDied(int Client, int &Attacker, int &Inflictor, int DamageType)
{

}

public void OnClientSettingsChanged(int Client)
{
}

public bool IsCustomGunsLoaded()
{

	//Return:
	return CustomGuns;
}

public int GetForceSwitch(int Client)
{

	//Return:
	return view_as<int>(ForceSwitch[Client]);
}

public int SetForceSwitch(int Client, int Result)
{

	//Initulize:
	ForceSwitch[Client] = Result;
}

public bool GetModSetup()
{

	//Return:
	return view_as<bool>(ModSetup);
}