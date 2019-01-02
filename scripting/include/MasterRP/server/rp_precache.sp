//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_precache_included_
  #endinput
#endif
#define _rp_precache_included_

//Roleplay Core:
char DownloadPath[256];

public void InitPrecache()
{

	//Config DB:
    	BuildPath(Path_SM, DownloadPath, 64, "data/roleplay/download.txt");
}

public void PrecacheItems()
{

    	//Auto Downloader
	Handle Vault = OpenFile(DownloadPath, "r");

	//Declare:
	char buffer[5120];

	//Switch:
	while(ReadFileLine(Vault, buffer, sizeof(buffer)))
	{

		//Declare:
		int len = strlen(buffer);

		//Not Null:
		if(buffer[len-1] == '\n')
			buffer[--len] = '\0';

		//Is File:
		if(FileExists(buffer))
		{

			AddFileToDownloadsTable(buffer);

			//Print:
			//PrintToServer("%s               -Custom", buffer);
		}

		//Override:
		else
		{

			//Print:
			//PrintToServer("%s               -Non-Custom", buffer);
		}

		if(StrContains(buffer, ".mdl", false) == 0)
			PrecacheModel(buffer, true);

		if(StrContains(buffer, ".wav", false) == 0)
			PrecacheSound(buffer, true);

		if(StrContains(buffer, ".mp3", false) == 0)
			PrecacheSound(buffer, true);
        
		if(IsEndOfFile(Vault))
			break;
	}

	//Close:
	CloseHandle(Vault);



	PrecacheModel("models/props_trainstation/payphone001a.mdl");

	PrecacheModel("models/props_lab/cactus.mdl");

	PrecacheModel("models/money/broncoin.mdl");

	PrecacheModel("models/money/silvcoin.mdl");

	PrecacheModel("models/money/goldcoin.mdl");

	PrecacheModel("models/money/note3.mdl");

	PrecacheModel("models/money/note2.mdl");

	PrecacheModel("models/money/note1.mdl");

	PrecacheModel("models/money/goldbar.mdl");

	PrecacheModel("models/props_c17/consolebox01a.mdl");

	PrecacheModel("models/props_lab/reciever01a.mdl");

	PrecacheModel("models/props_lab/monitor01b.mdl");

	PrecacheModel("models/props_c17/doll01.mdl");

	PrecacheModel("models/pot/pot.mdl");

	PrecacheModel("models/pot/pot_stage2.mdl");

	PrecacheModel("models/pot/pot_stage3.mdl");

	PrecacheModel("models/pot/pot_stage4.mdl");

	PrecacheModel("models/pot/pot_stage5.mdl");

	PrecacheModel("models/pot/pot_stage6.mdl");

	PrecacheModel("models/pot/pot_stage7.mdl");

	PrecacheModel("models/pot/pot_stage8.mdl");

	PrecacheModel("models/props_citizen_tech/firetrap_propanecanister01a.mdl");

	PrecacheModel("models/props_industrial/gascanister02.mdl");

	PrecacheModel("models/props_industrial/gascanister01.mdl");

	PrecacheModel("models/john/euromoney.mdl");

	PrecacheModel("models/winningrook/gtav/meth/acetone/acetone.mdl");

	PrecacheModel("models/winningrook/gtav/meth/ammonia/ammonia.mdl");

	PrecacheModel("models/winningrook/gtav/meth/hcacid/hcacid.mdl");

	PrecacheModel("models/winningrook/gtav/meth/lithium_battery/lithium_battery.mdl");

	PrecacheModel("models/winningrook/gtav/meth/phosphoru/phosphoru.mdl");

	PrecacheModel("models/winningrook/gtav/meth/sacid/sacid.mdl");

	PrecacheModel("models/winningrook/gtav/meth/sodium/sodium.mdl");

	PrecacheModel("models/winningrook/gtav/meth/toulene/toulene.mdl");

	PrecacheModel("models/props_interiors/furniture_lamp01a.mdl");

	PrecacheModel("models/props_combine/combine_light001a.mdl");

	PrecacheModel("models/props_junk/glassjug01.mdl");

	PrecacheModel("models/generator/generator_base.mdl");

	PrecacheModel("models/azok30_compresseur_air/azok30_compresseur_air.mdl");


	PrecacheModel("models/advisor.mdl");

	PrecacheModel("models/advisor_ragdoll.mdl");

	PrecacheModel("models/synth.mdl");

	PrecacheModel("models/props_combine/breenpod_inner.mdl");

	PrecacheModel("models/blodia/buggy.mdl");

	PrecacheModel("models/buggy.mdl");

	PrecacheModel("models/combine_apc.mdl");

	PrecacheModel("models/props_c17/trappropeller_blade.mdl");

	PrecacheModel("models/props/cs_office/fire_extinguisher.mdl");

	PrecacheModel("models/zombie/fast.mdl");

	PrecacheModel("models/gibs/hgibs.mdl");

	PrecacheModel("models/golf/golf.mdl");

	PrecacheModel("models/props_combine/headcrabcannister01a.mdl");

	PrecacheModel("models/props_combine/headcrabcannister01b.mdl");

	//PreCache Sound:
	PrecacheSound("buttons/lightswitch2.wav");

	PrecacheSound("npc/turret_floor/ping.wav");

	PrecacheSound("music/jihad.wav");

	PrecacheSound("buttons/button2.wav");

	PrecacheSound("buttons/button3.wav");

	PrecacheSound("ambient/machines/engine1.wav");

	PrecacheSound("ambient/explosions/explode_5.wav");

	PrecacheSound("vehicles/airboat/fan_blade_fullthrottle_loop1.wav");

	PrecacheSound("city8/city8-jw.wav");

	PrecacheSound("city8/city8-inspection.wav");

	PrecacheSound("ambient/alarms/citadel_alert_loop2.wav");

	PrecacheSound("ambient/levels/labs/electric_explosion5.wav");

	PrecacheSound("roleplay/regen.mp3");

	PrecacheSound("roleplay/cashregister.wav");

	//Canister:
	PrecacheSound("npc/env_headcrabcanister/launch.wav");

	PrecacheSound("npc/env_headcrabcanister/incoming.wav");

	PrecacheSound("npc/env_headcrabcanister/explosion.wav");

	PrecacheSound("npc/env_headcrabcanister/hiss.wav");

	PrecacheSound("ambient/levels/canals/headcrab_canister_open1.wav");

	//Drugs:
	PrecacheModel("models/props_lab/jar01a.mdl");

	PrecacheModel("models/props_lab/jar01b.mdl");

	PrecacheModel("models/striker/nicebongstriker.mdl");

	PrecacheModel("models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl");

	PrecacheModel("models/katharsmodels/contraband/metasync/blue_sky.mdl");

	PrecacheModel("models/srcocainelab/ziplockedcocaine.mdl");

	PrecacheModel("models/cocn.mdl");

	//Resources
	PrecacheModel("models/props_debris/concrete_chunk05g.mdl");

	PrecacheModel("models/props_debris/concrete_chunk04a.mdl");

	PrecacheModel("models/props_debris/concrete_chunk09a.mdl");

	//Metal:
	PrecacheModel("models/gibs/metal_gib1.mdl");

	PrecacheModel("models/gibs/metal_gib2.mdl");

	PrecacheModel("models/gibs/metal_gib3.mdl");

	PrecacheModel("models/gibs/metal_gib4.mdl");

	PrecacheModel("models/gibs/metal_gib5.mdl");

	//Combine:
	PrecacheModel("models/combine_helicopter.mdl");
}
