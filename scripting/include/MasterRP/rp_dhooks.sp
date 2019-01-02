//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_dhooks_included_
  #endinput
#endif
#define _rp_dhooks_included_

//Pre Client Hook:
Handle hPreSpawn = INVALID_HANDLE;
Handle hPreChangeTeam = INVALID_HANDLE;
Handle hPreEventKilled = INVALID_HANDLE;
Handle hPreGiveNamedItem = INVALID_HANDLE;
Handle hPreWeaponEquip = INVALID_HANDLE;
Handle hPreWeaponDrop = INVALID_HANDLE;
Handle hPreDeathSound = INVALID_HANDLE;
Handle hPreStartTouch = INVALID_HANDLE;
Handle hPreTouch = INVALID_HANDLE;
Handle hPreEndTouch = INVALID_HANDLE;
Handle hPreThink = INVALID_HANDLE;
Handle hPreStartObserverMode = INVALID_HANDLE;
Handle hPreGetInVehicle = INVALID_HANDLE;
Handle hPreLeaveVehicle = INVALID_HANDLE;

//Post Client Hooks:
Handle hPostSpawn = INVALID_HANDLE;
Handle hPostThinkPost = INVALID_HANDLE;
Handle hPostWeaponEquip = INVALID_HANDLE;

//GameRule Pre Hooks:
Handle hPreConnected = INVALID_HANDLE;
Handle hPreDisConnected = INVALID_HANDLE;

//Other Hooks:
Handle hPreAcceptInput = INVALID_HANDLE;

//Init DHooks Extension
public void initDHooks()
{

	//Declare:
	Handle GameData = LoadGameConfigFile("MasterRP");



	//Add OnEntityCreated Hook:
	DHookAddEntityListener(ListenType_Created, OnEntityCreated);

	//Add OnEntityDeleted Hook:
	DHookAddEntityListener(ListenType_Deleted, OnEntityDeleted);

	//Has Failed:
	if(GameData == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset File! 'sourcemod/gamedata/MasterRP.txt'");
	}

	//Pre Hooks:

	// void CHL2MP_Player::ChangeTeam( int )
	int offset = GameConfGetOffset(GameData, "ChangeTeam");

	//DHooks:
	hPreChangeTeam = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPreChangeTeam);

	//Has Failed:
	if(hPreChangeTeam == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CHL2MP_Player::ChangeTeam( int )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreChangeTeam, HookParamType_Int);
	}

	// void CHL2MP_Player::Event_Killed( const CTakeDamageInfo &info )
	offset = GameConfGetOffset(GameData, "EventKilled");

	//DHooks:
	hPreEventKilled = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPreEventKilled);

	//Has Failed:
	if(hPreEventKilled == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CHL2MP_Player::Event_Killed( const CTakeDamageInfo &info )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreEventKilled, HookParamType_ObjectPtr, -1, DHookPass_ByRef);
	}

	// void CHL2MP_Player::Spawn( void )
	offset = GameConfGetOffset(GameData, "Spawn");

	//DHooks:
	hPreSpawn = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPreSpawn);

	//Has Failed:
	if(hPreSpawn == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CHL2MP_Player::Spawn( void )'");
	}

	// void CBasePlayer:GiveNamedItem( char const*, int)
	offset = GameConfGetOffset(GameData, "GiveNamedItem");

	//DHooks:
	hPreGiveNamedItem = DHookCreate(offset, HookType_Entity, ReturnType_CBaseEntity, ThisPointer_CBaseEntity, OnPreGiveNamedItem);

	//Has Failed:
	if(hPreGiveNamedItem == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CBasePlayer:GiveNamedItem( char const*, int)'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreGiveNamedItem, HookParamType_CharPtr);

		DHookAddParam(hPreGiveNamedItem, HookParamType_Int);
	}

	// void CBasePlayer::Weapon_Equip( CBaseCombatWeapon *pWeapon )
	offset = GameConfGetOffset(GameData, "WeaponEquip");

	//DHooks:
	hPreWeaponEquip = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPreWeaponEquip);

	//Has Failed:
	if(hPreWeaponEquip == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CBasePlayer::Weapon_Equip( CBaseCombatWeapon *pWeapon )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreWeaponEquip, HookParamType_CBaseEntity);
	}

	// void CHL2MP_Player::Weapon_Equip( CBaseCombatWeapon*, vector const*, vector const*)
	offset = GameConfGetOffset(GameData, "WeaponDrop");

	//DHooks:
	hPreWeaponDrop = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPreWeaponDrop);

	//Has Failed:
	if(hPreWeaponDrop == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CHL2MP_Player::Weapon_Equip( CBaseCombatWeapon*, vector const*, vector const*)'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreWeaponDrop, HookParamType_CBaseEntity);

		DHookAddParam(hPreWeaponDrop, HookParamType_VectorPtr);

		DHookAddParam(hPreWeaponDrop, HookParamType_VectorPtr);
	}

	// void CHL2MP_Player::DeathSound( const CTakeDamageInfo &info )
	offset = GameConfGetOffset(GameData, "DeathSound");

	//DHooks:
	hPreDeathSound = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPreDeathSound);

	//Has Failed:
	if(hPreEventKilled == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CHL2MP_Player::DeathSound( const CTakeDamageInfo &info )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreDeathSound, HookParamType_ObjectPtr, -1, DHookPass_ByRef);
	}

	// void CBaseEntity::Touch( CBaseEntity* )
	offset = GameConfGetOffset(GameData, "Touch");

	//DHooks:
	hPreTouch = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPreTouch);

	//Has Failed:
	if(hPreTouch == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CBaseEntity::Touch( CBaseEntity* )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreTouch, HookParamType_CBaseEntity);
	}

	// void CBaseEntity::EndTouch( CBaseEntity* )
	offset = GameConfGetOffset(GameData, "EndTouch");

	//DHooks:
	hPreEndTouch = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPreEndTouch);

	//Has Failed:
	if(hPreEndTouch == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CBaseEntity::EndTouch( CBaseEntity* )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreEndTouch, HookParamType_CBaseEntity);
	}

	// void CBaseEntity::StartTouch( CBaseEntity* )
	offset = GameConfGetOffset(GameData, "StartTouch");

	//DHooks:
	hPreStartTouch = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPreStartTouch);

	//Has Failed:
	if(hPreStartTouch == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CBaseEntity::StartTouch( CBaseEntity* )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreStartTouch, HookParamType_CBaseEntity);
	}

	// void CHL2MP_Player::PreThink( void )
	offset = GameConfGetOffset(GameData, "PreThink");

	//DHooks:
	hPreThink = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPreThinkPre);

	//Has Failed:
	if(hPreThink == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CHL2MP_Player::PreThink( void )'");
	}

	// bool CBasePlayer::StartObserverMode( int )
	offset = GameConfGetOffset(GameData, "StartObserverMode");

	//DHooks:
	hPreStartObserverMode = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, OnPreStartObserverMode);

	//Has Failed:
	if(hPreStartObserverMode == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'bool CBasePlayer::StartObserverMode( int )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreStartObserverMode, HookParamType_Int);
	}

	// bool CBasePlayer::GetInVehicle( IServerVehicle *pVehicle, int nRole )
	offset = GameConfGetOffset(GameData, "GetInVehicle");

	//DHooks:
	hPreGetInVehicle = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, OnPreGetInVehicle);

	//Has Failed:
	if(hPreGetInVehicle == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'bool CBasePlayer::GetInVehicle( IServerVehicle *pVehicle, int nRole )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreGetInVehicle, HookParamType_Int);

		DHookAddParam(hPreGetInVehicle, HookParamType_Int);
	}

	// void CBasePlayer::LeaveVehicle( Vector const&, QAngle const& )
	offset = GameConfGetOffset(GameData, "LeaveVehicle");

	//DHooks:
	hPreLeaveVehicle = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPreLeaveVehicle);

	//Has Failed:
	if(hPreLeaveVehicle == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CBasePlayer::LeaveVehicle( Vector const&, QAngle const& )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreGetInVehicle, HookParamType_VectorPtr);

		DHookAddParam(hPreGetInVehicle, HookParamType_VectorPtr);
	}

	//Post Hooks

	// void CHL2MP_Player::Spawn( void )
	offset = GameConfGetOffset(GameData, "Spawn");

	//DHooks:
	hPostSpawn = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPostSpawn);

	//Has Failed:
	if(hPostSpawn == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CHL2MP_Player::Spawn( void )'");
	}

	// void CHL2MP_Player::PostThink( void )
	offset = GameConfGetOffset(GameData, "PostThink");

	//DHooks:
	hPostThinkPost = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPostThinkPost);

	//Has Failed:
	if(hPostThinkPost == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CHL2MP_Player::PostThink( void )'");
	}

	// void CBasePlayer::Weapon_Equip( CBaseCombatWeapon *pWeapon )
	offset = GameConfGetOffset(GameData, "WeaponEquip");

	//DHooks:
	hPostWeaponEquip = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnPostWeaponEquip);

	//Has Failed:
	if(hPostWeaponEquip == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CBasePlayer::Weapon_Equip( CBaseCombatWeapon *pWeapon )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPostWeaponEquip, HookParamType_CBaseEntity);
	}

	//GameRule Pre Hook:

	// bool CMultiplayRules::ClientConnected(edict_t * pEntity, char const*, char const*, int )
	offset = GameConfGetOffset(GameData, "ClientConnected");

	//DHooks:
	hPreConnected = DHookCreate(offset, HookType_GameRules, ReturnType_Bool, ThisPointer_Ignore, OnPreClientConnected);

	//Has Failed:
	if(hPreConnected == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'bool CMultiplayRules::ClientConnected(edict_t * pEntity, char const*, char const*, int )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreConnected, HookParamType_Edict);
	}

	// void CHL2MPRules::ClientDisconnected(edict_t * pClient )
	offset = GameConfGetOffset(GameData, "ClientDisconnected");

	//DHooks:
	hPreDisConnected = DHookCreate(offset, HookType_GameRules, ReturnType_Void, ThisPointer_Ignore, OnPreClientDisconnected);

	//Has Failed:
	if(hPreDisConnected == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CHL2MPRules::ClientDisconnected(edict_t * pClient )'");
	}

	//Override:
	else
	{

		//Param:
		DHookAddParam(hPreDisConnected, HookParamType_Edict);
	}

	// bool CBaseEntity::AcceptInput(char  const*, CBaseEntity*, CBaseEntity*, variant_t, int)
	offset = GameConfGetOffset(GameData, "AcceptInput");

	//DHooks:
	hPreAcceptInput = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, PreAcceptInput);

	//Has Failed:
	if(hPreDisConnected == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CHL2MPRules::ClientDisconnected(edict_t * pClient )'");
	}

	//Override:
	else
	{
		DHookAddParam(hPreAcceptInput, HookParamType_CharPtr);
		DHookAddParam(hPreAcceptInput, HookParamType_CBaseEntity);
		DHookAddParam(hPreAcceptInput, HookParamType_CBaseEntity);
		DHookAddParam(hPreAcceptInput, HookParamType_Object, 20, DHookPass_ByVal|DHookPass_ODTOR|DHookPass_OCTOR|DHookPass_OASSIGNOP); //varaint_t is a union of 12 (float[3]) plus two int type params 12 + 8 = 20
		DHookAddParam(hPreAcceptInput, HookParamType_Int);
	}

	//Close:
	CloseHandle(GameData);

	//Fail State:
	PrintToServer("|RP| - DHooks Successfully Loaded");
}

public void HookGameRules()
{

	//GameRules Pre Hook Types:
	DHookGamerules(hPreConnected, false);

	DHookGamerules(hPreDisConnected, false);
}

//int ; //1
// void CHL2MP_Player::ChangeTeam( int )
public MRESReturn OnPreChangeTeam(int Entity, Handle hParams)
{


	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Declare
			int Team = -1;
			Team = DHookGetParam(hParams, 1);

			//Return:
			return OnClientPreChangeTeam(Entity, hParams, Team);
		}
	}

	//Return:
	return MRES_Ignored; 
}

//Vector	m_vecDamageForce; //0
//Vector	m_vecDamagePosition; //12
//Vector	m_vecReportedPosition; //24
//EHANDLE	m_hInflictor; //36
//EHANDLE	m_hAttacker; //40
//EHANDLE	m_hWeapon; //44
//float	m_flDamage; //48
//float	m_flMaxDamage; //52
//float	m_flBaseDamage;	//56
//int	m_bitsDamageType; //60
//int	m_iDamageCustom; //64
//int	m_iDamageStats; //68
//int	m_iAmmoType; //72
//int	m_iDamagedOtherPlayers; //76
//int	m_iPlayerPenetrateCount; //80

// void CHL2MP_Player::Event_Killed( const CTakeDamageInfo &info )
public MRESReturn OnPreEventKilled(int Entity, Handle hParams)
{

	//Declare:
	float DamageForce[3] = {0.0,...};

	DHookGetParamObjectPtrVarVector(hParams, 1, 0, ObjectValueType_Vector, DamageForce);


	//Declare:
	float DamagePosition[3] = {0.0,...};

	DHookGetParamObjectPtrVarVector(hParams, 1, 12, ObjectValueType_Vector, DamagePosition);

	int Inflictor = -1;
	Inflictor = DHookGetParamObjectPtrVar(hParams, 1, 36, ObjectValueType_Int);

	int Attacker = -1;
	Attacker = DHookGetParamObjectPtrVar(hParams, 1, 40, ObjectValueType_Int);

	int Weapon = -1;
	Weapon = DHookGetParamObjectPtrVar(hParams, 1, 40, ObjectValueType_Int);

	float fDamage = 0.0;
	fDamage = DHookGetParamObjectPtrVar(hParams, 1, 48, ObjectValueType_Float);

	int DamageType = -1;
	DamageType = DHookGetParamObjectPtrVar(hParams, 1, 60, ObjectValueType_Float);

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Forward:
			return OnClientPreEventKilled(Entity, hParams, Attacker, Inflictor, Weapon, fDamage, DamageType, DamageForce, DamagePosition);
		}
	}

	//Return:
	return MRES_Ignored;
}

// void CHL2MP_Player::Spawn( Void )
public MRESReturn OnPreSpawn(int Entity, Handle hParams)
{

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{
			//Forward:
			return OnClientPreSpawn(Entity, hParams);
		}
	}

	//Return:
	return MRES_Ignored;
}

// void CBasePlayer:GiveNamedItem( char const*, int )
public MRESReturn OnPreGiveNamedItem(int Entity, Handle hReturn, Handle hParams)
{

	//Declare:
	int Weapon = DHookGetReturn(hReturn);

	//Declare:
	char WeaponName[128];

	int Unknown = -1;
	Unknown = DHookGetParam(hParams, 2);

	//Get Param:
	DHookGetParamString(hParams, 1, WeaponName, sizeof(WeaponName));

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			return OnPreClientGiveNamedItem(Entity, hReturn, hParams, WeaponName, Weapon, Unknown);
		}
	}

	//Return:
	return MRES_Ignored;
}

// void CBasePlayer::Weapon_Equip( CBaseCombatWeapon *pWeapon )
public MRESReturn OnPreWeaponEquip(int Entity, Handle hParams)
{

	int Weapon = -1;
	Weapon = DHookGetParam(hParams, 1);

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			return OnPreClientWeaponEquip(Entity, hParams, Weapon);
		}
	}

	//Return:
	return MRES_Ignored;
}

// void CHL2MP_Player::Weapon_Drop( CBaseCombatWeapon*, vector const*, vector const* )
public MRESReturn OnPreWeaponDrop(int Entity, Handle hParams)
{

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			return OnPreClientWeaponDrop(Entity, hParams);
		}
	}

	//Return:
	return MRES_Ignored;
}

//Vector	m_vecDamageForce; //0
//Vector	m_vecDamagePosition; //12
//Vector	m_vecReportedPosition; //24
//EHANDLE	m_hInflictor; //36
//EHANDLE	m_hAttacker; //40
//EHANDLE	m_hWeapon; //44
//float	m_flDamage; //48
//float	m_flMaxDamage; //52
//float	m_flBaseDamage;	//56
//int	m_bitsDamageType; //60
//int	m_iDamageCustom; //64
//int	m_iDamageStats; //68
//int	m_iAmmoType; //72
//int	m_iDamagedOtherPlayers; //76
//int	m_iPlayerPenetrateCount; //80

// void CHL2MP_Player::DeathSound( const CTakeDamageInfo &info )
public MRESReturn OnPreDeathSound(int Entity, Handle hParams)
{

	//Declare:
	float DamageForce[3] = {0.0,...};

	DHookGetParamObjectPtrVarVector(hParams, 1, 0, ObjectValueType_Vector, DamageForce);


	//Declare:
	float DamagePosition[3] = {0.0,...};

	DHookGetParamObjectPtrVarVector(hParams, 1, 12, ObjectValueType_Vector, DamagePosition);

	int Inflictor = -1;
	Inflictor = DHookGetParamObjectPtrVar(hParams, 1, 36, ObjectValueType_Int);

	int Attacker = -1;
	Attacker = DHookGetParamObjectPtrVar(hParams, 1, 40, ObjectValueType_Int);

	int Weapon = -1;
	Weapon = DHookGetParamObjectPtrVar(hParams, 1, 40, ObjectValueType_Int);

	float fDamage = 0.0;
	fDamage = DHookGetParamObjectPtrVar(hParams, 1, 48, ObjectValueType_Float);

	int DamageType = -1;
	DamageType = DHookGetParamObjectPtrVar(hParams, 1, 60, ObjectValueType_Float);

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Forward:
			return OnClientPreDeathSound(Entity, hParams, Attacker, Inflictor, Weapon, fDamage, DamageType, DamageForce, DamagePosition);
		}
	}

	//Return:
	return MRES_Ignored;
}

// void CBaseEntity::StartTouch( CBaseEntity* )
public MRESReturn OnPreStartTouch(int Entity, Handle hParams)
{

	int OtherEntity = -1;
	OtherEntity = DHookGetParam(hParams, 1);

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			return OnPreClientStartTouch(Entity, hParams, OtherEntity);
		}
	}

	//Override:
	else
	{
#if defined HL2DM
		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(Entity, ClassName, sizeof(ClassName));

		//Is Grenade:
		if(StrContains(ClassName, "grenade") != -1)
		{

			//Get Entity Info:
			GetEdictClassname(OtherEntity, ClassName, sizeof(ClassName));

			//Is Door:
			if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Return:
				return OnPreGrenadeStartTouchDoor(Entity, hParams, OtherEntity);
			}
		}
#endif
		//Is Entity a Vendor!
		if(IsValidNpc(Entity))
		{

			//Declare:
			int Type = GetNpcType(Entity);

			//Hardware Store NPC:
			if(Type == 6)
			{

				//Return:
				return OnPreVendorHardWareStoreTouch(Entity, hParams, OtherEntity);
			}
		}

		//Is Entity
		if(IsValidPdBomb(Entity))
		{

			//Return:
			return OnPrePdBombTouch(Entity, hParams, OtherEntity);
		}
	}

	//Return:
	return MRES_Ignored;
}
#if defined HL2DM
public MRESReturn OnPreGrenadeStartTouchDoor(int Entity, Handle hParams, int OtherEntity)
{

	//Kill:
	AcceptEntityInput(Entity, "Kill");

	//Return:
	return MRES_Ignored;
}
#endif
public MRESReturn OnPreVendorHardWareStoreStartTouch(int Entity, Handle hParams, int OtherEntity)
{

	//Initulize:
	OnPreHandleHardWareVendorTouch(Entity, OtherEntity);

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPrePdBombStartTouch(int Entity, Handle hParams, int OtherEntity)
{

	//Initulize:
	OnPreHandlePdBombTouch(Entity, OtherEntity);

	//Return:
	return MRES_Ignored;
}

// void CBaseEntity::Touch( CBaseEntity* )
public MRESReturn OnPreTouch(int Entity, Handle hParams)
{

	int OtherEntity = -1;
	OtherEntity = DHookGetParam(hParams, 1);

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			return OnPreClientTouch(Entity, hParams, OtherEntity);
		}
	}

	//Override:
	else
	{

		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(Entity, ClassName, sizeof(ClassName));

		//Is Door:
		if(StrContains(ClassName, "grenade") != -1 && !StrEqual(ClassName, "grenade_ar2"))
		{

			//Get Entity Info:
			GetEdictClassname(OtherEntity, ClassName, sizeof(ClassName));

			//Is Func Door:
			if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Return:
				return OnPreGrenadeTouchDoor(Entity, hParams, OtherEntity);
			}
		}

		//Is Entity a Vendor!
		if(IsValidNpc(Entity))
		{

			//Declare:
			int Type = GetNpcType(Entity);

			//Hardware Store NPC:
			if(Type == 6)
			{

				//Return:
				return OnPreVendorHardWareStoreStartTouch(Entity, hParams, OtherEntity);
			}
		}

		//Check:
		if(IsValidPdBomb(Entity))
		{

			//Return:
			return OnPrePdBombStartTouch(Entity, hParams, OtherEntity);
		}
	}

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreGrenadeTouchDoor(int Entity, Handle hParams, int OtherEntity)
{

	//Kill:
	AcceptEntityInput(Entity, "Kill");

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreVendorHardWareStoreTouch(int Entity, Handle hParams, int OtherEntity)
{

	//Initulize:
	OnPreHandleHardWareVendorTouch(Entity, OtherEntity);

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPrePdBombTouch(int Entity, Handle hParams, int OtherEntity)
{

	//Initulize:
	OnPreHandlePdBombTouch(Entity, OtherEntity);

	//Return:
	return MRES_Ignored;
}

// void CBaseEntity::EndTouch( CBaseEntity* )
public MRESReturn OnPreEndTouch(int Entity, Handle hParams)
{

	int OtherEntity = -1;
	OtherEntity = DHookGetParam(hParams, 1);

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			return OnPreClientEndTouch(Entity, hParams, OtherEntity);
		}
	}

	//Return:
	return MRES_Ignored;
}

// void CHL2MP_Player::ThinkPost( Void )
public MRESReturn OnPreThinkPre(int Entity, Handle hParams)
{

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			OnClientPreThinkPre(Entity, hParams);
		}
	}

	//Return:
	return MRES_Ignored; 
}

// bool CBasePlayer:StartObserverMode( int )
public MRESReturn OnPreStartObserverMode(int Entity, Handle hReturn, Handle hParams)
{

	int Mode = -1;
	Mode = DHookGetParam(hParams, 1);

	//Declare:
	bool Result = DHookGetReturn(hReturn);

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			return OnPreClientStartObserverMode(Entity, hReturn, hParams, Mode, Result);
		}
	}

	//Return:
	return MRES_Ignored;
}

// bool CBasePlayer::GetInVehicle( IServerVehicle *pVehicle, int nRole )
public MRESReturn OnPreGetInVehicle(int Entity, Handle hReturn, Handle hParams)
{

	//Declare:
	bool Result = DHookGetReturn(hReturn);

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			return OnClientGetInVehicle(Entity, Result, hParams);
		}
	}

	//Return:
	return MRES_Ignored;
}

// void CBasePlayer::LeaveVehicle( Vector const&, QAngle const& )
public MRESReturn OnPreLeaveVehicle(int Entity, Handle hParams)
{

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			return OnClientLeaveVehicle(Entity, hParams);
		}
	}

	//Return:
	return MRES_Ignored;
}

// void CHL2MP_Player::Spawn( Void )
public MRESReturn OnPostSpawn(int Entity, Handle hParams)
{

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			return OnClientPostSpawn(Entity, hParams);
		}
	}

	//Override:
	else
	{
#if defined HL2DM
		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(Entity, ClassName, sizeof(ClassName));

		//Is grenade:
		if(StrContains(ClassName, "grenade", false) == 0 || StrEqual(ClassName, "npc_grenade"))
		{

			//Return:
			return OnGrenadePostSpawn(Entity, hParams);
		}

		//Is Combine Ball:
		if(StrEqual(ClassName, "prop_combine_ball"))
		{

			//Return:
			return OnPropCombineBallPostSpawn(Entity, hParams);
		}

		//Is Combine Ball:
		if(StrEqual(ClassName, "crossbow_bolt"))
		{

			//Return:
			return OnPropCrossbowBoltPostSpawn(Entity, hParams);
		}

		//Is Prop:
		if(StrContains(ClassName, "prop_", false) == 0)
		{

			//Return:
			return OnPropPostSpawn(Entity, hParams);
		}

		//Is Combine Ball:
		if(StrEqual(ClassName, "env_explosion"))
		{

			//Return:
			return OnEnvExplosionPostSpawn(Entity, hParams);
		}

		//Mine:
		if(StrEqual(ClassName, "npc_tripmine") || StrEqual(ClassName, "npc_satchel"))
		{

			//Return:
			return OnTripMinePostSpawn(Entity, hParams);
		}
#endif
	}

	//Return:
	return MRES_Ignored;
}

// void CHL2MP_Player::ThinkPost( Void )
public MRESReturn OnPostThinkPost(int Entity, Handle hParams)
{

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			OnClientPostThinkPost(Entity, hParams);
		}
	}

	//Return:
	return MRES_Ignored; 
}

// void CBasePlayer::Weapon_Equip( CBaseCombatWeapon *pWeapon )
public MRESReturn OnPostWeaponEquip(int Entity, Handle hParams)
{

	int Weapon = -1;
	Weapon = DHookGetParam(hParams, 1);

	//InGame:
	if(Entity > 0 && Entity <= GetMaxClients() && IsClientInGame(Entity))
	{

		//FakeClient:
		if(!IsFakeClient(Entity))
		{

			//Return:
			return OnPostClientWeaponEquip(Entity, hParams, Weapon);
		}
	}

	//Return:
	return MRES_Ignored;
}

public MRESReturn PreAcceptInput(int Entity, Handle hReturn, Handle hParams)
{

	char Command[128];
	DHookGetParamString(hParams, 1, Command, sizeof(Command));
	int type = DHookGetParamObjectPtrVar(hParams, 4, 16,ObjectValueType_Int);

	char wtf[128];
	DHookGetParamObjectPtrString(hParams, 4, 0, ObjectValueType_String, wtf, sizeof(wtf));

	//PrintToServer("Command %s Type %i String %s", Command, type, wtf);

	//Is Door:
	if(StrEqual(Command, "kill"))
	{


		PrintToServer("Command %s Type %i String %s", Command, type, wtf);

		DHookSetReturn(hReturn, false);

		return MRES_Supercede;
	}

	//Return:
	return MRES_Ignored;

}
