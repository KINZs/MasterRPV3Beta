//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_init_included_
  #endinput
#endif
#define _rp_init_included_

//Server int
int HudTimer = -1;
int TeamTimer = -1;

//Server Timer Handle:
Handle hTimer = INVALID_HANDLE;

//Server RunTime
int RunTime = 0;

public void initHudTicker()
{

	//Initulize:
	RunTime = GetTime();

	//Draw Player Hud:
	hTimer = CreateTimer(0.1, initMainModTicker, _, TIMER_REPEAT);
}

public void StopHudTicker()
{

	//Kill:
	KillTimer(hTimer);

	//Initulize:
	hTimer = INVALID_HANDLE;
}

//Client Hud:
public Action initMainModTicker(Handle Timer)
{

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client) && !IsFakeClient(Client))
		{

			//Int JetPack:
			initJetPackTimer(Client, HudTimer);

			//Player Trail Effects:
			initPlayerTrailEffects(Client, HudTimer);
		}
	}

	//Entity Notice: Dont Remove!
	initClientEntityNotice(HudTimer);

	//Init Effect:
	intAnomalyEffectTimer(TeamTimer);

	//Create Generator Timer Init:
	initGeneratorTime(HudTimer);

	//Car Mod:
	initCarModThink();

	//Switch:
	switch(HudTimer)
	{

		case 1:
		{

			//Create Erythroxylum Timer Init:
			initErythroxylumTime();

			//Create Water Bomb Timer Init:
			initWaterBombTime();

			//Create Plasma Bomb Timer Init:
			initPlasmaBombTime();

			//Create Fire Extinguisher Timer Init:
			initFireExtinguisherTime();
#if defined HL2DM
			//Create AntLion Boss Timer Init:
			initAntLionBossTimer();
#endif
			//Create Employer Rob Timer Init:
			initEmployerRobbing();
		}

		case 2:
		{

			//Create Bong Timer Init:
			initBongTime();

			//Create Printer Timer Init:
			initPrintTime();

			//Create Meth Timer Init:
			initMethTime();

			//Create Pills Timer Init:
			initPillsTime();

			//Create Global Bomb Timer Init:
			initGlobalBombTick();
#if defined HL2DM
			//Create AntLion Timer Init:
			initAntLionTimer();
#endif
		}

		case 3:
		{

			//Create Benzocaine Timer Init:
			initBenzocaineTime();

			//Create Plant Timer Init:
			initPlantTime();

			//Create Cocain Timer Init:
			initCocainTime();

			//Create Rice Timer Init:
			initRiceTime();

			//Create Anomaly Timer Init:
			initGlobalAnomalyTick();
#if defined HL2DM
			//Create Vortigaunt Timer Init:
			initVortigauntTimer();
#endif
		}

		case 4:
		{

			//Create Lamp Timer Init:
			initLampTime();

			//Create Bomb Timer Init:
			initBombTime();

			//Create Gun Lab Timer Init:
			initGunLabTime();

			//Create Battery Timer Init:
			initBatteryTime();

			//Create Global Fire Timer Init:
			initGlobalFireTick();
#if defined HL2DM
			//Create Zombie Timer Init:
			initZombieTimer();
#endif
		}

		case 5:
		{

			//Create SmokeBomb Timer Init:
			initSmokeBombTime();

			//Create Microwave Timer Init:
			initMicrowaveTime();

			//Create Shield Timer Init:
			initShieldTime();

			//Create Toulene Timer Init:
			initTouleneTime();

			//Create IonCannon Init:
			initGlobalIonCannonTick();
#if defined HL2DM
			//AntLionSpark: Dont Remove!
			SparkAntlionEffects();
#endif
		}

		case 6:
		{

			//Create Fire Bomb Timer Init:
			initFireBombTime();

			//Create SAcidTub Timer Init:
			initSAcidTubTime();

			//Create Money Safe Rob Timer Init:
			iRobTimer();
#if defined HL2DM
			//Create Lockdown Timer Init:
			initLockdownTimer();
#endif
			//Create Player Hack Init:
			initPlayerHacking();
		}

		case 7:
		{

			//Create BitCoin Mine Timer Init:
			initBitCoinMineTime();

			//Create Propane Tank Timer Init:
			initPropaneTankTime();

			//Create Ammonia Timer Init:
			initAmmoniaTime();

			//Vendor NPC Rob Timer:
			initVendorRobbing();

			//Server Rob Timer:
			iServerRobTimer();
#if defined HL2DM
			//Create Police Boss Timer Init:
			initPoliceBossTimer();
#endif
		}

		case 8:
		{

			//Create Phosphoru Tank Timer Init:
			initPhosphoruTankTime();

			//Create Sodium Tub Timer Init:
			initSodiumTubTime();

			//Create SAcid Tub Timer Init:
			initSAcidTubTime();

			//Banking NPC Rob Timer:
			initBankRobbing();

			//NPC Timer:
			intNpc();
		}

		case 9:
		{

			//Create Thumper Timer Init:
			initThumperRobbing();

			//Create HcAcid Tub Timer Init:
			initHcAcidTubTime();

			//Create Acetone Can Timer Init:
			initAcetoneCanTime();

			//Create Toulene Timer Init:
			initTouleneTime();

			//Crate Timer Init:
			initCrateTick();

			//Banking NPC Hack Timer:
			initBankHacking();
		}

		case 10:
		{

			//Create Seeds Timer Init:
			initSeedsTime();

			//Init Job System Timer
			initSalaryTimer();

			//Main Mod Ticker:
			initClientTick();
#if defined HL2DM
			//AntLionSpark: Dont Remove!
			SparkAntlionEffects();
#endif
			//Computer Hack Timer:
			initComputer();

			//SuitCase Timer
			initSuitCaseTick();

			//Initulize:
			HudTimer = 1;
		}
	}

	//Int every 2.5 sec to manage client team and world entities
	if(TeamTimer == 25)
	{

		//Change Model:
		ChangeGunShopWeaponModel();
	}

	//Int every 5 sec to manage client team and world entities
	if(TeamTimer >= 50)
	{

		//Initulize:
		TeamTimer = 0;

		//TeamFix:
		initManageClientTeam();

		//Entity Check:
		initIsCheckEntityOutSideOfWorld(); //

		initCheckPlayerAfkStatus();
	}

	//Initulize:
	HudTimer += 1;

	TeamTimer += 1;
}

public void initClientEntityNotice(int Time)
{

	//Declare:
	float NoticeInterval = 0.2;

	if(Time == 1 || Time == 3 || Time == 5 || Time == 7 || Time == 9)
	{

		//Loop:
		for(int Client = 1; Client <= GetMaxClients(); Client++)
		{

			//Connected:
			if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
			{

				//Check:
				if(IsPlayerAlive(Client) && !IsFakeClient(Client))
				{

					//Declare:
					int Ent = GetClientAimTarget(Client, false);

					//Is Enity:
					if(Ent > GetMaxClients() + 1 && IsValidEntity(Ent) && !LookingAtWall(Client))
					{

						//Show Hud:
						ShowEntityNotice(Client, Ent, NoticeInterval);
					}

					//Is Player
					if(Ent > 0 && Ent < GetMaxClients() && IsClientConnected(Ent) && !LookingAtWall(Client))
					{

						//Show Hud:
						ShowPlayerNotice(Client, Ent, NoticeInterval);
					}

					//Has GodMode:
					if(IsLoaded(Client) && GetGodMode(Client))
					{

						//Show Box:
						ShowGodModeBox(Client, NoticeInterval);
					}
				}
			}
		}
	}
}

public void initClientTick()
{

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client) && IsPlayerAlive(Client) && !IsFakeClient(Client))
		{

			//Has Hud Enabled?
			if(GetHudEnable(Client) == 1)
			{

				//Show Client Hud
				ShowClientHud(Client);

				//Draw Hud:
				ShowCrimeHud(Client);

				//Declare:
				int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

				//Check:
				if(IsValidEdict(InVehicle))
				{

					//Has Other Hud Disabled:
					if(GetHudOnline(Client) == 1)
					{

						//Draw Hud:
						showOnlineStats(Client);
					}
				}

				//Added Hud Info:
				else if(GetHudInfo(Client) == 1 && IsSleeping(Client) == -1)
				{

					//Is Admin:
					if(IsAdmin(Client))
					{

						//Draw Hud:
						showAdminStats(Client);
					}

					//Is Cop:
					else if(IsCop(Client))
					{

						//Draw Hud:
						showCopStats(Client);
					}

					//Override:
					else
					{

						//Draw Hud:
						showAddedStats(Client);
					}
				}

				//Has Other Hud Disabled:
				else if(GetHudOnline(Client) == 1)
				{

					//Draw Hud:
					showOnlineStats(Client);
				}
			}

			//Show Tracers:
			OnClientShowTracers(Client);

			//ManageNoKillZone:
			NokillZone(Client);

			//Init Jail Timer:
			IntJailTimer(Client);

			//Quick Check:
			ClientCriticalOverride(Client);

			//Init Drugs:
			OnDrugTick(Client);

			//Init Crime Removal and Bounty Check:
			initCrimeTimer(Client);
		}
	}
}

//Remove props that are outside in the void!
public void initIsCheckEntityOutSideOfWorld()
{

	//Declare:
	char ClassName[32];

	//Loop:
	for(int Ent = GetMaxClients(); Ent < 2047; Ent++)
	{

		//Valid:
		if(IsValidEdict(Ent))
		{

			//Get Entity Info:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Is Weaponp:
			if(StrContains(ClassName, "weapon", false) == 0 && !IsValidPropWeapon(Ent))
			{

				//Initulize:
				//GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

				//Check:
				//if(TR_PointOutsideWorld(Origin))

				//GetOwner: to stop Clients weapons from removing:
				int Client = GetEntPropEnt(Ent, Prop_Data, "m_hOwnerEntity");

				//Check:
				if(Client == -1)
				{

					//Request:
					RequestFrame(OnNextFrameKill, Ent);
				}
			}
		}
	}
}

public int GetRunTime()
{

	//Return:
	return view_as<int>(RunTime);
}