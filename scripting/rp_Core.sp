//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

//Terminate:
#pragma semicolon		1
#pragma newdecls		required
#pragma dynamic			4194304

//Includes:
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <masterrp>


#include <dhooks>

#include <colors>



//Version:
#define MAINVERSION		"5.55.55"

//Defined Chat colors
#define PREFIX		"{red}|RP|{white} -"
#define COLORRED	"{red}"
#define COLORGREEN	"{green}"
#define COLORWHITE	"{white}"

/*Define the game that you to compile for!*/ 
#define HL2DM
/*Define the Sourcemod Conversion files that you to compile!*/
/*Do not remove any of these first defines*/

//Main Includes:
#include "MasterRP/rp_forwards.sp"
#include "MasterRP/rp_stock.sp"
#include "MasterRP/rp_dhooks.sp"
#include "MasterRP/rp_dhooksplayer.sp"
#include "MasterRP/rp_dhooksentity.sp"
#include "MasterRP/rp_entity.sp"
#include "MasterRP/rp_sdkcalls.sp"
#include "MasterRP/rp_multigame.sp"
#include "MasterRP/rp_native.sp"

#if defined HL2DM
#include "MasterRP/rp_customguns.inc"
#endif
/*Do not remove any of these first defines*/

#if defined CSS
#include <cstrike>
#endif
#if defined CSGO
#include <cstrike>
#endif
#if defined TF2
#include <tf2>
#include <tf2_stocks>
#endif
#if defined TF2BETA
#include <tf2>
#include <tf2_stocks>
#endif
/*Do not remove any of these first defines*/

//Server Includes:
#include "MasterRP/server/rp_cvar.sp"
#include "MasterRP/server/rp_attachedeffects.sp"
#include "MasterRP/server/rp_forwardsmessages.sp"
#include "MasterRP/server/rp_hl2dmfixes.sp"
#include "MasterRP/server/rp_init.sp"
#include "MasterRP/server/rp_spawns.sp"
#include "MasterRP/server/rp_sql.sp"
#include "MasterRP/server/rp_talkzone.sp"
#include "MasterRP/server/rp_talksounds.sp"
#include "MasterRP/server/rp_teamfix.sp"
#include "MasterRP/server/rp_teamname.sp"
#include "MasterRP/server/rp_weaponmod.sp"
#include "MasterRP/server/rp_notice.sp"
#include "MasterRP/server/rp_npcnotice.sp"
#include "MasterRP/server/rp_props.sp"
#include "MasterRP/server/rp_light.sp"
#include "MasterRP/server/rp_scanner.sp"
#include "MasterRP/server/rp_precache.sp"
#include "MasterRP/server/rp_viewmanagement.sp"
#include "MasterRP/server/rp_unlocker.sp"
#include "MasterRP/server/rp_afkmanage.sp"

//Vendor Includes:
#include "MasterRP/vendor/rp_npc.sp"
#include "MasterRP/vendor/rp_bank.sp"
#include "MasterRP/vendor/rp_vendorbuy.sp"
#include "MasterRP/vendor/rp_vendorresell.sp"
#include "MasterRP/vendor/rp_vendordrugs.sp"
#include "MasterRP/vendor/rp_vendorexptrade.sp"
#include "MasterRP/vendor/rp_vendorhardware.sp"
#include "MasterRP/vendor/rp_vendorcars.sp"
#include "MasterRP/vendor/rp_copranking.sp"
#include "MasterRP/vendor/rp_lottery.sp"

//jobs Includes:
#include "MasterRP/jobs/rp_garbagezone.sp"
#include "MasterRP/jobs/rp_computer.sp"
#include "MasterRP/jobs/rp_jobhelper.sp"
#include "MasterRP/jobs/rp_jobmenu.sp"
#include "MasterRP/jobs/rp_jobsetup.sp"
#include "MasterRP/jobs/rp_jobsystem.sp"
#include "MasterRP/jobs/rp_jobexperience.sp"
#include "MasterRP/jobs/rp_thumpers.sp"
#include "MasterRP/jobs/rp_jail.sp"
#include "MasterRP/jobs/rp_gangsystem.sp"
#include "MasterRP/jobs/rp_trappropeller.sp"
#include "MasterRP/jobs/rp_serversafe.sp"
#include "MasterRP/jobs/rp_moneysafe.sp"
#include "MasterRP/jobs/rp_carmod.sp"
#include "MasterRP/jobs/rp_copcars.sp"
#include "MasterRP/jobs/rp_pdcomputer.sp"
#include "MasterRP/jobs/rp_cosino.sp"
#include "MasterRP/jobs/rp_trading.sp"
#include "MasterRP/jobs/rp_marketplace.sp"
#include "MasterRP/jobs/rp_gunshopweapons.sp"
#include "MasterRP/jobs/rp_rockzone.sp"
#include "MasterRP/jobs/rp_vendorrobbing.sp"
#include "MasterRP/jobs/rp_bankhacking.sp"
#include "MasterRP/jobs/rp_bankrobbing.sp"
#include "MasterRP/jobs/rp_employrobbing.sp"
#include "MasterRP/jobs/rp_prisonpod.sp"

//Events Includes:
#include "MasterRP/events/rp_firezone.sp"
#include "MasterRP/events/rp_bombzone.sp"
#include "MasterRP/events/rp_cratezone.sp"
#include "MasterRP/events/rp_anomalyzone.sp"
#include "MasterRP/events/rp_ioncannon.sp"
#include "MasterRP/events/rp_spin.sp"
#include "MasterRP/events/rp_suitcase.sp"
#include "MasterRP/events/rp_explodepd.sp"

#if defined HL2DM
//Dynamic:
#include "MasterRP/events/rp_lockdown.sp"
#include "MasterRP/events/rp_policeboss.sp"
#include "MasterRP/events/rp_antlionboss.sp"
#include "MasterRP/events/rp_antlion.sp"
#include "MasterRP/events/rp_vortigaunt.sp"
#include "MasterRP/events/rp_zombie.sp"
#endif

//Client Includes:
#include "MasterRP/client/rp_laststats.sp"
#include "MasterRP/client/rp_tracers.sp"
#include "MasterRP/client/rp_playermenu.sp"
#include "MasterRP/client/rp_hats.sp"
#include "MasterRP/client/rp_defaults.sp"
#include "MasterRP/client/rp_hud.sp"
#include "MasterRP/client/rp_player.sp"
#include "MasterRP/client/rp_playerhacking.sp"
#include "MasterRP/client/rp_iscritical.sp"
#include "MasterRP/client/rp_donator.sp"
#include "MasterRP/client/rp_settings.sp"
#include "MasterRP/client/rp_jetpack.sp"
#include "MasterRP/client/rp_cough.sp"
#include "MasterRP/client/rp_nokillzone.sp"
#include "MasterRP/client/rp_spawnprotect.sp"
#include "MasterRP/client/rp_sleeping.sp"
#include "MasterRP/client/rp_trail.sp"
#include "MasterRP/client/rp_crime.sp"
#include "MasterRP/client/rp_doublejump.sp"

//Custom npcs Includes:
#include "MasterRP/npcs/rp_npcdynamic.sp"
#include "MasterRP/npcs/rp_npcevent.sp"
#if defined HL2DM
#include "MasterRP/npcs/rp_npcantlion.sp"
#include "MasterRP/npcs/rp_npcantlionguard.sp"
#include "MasterRP/npcs/rp_npcichthyosaur.sp"
#include "MasterRP/npcs/rp_npchelicopter.sp"
#include "MasterRP/npcs/rp_npcvortigaunt.sp"
#include "MasterRP/npcs/rp_npcdog.sp"
#include "MasterRP/npcs/rp_npcstrider.sp"
#include "MasterRP/npcs/rp_npcmetropolice.sp"
#include "MasterRP/npcs/rp_npczombie.sp"
#include "MasterRP/npcs/rp_npcpoisonzombie.sp"
#include "MasterRP/npcs/rp_npcheadcrab.sp"
#include "MasterRP/npcs/rp_npcheadcrabfast.sp"
#include "MasterRP/npcs/rp_npcheadcrabblack.sp"
#include "MasterRP/npcs/rp_npcturretfloor.sp"
#include "MasterRP/npcs/rp_npcadvisor.sp"
#include "MasterRP/npcs/rp_npccrabsynth.sp"
#include "MasterRP/npcs/rp_npcmanhack.sp"
#include "MasterRP/npcs/rp_npcfastzombie.sp"
#include "MasterRP/npcs/rp_npcrollermine.sp"
#include "MasterRP/npcs/rp_npccombines.sp"
#include "MasterRP/npcs/rp_npcscanner.sp"
#include "MasterRP/npcs/rp_npcvortigauntslave.sp"
#include "MasterRP/npcs/rp_npcdogpet.sp"
#endif

//Door System:
#include "MasterRP/doors/rp_admindoors.sp"
#include "MasterRP/doors/rp_doorsystem.sp"
#include "MasterRP/doors/rp_doorlocked.sp"
#include "MasterRP/doors/rp_copdoors.sp"
#include "MasterRP/doors/rp_doormisc.sp"
#include "MasterRP/doors/rp_vipdoors.sp"
#include "MasterRP/doors/rp_publicdoors.sp"
#include "MasterRP/doors/rp_firefighterdoors.sp"
#include "MasterRP/doors/rp_doorsautoopen.sp"
#include "MasterRP/doors/rp_dooritems.sp"


//Core Item System:
#include "MasterRP/items/rp_items.sp"
#include "MasterRP/items/rp_itemlist.sp"

//Spawnable Items:
#include "MasterRP/items/rp_dropped.sp"
#include "MasterRP/items/rp_savespawneditems.sp"
#include "MasterRP/items/rp_savedrugs.sp"

//General Items:
#include "MasterRP/items/misc/rp_propanetank.sp"
#include "MasterRP/items/misc/rp_rice.sp"
#include "MasterRP/items/misc/rp_bomb.sp"
#include "MasterRP/items/misc/rp_microwave.sp"
#include "MasterRP/items/misc/rp_shield.sp"
#include "MasterRP/items/misc/rp_firebomb.sp"
#include "MasterRP/items/misc/rp_smokebomb.sp"
#include "MasterRP/items/misc/rp_waterbomb.sp"
#include "MasterRP/items/misc/rp_plasmabomb.sp"
#include "MasterRP/items/misc/rp_fireextinguisher.sp"

//Energy Items:
#include "MasterRP/items/energy/rp_generator.sp"
#include "MasterRP/items/energy/rp_battery.sp"
#include "MasterRP/items/energy/rp_printers.sp"
#include "MasterRP/items/energy/rp_bitcoinmine.sp"
#include "MasterRP/items/energy/rp_gunlab.sp"

//Drug Plant Items:
#include "MasterRP/items/drug/rp_lamp.sp"
#include "MasterRP/items/drug/rp_plant.sp"
#include "MasterRP/items/drug/rp_harvestseeds.sp"
#include "MasterRP/items/drug/rp_bong.sp"

//Meth Items:
#include "MasterRP/items/meth/rp_meth.sp"
#include "MasterRP/items/meth/rp_phosphorutank.sp"
#include "MasterRP/items/meth/rp_sodiumtub.sp"
#include "MasterRP/items/meth/rp_hcacidtub.sp"
#include "MasterRP/items/meth/rp_acetonecan.sp"

//Pills Items:
#include "MasterRP/items/pills/rp_pills.sp"
#include "MasterRP/items/pills/rp_toulene.sp"
#include "MasterRP/items/pills/rp_sacidtub.sp"
#include "MasterRP/items/pills/rp_ammonia.sp"

//Cocain Items:
#include "MasterRP/items/cocain/rp_cocain.sp"
#include "MasterRP/items/cocain/rp_erythroxylum.sp"
#include "MasterRP/items/cocain/rp_benzocaine.sp"
