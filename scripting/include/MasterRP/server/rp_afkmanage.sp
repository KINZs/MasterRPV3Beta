//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_afkmanage_included_
  #endinput
#endif
#define _rp_afkmanage_included_

bool IsPlayerAFK[MAXPLAYERS + 1] = {false,...};
float PlayerAFKEyePosition[MAXPLAYERS + 1][3];
float PlayerAFKPosition[MAXPLAYERS + 1][3];
int PlayerAFKPoints[MAXPLAYERS + 1] = {0,...};

public void initCheckPlayerAfkStatus()
{

	//Declare:
	float EyeOrigin[3];
	float Origin[3];
	float Dist = 0.0;

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Connected:
			if(IsPlayerAlive(Client) && !IsFakeClient(Client))
			{

				//Initulize:
				GetClientCollisionPoint(Client, EyeOrigin);
				GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Origin);

				//Initialize:
				Dist = GetVectorDistance(Origin, PlayerAFKPosition[Client]);

				//Check:
				if(Dist <= 150 && PlayerAFKPoints[Client] < 50)
				{

					//Initulize:
					PlayerAFKPoints[Client] += 1;
				}

				//Check:
				if((EyeOrigin[0] == PlayerAFKEyePosition[Client][0]) && (EyeOrigin[1] == PlayerAFKEyePosition[Client][1]) && (EyeOrigin[2] == PlayerAFKEyePosition[Client][2]) && PlayerAFKPoints[Client] < 50)
				{

					//Initulize:
					PlayerAFKPoints[Client] += 1;

					//Print:
					//PrintToConsole(Client, "|RP| - Your AFK Points %i/50", PlayerAFKPoints[Client]);
				}

				//Check:
				if(PlayerAFKPoints[Client] >= 50 && !IsPlayerAFK[Client])
				{

					//Initulize:
					IsPlayerAFK[Client] = true;

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - AFK - Enabled!");
				}

				//Check:
				if((EyeOrigin[0] != PlayerAFKEyePosition[Client][0]) || (EyeOrigin[1] != PlayerAFKEyePosition[Client][1]) || (EyeOrigin[2] != PlayerAFKEyePosition[Client][2]))
				{

					//Initulize:
					PlayerAFKPoints[Client] = 0;
				}

				//Initulize:
				PlayerAFKEyePosition[Client] = EyeOrigin;

				PlayerAFKPosition[Client] = Origin;
			}
		}
	}
}

public bool CheckClientAfkStatus(int Client)
{

	//Declare:
	bool Result = false;
	float EyeOrigin[3];

	//Initulize:
	GetClientCollisionPoint(Client, EyeOrigin);

	//Check:
	if((EyeOrigin[0] != PlayerAFKEyePosition[Client][0]) || (EyeOrigin[1] != PlayerAFKEyePosition[Client][1]) || (EyeOrigin[2] != PlayerAFKEyePosition[Client][2]))
	{

		//Initulize:
		Result = true;
	}

	//Return:
	return view_as<bool>(Result);
}

public void ResetPlayerAfk(int Client)
{

	//Initulize:
	PlayerAFKPoints[Client] = 0;

	IsPlayerAFK[Client] = false;
}

public bool GetIsPlayerAfk(int Client)
{

	//Return:
	return view_as<bool>(IsPlayerAFK[Client]);
}