//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_savespawneditems_included_
  #endinput
#endif
#define _rp_savespawneditems_included_

#define MAXSPAWNEDITEMS		10

public void initSpawnedItems()
{

	//Timer:
	CreateTimer(4.0, CreateSQLdbSpawnedItems);
}

//Create Database:
public Action CreateSQLdbSpawnedItems(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `SpawnedItems`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) NULL, `ItemType` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `ItemId` int(12) NULL, `ItemTime` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `ItemValue` int(12) NULL, `IsSpecialItem` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `AddedData` varchar(256) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(64) NULL, `Angle` varchar(64) NULL);");


	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 136);
}

public void DBLoadSpawnedItems(int Client)
{
	//Declare:
	char query[255];

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Format:
	Format(query, sizeof(query), "SELECT * FROM SpawnedItems WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadSpawnedItems, query, conuserid);
}

public void T_DBLoadSpawnedItems(Handle owner, Handle hndl, const char[] error, any data)
{

	//Declare:
	int Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Player] T_DBLoadSpawnedItems: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Loading Spawned Items...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| No Spawned Items Detected!");
		}

		//Not Player:
		if(SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| Spawned Items Detected!");
		}

		//Declare:
		int SpawnId = 0;
		int Type = 0;
		int ItemTime = 0;
		int ItemValue = 0;
		int IsSpecialItem = 0;
		float Position[3];
		float Angle[3];
		char Buffer[64];
		char AddedItemData[64];
		char Dump[3][64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Type = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 2);

			//Database Field Loading Intiger:
			ItemTime = SQL_FetchInt(hndl, 3);

			//Database Field Loading Intiger:
			ItemValue = SQL_FetchInt(hndl, 4);

			//Database Field Loading Intiger:
			IsSpecialItem = SQL_FetchInt(hndl, 5);

			//Database Field Loading String:
			SQL_FetchString(hndl, 6, AddedItemData, 64);

			//Database Field Loading String:
			SQL_FetchString(hndl, 7, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 8, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 4, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Angle[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			Position[2] += 5;

			//Switch:
			switch(Type)
			{


				//Drugs:
				case 1:
				{

					//Convert:
					ExplodeString(AddedItemData, "^", Dump, 3, 64);

					//Initulize:
					float WaterLevel = StringToFloat(Dump[0]);

					float Grams = StringToFloat(Dump[1]);

					int Health = StringToInt(Dump[2]);

					//Spawn Drug Plant:
					CreatePlant(Client, SpawnId, ItemTime, Grams, WaterLevel, ItemValue, IsSpecialItem, Health, Position, Angle, true);
				}

				//Printers:
				case 2:
				{

					//Convert:
					ExplodeString(AddedItemData, "^", Dump, 2, 64);

					//Initulize:
					float Ink = StringToFloat(Dump[0]);

					int Health = StringToInt(Dump[1]);

					//Spawn Printer:
					CreatePrinter(Client, SpawnId, ItemTime, Ink, ItemValue, IsSpecialItem, Health, Position, Angle, true);
				}
			
				//Meth Kitchen:
				case 3:
				{

					//Initulize:
					float Grams = StringToFloat(AddedItemData);

					//Spawn Meth Kitchen:
					CreateMeth(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
				}

				//Pill Kitchen:
				case 4:
				{

					//Initulize:
					float Grams = StringToFloat(AddedItemData);

					//Spawn Pills Kitchen:
					CreatePills(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
				}

				//Cocain Kitchen:
				case 5:
				{

					//Initulize:
					float Grams = StringToFloat(AddedItemData);

					//Spawn Meth Kitchen:
					CreateCocain(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
				}

				//Rice:
				case 6:
				{

					//Spawn Rice Plant:
					CreateRice(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
				}

				//Bomb:
				case 7:
				{

					//Spawn Bomb:
					CreateBomb(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
				}

				//Gun Lab:
				case 8:
				{

					//Spawn Gun Lab:
					CreateGunLab(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
				}

				//Microwave:
				case 9:
				{

					//Spawn Gun Lab:
					CreateMicrowave(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
				}

				//Shield:
				case 10:
				{

					//Spawn Shield:
					CreateShield(Client, SpawnId, ItemTime, IsSpecialItem, Position, Angle, true);
				}

				//Fire Bomb:
				case 11:
				{

					//Spawn Microwave:
					CreateFireBomb(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
				}

				//Generator:
				case 12:
				{

					//Declare:
					float Energy2 = float(ItemTime);

					float Fuel = float(ItemValue);

					//Initulize:
					int Level = StringToInt(AddedItemData);

					//Spawn Generator:
					CreateGenerator(Client, SpawnId, Energy2, Fuel, Level, IsSpecialItem, Position, Angle, true);
				}

				//BitCoin Mine:
				case 13:
				{

					//Initulize:
					float Coin = StringToFloat(AddedItemData);

					//Spawn BitCoin Mine:
					CreateBitCoinMine(Client, SpawnId, Coin, ItemValue, IsSpecialItem, Position, Angle, true);
				}

				//Propane Tank:
				case 14:
				{

					//Initulize:
					float Fuel = StringToFloat(AddedItemData);

					//Spawn Propane Tank:
					CreatePropaneTank(Client, SpawnId, Fuel, ItemValue, IsSpecialItem, Position, Angle, true);
				}

				//Phosphoru Tank:
				case 15:
				{

					//Initulize:
					float Fuel = StringToFloat(AddedItemData);

					//Spawn Phosphoru Tank:
					CreatePhosphoruTank(Client, SpawnId, Fuel, IsSpecialItem, Position, Angle, true);
				}

				//Sodium Tub:
				case 16:
				{

					//Initulize:
					float Grams = StringToFloat(AddedItemData);

					//Spawn Sodium Tub Tank:
					CreateSodiumTub(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
				}

				//HcAcid Tub:
				case 17:
				{

					//Initulize:
					float Fuel = StringToFloat(AddedItemData);

					//Spawn HcAcid Tub Tank:
					CreateHcAcidTub(Client, SpawnId, Fuel, IsSpecialItem, Position, Angle, true);
				}

				//Acetone Can:
				case 18:
				{

					//Initulize:
					float Grams = StringToFloat(AddedItemData);

					//Spawn Acetone Can:
					CreateAcetoneCan(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
				}

				//Seeds:
				case 19:
				{

					//Spawn Seeds:
					CreateSeeds(Client, SpawnId, ItemValue, IsSpecialItem, Position, Angle, true);
				}

				//Lamp:
				case 20:
				{

					//Initulize:
					int DataType = StringToInt(AddedItemData);

					//Spawn Lamp:
					CreateLamp(Client, SpawnId, DataType, IsSpecialItem, Position, Angle, true);
				}

				//Erythroxylum:
				case 21:
				{

					//Initulize:
					float Fuel = StringToFloat(AddedItemData);

					//Spawn Erythroxylum:
					CreateErythroxylum(Client, SpawnId, Fuel, IsSpecialItem, Position, Angle, true);
				}

				//Benzocaine:
				case 22:
				{

					//Initulize:
					float Grams = StringToFloat(AddedItemData);

					//Spawn Benzocaine:
					CreateBenzocaine(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
				}

				//Battery:
				case 23:
				{

					//Initulize:
					float Energy2 = StringToFloat(AddedItemData);

					//Spawn Battery:
					CreateBattery(Client, SpawnId, Energy2, IsSpecialItem, Position, Angle, true);
				}

				//Toulene:
				case 24:
				{

					//Initulize:
					float Fuel = StringToFloat(AddedItemData);

					//Spawn Toulene:
					CreateToulene(Client, SpawnId, Fuel, IsSpecialItem, Position, Angle, true);
				}


				//SAvid Tub:
				case 25:
				{

					//Initulize:
					float Fuel = StringToFloat(AddedItemData);

					//Spawn SAcidTub:
					CreateSAcidTub(Client, SpawnId, Fuel, IsSpecialItem, Position, Angle, true);
				}


				//Ammonia:
				case 26:
				{

					//Initulize:
					float Grams = StringToFloat(AddedItemData);

					//Spawn SAcidTub:
					CreateAmmonia(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
				}


				//Bong:
				case 27:
				{

					//Spawn Bong:
					CreateBong(Client, SpawnId, IsSpecialItem, Position, Angle, true);
				}

				//Smoke Bomb:
				case 28:
				{

					//Spawn Smoke Bomb:
					CreateSmokeBomb(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
				}

				//Fire Bomb:
				case 29:
				{

					//Spawn Smoke Bomb:
					CreateFireBomb(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
				}

				//Plasma Bomb:
				case 30:
				{

					//Spawn Smoke Bomb:
					CreatePlasmaBomb(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
				}

				//Fire Extinguisher:
				case 31:
				{

					//Initulize:
					float Gas = StringToFloat(AddedItemData);

					//Spawn Fire Extinguisher:
					CreateFireExtinguisher(Client, SpawnId, Gas, Position, Angle, true);
				}

				//Fire Extinguisher:
				case 32:
				{

					//Convert:
					ExplodeString(AddedItemData, "^", Dump, 3, 64);

					//Initulize:
					float Fuel = StringToFloat(Dump[1]);

					//Initulize:
					int VehMetal = StringToInt(Dump[2]);

					//Create Vehicle
					CreateVehicleFromString(Client, true, Dump[0], -1, Position, Angle, ItemTime, ItemValue, Fuel, VehMetal);
				}

				//Default:
				default :
				{

					//Print:
					PrintToConsole(Client, "|RP| - Failed To spawn Item, Id - %i Type - %i", SpawnId, Type);
				} 
			}
		}
	}
}

public void InsertSpawnedItem(int Client, int Type, int Id, int Time, int Value, int Special, const char[] AddedData, float Position[3], float Angle[3])
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `SpawnedItems` WHERE STEAMID = %i AND ItemType = %i AND ItemId = %i;", SteamIdToInt(Client), Id, Type);

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Declare:
		char Pos[64];
		char Ang[64];

		//Sql String:
		Format(Pos, sizeof(Pos), "%f^%f^%f", Position[0], Position[1], Position[2]);

		//Sql String:
		Format(Ang, sizeof(Ang), "%f^%f^%f", Angle[0], Angle[1], Angle[2]);

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Declare:
		bool Fetch = SQL_FetchRow(hQuery);

		//Already Inserted:
		if(Fetch)
		{

			//Format:
			Format(query, sizeof(query), "UPDATE SpawnedItems SET ItemTime = %i, ItemValue = %i, IsSpecialItem = %i, AddedData = '%s', Position = '%s', Angle = '%s' WHERE STEAMID = %i AND ItemId = %i AND ItemType = %i;", Time, Value, Special, AddedData, Pos, Ang, SteamIdToInt(Client), Id, Type);
		}

		//Override:
		else
		{

			//Format:
			Format(query, sizeof(query), "INSERT INTO SpawnedItems (`STEAMID`,`ItemType`,`ItemId`,`ItemTime`,`ItemValue`,`IsSpecialItem`,`AddedData`,`Position`,`Angle`) VALUES (%i,%i,%i,%i,%i,%i,'%s','%s','%s');", SteamIdToInt(Client), Type, Id, Time, Value, Special, AddedData, Pos, Ang);
		}

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 137);
	}

	//Close:
	CloseHandle(hQuery);
}

public void RemoveSpawnedItem(int Client, int Type, int Id)
{

	//Declare:
	char buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "DELETE FROM SpawnedItems WHERE STEAMID = %i AND ItemType = %i AND ItemId = %i;", SteamIdToInt(Client), Type, Id);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer, 138);
}

public void SaveSpawnedItemForward(int Client, bool Disconnect)
{

	//Declare:
	int Ent = 1;

	//Loop:
	for(int X = 1; X <= MAXSPAWNEDITEMS; X++)
	{

		//Initulize:
		Ent = HasClientPlant(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f^%f^%i", GetPlantWaterLevel(Client, X), GetPlantGrams(Client, X), GetPlantHealth(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 1, X, GetPlantTime(Client, X), GetIsPlanted(Client, X), GetPlantType(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientPrinter(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f^%i", GetPrinterInk(Client, X), GetPrinterHealth(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 2, X, GetPrinterMoney(Client, X), GetPrinterPaper(Client, X), GetPrinterLevel(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientMeth(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetMethGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 3, X, 0, 0, GetMethHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientPills(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetPillsGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 4, X, 0, 0, GetPillsHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientCocain(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetCocainGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 5, X, 0, 0, GetCocainHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientRice(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 6, X, GetRiceTime(Client, X), GetRiceValue(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientBomb(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 7, X, GetBombUse(Client, X), GetBombExplode(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientGunLab(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 8, X, GetGunLabTime(Client, X), GetGunLabUse(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientMicrowave(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 9, X, GetMicrowaveTime(Client, X), GetMicrowaveValue(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientShield(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 10, X, GetShieldTime(Client, X), GetShieldValue(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientFireBomb(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 11, X, GetFireBombUse(Client, X), GetFireBombExplode(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientGenerator(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{
			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%i", GetGeneratorLevel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 12, X, RoundFloat(GetGeneratorEnergy(Client, X)), RoundFloat(GetGeneratorFuel(Client, X)), GetGeneratorHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientBitCoinMine(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetBitCoinMine(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 13, X, 0, GetBitCoinMineLevel(Client, X), GetBitCoinMineHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientPropaneTank(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetPropaneTankFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 14, X, 0, GetPropaneTankLevel(Client, X), GetPropaneTankHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientPhosphoruTank(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetPhosphoruTankFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 15, X, 0, 0, GetPhosphoruTankHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientSodiumTub(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetSodiumTubGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 16, X, 0, 0, GetSodiumTubHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientHcAcidTub(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetHcAcidTubFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 17, X, 0, 0, GetHcAcidTubHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientAcetoneCan(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetAcetoneCanGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 18, X, 0, 0, GetAcetoneCanHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientAcetoneCan(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 19, X, 0, GetSeedsType(Client, X), GetSeedsHealth(Client, X), "");
		}

		//Initulize:
		Ent = HasClientLamp(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%i", GetLampType(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 20, X, 0, 0, GetLampHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientErythroxylum(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetErythroxylumFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 21, X, 0, 0, GetErythroxylumHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientBenzocaine(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetBenzocaineGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 22, X, 0, 0, GetBenzocaineHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientBattery(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetBatteryEnergy(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 23, X, 0, 0, GetBatteryHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientToulene(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetTouleneFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 24, X, 0, 0, GetTouleneHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientToulene(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetSAcidTubFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 25, X, 0, 0, GetSAcidTubHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientAmmonia(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetAmmoniaGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 26, X, 0, 0, GetAmmoniaHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientBong(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 27, X, 0, 0, GetBongHealth(Client, X), "");
		}

		//Initulize:
		Ent = HasClientSmokeBomb(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 28, X, GetSmokeBombUse(Client, X), GetSmokeBombExplode(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientWaterBomb(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 29, X, GetWaterBombUse(Client, X), GetWaterBombExplode(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientPlasmaBomb(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 30, X, GetPlasmaBombUse(Client, X), GetPlasmaBombExplode(Client, X), 0, "");
		}

		//Initulize:
		Ent = GetPlayerVehicle(Client);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char ClassName[32];

			//Get Entity Info:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			int VehicleLocked = 0;

			//Check:
			if(!StrEqual(ClassName, "prop_vehicle_damaged") && StrContains(ClassName, "prop_vehicle", false) == 0)
			{

				//Initulize:
				VehicleLocked = GetEntProp(Ent, Prop_Data, "m_bLocked");
			}

			//Declare:
			int Health = 0;

			//Check:
			if(!StrEqual(ClassName, "prop_vehicle_damaged"))
			{

				//Initulize:
				Health = GetEntProp(Ent, Prop_Data, "m_iHealth");
			}

			//Declare:
			char AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%s^%f^%i", GetVehicleTypeFromModel(Ent), GetPlayerVehicleFuel(Ent), GetPlayerVehicleMetal(Ent));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 32, X, Health, VehicleLocked, 0, AddedData);

		}

		//Initulize:
		//Ent = HasClientFireExtinguisher(Client, X);

		//Check:
		//if(IsValidEdict(Ent))
		//{

			//Declare:
			//char AddedData[64];

			//Format:
			//Format(AddedData, sizeof(AddedData), "%f", GetFireExtinguisherGas(Client, X));

			//Update:
			//UpdateSpawnedItem(Client, Ent, Disconnect, 31, X, 0, 0, 0, AddedData);
		//}
	}
}

//Saves the Ownership of an Item
public void UpdateSpawnedItem(int Client, int Ent, bool Disconnect, int Type, int Id, int Time, int Value, int ExtraValue, const char[]AddedData)
{

	//Connected:
	if(IsClientConnected(Client))
	{

		//Declare:
		char query[512];
		char Pos[64];
		char Ang[64];
		float Position[3];
		float Angle[3];

		//Get Prop Data:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angle);

		//Sql String:
		Format(Pos, sizeof(Pos), "%f^%f^%f", Position[0], Position[1], Position[2]);

		Format(Ang, sizeof(Ang), "%f^%f^%f", Angle[0], Angle[1], Angle[2]);

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE SpawnedItems SET ItemTime = %i, ItemValue = %i, IsSpecialItem = %i, AddedData = '%s', Position = '%s', Angle = '%s' WHERE STEAMID = %i AND ItemId = %i AND ItemType = %i;", Time, Value, ExtraValue, AddedData, Pos, Ang, SteamIdToInt(Client), Id, Type);

		//Send Query:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 139);

		//Remove if Disconnected:
		if(Disconnect == true)
		{

			//Check:
			switch(Type)
			{

				//Check:
				case 1:
				{

					//Remove:
					RemovePlant(Client, Id);
				}

				//Check:
				case 2:
				{

					//Remove:
					RemovePrinter(Client, Id, false);
				}

				//Check:
				case 3:
				{

					//Remove:
					RemoveMeth(Client, Id);
				}

				//Check:
				case 4:
				{

					//Remove:
					RemovePills(Client, Id);
				}

				//Check:
				case 5:
				{

					//Remove:
					RemoveCocain(Client, Id);
				}

				//Check:
				case 6:
				{

					//Remove:
					RemoveRice(Client, Id);
				}

				//Check:
				case 7:
				{

					//Remove:
					RemoveBomb(Client, Id, false);
				}

				//Check:
				case 8:
				{

					//Remove:
					RemoveGunLab(Client, Id);
				}

				//Check:
				case 9:
				{

					//Remove:
					RemoveMicrowave(Client, Id);
				}

				//Check:
				case 10:
				{

					//Remove:
					RemoveShield(Client, Id);
				}

				//Check:
				case 11:
				{

					//Remove:
					RemoveFireBomb(Client, Id, false);
				}

				//Check:
				case 12:
				{

					//Remove:
					RemoveGenerator(Client, Id, false);
				}

				//Check:
				case 13:
				{

					//Remove:
					RemoveBitCoinMine(Client, Id, false);
				}

				//Check:
				case 14:
				{

					//Remove:
					RemovePropaneTank(Client, Id, false);
				}

				//Check:
				case 15:
				{

					//Remove:
					RemovePhosphoruTank(Client, Id, false);
				}

				//Check:
				case 16:
				{

					//Remove:
					RemoveSodiumTub(Client, Id);
				}

				//Check:
				case 17:
				{

					//Remove:
					RemoveHcAcidTub(Client, Id);
				}

				//Check:
				case 18:
				{

					//Remove:
					RemoveAcetoneCan(Client, Id);
				}

				//Check:
				case 19:
				{

					//Remove:
					RemoveSeeds(Client, Id);
				}

				//Check:
				case 20:
				{

					//Remove:
					RemoveLamp(Client, Id);
				}

				//Check:
				case 21:
				{

					//Remove:
					RemoveErythroxylum(Client, Id);
				}

				//Check:
				case 22:
				{

					//Remove:
					RemoveBenzocaine(Client, Id);
				}

				//Check:
				case 23:
				{

					//Remove:
					RemoveBattery(Client, Id, false);
				}

				//Check:
				case 24:
				{

					//Remove:
					RemoveToulene(Client, Id);
				}

				//Check:
				case 25:
				{

					//Remove:
					RemoveSAcidTub(Client, Id);
				}

				//Check:
				case 26:
				{

					//Remove:
					RemoveAmmonia(Client, Id);
				}

				//Check:
				case 27:
				{

					//Remove:
					RemoveBong(Client, Id);
				}

				//Check:
				case 28:
				{

					//Remove:
					RemoveSmokeBomb(Client, Id, false);
				}

				//Check:
				case 29:
				{

					//Remove:
					RemoveWaterBomb(Client, Id, false);
				}

				//Check:
				case 30:
				{

					//Remove:
					RemovePlasmaBomb(Client, Id, false);
				}

				//Check:
				case 31:
				{

					//Remove:
					RemoveFireExtinguisher(Client, Id);
				}


				//Check:
				case 32:
				{

					//Remove:
					RemovePlayerCar(Client);
				}

				//Default:
				default :
				{

					//Print:
					PrintToConsole(Client, "|RP| - Failed To Remove Item, Id - %i Type - %i", Id, Type);
				}
			}
		}
	}
}

public bool IsSpawnedItemSaved(int Client, int ItemType, int ItemId)
{

	//Declare:
	bool Result = false;
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM SpawnedItems WHERE STEAMID = %i AND ItemType = %i AND ItemId = %i;", SteamIdToInt(Client), ItemType, ItemId);

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Already Inserted:
		if(SQL_FetchRow(hQuery))
		{

			//Initulize:
			Result = true;
		}
	}

	//Close:
	CloseHandle(hQuery);

	//Return:
	return view_as<bool>(Result);
}