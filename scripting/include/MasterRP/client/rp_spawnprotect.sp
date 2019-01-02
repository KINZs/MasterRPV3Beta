//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_spawnprotect_included_
  #endinput
#endif
#define _rp_spawnprotect_included_

//Is Spawnable:
Handle SpawnManagementTimer[MAXPLAYERS + 1] = {INVALID_HANDLE,...};
bool ShouldCollide[MAXPLAYERS + 1] = {false,...};
bool HasGodMode[MAXPLAYERS + 1] = {false,...};
bool HasSpawnProtect[MAXPLAYERS + 1] = {false,...};
float ProtectionTimer[MAXPLAYERS + 1] = {0.0,...};

public void StartSpawnProtect(int Client)
{

	//Has Crime:
	if(!IsCuffed(Client) && GetSpawnProtectTime() != 0)
	{

		//Is Valid:
		if(SpawnManagementTimer[Client] != INVALID_HANDLE)
		{

			//Kill:
			KillTimer(SpawnManagementTimer[Client]);

			//Handle:
			SpawnManagementTimer[Client] = INVALID_HANDLE;
		}

		//Initulize:
		ProtectionTimer[Client] = float(GetSpawnProtectTime());

		//Handle:
		SpawnManagementTimer[Client] = CreateTimer(0.1, ShowProtectHudTimer, Client, TIMER_REPEAT);

		//Protect:
		SpawnProtect(Client, true);
	}
}

public void RemoveProtectTimer(int Client)
{

	//Is Valid:
	if(SpawnManagementTimer[Client] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(SpawnManagementTimer[Client]);

		//Handle:
		SpawnManagementTimer[Client] = INVALID_HANDLE;
	}

	//Alive:
	if(IsPlayerAlive(Client))
	{

		//Protect:
		SpawnProtect(Client, false);
	}
}

public Action ShowProtectHudTimer(Handle Timer, any Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Is Valid:
		if(ProtectionTimer[Client] > 0.0)
		{

			//Initulize:
			ProtectionTimer[Client] -= 0.1;

			if(ProtectionTimer[Client] > 0.1)
			{

				//Print:
				PrintCenterText(Client, "%s: %.1f", "Spawn Protection", ProtectionTimer[Client] / 2.0);
			}

			//Override:
			else
			{

				//Print:
				PrintCenterText(Client, "%s: 0.0", "Spawn Protection");
			}
		}

		//Override:
		else
		{

			//Protect:
			SpawnProtect(Client, false);
		}

		//Return:
		return Plugin_Continue;
	}

	//Is Valid:
	if(SpawnManagementTimer[Client] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(SpawnManagementTimer[Client]);

		//Handle:
		SpawnManagementTimer[Client] = INVALID_HANDLE;

		//Protection:
		HasSpawnProtect[Client] = false;
		HasGodMode[Client] = false;
		ShouldCollide[Client] = false;
	}

	//Return:
	return Plugin_Handled;
}

//Set Protection:
public void SpawnProtect(int Client, bool Result)
{

	//Check:
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Override:
		if(Result == false)
		{

			//Protection:
			HasSpawnProtect[Client] = false;
			HasGodMode[Client] = false;
			ShouldCollide[Client] = false;

			// CAN NOT PASS THRU ie: Players can jump on each other
			SetEntData(Client, GetCollisionOffset(), 5, 4, true);

			//Set Colour:
			SetEntityRenderColor(Client);

			//Set Render:
			SetEntityRenderMode(Client, RENDER_NORMAL);

			//Set Render Ex:
			SetEntityRenderFx(Client, RENDERFX_NONE);

			//Kill Timer:
			if(SpawnManagementTimer[Client] != INVALID_HANDLE)
			{

				//Kill:
				KillTimer(SpawnManagementTimer[Client]);
			}

			//Handle:
			SpawnManagementTimer[Client] = INVALID_HANDLE;
		}

		//Protect:
		else if(Result == true)
		{

			//Protection:
			HasSpawnProtect[Client] = true;
			HasGodMode[Client] = true;
			ShouldCollide[Client] = true;

			// Noblock active ie: Players can walk thru each other
			SetEntData(Client, GetCollisionOffset(), 2, 4, true);

			//Is Combine:
			if(IsCop(Client)) SetEntityRenderColor(Client, 50, 50, 255, 128);

			//Is Admin:
			else if(IsAdmin(Client)) SetEntityRenderColor(Client, 255, 255, 50, 128);

			//Is Player:
			else SetEntityRenderColor(Client, 255, 50, 50, 128);

			//Set Render:
			SetEntityRenderMode(Client, RENDER_TRANSCOLOR);

			//Set Render Ex:
			SetEntityRenderFx(Client, RENDERFX_DISTORT);
		}
	}
}

public bool GetGodMode(int Client)
{

	//Return:
	return view_as<bool>(HasGodMode[Client]);
}

public bool IsProtected(int Client)
{

	//Return:
	return view_as<bool>(HasSpawnProtect[Client]);
}

public void ShowGodModeBox(int Client, float NoticeInterval)
{

	//Declare:
	int Random = GetRandomInt(1, 7);

	//Declare:
	int BeamColor[4] = {255,...};

	switch(Random)
	{

		case 1:
		{

			//Initulize:
			BeamColor[0] = 255;
			BeamColor[1] = 100;
			BeamColor[2] = 100;
		}

		case 2:
		{

			//Initulize:
			BeamColor[0] = 255;
			BeamColor[1] = 225;
			BeamColor[2] = 100;
		}

		case 3:
		{

			//Initulize:
		}

		case 4:
		{

			//Initulize:
			BeamColor[0] = 100;
			BeamColor[1] = 225;
			BeamColor[2] = 225;
		}

		case 5:
		{

			//Initulize:
			BeamColor[0] = 100;
			BeamColor[1] = 100;
			BeamColor[2] = 225;
		}

		case 6:
		{

			//Initulize:
			BeamColor[0] = 255;
			BeamColor[1] = 100;
			BeamColor[2] = 225;
		}

		case 7:
		{

			//Initulize:
			BeamColor[0] = 100;
			BeamColor[1] = 225;
			BeamColor[2] = 100;
		}
	}

	//Draw Box:
	DrawPlayerBeamBoxToAll(Client, Laser(), 0, 0, 66, NoticeInterval, 1.0, 1.0, 0, 0.05, BeamColor, 0);
}

public void DrawPlayerBeamBoxToAll(int Client, int modelIndex, int haloIndex, int startFrame, int frameRate, float life, float width, float endWidth, int fadeLength, float amplitude, int Color[4], int speed)
{

	//Declare:
	float Origin[3];

	//Initialize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Origin);

	//Declare:
	float ButtomOrigin[4][3];

	//Loop:
	for(int i = 0; i < 4; i++)
	{

		//Initulize:
		ButtomOrigin[i] = Origin;
	}

	ButtomOrigin[0][0] += 25.0;
	ButtomOrigin[0][1] += 25.0;

	ButtomOrigin[1][0] += 25.0;
	ButtomOrigin[1][1] -= 25.0;

	ButtomOrigin[2][0] -= 25.0;
	ButtomOrigin[2][1] += 25.0;

	ButtomOrigin[3][0] -= 25.0;
	ButtomOrigin[3][1] -= 25.0;

	TE_SetupBeamPoints(ButtomOrigin[0], ButtomOrigin[1], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();

	TE_SetupBeamPoints(ButtomOrigin[0], ButtomOrigin[2], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();

	TE_SetupBeamPoints(ButtomOrigin[3], ButtomOrigin[1], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();

	TE_SetupBeamPoints(ButtomOrigin[3], ButtomOrigin[2], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();

	//Declare:
	float TopOrigin[4][3];

	//Loop:
	for(int i = 0; i < 4; i++)
	{

		//Initulize:
		TopOrigin[i] = ButtomOrigin[i];

		//Make Top
		TopOrigin[i][2] += 75;
	}

	TE_SetupBeamPoints(TopOrigin[0], TopOrigin[1], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();

	TE_SetupBeamPoints(TopOrigin[0], TopOrigin[2], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();

	TE_SetupBeamPoints(TopOrigin[3], TopOrigin[1], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();

	TE_SetupBeamPoints(TopOrigin[3], TopOrigin[2], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();


	//Sides

	TE_SetupBeamPoints(TopOrigin[0], ButtomOrigin[0], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();

	TE_SetupBeamPoints(TopOrigin[1], ButtomOrigin[1], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();

	TE_SetupBeamPoints(TopOrigin[2], ButtomOrigin[2], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();

	TE_SetupBeamPoints(TopOrigin[3], ButtomOrigin[3], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToAll();
}


//Event Death:
public void StartClientRespawn(int Client)
{

	//Is Valid:
	if(SpawnManagementTimer[Client] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(SpawnManagementTimer[Client]);

		//Handle:
		SpawnManagementTimer[Client] = INVALID_HANDLE;
	}

	//Handle:
	SpawnManagementTimer[Client] = CreateTimer(5.0, RespawnPlayer, Client, TIMER_REPEAT);
}

public Action RespawnPlayer(Handle Timer, any Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client) && !IsPlayerAlive(Client))
	{

		//Spawn:
		DispatchSpawn(Client);

		//Print:
		PrintToConsole(Client, "|RP| - You have been respawned");

		//Is Valid:
		if(SpawnManagementTimer[Client] != INVALID_HANDLE)
		{

			//Kill:
			KillTimer(SpawnManagementTimer[Client]);

			//Handle:
			SpawnManagementTimer[Client] = INVALID_HANDLE;
		}
	}
}
