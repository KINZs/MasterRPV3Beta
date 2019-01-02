//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_cvar_included_
  #endinput
#endif
#define _rp_cvar_included_

//ConVars Handles:
ConVar CV_ROBTIME;
ConVar CV_HACKTIME;
ConVar CV_ROBBANK;
ConVar CV_HACKBANK;
ConVar CV_ROBVENDOR;
ConVar CV_HACKCOMPUTER;
ConVar CV_PLAYERTIME;
ConVar CV_PLAYERHACK;
ConVar CV_CRIMEBOUNTY;
ConVar CV_CUFFDAMAGE;
ConVar CV_COPKILL;
ConVar CV_COPMONEDROP;
ConVar CV_ALLCOPUNCUFF;
ConVar CV_PHYSDAMAGE;
ConVar CV_PROTECT;
ConVar CV_HUNGER;
ConVar CV_DEPOSIT;
ConVar CV_CRATEINIT;
ConVar CV_BOMBINIT;
ConVar CV_FIREINIT;
ConVar CV_ANOMALYINIT;
ConVar CV_IONCANNON;
ConVar CV_LOCKDOWN;
ConVar CV_MAXDOORSOWN;
ConVar CV_MINIMUMRESPAWN;
ConVar CV_DELETEPROPTIMER;
ConVar CV_DISABLECOPDROP;
ConVar CV_LOTTERYDURATION;
ConVar CV_LOTTERYCHANCE;
ConVar CV_LOTTERYTICKETPRICE;
ConVar CV_SUITCASEINIT;
ConVar CV_EXPLODEPDINIT;

ConVar SV_CHEATS;
ConVar MP_FORCECAMERA;

//ConVars Values:
enum CVarValues
{
	ROBTIME = 0,
	HACKTIME,
	ROBBANK,
	HACKBANK,
	ROBVENDOR,
	HACKCOMPUTER,
	PLAYERTIME,
	PLAYERHACK,
	CRIMEBOUNTY,
	CUFFDAMAGE,
	COPKILL,
	COPMONEDROP,
	ALLCOPUNCUFF,
	PHYSDAMAGE,
	PROTECT,
	HUNGER,
	DEPOSIT,
	CRATEINIT,
	BOMBINIT,
	FIREINIT,
	ANOMALYINIT,
	IONCANNON,
	LOCKDOWN,
	MAXDOORSOWN,
	MINIMUMRESPAWN,
	CHEATS,
	DELETEPROPTIMER,
	DISABLECOPDROP,
	LOTTERYDURATION,
	LOTTERYCHANCE,
	LOTTERYTICKETPRICE,
	SUITCASEINIT,
	EXPLODEPDINIT
};

//CVar Handle:
int CVarValue[CVarValues];

public void initCvar()
{

	//Server Version:
	CreateConVar("sm_roleplay_version", MAINVERSION, "show the version of the roleplaying mod", FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);

	//Create Auto Configurate File:
	AutoExecConfig(true, "MS_Roleplay_AutoExec");

	//Main Mod ConVar:
	CV_CRIMEBOUNTY = CreateConVar("sm_setbounty_start", "5000","Set crime to bounty start limitdefault (5000)");

	CV_ROBTIME = CreateConVar("sm_robtime", "600", "Npc Robbing interval default (900)");

	CV_HACKTIME = CreateConVar("sm_hacktime", "1500", "Npc hacking interval default (900)");

	CV_ROBBANK = CreateConVar("sm_rob_bank_amount", "500", "Total sum of robbable cash (500)");

	CV_HACKBANK = CreateConVar("sm_Hack_bank_amount", "1000", "Total sum of Hackable cash (1000)");

	CV_ROBVENDOR = CreateConVar("sm_rob_vendor_amount", "400", "Total sum of robbable cash (400)");

	CV_HACKCOMPUTER = CreateConVar("sm_rob_hack_amount", "800", "Total sum of robbable cash (800)");

	CV_PLAYERTIME = CreateConVar("sm_player_hack_time", "1500", "Player hacking interval default (15000)");

	CV_PLAYERHACK = CreateConVar("sm_player_hack_cah", "500", "Player hacking interval default (500)");

	CV_CUFFDAMAGE = CreateConVar("sm_cuffdamage_disable", "1", "disable/enable damage while a player is default (1)");

	CV_COPKILL = CreateConVar("sm_copkill_disable", "0", "Disable/Enable teamkilling for cops default (0)");

	CV_ALLCOPUNCUFF = CreateConVar("sm_copcuff_disable", "1", "disable/enable cops uncuff default (0)");

	CV_PHYSDAMAGE = CreateConVar("sm_physdamage_disable", "1", "disable/enable physdamage from props default (1)");

	CV_PROTECT = CreateConVar("sm_protect_time", "5.0", "set the spawn protection time default (10.0)");

	CV_HUNGER = CreateConVar("sm_hunger_disable", "0", "Disable/Enable default (1)");

	CV_DEPOSIT = CreateConVar("sm_quickdepsoit", "1", "default 1");

	CV_CRATEINIT = CreateConVar("sm_cratezone_time", "1501", "default 900 sec");

	CV_BOMBINIT = CreateConVar("sm_bombzone_time", "3001", "default 1200 sec");

	CV_FIREINIT = CreateConVar("sm_firezone_time", "2251", "default 1200 sec");

	CV_ANOMALYINIT = CreateConVar("sm_anomalyone_time", "3501", "default 1800 sec");

	CV_IONCANNON = CreateConVar("sm_ioncannonzone_time", "6001", "default 600 sec");

	CV_LOCKDOWN = CreateConVar("sm_lockdown_disable", "0", "default 0 sec");

	CV_MAXDOORSOWN = CreateConVar("sm_maxdoorsown", "2", "default 2 sec");

	CV_MINIMUMRESPAWN = CreateConVar("sm_minrespawntime", "0.5", "default 0.5 sec");

	CV_DELETEPROPTIMER = CreateConVar("sm_deletepropafter", "900.0", "default 900.0 sec");

	CV_DISABLECOPDROP = CreateConVar("sm_copdrop_disable", "1", "1 to disable cop weapon drop 0 to enable");

	CV_COPMONEDROP = CreateConVar("sm_copdrop_disable", "1", "1 to disable cop money drop 0 to enable");

	CV_LOTTERYDURATION = CreateConVar("sm_lottery_duration", "60", "timer is in Minutes");

	CV_LOTTERYCHANCE = CreateConVar("sm_lottery_chance", "50", "1 out of ? to add a ticket every minute");

	CV_LOTTERYTICKETPRICE = CreateConVar("sm_lottery_ticket_price", "5000", "how much per ticket to enter");

	CV_SUITCASEINIT = CreateConVar("sm_suitcase_time", "2001", "default 900 sec");

	CV_EXPLODEPDINIT = CreateConVar("sm_explodepd_time", "12001", "default 900 sec");

	//Server ConVar:
	SV_CHEATS = FindConVar("sv_cheats");

	MP_FORCECAMERA = FindConVar("mp_forcecamera");

	//Main Mod ConVar Hooks:
	CV_CRIMEBOUNTY.AddChangeHook(OnConVarChange);

	CV_ROBTIME.AddChangeHook(OnConVarChange);

	CV_HACKTIME.AddChangeHook(OnConVarChange);

	CV_ROBBANK.AddChangeHook(OnConVarChange);

	CV_HACKBANK.AddChangeHook(OnConVarChange);

	CV_ROBVENDOR.AddChangeHook(OnConVarChange);

	CV_HACKCOMPUTER.AddChangeHook(OnConVarChange);

	CV_PLAYERTIME.AddChangeHook(OnConVarChange);

	CV_PLAYERHACK.AddChangeHook(OnConVarChange);

	CV_CUFFDAMAGE.AddChangeHook(OnConVarChange);

	CV_COPKILL.AddChangeHook(OnConVarChange);

	CV_ALLCOPUNCUFF.AddChangeHook(OnConVarChange);

	CV_PHYSDAMAGE.AddChangeHook(OnConVarChange);

	CV_PROTECT.AddChangeHook(OnConVarChange);

	CV_HUNGER.AddChangeHook(OnConVarChange);

	CV_CRATEINIT.AddChangeHook(OnConVarChange);

	CV_BOMBINIT.AddChangeHook(OnConVarChange);

	CV_FIREINIT.AddChangeHook(OnConVarChange);

	CV_ANOMALYINIT.AddChangeHook(OnConVarChange);

	CV_IONCANNON.AddChangeHook(OnConVarChange);

	CV_LOCKDOWN.AddChangeHook(OnConVarChange);

	CV_MAXDOORSOWN.AddChangeHook(OnConVarChange);

	CV_MINIMUMRESPAWN.AddChangeHook(OnConVarChange);

	CV_DELETEPROPTIMER.AddChangeHook(OnConVarChange);

	CV_DISABLECOPDROP.AddChangeHook(OnConVarChange);

	CV_COPMONEDROP.AddChangeHook(OnConVarChange);

	CV_LOTTERYDURATION.AddChangeHook(OnConVarChange);

	CV_LOTTERYCHANCE.AddChangeHook(OnConVarChange);

	CV_LOTTERYTICKETPRICE.AddChangeHook(OnConVarChange);

	CV_SUITCASEINIT.AddChangeHook(OnConVarChange);

	CV_EXPLODEPDINIT.AddChangeHook(OnConVarChange);

	//Server ConVar Hooks:
	CV_DEPOSIT.AddChangeHook(OnConVarChange);

	SV_CHEATS.AddChangeHook(OnConVarChange);
}

public void OnConfigsExecuted()
{

	//Get Values:
	CVarValue[ROBTIME] = GetConVarInt(CV_ROBTIME);

	CVarValue[HACKTIME] = GetConVarInt(CV_HACKTIME);

	CVarValue[ROBBANK] = GetConVarInt(CV_ROBBANK);

	CVarValue[HACKBANK] = GetConVarInt(CV_HACKBANK);

	CVarValue[ROBVENDOR] = GetConVarInt(CV_ROBVENDOR);

	CVarValue[HACKCOMPUTER] = GetConVarInt(CV_HACKCOMPUTER);

	CVarValue[PLAYERTIME] = GetConVarInt(CV_PLAYERTIME);

	CVarValue[PLAYERHACK] = GetConVarInt(CV_PLAYERHACK);

	CVarValue[CRIMEBOUNTY] = GetConVarInt(CV_CRIMEBOUNTY);

	CVarValue[CUFFDAMAGE] = GetConVarInt(CV_CUFFDAMAGE);

	CVarValue[COPKILL] = GetConVarInt(CV_COPKILL);

	CVarValue[ALLCOPUNCUFF] = GetConVarInt(CV_ALLCOPUNCUFF);

	CVarValue[PHYSDAMAGE] = GetConVarInt(CV_PHYSDAMAGE);

	CVarValue[PROTECT] = GetConVarInt(CV_PROTECT);

	CVarValue[HUNGER] = GetConVarInt(CV_HUNGER);

	CVarValue[DEPOSIT] = GetConVarInt(CV_DEPOSIT);

	CVarValue[CRATEINIT] = GetConVarInt(CV_CRATEINIT);

	CVarValue[BOMBINIT] = GetConVarInt(CV_BOMBINIT);

	CVarValue[FIREINIT] = GetConVarInt(CV_FIREINIT);

	CVarValue[ANOMALYINIT] = GetConVarInt(CV_ANOMALYINIT);

	CVarValue[IONCANNON] = GetConVarInt(CV_IONCANNON);

	CVarValue[MAXDOORSOWN] = GetConVarInt(CV_MAXDOORSOWN);

	CVarValue[LOCKDOWN] = GetConVarInt(CV_LOCKDOWN);

	CVarValue[MINIMUMRESPAWN] = GetConVarInt(CV_MINIMUMRESPAWN);

	CVarValue[DISABLECOPDROP] = GetConVarInt(CV_DISABLECOPDROP);

	CVarValue[COPMONEDROP] = GetConVarInt(CV_COPMONEDROP);

	CVarValue[CHEATS] = GetConVarInt(SV_CHEATS);

	CVarValue[DELETEPROPTIMER] = GetConVarInt(CV_DELETEPROPTIMER);

	CVarValue[LOTTERYDURATION] = GetConVarInt(CV_LOTTERYDURATION);

	CVarValue[LOTTERYCHANCE] = GetConVarInt(CV_LOTTERYCHANCE);

	CVarValue[LOTTERYTICKETPRICE] = GetConVarInt(CV_LOTTERYTICKETPRICE);

	CVarValue[SUITCASEINIT] = GetConVarInt(CV_SUITCASEINIT);

	CVarValue[EXPLODEPDINIT] = GetConVarInt(CV_EXPLODEPDINIT);
#if defined BANS
	//Bans Cfg:
	OnBansExecuted();
#endif
}

public void OnConVarChange(ConVar hCVar, char[] oldValue, char[] newValue) 
{

	//Check Handle:
	if(hCVar == CV_ROBTIME)
	{

		//Initulize:
		CVarValue[ROBTIME] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_HACKTIME)
	{

		//Initulize:
		CVarValue[HACKTIME] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_ROBBANK)
	{

		//Initulize:
		CVarValue[ROBBANK] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_HACKBANK)
	{

		//Initulize:
		CVarValue[HACKBANK] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_ROBVENDOR)
	{

		//Initulize:
		CVarValue[ROBVENDOR] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_HACKCOMPUTER)
	{

		//Initulize:
		CVarValue[HACKCOMPUTER] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_PLAYERTIME)
	{

		//Initulize:
		CVarValue[PLAYERTIME] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_PLAYERHACK)
	{

		//Initulize:
		CVarValue[PLAYERHACK] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_CRIMEBOUNTY)
	{

		//Initulize:
		CVarValue[CRIMEBOUNTY] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_CUFFDAMAGE)
	{

		//Initulize:
		CVarValue[CUFFDAMAGE] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_COPKILL)
	{

		//Initulize:
		CVarValue[COPKILL] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_ALLCOPUNCUFF)
	{

		//Initulize:
		CVarValue[ALLCOPUNCUFF] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_PHYSDAMAGE)
	{

		//Initulize:
		CVarValue[PHYSDAMAGE] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_PROTECT)
	{

		//Initulize:
		CVarValue[PROTECT] = StringToInt(newValue) * 2;
	}

	//Check Handle:
	if(hCVar == CV_HUNGER)
	{

		//Initulize:
		CVarValue[HUNGER] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_DEPOSIT)
	{

		//Initulize:
		CVarValue[DEPOSIT] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_CRATEINIT)
	{

		//Initulize:
		CVarValue[CRATEINIT] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_BOMBINIT)
	{

		//Initulize:
		CVarValue[BOMBINIT] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_FIREINIT)
	{

		//Initulize:
		CVarValue[FIREINIT] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_ANOMALYINIT)
	{

		//Initulize:
		CVarValue[ANOMALYINIT] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_IONCANNON)
	{

		//Initulize:
		CVarValue[IONCANNON] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_LOCKDOWN)
	{

		//Initulize:
		CVarValue[LOCKDOWN] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_MAXDOORSOWN)
	{

		//Initulize:
		CVarValue[MAXDOORSOWN] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_MINIMUMRESPAWN)
	{

		//Initulize:
		CVarValue[MINIMUMRESPAWN] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_DISABLECOPDROP)
	{

		//Initulize:
		CVarValue[DISABLECOPDROP] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_COPMONEDROP)
	{

		//Initulize:
		CVarValue[COPMONEDROP] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == SV_CHEATS)
	{

		//Initulize:
		CVarValue[CHEATS] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_DELETEPROPTIMER)
	{

		//Initulize:
		CVarValue[DELETEPROPTIMER] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_LOTTERYDURATION)
	{

		//Initulize:
		CVarValue[LOTTERYDURATION] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_LOTTERYCHANCE)
	{

		//Initulize:
		CVarValue[LOTTERYCHANCE] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_LOTTERYTICKETPRICE)
	{

		//Initulize:
		CVarValue[LOTTERYTICKETPRICE] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_SUITCASEINIT)
	{

		//Initulize:
		CVarValue[SUITCASEINIT] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_EXPLODEPDINIT)
	{

		//Initulize:
		CVarValue[EXPLODEPDINIT] = StringToInt(newValue);
	}
}

public int GetRobTime()
{

	//Return:
	return view_as<int>(CVarValue[ROBTIME]);
}

public int GetHackTime()
{

	//Return:
	return view_as<int>(CVarValue[HACKTIME]);
}

public int GetRobBankAmount()
{

	//Return:
	return view_as<int>(CVarValue[ROBBANK]);
}

public int GetHackBankAmount()
{

	//Return:
	return view_as<int>(CVarValue[HACKBANK]);
}

public int GetRobVendorAmount()
{

	//Return:
	return view_as<int>(CVarValue[ROBVENDOR]);
}

public int GetHackComputerAmount()
{

	//Return:
	return view_as<int>(CVarValue[HACKCOMPUTER]);
}

public int GetPlayerHackTime()
{

	//Return:
	return view_as<int>(CVarValue[PLAYERTIME]);
}

public int GetPlayerHackCash()
{

	//Return:
	return view_as<int>(CVarValue[PLAYERHACK]);
}


public int GetCrimeToBounty()
{

	//Return:
	return view_as<int>(CVarValue[CRIMEBOUNTY]);
}


public int IsCuffDamageDisabled()
{

	//Return:
	return view_as<int>(CVarValue[CUFFDAMAGE]);
}

public int IsCopKillDisabled()
{

	//Return:
	return view_as<int>(CVarValue[COPKILL]);
}

public int IsPhysDamageDisabled()
{

	//Return:
	return view_as<int>(CVarValue[PHYSDAMAGE]);
}

public int IsCopUnCuffDisabled()
{

	//Return:
	return view_as<int>(CVarValue[ALLCOPUNCUFF]);
}

public int IsHungerDisabled()
{

	//Return:
	return view_as<int>(CVarValue[HUNGER]);
}

public int IsQuickDepositDisabled()
{

	//Return:
	return view_as<int>(CVarValue[DEPOSIT]);
}

public int GetSpawnProtectTime()
{

	//Return:
	return view_as<int>(CVarValue[PROTECT]);
}

public bool GetCheatsEnabled()
{

	//Return:
	return view_as<bool>(intTobool(CVarValue[CHEATS]));
}

public int GetCrateSpawnTimer()
{

	//Return:
	return view_as<int>(CVarValue[CRATEINIT]);
}

public int GetBombSpawnTimer()
{

	//Return:
	return view_as<int>(CVarValue[BOMBINIT]);
}

public int GetFireSpawnTimer()
{

	//Return:
	return view_as<int>(CVarValue[FIREINIT]);
}

public int GetAnomalySpawnTimer()
{

	//Return:
	return view_as<int>(CVarValue[ANOMALYINIT]);
}

public int GetIonCannonSpawnTimer()
{

	//Return:
	return view_as<int>(CVarValue[IONCANNON]);
}

public int IsLockdownDisabled()
{

	//Return:
	return view_as<int>(CVarValue[LOCKDOWN]);
}

public int GetMaxDoorsOwn()
{

	//Return:
	return view_as<int>(CVarValue[MAXDOORSOWN]);
}

public int GetMinRespawnTime()
{

	//Return:
	return view_as<int>(CVarValue[MINIMUMRESPAWN]);
}

public int GetPropTimeLimit()
{

	//Return:
	return view_as<int>(CVarValue[DELETEPROPTIMER]);
}

public bool IsCopWeaponDropDisabled()
{

	//Return:
	return view_as<bool>(intTobool(CVarValue[DISABLECOPDROP]));
}

public bool IsCopMoneyDropDisabled()
{

	//Return:
	return view_as<bool>(intTobool(CVarValue[COPMONEDROP]));
}

public int GetLotteryDuration()
{

	//Return:
	return view_as<int>(CVarValue[LOTTERYDURATION]);
}

public int GetLotteryChance()
{

	//Return:
	return view_as<int>(CVarValue[LOTTERYCHANCE]);
}

public int GetLotterTicketPrice()
{

	//Return:
	return view_as<int>(CVarValue[LOTTERYTICKETPRICE]);
}

public int GetSuitCaseDropTimer()
{

	//Return:
	return view_as<int>(CVarValue[SUITCASEINIT]);
}

public int GetExplodePdTimerDuration()
{

	//Return:
	return view_as<int>(CVarValue[EXPLODEPDINIT]);
}

//Server Returns:
public ConVar GetCheatsConVar()
{

	//Return:
	return SV_CHEATS;
}
public ConVar GetForceCameraConVar()
{

	//Return:
	return MP_FORCECAMERA;
}