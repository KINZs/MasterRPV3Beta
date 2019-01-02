//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendorhardware_included_
  #endinput
#endif
#define _rp_vendorhardware_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//On Client Attempt To Sell Item:
public bool OnPreHandleHardWareVendorTouch(int Ent, int OtherEnt)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(OtherEnt, ClassName, sizeof(ClassName));

	//Prop Battery:
	if(StrEqual(ClassName, "prop_Battery"))
	{

		//Declare:
		int Client = GetBatteryOwnerFromEnt(OtherEnt);

		int Id = GetBatteryIdFromEnt(OtherEnt);

		//Check:
		if(GetBatteryEnergy(Client, Id) > 250.0)
		{

			//Declare:
			int AddCash = (RoundFloat(GetBatteryEnergy(Client, Id)) * 4);

			//Initulize:
			SetCash(Client, (GetCash(Client) + AddCash));

			//Remove From DB:
			RemoveSpawnedItem(Client, 23, Id);

			//Remove:
			RemoveBattery(Client, Id, false);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You have sold a battery for \x0732CD32%s\x07FFFFFF!", IntToMoney(AddCash));

			//Return:
			return true;
		}

		//Override:
		else
		{

			//Print:
			OverflowMessage(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You can't sell this battery as it doesn't have enough charge!");
		}
	}

	//Prop Battery:
	if(StrEqual(ClassName, "prop_Plant_Drug"))
	{

		//Declare:
		int Client = GetPlantOwnerFromEnt(OtherEnt);

		int Id = GetPlantIdFromEnt(OtherEnt);

		//Check:
		if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client) && IsClientInGame(Client) && Id > 0)
		{

			//Is Plant Ready:
			if(GetIsPlanted(Client, Id) > 0)
			{

				//Is Plant Ready:
				if(GetIsPlanted(Client, Id) == 1)
				{

					//Declare:
					int Earns = RoundFloat(GetPlantGrams(Client, Id) * 3.7);

					//Initulize:
					SetCash(Client, (GetCash(Client) + Earns));

					//Set Menu State:
					CashState(Client, Earns);

					//Initulize:
					SetCrime(Client, (GetCrime(Client) + RoundFloat(GetPlantGrams(Client, Id))));

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You have sold \x0732CD32%ig\x07FFFFFF for \x0732CD32%s\x07FFFFFF!", RoundFloat(GetPlantGrams(Client, Id)), IntToMoney(Earns));

					//Remove From DB:
					RemoveSpawnedItem(Client, 1, Id);

					//Remove:
					RemovePlant(Client, Id);

					//Return:
					return true;
				}

				//Override:
				else
				{

					//Print:
					OverflowMessage(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You can't sell this plant because it hasn't finished growing yet!");
				}
			}

			//Override:
			else
			{

				//Print:
				OverflowMessage(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You can't sell this plant because it wasn't grown anything!");
			}
		}
	}

	//Prop Battery:
	if(StrContains(ClassName, "weapon", false) != -1)
	{

		//Initulize:
		int Owner = GetEntPropEnt(OtherEnt, Prop_Data, "m_hOwnerEntity");
		//int Owner = GetPhysCannonPickupItem(int Client);

		//Print:
		//PrintToServer("|RP| - Entity %i, owner %i",OtherEnt, Owner);

		if(Owner > 0)
		{

			int ItemId = ConvertWeaponToItem(ClassName);

			int Earns = RoundFloat(float(GetItemCost(ItemId)) / 1.2);

			//Initulize:
			SetCash(Owner, (GetCash(Owner) + Earns));

			//Set Menu State:
			CashState(Owner, Earns);

			//Print:
			CPrintToChat(Owner, "\x07FF4040|RP-Drug|\x07FFFFFF - You have sold \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF!", ClassName, IntToMoney(Earns));

			//Remove Weapon:
			AcceptEntityInput(OtherEnt, "Kill");

			//Return:
			return true;
		}	
	}

	//Return:
	return false;
}
