//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bomb_included_
  #endinput
#endif
#define _rp_bomb_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Define:
#define MAXITEMSPAWN		10

//Bomb:
int BombUse[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int BombEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int BombExplode[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char BombModel[256] = "models/props_junk/cardboard_box004a.mdl";

public void initBomb()
{

	//Commands:
	RegAdminCmd("sm_testbomb", Command_TestBomb, ADMFLAG_ROOT, "<Id> <Time> - Creates a Bomb");
}

public int initDefaultBomb(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		BombEnt[Client][X] = -1;

		BombExplode[Client][X] = 0;

		BombUse[Client][X] = 0;
	}
}

public int HasClientBomb(int Client, int Id)
{

	//Is Valid:
	if(BombEnt[Client][Id] > 0)
	{

		//Return:
		return BombEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetBombUse(int Client, int Id)
{

	//Return:
	return BombUse[Client][Id];
}

public int GetBombExplode(int Client, int Id)
{

	//Return:
	return BombExplode[Client][Id];
}

public void OnBombUse(int Client, int Ent)
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
						if(BombEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 7, X);

								//Remove:
								RemoveBomb(i, X, false);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Bomb|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Bomb!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 2500));

								//Set Menu State:
								BankState(Client, 2500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Bomb|\x07FFFFFF - You have just destroyed a Bomb. reseaved €\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Is Valid:
							else if(BombUse[i][X] == 0 && Client == i)
							{

								//Initulize:
								BombExplode[i][X] = 30;

								BombUse[i][X] = 1;

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Bomb|\x07FFFFFF - You have just armed your bomb. it will explode in \x0732CD3230\x07FFFFFF seconds!");
							}

							//Is Valid:
							else if(BombUse[i][X] == 1)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Bomb|\x07FFFFFF - This bomb is going to explode in %i Sec", BombExplode[i][X]);
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Bomb|\x07FFFFFF - You can't use this explosive Bomb!");
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
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Bomb!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public void initBombTime()
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
				if(IsValidEdict(BombEnt[i][X]))
				{

					//Declare:
					float EntOrigin[3];

					//Initialize:
					GetEntPropVector(BombEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Is Enabled:
					if(BombUse[i][X] == 1)
					{

						//Initulize:
						BombExplode[i][X] -=1;

						//Explode:
						if(BombExplode[i][X] == 0)
						{

							//Remove From DB:
							RemoveSpawnedItem(i, 7, X);

							//Explode:
							RemoveBomb(i, X, true);
						}
					}

					//Show CrimeHud:
					ShowBombToAll(EntOrigin, i, X);
				}
			}
		}
	}
}

public Action BombHud(int Client, int Ent, float NoticeInterval)
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
				if(BombEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Is Bomb Finished:
					if(BombUse[i][X] == 0)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Bomb:\nBomb is ready to be armed!");
					}

					//Override:
					else
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Bomb:\nBomb will explode in\n(%i) Seconds", BombExplode[i][X]);
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

//Crime Hud:
public Action ShowBombToAll(float BombOrigin[3], int Client, int X)
{

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

	//Initialize:
	float Dist = GetVectorDistance(ClientOrigin, BombOrigin);

	//In Distance:
	if(Dist <= 800)
	{

		//Initulize:
		BombOrigin[2] += 1.0;

		//Declare:
		int ColorBomb[4] = {50, 250, 50, 250};

		//Check:
		if(BombExplode[Client][X] > 20 && BombExplode[Client][X] < 30)
		{

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", BombOrigin, BombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Check:
		if(BombExplode[Client][X] > 10 && BombExplode[Client][X] < 21)
		{

			//Initulize:
			ColorBomb[0] = 255;

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", BombOrigin, BombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Check:
		else if(BombExplode[Client][X] > 0 && BombExplode[Client][X] < 11)
		{

			//Initulize:
			ColorBomb[0] = 255;
			ColorBomb[1] = 50;

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", BombOrigin, BombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Show To Client:
		TE_SetupBeamRingPoint(BombOrigin, 1.0, 100.0, Laser(), Sprite(), 0, 10, 0.7, 5.0, 0.5, ColorBomb, 10, 0);

		//End Temp:
		TE_SendToAll();
	}
}

public Action RemoveBomb(int Client, int X, bool Explode)
{

	//Can Explode:
	if(Explode)
	{

		//Explode:
		CreateExplosion(Client, BombEnt[Client][X]);
	}

	//Initulize:
	BombUse[Client][X] = 0;

	BombExplode[Client][X] = 0;

	//Check
	if(IsValidEdict(BombEnt[Client][X]) && BombEnt[Client][X] > GetMaxClients())
	{

		//Request:
		RequestFrame(OnNextFrameKill, BombEnt[Client][X]);
	}

	//Inituze:
	BombEnt[Client][X] = -1;
}

public bool CreateBomb(int Client, int Id, int Time, int Value, float Position[3], float Angle[3], bool IsConnected)
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
		Position[0] = (ClientOrigin[0] + (FloatMul(50.0, Cosine(DegToRad(EyeAngles[1])))));

		Position[1] = (ClientOrigin[1] + (FloatMul(50.0, Sine(DegToRad(EyeAngles[1])))));

		Position[2] = (ClientOrigin[2] + 10);

		Angle = EyeAngles;

		//Check:
		if(TR_PointOutsideWorld(Position))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bomb|\x07FFFFFF - Unable to spawn Bomb due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 7, Id, Time, 0, 0, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bomb|\x07FFFFFF - You have just spawned a Bomb!");
	}

	//Initulize:
	BombUse[Client][Id] = Time;

	BombExplode[Client][Id] = 30;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", BombModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	BombEnt[Client][Id] = Ent;

	//Set Prop:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Bomb");

	//Is Valid:
	if(StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestBomb(int Client, int Args)
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
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testbomb <Id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	int Id = 0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	Id = StringToInt(sId);

	if(BombEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Bomb with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Bomb %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//CreateBomb
	CreateBomb(Client, Id, 0, 0, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsBombUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bomb|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bomb|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		int MaxSlots = 1;

		//Valid Job:
		if(StrContains(GetJob(Client), "Drug Lord", false) != -1)
		{

			//Initulize:
			MaxSlots = 1;
		}

		//Valid Job:
		if(StrContains(GetJob(Client), "Crime Lord", false) != -1)
		{

			//Initulize:
			MaxSlots = 2;
		}

		//Valid Job:
		if(StrContains(GetJob(Client), "God Father", false) != -1)
		{

			//Initulize:
			MaxSlots = 3;
		}

		//Valid Job:
		if(GetDonator(Client) > 0 || IsAdmin(Client))
		{

			//Initulize:
			MaxSlots = 5;
		}

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
			Ent = HasClientBomb(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn Bomb:
				if(CreateBomb(Client, Y, StringToInt(GetItemVar(ItemId)), 0, Position, EyeAngles, false))
				{

					//Save:
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Initulize:
					SetCrime(Client, (GetCrime(Client) + 500));

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
					CPrintToChat(Client, "\x07FF4040|RP-Bomb|\x07FFFFFF - You already have too many Printers, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);

					//Stop:
					break;
				}
			}
		}
	}
}