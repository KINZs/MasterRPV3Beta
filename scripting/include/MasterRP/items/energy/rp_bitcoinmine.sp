//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bitcoin_included_
  #endinput
#endif
#define _rp_bitcoin_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Define:
#define MAXITEMSPAWN		10

//BitCoin:
int BitCoinEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int BitCoinLevel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int BitCoinHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float BitCoin[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char BitCoinModel[256] = "models/bitminer/bitminerlight.mdl";

public void initBitCoinMine()
{

	//Commands:
	RegAdminCmd("sm_testbitcoinmine", Command_TestBitCoin, ADMFLAG_ROOT, "<Id> <Time> - Creates a BitCoin");
}

public void initDefaultBitCoinMine(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		BitCoinEnt[Client][X] = -1;

		BitCoinHealth[Client][X] = 0;

		BitCoinLevel[Client][X] = 0;

		BitCoin[Client][X] = 0.0;
	}
}

public int GetBitCoinMineIdFromEnt(int Ent)
{

	//Declare:
	int Result = -1;

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(int X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(BitCoinEnt[i][X] == Ent)
				{

					//Initulize:
					Result = X;

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Result;
}

public int HasClientBitCoinMine(int Client, int Id)
{

	//Is Valid:
	if(BitCoinEnt[Client][Id] > 0)
	{

		//Return:
		return BitCoinEnt[Client][Id];
	}

	//Return:
	return -1;
}

public float GetBitCoinMine(int Client, int Id)
{

	//Return:
	return BitCoin[Client][Id];
}

public void SetBitCoinMine(int Client, int Id, float Amount)
{

	//Initulize:
	BitCoin[Client][Id] = Amount;
}

public int GetBitCoinMineHealth(int Client, int Id)
{

	//Return:
	return BitCoinHealth[Client][Id];
}

public void SetBitCoinMineHealth(int Client, int Id, int Amount)
{

	//Initulize:
	BitCoinHealth[Client][Id] = Amount;
}

public int GetBitCoinMineLevel(int Client, int Id)
{

	//Return:
	return BitCoinLevel[Client][Id];
}

public void SetBitCoinMineLevel(int Client, int Id, int Amount)
{

	//Initulize:
	BitCoinLevel[Client][Id] = Amount;
}

public void OnBitCoinMineUse(int Client, int Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Is In Time:
		if(GetLastPressedE(Client) > (GetGameTime() - 1.5))
		{

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Loop:
					for(int X = 1; X < MAXITEMSPAWN; X++)
					{

						//Is Valid:
						if(BitCoinEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-BitCoin|\x07FFFFFF - You have to damage the BitCoin in order to distroy it!");

							}

							//Is Valid:
							else
							{

								//Check:
								if(BitCoin[i][X] > 0.0)
								{

									//Initulize:
									SetBitCoin(Client, (GetBitCoin(Client) + BitCoin[i][X]));

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-BitCoin|\x07FFFFFF - You have Collected %0.7fBTC!", BitCoin[i][X]);

									//Initulize:
									BitCoin[i][X] = 0.0;
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-BitCoin|\x07FFFFFF - You depleted this BitCoin Mine!");
								}
							}
						}
					}
				}
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-BitCoin|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF Again To Collect BitCoin!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public void initBitCoinMineTime()
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i) && !GetIsPlayerAfk(i))
		{

			//Loop:
			for(int X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(IsValidEdict(BitCoinEnt[i][X]))
				{

					//Check:
					if(!CheckGeneratorToBitCoinMine(i, X))
					{

						//Initulize:
						CheckBatteryToBitCoinMine(i, X);
					}
				}
			}
		}
	}
}

public void BitCoinMineHud(int Client, int Ent, float NoticeInterval)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(int X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(BitCoinEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Is Valid:
					if(BitCoinLevel[i][X] == 1)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "BitCoin Miner (Basic):\n%0.7fBTC\nHealth: %i", BitCoin[i][X], BitCoinHealth[i][X]);
					}

					//Is Valid:
					if(BitCoinLevel[i][X] == 2)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "BitCoin Miner (Advanced):\n%0.7fBTC\nHealth: %i", BitCoin[i][X], BitCoinHealth[i][X]);
					}

					//Is Valid:
					if(BitCoinLevel[i][X] == 3)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "BitCoin (Master) Miner:\n%0.7fBTC\nHealth: %i", BitCoin[i][X], BitCoinHealth[i][X]);
					}

					//Is Valid:
					if(BitCoinLevel[i][X] == 4)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "BitCoin (Ultimate) Miner:\n%0.7fBTC\nHealth: %i", BitCoin[i][X], BitCoinHealth[i][X]);
					}

					//Declare:
					float Pos[2] = {-1.0, -0.805};
					int Color[4];

					//Initulize:
					Color[0] = GetEntityHudColor(Client, 0);
					Color[1] = GetEntityHudColor(Client, 1);
					Color[2] = GetEntityHudColor(Client, 2);
					Color[3] = 255;

					//Check:
					if(GetGame() == 2 || GetGame() == 3)
					{

						//Show Hud Text:
						CSGOShowHudTextEx(Client, 1, Pos, Color, Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
					}

					//Override:
					else
					{

						//Show Hud Text:
						ShowHudTextEx(Client, 1, Pos, Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
					}
				}
			}
		}
	}
}

public void RemoveBitCoinMine(int Client, int X, bool Result)
{

	//Initulize:
	BitCoin[Client][X] = 0.0;

	BitCoinHealth[Client][X] = 0;

	BitCoinLevel[Client][X] = 0;

	//EntCheck:
	if(CheckMapEntityCount() < 2047 && Result && IsValidEdict(BitCoinEnt[Client][X]))
	{

		//Declare:
		float BitCoinOrigin[3];

		//Get Prop Data:
		GetEntPropVector(BitCoinEnt[Client][X], Prop_Send, "m_vecOrigin", BitCoinOrigin);

		//Temp Ent:
		TE_SetupSparks(BitCoinOrigin, NULL_VECTOR, 5, 5);

		//Send:
		TE_SendToAll();

		//Temp Ent:
		TE_SetupExplosion(BitCoinOrigin, Explode(), 5.0, 1, 0, 600, 5000);

		//Send:
		TE_SendToAll();
	}

	//Check:
	if(IsValidAttachedEffect(BitCoinEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(BitCoinEnt[Client][X]);
	}

	//Check
	if(IsValidEdict(BitCoinEnt[Client][X]) && BitCoinEnt[Client][X] > GetMaxClients())
	{

		//Request:
		RequestFrame(OnNextFrameKill, BitCoinEnt[Client][X]);
	}

	//Inituze:
	BitCoinEnt[Client][X] = -1;
}

public bool CreateBitCoinMine(int Client, int Id, float Coin, int Level, int Health, float Position[3], float Angle[3], bool IsConnected)
{

	//Check:
	if(IsConnected == false)
	{

		//Declare:
		float ClientOrigin[3];
		float EyeAngles[3];

		//Initialize:
		GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

		//Initialize:
  		GetClientEyeAngles(Client, EyeAngles);

		//Initialize:
		Position[0] = (ClientOrigin[0] + (FloatMul(100.0, Cosine(DegToRad(EyeAngles[1])))));

		Position[1] = (ClientOrigin[1] + (FloatMul(100.0, Sine(DegToRad(EyeAngles[1])))));

		Position[2] = (ClientOrigin[2] + 10);

		Angle = EyeAngles;

		//Check:
		if(TR_PointOutsideWorld(Position))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-BitCoin|\x07FFFFFF - Unable to spawn BitCoin due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Coin);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 13, Id, 0, Level, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-BitCoin|\x07FFFFFF - You have just spawned a BitCoin!");
	}

	//Initulize:
	BitCoin[Client][Id] = Coin;

	BitCoinLevel[Client][Id] = Level;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	BitCoinHealth[Client][Id] = Health;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", BitCoinModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	BitCoinEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientBitCoinMine);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_BitCoin_Mine");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (BitCoinHealth[Client][Id] / 2), (BitCoinHealth[Client][Id] / 2), 255);

	//Check:
	if(BitCoinHealth[Client][Id] > 0 && BitCoinHealth[Client][Id] <= 100)
	{

		//Initulize Effects:
		int Effect = CreateEnvFire(BitCoinEnt[Client][Id], "null", "200", "700", "0", "Natural");

		SetEntAttatchedEffect(BitCoinEnt[Client][Id], 1, Effect);
	}

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestBitCoin(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 4)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testbitcoin <Id> <Coin> <Level 1-4> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sCoin[32];
	char sLevel[32];
	char sHealth[32];
	int Id = 0;
	int Level = 0;
	int Health = 0;
	float Coin = 0.0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sCoin, sizeof(sCoin));

	//Initialize:
	GetCmdArg(3, sLevel, sizeof(sLevel));

	//Initialize:
	GetCmdArg(4, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Coin = StringToFloat(sCoin);

	Level = StringToInt(sLevel);

	Health = StringToInt(sHealth);

	if(BitCoinEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a BitCoin Mine with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid BitCoin %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//Create BitCoin:
	CreateBitCoinMine(Client, Id, Coin, Level, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsBitCoinMineUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-BitCoin|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-BitCoin|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		int MaxSlots = 1;

		//Declare:
		float ClientOrigin[3];
		float EyeAngles[3];

		//Initulize:
		GetClientAbsOrigin(Client, ClientOrigin);

		GetClientEyeAngles(Client, EyeAngles);

		//Declare:
		int Ent = -1;
		float Position[3];

		//Loop:
		for(int Y = 1; Y <= MaxSlots; Y++)
		{

			//Initulize:
			Ent = HasClientBitCoinMine(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//CreateBitCoin
				if(CreateBitCoinMine(Client, Y, 0.0, 1, 500, Position, EyeAngles, false))
				{

					//Save:
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Stop:
					break;
				}
			}

			//Override:
			else
			{

				//Too Many:
				if(Y == MaxSlots)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-BitCoin|\x07FFFFFF - You already have too many BitCoin Mines, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);

					//Stop:
					break;
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientBitCoinMine(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(BitCoinEnt[i][X] == Ent)
			{

				//Check:
				if(Ent2 > 0 && Ent2 <= GetMaxClients() && IsClientConnected(Ent2))
				{

					//Check:
					if(Ent2 == i)
					{

						//Declare:
						char WeaponName[32];

						//Initulize;
						GetClientWeapon(Ent2, WeaponName, sizeof(WeaponName));

						//Check:
						if(StrContains(WeaponName, GetRepairWeapon(), false) == 0)
						{

							//Initulize:
							if(BitCoinHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								BitCoinHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								BitCoinHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Check:
							if(BitCoinHealth[i][X] > 100)
							{

								//Declare:
								int TempEnt = GetEntAttatchedEffect(BitCoinEnt[i][X], 1);

								//Check:
								if(IsValidEdict(TempEnt))
								{

									//Kill:
									AcceptEntityInput(TempEnt, "kill");

									//Initulize:
									SetEntAttatchedEffect(TempEnt, 1, -1);
								}
							}
							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (BitCoinHealth[i][X] / 2), (BitCoinHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientBitCoinMine(BitCoinEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientBitCoinMine(BitCoinEnt[i][X], Damage, Ent2);
					}
				}

				//stop:
				break;
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public Action DamageClientBitCoinMine(int Ent, float &Damage, int &Attacker)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(int X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(BitCoinEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) BitCoinHealth[i][X] -= RoundFloat(Damage);

					//Check:
					if(BitCoinHealth[i][X] > 0 && BitCoinHealth[i][X] <= 100)
					{

						//Declare:
						int TempEnt = GetEntAttatchedEffect(BitCoinEnt[i][X], 1);

						//Check:
						if(!IsValidEdict(TempEnt) && BitCoinEnt[i][X] != -1)
						{

							//Explode:
							CreateExplosion(Attacker, BitCoinEnt[i][X]);

							//Initulize Effects:
							int Effect = CreateEnvFire(BitCoinEnt[i][X], "null", "200", "700", "0", "Natural");

							SetEntAttatchedEffect(BitCoinEnt[i][X], 1, Effect);
						}
					}

					//Check:
					if(BitCoinHealth[i][X] > 100)
					{

						//Declare:
						int TempEnt = GetEntAttatchedEffect(BitCoinEnt[i][X], 1);

						//Check:
						if(IsValidEdict(TempEnt))
						{

							//Kill:
							AcceptEntityInput(TempEnt, "kill");

							//Initulize:
							SetEntAttatchedEffect(TempEnt, 1, -1);
						}
					}

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (BitCoinHealth[i][X] / 2), (BitCoinHealth[i][X] / 2), 255);

					//Check:
					if(BitCoinHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 13, X);

						//Remove:
						RemoveBitCoinMine(i, X, true);
					}

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public bool IsBitCoinMineInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(BitCoinEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, BitCoinEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}

//Check to see if the generator is in distance
public bool CheckGeneratorToBitCoinMine(int Client, int Y)
{

	//Declare:
	int Ent = -1;

	//Switch:
	while ((Ent = FindEntityByClassname(Ent, "prop_Generator")) > 0)
	{

		//Check:
		if(IsInDistance(BitCoinEnt[Client][Y], Ent))
		{

			//Declare:
			int Id = GetGeneratorIdFromEnt(Ent);

			//Check:
			if(GetGeneratorEnergy(Client, Id) - 0.25 > 0)
			{

				//Initulize:
				SetGeneratorEnergy(Client, Id, (GetGeneratorEnergy(Client, Id) - 0.25));

				//Declare:
				int Random = GetRandomInt(1, 5);

				//Valid:
				if(Random <= 2)
				{

					//Declare:
					float AddedValue = (GetRandomFloat(0.00010, 0.00001) * float(BitCoinLevel[Client][Y]));

					//Initulize:
					BitCoin[Client][Y] += AddedValue;
				}
			}

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

//Check to see if the generator is in distance
public bool CheckBatteryToBitCoinMine(int Client, int Y)
{

	//Declare:
	int Ent = -1;

	//Switch:
	while ((Ent = FindEntityByClassname(Ent, "prop_Battery")) > 0)
	{

		//Check:
		if(IsInDistance(BitCoinEnt[Client][Y], Ent))
		{

			//Declare:
			int Id = GetBatteryIdFromEnt(Ent);

			//Check:
			if(GetGeneratorEnergy(Client, Id) - 0.25 > 0)
			{

				//Initulize:
				SetGeneratorEnergy(Client, Id, (GetGeneratorEnergy(Client, Id) - 0.25));

				//Declare:
				int Random = GetRandomInt(1, 5);

				//Valid:
				if(Random <= 2)
				{

					//Declare:
					float AddedValue = (GetRandomFloat(0.00010, 0.00001) * float(BitCoinLevel[Client][Y]));

					//Initulize:
					BitCoin[Client][Y] += AddedValue;
				}
			}

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}
