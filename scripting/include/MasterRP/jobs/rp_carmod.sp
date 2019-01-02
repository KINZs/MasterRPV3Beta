//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).
///////////////////////////////////////////////////////////////////////////////
///////////////////////// Masters Car Mod v1.5.22 /////////////////////////////
///////////////////////////////////////////////////////////////////////////////

/** Double-include prevention */
#if defined _rp_carmod_included_
  #endinput
#endif
#define _rp_carmod_included_

//vendor menu for cars
//vendor menu spawn for cars
//have ownership of each car
//have police apcs

float CurrentEyeAngle[MAXPLAYERS + 1][3];

public void initCarMod()
{

	//Beta
	RegAdminCmd("sm_exitcar", Command_ExitCars, ADMFLAG_ROOT, "test");

	//Command:
    	RegAdminCmd("sm_createairboat", Command_AirBoat, ADMFLAG_SLAY, "Creates an Entity");

    	RegAdminCmd("sm_createapc", Command_Apc, ADMFLAG_SLAY, "Creates an Entity");

    	RegAdminCmd("sm_creategolf", Command_Golf, ADMFLAG_SLAY, "Creates an Entity");

    	RegAdminCmd("sm_createjeep", Command_Jeep, ADMFLAG_SLAY, "Creates an Entity");

    	//RegAdminCmd("sm_createprisionpod", Command_PrisionPod, ADMFLAG_SLAY, "Creates an Entity");

    	RegAdminCmd("sm_creategt250", Command_GT250, ADMFLAG_SLAY, "Creates an Entity");

    	RegAdminCmd("sm_createcorvette", Command_Corvette, ADMFLAG_SLAY, "Creates an Entity");

    	RegAdminCmd("sm_createhelicopter", Command_Helicopter, ADMFLAG_SLAY, "Creates an Entity");
}

public void OnClientPostThinkPostVehicleViewFix(int Client)
{

	//Declare:
	int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Is In Car:
	if(InVehicle == -1)
	{

		//Return:
		return;
	}

	// "m_bEnterAnimOn" is the culprit for vehicles controlling all players views.
	// this is the earliest it can be changed, also stops vehicle starting..
	if(GetEntProp(InVehicle, Prop_Send, "m_bEnterAnimOn") == 1)
	{

		//Check:
		if(IsClientInThirdPersonMode(Client))
		{

			//Set First Person
			SetThirdPersonView(Client, false);
		}

		//Declare:
		float FaceFront[3] = {0.0, 90.0, 0.0};

		//Teleport:
		TeleportEntity(Client, NULL_VECTOR, FaceFront, NULL_VECTOR);

		//Set Ent:
		SetEntProp(InVehicle, Prop_Send, "m_bEnterAnimOn", 0);

		// stick the player in the correct view position if they're stuck in and enter animation.
		SetEntProp(InVehicle, Prop_Send, "m_nSequence", 0);
		
		// set the vehicles team so team mates can't destroy it.
		int DriverTeam = GetEntProp(Client, Prop_Send, "m_iTeamNum");
		SetEntProp(InVehicle, Prop_Send, "m_iTeamNum", DriverTeam);

		//Loop:
		for(int players = 1; players <= MaxClients; players++) 
		{

			//Is Valid:
			if(IsClientInGame(players) && IsPlayerAlive(players))
			{

				//Not Player:
				if(players != Client)
				{

					//Teleport:
					TeleportEntity(players, NULL_VECTOR, CurrentEyeAngle[players], NULL_VECTOR);
				}
			}
		}

		//Initulize:
		SendConVarValue(Client, FindConVar("sv_Client_predict"), "0");

		//Check:
		if(GetThirdPersonView(Client) == true)
		{

			//Initulize:
			SetThirdPersonView(Client, false);
		}

		//Send:
		SetEntProp(InVehicle, Prop_Data, "m_bLocked", 1);

		//Declare:
		int Flags = GetEntProp(InVehicle, Prop_Data, "m_iEFlags");

		//Send:
		SetEntProp(InVehicle, Prop_Data, "m_iEFlags", Flags|EFL_NO_PHYSCANNON_INTERACTION);
	}
}
public bool OnVehicleUse(int Client)
{

	//Declare:
	int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Check:
	if(IsValidEdict(InVehicle))
	{

		//Declare:
		int VehicleLocked = GetEntProp(InVehicle, Prop_Data, "m_bLocked");

		if(VehicleLocked == 1)
		{

			//Declare:
			char ClassName[32];
			int Speed = 0;

			//Get Entity Info:
			GetEdictClassname(InVehicle, ClassName, sizeof(ClassName));

			//Check:
			if(!StrEqual(ClassName, "prop_vehicle_prisoner_pod"))
			{

				//Declare:
				Speed = GetEntProp(InVehicle, Prop_Data, "m_nSpeed");
			}

			//Check:
			if(Speed <= 2)
			{

				//Declare:
				float Velocity[3];

				//Initulize:
				GetEntPropVector(InVehicle, Prop_Data, "m_vecVelocity", Velocity);

				//Check:
				if(Velocity[0] == 0.0 && Velocity[1] == 0.0 && Velocity[2] == 0.0)
				{

					//Exit:
					if(ExitVehicle(Client, InVehicle, true) == true)
					{

						//Return:
						return true;
					}
				}
			}
		}
	}

	//Return:
	return false;
}

public Action OnVehicleShift(int Client, int Vehicle)
{

	//Declare:
	int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Check:
	if(!IsValidEdict(InVehicle))
	{

		//Declare:
		int Driver = GetEntPropEnt(Vehicle, Prop_Send, "m_hPlayer");

		//Check:
		if(Driver == -1)
		{

			//Declare:
			char ClassName[32];
			int Speed = 0;

			//Get Entity Info:
			GetEdictClassname(Vehicle, ClassName, sizeof(ClassName));

			//Check:
			if(!StrEqual(ClassName, "prop_vehicle_prisoner_pod"))
			{

				//Declare:
				Speed = GetEntProp(Vehicle, Prop_Data, "m_nSpeed");
			}

			//Check:
			if(Speed == 0)
			{

				//Declare:
				int VehicleLocked = GetEntProp(Vehicle, Prop_Data, "m_bLocked");

				//Check:
				if(VehicleLocked == 1)
				{

					//Send:
					SetEntProp(Vehicle, Prop_Data, "m_bLocked", 0);

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF you have unlocked this vehicle");
				}

				//Override:
				else
				{

					//Send:
					SetEntProp(Vehicle, Prop_Data, "m_bLocked", 1);

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF you have locked this vehicle");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF you can't lock the vehicle whilst it is moving");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF You can't lock the vehicle whilst someone is inside");
		}
	}
}

public bool ExitVehicle(int Client, int Vehicle, bool Force)
{

	//Declare:
	float ExitPoint[3];

	//Declare:
	//int Driver = GetEntPropEnt(Vehicle, Prop_Send, "m_hPlayer");

	//Force:
	if(Force)
	{

		// check left.
		if (!IsExitClear(Client, Vehicle, 90.0, ExitPoint))
		{

			// check right.
			if (!IsExitClear(Client, Vehicle, -90.0, ExitPoint))
			{

				// check front.
				if (!IsExitClear(Client, Vehicle, 0.0, ExitPoint))
				{

					// check back.
					if (!IsExitClear(Client, Vehicle, 180.0, ExitPoint))
					{

						// check above the vehicle.
						float ClientEye[3];

						//Initulize:
						GetClientEyePosition(Client, ClientEye);

						//Declare:
						float ClientMinHull[3];

						float ClientMaxHull[3];

						//Initulize:
						GetEntPropVector(Client, Prop_Send, "m_vecMins", ClientMinHull);

						GetEntPropVector(Client, Prop_Send, "m_vecMaxs", ClientMaxHull);

						//Declare:
						float TraceEnd[3];

						//Initulize:
						TraceEnd = ClientEye;
						TraceEnd[2] += 500.0;

						//Trace:
						TR_TraceHullFilter(ClientEye, TraceEnd, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID, DontHitClientOrVehicle, Client);

						//Declare:
						float CollisionPoint[3];

						//Check:
						if (TR_DidHit())
						{

							//Get Ent Position:
							TR_GetEndPosition(CollisionPoint);
						}

						//Override:
						else
						{

							//Initulize:
							CollisionPoint = TraceEnd;
						}

						//Trace
						TR_TraceHull(CollisionPoint, ClientEye, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID);

						//Declare:
						float VehicleEdge[3];

						//En:
						TR_GetEndPosition(VehicleEdge);
						
						float ClearDistance = GetVectorDistance(VehicleEdge, CollisionPoint);

						//Check:
						if (ClearDistance >= 100.0)
						{
							ExitPoint = VehicleEdge;
							ExitPoint[2] += 100.0;
							
							if (TR_PointOutsideWorld(ExitPoint))
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF No safe exit point found!!!!!");

								//Initulize:
								GetEntPropVector(Vehicle, Prop_Send, "m_vecOrigin", ExitPoint);
							}
						}
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF safe exit point found!!!!!");

							//Initulize:
							GetEntPropVector(Vehicle, Prop_Send, "m_vecOrigin", ExitPoint);
						}
					}
				}
			}
		}
	}
	else
	{
		//Initulize:
		GetEntPropVector(Vehicle, Prop_Send, "m_vecOrigin", ExitPoint);
	}

	// stick the player in the correct view position if they're stuck sin and enter animation.
	SetEntProp(Vehicle, Prop_Send, "m_nSequence", 0);

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Vehicle, ClassName, sizeof(ClassName));

	//Check:
	if(!StrEqual(ClassName, "prop_vehicle_prisoner_pod"))
	{

		SetEntProp(Vehicle, Prop_Send, "m_nSpeed", 0);
		SetEntPropFloat(Vehicle, Prop_Send, "m_flThrottle", 0.0);
	}

	AcceptEntityInput(Client, "ClearParent");

	SetEntPropEnt(Client, Prop_Send, "m_hVehicle", -1);

	SetEntPropEnt(Vehicle, Prop_Send, "m_hPlayer", -1);

	SetEntityMoveType(Client, MOVETYPE_WALK);

	SetEntProp(Client, Prop_Send, "m_CollisionGroup", 5);

	int hud = GetEntProp(Client, Prop_Send, "m_iHideHUD");
	hud &= ~1;
	hud &= ~256;
	hud &= ~1024;
	SetEntProp(Client, Prop_Send, "m_iHideHUD", hud);

	int EntEffects = GetEntProp(Client, Prop_Send, "m_fEffects");
	EntEffects &= ~32;
	SetEntProp(Client, Prop_Send, "m_fEffects", EntEffects);

	float ExitAng[3];
	
	GetEntPropVector(Vehicle, Prop_Data, "m_angRotation", ExitAng);
	ExitAng[0] = 0.0;
	ExitAng[1] += 90.0;
	ExitAng[2] = 0.0;

	TeleportEntity(Client, ExitPoint, ExitAng, NULL_VECTOR);

	SetClientViewEntity(Client, Client);

	// stops the vehicle rolling back when it is spawned.
	SetEntProp(Vehicle, Prop_Data, "m_nNextThinkTick", -1);

	//Initulize:
	SendConVarValue(Client, FindConVar("sv_Client_predict"), "1");

	//Fixes weapon switch:
	SetForceSwitch(Client, 1);

	//Send:
	SetEntProp(Vehicle, Prop_Data, "m_bLocked", 0);

	//Declare:
	int Owner = GetOwnerOfVehicle(Vehicle);

	//Check:
	if(Owner > 0)
	{

		//Respawn Vehicle:
		RespawnVehicle(Owner, Vehicle);
	}

	//Check:
	if(IsValidCopCar(Vehicle))
	{

		//Respawn Vehicle:
		RespawnCopVehicleOnPlayerExit(Vehicle);
	}

	//Return:
	return true;
}

// checks if 100 units away from the edge of the Vehicle in the given direction is clear.
public bool IsExitClear(int Client, int Vehicle, float direction, float exitpoint[3])
{

	//Declare:
	float ClientEye[3];
	float VehicleAngle[3];
	float ClientMinHull[3];
	float ClientMaxHull[3];
	float DirectionVec[3];

	//Initulize:
	GetClientEyePosition(Client, ClientEye);

	GetEntPropVector(Vehicle, Prop_Data, "m_angRotation", VehicleAngle);

	GetEntPropVector(Client, Prop_Send, "m_vecMins", ClientMinHull);

	GetEntPropVector(Client, Prop_Send, "m_vecMaxs", ClientMaxHull);

	//Math:
	VehicleAngle[0] = 0.0;
	VehicleAngle[2] = 0.0;
	VehicleAngle[1] += direction;
	
	//Initulize:
	GetAngleVectors(VehicleAngle, NULL_VECTOR, DirectionVec, NULL_VECTOR);

	//Scale:
	ScaleVector(DirectionVec, -500.0);

	//Declare:
	float TraceEnd[3];
	float CollisionPoint[3];
	float VehicleEdge[3];

	//Add:
	AddVectors(ClientEye, DirectionVec, TraceEnd);

	//Trace:
	TR_TraceHullFilter(ClientEye, TraceEnd, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID, DontHitClientOrVehicle, Client);

	//Found End:
	if(TR_DidHit())
	{

		//Get End Point:
		TR_GetEndPosition(CollisionPoint);
	}

	//Override:
	else
	{

		//Initulize:
		CollisionPoint = TraceEnd;
	}

	//Trace:
	TR_TraceHull(CollisionPoint, ClientEye, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID);

	//Get End Point:
	TR_GetEndPosition(VehicleEdge);

	//Declare:
	float ClearDistance = GetVectorDistance(VehicleEdge, CollisionPoint);

	//Is Valid:
	if(ClearDistance >= 100.0)
	{

		//Math:
		MakeVectorFromPoints(VehicleEdge, CollisionPoint, DirectionVec);
		NormalizeVector(DirectionVec, DirectionVec);
		ScaleVector(DirectionVec, 100.0);
		AddVectors(VehicleEdge, DirectionVec, exitpoint);

		//Can Spawn:
		if(TR_PointOutsideWorld(exitpoint))
		{

			//Return:
			return false;
		}

		//Override:
		else
		{

			//Return:
			return true;
		}
	}

	//Override:
	else
	{

		//Return:
		return false;
	}
}

public bool DontHitClientOrVehicle(int Entity, int contentsMask, any data)
{

	//Declare:
	int InVehicle = GetEntPropEnt(data, Prop_Send, "m_hVehicle");

	//Return:
	return ((Entity != data) && (Entity != InVehicle));
}

public bool RayDontHitClient(int Entity, int contentsMask, any data)
{
	return (Entity != data);
}

//Create NPC:
public Action Command_ExitCars(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("[SM] This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Is In Car:
	if(InVehicle != -1)
	{

		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(InVehicle, ClassName, sizeof(ClassName));

		//Check:
		if(StrEqual(ClassName, "prop_vehicle_prisoner_pod"))
		{

			//Exit:
			ExitVehicle(Client, InVehicle, true);
		}

		//Override:
		else
		{

			//Declare:
			int Speed = GetEntProp(InVehicle, Prop_Data, "m_nSpeed");

			//Check:
			if(Speed == 0)
			{

				//Exit:
				ExitVehicle(Client, InVehicle, true);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF You are moving to fast to leave the vehicle");
			}
		}

	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF You are currently not in a vehicle");
	}

	//Return:
	return Plugin_Handled;
}

public void CarHud(int Client, int Ent, char ClassName[32], float NoticeInterval)
{


	//Declare:
	char FormatMessage[255];
	int len = 0;

	//Check:
	if(StrEqual(ClassName, "prop_vehicle_damaged"))
	{

		//Declare:
		int Owner = GetOwnerOfVehicle(Ent);

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Owner: %N", Owner);

		//Declare:
		int VehMetal = GetVehicleMetal(Owner);

		if(VehMetal > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nMetal: %i", VehMetal);
		}

		//Override:
		else
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nMetal: No Metal Avaiable", VehMetal);
		}
	}

	//Check:
	else if(StrEqual(ClassName, "prop_vehicle_prisoner_pod"))
	{

		//Declare:
		int Driver = GetEntPropEnt(Ent, Prop_Send, "m_hPlayer");

		//Check:
		if(Driver == Client)
		{

			//Return:
			return;
		}

		//Check:
		if(Driver > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Prisioner: %N", Driver);
		}

		//Override:
		else
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Prisioner: Empty!");
		}

		//Health:
		int Health = GetEntProp(Ent, Prop_Data, "m_iHealth");

		//Check:
		if(Health > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nHealth: %i!", Health);
		}
	}

	//Override:
	else
	{

		//Declare:
		int Driver = GetEntPropEnt(Ent, Prop_Send, "m_hPlayer");

		//Check:
		if(Driver == Client)
		{

			//Return:
			return;
		}

		//Check:
		if(Driver > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Driver: %N", Driver);
		}

		//Override:
		else
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nDriver: Empty!");
		}

		//Health:
		int Health = GetEntProp(Ent, Prop_Data, "m_iHealth");

		//Check:
		if(Health > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nHealth: %i!", Health);
		}
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
	if(GetGame() != 2 && GetGame() != 3)
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

public void SetClientCurrentEyeAngle(int Client, float Angles[3])
{

	//Initulize:
	CurrentEyeAngle[Client] = Angles;
}

public MRESReturn OnClientGetInVehicleForward(int Client)
{

	//Print:
	PrintToConsole(Client, "|RP| - you have enterd your vehicle");

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnClientLeaveVehicleForward(int Client, int InVehicle)
{

	//Print:
	PrintToConsole(Client, "|RP| - you have your vehicle");

	//Return:
	return MRES_Ignored;
}


/////////////////////ADMIN COMMANDS/////////////////////////

public Action Command_AirBoat(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Create Airboat:
	CreateAirBoat(Client, Origin, EyeAngles, 1000, 0);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF you have spawned a prop_vehicle_airboat");

	//Return:
	return Plugin_Handled;
}

public Action Command_Apc(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Create Jeep:
	CreateAPC(Client, Origin, EyeAngles, 4000, 0);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF you have spawned a prop_vehicle_apc");

	//Return:
	return Plugin_Handled;
}

public Action Command_Golf(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Declare:
	CreateCustomCar(Client, Origin, EyeAngles, "models/golf/golf.mdl", "scripts/vehicles/golf.txt", 1000, 0);

	//Return:
	return Plugin_Handled;
}

public Action Command_Jeep(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Create Jeep:
	CreateJeep(Client, Origin, EyeAngles, 1000, 0);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF you have spawned a prop_vehicle_jeep", 1000, 0);

	//Return:
	return Plugin_Handled;
}

public Action Command_PrisionPod(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Declare:
	int Ent = CreateEntityByName("prop_vehicle_prisoner_pod");


	//Declare:
	char TargetName[10];

	//Format:
	Format(TargetName, sizeof(TargetName), "%i", Ent);

	//Dispatch:
	DispatchKeyValue(Ent, "targetname", TargetName);

	DispatchKeyValue(Ent, "physdamagescale", "1.0");


	DispatchKeyValue(Ent, "model", "models/props_combine/breenpod_inner.mdl");


	DispatchKeyValue(Ent, "vehiclescript", "scripts/vehicles/prisoner_pod.txt");


	//Spawn
	DispatchSpawn(Ent);


	//Invincible:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

	//Teleport:
	TeleportEntity(Ent, Origin, NULL_VECTOR, NULL_VECTOR);

	//Set Physics:
	SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);   

	//Return:
	return Plugin_Handled;
}

public Action Command_GT250(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Declare:
	CreateCustomCar(Client, Origin, EyeAngles, "models/tdmcars/ferrari250gt.mdl", "scripts/vehicles/gt250.txt", 1000, 0);

	//Return:
	return Plugin_Handled;
}

public Action Command_Corvette(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Declare:
	CreateCustomCar(Client, Origin, EyeAngles, "models/corvette/corvette.mdl", "scripts/vehicles/corvette.txt", 1000, 0);

	//Return:
	return Plugin_Handled;
}

public Action Command_Helicopter(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Create Jeep:
	CreateHelicopter(Client, Origin, EyeAngles, 4000, 0);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF you have spawned a prop_vehicle_Helicopter");

	//Return:
	return Plugin_Handled;
}

/////////////////////////Create vehicles/////////////////////////

public int CreateCustomCar(int Client, float Origin[3], float Angles[3], char Model[256], char VehicleScript[256], int Health, int IsCarLocked)
{

	//Declare:
	int Ent = CreateEntityByName("prop_vehicle_driveable");


	//Check:
	if(Ent == -1)
	{

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create vehicle entity");

		//Return:
		return -1;
	}

	//Set Health:
	SetEntProp(Ent, Prop_Data, "m_iHealth", Health);

	//MaxHealth:
	SetEntProp(Ent, Prop_Data, "m_iMaxHealth", Health);

	//Send:
	SetEntProp(Ent, Prop_Data, "m_bLocked", IsCarLocked);

	//Declare:
	char TargetName[10];

	//Format:
	Format(TargetName, sizeof(TargetName), "%i", Ent);

	//Dispatch:
	DispatchKeyValue(Ent, "targetname", TargetName);

	DispatchKeyValue(Ent, "physdamagescale", "1.0");


	if(!IsModelPrecached(Model))
		PrecacheModel(Model);
	DispatchKeyValue(Ent, "model", Model);


	DispatchKeyValue(Ent, "vehiclescript", VehicleScript);


	DispatchKeyValue(Ent, "EnableGun", "0");

	//Spawn
	DispatchSpawn(Ent);


	ActivateEntity(Ent);

	//Set do default classname
	SetEntityClassName(Ent, "prop_vehicle_custom");

	//Teleport:
	TeleportEntity(Ent, Origin, Angles, NULL_VECTOR);

	//Set Physics:
	SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);

	SetEntProp(Ent, Prop_Data, "m_nVehicleType", 1);

	// stops the vehicle rolling back when it is spawned.
	SetEntProp(Ent, Prop_Data, "m_nNextThinkTick", -1);

	//Accept:
	AcceptEntityInput(Ent, "TurnOn", Client);

	// anti flip, not 100% effective.
	int PhysIndex = CreateEntityByName("phys_ragdollconstraint");

	//Check:
	if (PhysIndex == -1)
	{

		//Request:
		RequestFrame(OnNextFrameKill, Ent);

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create anti flip entity");

		//Return:
		return -1;
	}

	//Dispatch:
	DispatchKeyValue(PhysIndex, "spawnflags", "2");

	DispatchKeyValue(PhysIndex, "ymin", "-50.0");

	DispatchKeyValue(PhysIndex, "ymax", "50.0");

	DispatchKeyValue(PhysIndex, "zmin", "-180.0");

	DispatchKeyValue(PhysIndex, "zmax", "180.0");

	DispatchKeyValue(PhysIndex, "xmin", "-50.0");

	DispatchKeyValue(PhysIndex, "xmax", "50.0");
	
	DispatchKeyValue(PhysIndex, "attach1", TargetName);

	//Spawn:	
	DispatchSpawn(PhysIndex);

	//Activate:
	ActivateEntity(PhysIndex);

	//Set String:
	SetVariantString("!activator");

	//Accept:
	AcceptEntityInput(PhysIndex, "SetParent", Ent, PhysIndex, 0);

	//Teleport:
	TeleportEntity(PhysIndex, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);

	//Invincible:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnVehicleTakeDamage);

	//Return:
	return Ent;
}

public int CreateAirBoat(int Client, float Origin[3], float Angles[3], int Health, int IsCarLocked)
{

	//Declare:
	int Ent = CreateEntityByName("prop_vehicle_airboat");

	//int Ent = CreateEntityByName("prop_vehicle_driveable");


	//Check:
	if(Ent == -1)
	{

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create vehicle entity");

		//Return:
		return -1;
	}

	//Set Health:
	SetEntProp(Ent, Prop_Data, "m_iHealth", Health);

	//MaxHealth:
	SetEntProp(Ent, Prop_Data, "m_iMaxHealth", Health);

	//Send:
	SetEntProp(Ent, Prop_Data, "m_bLocked", IsCarLocked);

	//Declare:
	char TargetName[10];

	//Format:
	Format(TargetName, sizeof(TargetName), "%i", Ent);

	//Dispatch:
	DispatchKeyValue(Ent, "targetname", TargetName);

	DispatchKeyValue(Ent, "physdamagescale", "1.0");


	DispatchKeyValue(Ent, "model", "models/airboat.mdl");


	DispatchKeyValue(Ent, "vehiclescript", "scripts/vehicles/airboat_edit.txt");


	DispatchKeyValue(Ent, "EnableGun", "0");

	//Spawn
	DispatchSpawn(Ent);


	ActivateEntity(Ent);

	//Set do default classname
	SetEntityClassName(Ent, "prop_vehicle_airboat");

	//Teleport:
	TeleportEntity(Ent, Origin, Angles, NULL_VECTOR);

	//Set Physics:
	SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);

	SetEntProp(Ent, Prop_Data, "m_nVehicleType", 8);

	// stops the vehicle rolling back when it is spawned.
	SetEntProp(Ent, Prop_Data, "m_nNextThinkTick", -1);

	//Accept:
	AcceptEntityInput(Ent, "TurnOn", Client);

	// anti flip, not 100% effective.
	int PhysIndex = CreateEntityByName("phys_ragdollconstraint");

	//Check:
	if (PhysIndex == -1)
	{

		//Request:
		RequestFrame(OnNextFrameKill, Ent);

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create anti flip entity");

		//Return:
		return -1;
	}

	//Dispatch:
	DispatchKeyValue(PhysIndex, "spawnflags", "2");

	DispatchKeyValue(PhysIndex, "ymin", "-50.0");

	DispatchKeyValue(PhysIndex, "ymax", "50.0");

	DispatchKeyValue(PhysIndex, "zmin", "-180.0");

	DispatchKeyValue(PhysIndex, "zmax", "180.0");

	DispatchKeyValue(PhysIndex, "xmin", "-50.0");

	DispatchKeyValue(PhysIndex, "xmax", "50.0");
	
	DispatchKeyValue(PhysIndex, "attach1", TargetName);

	//Spawn:	
	DispatchSpawn(PhysIndex);

	//Activate:
	ActivateEntity(PhysIndex);

	//Set String:
	SetVariantString("!activator");

	//Accept:
	AcceptEntityInput(PhysIndex, "SetParent", Ent, PhysIndex, 0);

	//Teleport:
	TeleportEntity(PhysIndex, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);

	//Invincible:
	//SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnVehicleTakeDamage);

	//Return:
	return Ent;
}

public int CreateAPC(int Client, float Origin[3], float Angles[3], int Health, int IsCarLocked)
{

	//Declare:
	//int Ent = CreateEntityByName("prop_vehicle_apc");

	int Ent = CreateEntityByName("prop_vehicle_driveable");


	//Check:
	if(Ent == -1)
	{

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create vehicle entity");

		//Return:
		return -1;
	}

	//Set Health:
	SetEntProp(Ent, Prop_Data, "m_iHealth", Health);

	//MaxHealth:
	SetEntProp(Ent, Prop_Data, "m_iMaxHealth", Health);

	//Send:
	SetEntProp(Ent, Prop_Data, "m_bLocked", IsCarLocked);

	//Declare:
	char TargetName[10];

	//Format:
	Format(TargetName, sizeof(TargetName), "%i", Ent);

	//Dispatch:
	DispatchKeyValue(Ent, "targetname", TargetName);

	DispatchKeyValue(Ent, "physdamagescale", "1.0");


	DispatchKeyValue(Ent, "model", "models/combine_apc.mdl");


	DispatchKeyValue(Ent, "vehiclescript", "scripts/vehicles/apc_edit.txt");


	DispatchKeyValue(Ent, "EnableGun", "0");

	//Spawn
	DispatchSpawn(Ent);


	ActivateEntity(Ent);

	//Set do default classname
	SetEntityClassName(Ent, "prop_vehicle_apc");

	//Teleport:
	TeleportEntity(Ent, Origin, Angles, NULL_VECTOR);

	//Set Physics:
	SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);

	SetEntProp(Ent, Prop_Data, "m_nVehicleType", 1);

	// stops the vehicle rolling back when it is spawned.
	SetEntProp(Ent, Prop_Data, "m_nNextThinkTick", -1);

	//Accept:
	AcceptEntityInput(Ent, "TurnOn", Client);

	// anti flip, not 100% effective.
	int PhysIndex = CreateEntityByName("phys_ragdollconstraint");

	//Check:
	if (PhysIndex == -1)
	{

		//Request:
		RequestFrame(OnNextFrameKill, Ent);

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create anti flip entity");

		//Return:
		return -1;
	}

	//Dispatch:
	DispatchKeyValue(PhysIndex, "spawnflags", "2");

	DispatchKeyValue(PhysIndex, "ymin", "-50.0");

	DispatchKeyValue(PhysIndex, "ymax", "50.0");

	DispatchKeyValue(PhysIndex, "zmin", "-180.0");

	DispatchKeyValue(PhysIndex, "zmax", "180.0");

	DispatchKeyValue(PhysIndex, "xmin", "-50.0");

	DispatchKeyValue(PhysIndex, "xmax", "50.0");
	
	DispatchKeyValue(PhysIndex, "attach1", TargetName);

	//Spawn:	
	DispatchSpawn(PhysIndex);

	//Activate:
	ActivateEntity(PhysIndex);

	//Set String:
	SetVariantString("!activator");

	//Accept:
	AcceptEntityInput(PhysIndex, "SetParent", Ent, PhysIndex, 0);

	//Teleport:
	TeleportEntity(PhysIndex, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);

	//Invincible:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnVehicleTakeDamage);

	//Return:
	return Ent;
}

public int CreateJeep(int Client, float Origin[3], float Angles[3], int Health, int IsCarLocked)
{

	//Declare:
	//int Ent = CreateEntityByName("prop_vehicle_jeep");

	int Ent = CreateEntityByName("prop_vehicle_driveable");


	//Check:
	if(Ent == -1)
	{

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create vehicle entity");

		//Return:
		return -1;
	}

	//Set Health:
	SetEntProp(Ent, Prop_Data, "m_iHealth", Health);

	//MaxHealth:
	SetEntProp(Ent, Prop_Data, "m_iMaxHealth", Health);

	//Send:
	SetEntProp(Ent, Prop_Data, "m_bLocked", IsCarLocked);

	//Declare:
	char TargetName[10];

	//Format:
	Format(TargetName, sizeof(TargetName), "%i", Ent);

	//Dispatch:
	DispatchKeyValue(Ent, "targetname", TargetName);

	DispatchKeyValue(Ent, "physdamagescale", "1.0");


	DispatchKeyValue(Ent, "model", "models/blodia/buggy.mdl");


	DispatchKeyValue(Ent, "vehiclescript", "scripts/vehicles/buggy_edit.txt");


	DispatchKeyValue(Ent, "EnableGun", "0");

	//Spawn
	DispatchSpawn(Ent);


	ActivateEntity(Ent);

	//Set do default classname
	SetEntityClassName(Ent, "prop_vehicle_jeep");

	//Teleport:
	TeleportEntity(Ent, Origin, Angles, NULL_VECTOR);

	//Set Physics:
	SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);

	SetEntProp(Ent, Prop_Data, "m_nVehicleType", 1);

	// stops the vehicle rolling back when it is spawned.
	SetEntProp(Ent, Prop_Data, "m_nNextThinkTick", -1);

	//Accept:
	AcceptEntityInput(Ent, "TurnOn", Client);

	// anti flip, not 100% effective.
	int PhysIndex = CreateEntityByName("phys_ragdollconstraint");

	//Check:
	if (PhysIndex == -1)
	{

		//Request:
		RequestFrame(OnNextFrameKill, Ent);

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create anti flip entity");

		//Return:
		return -1;
	}

	//Dispatch:
	DispatchKeyValue(PhysIndex, "spawnflags", "2");

	DispatchKeyValue(PhysIndex, "ymin", "-50.0");

	DispatchKeyValue(PhysIndex, "ymax", "50.0");

	DispatchKeyValue(PhysIndex, "zmin", "-180.0");

	DispatchKeyValue(PhysIndex, "zmax", "180.0");

	DispatchKeyValue(PhysIndex, "xmin", "-50.0");

	DispatchKeyValue(PhysIndex, "xmax", "50.0");
	
	DispatchKeyValue(PhysIndex, "attach1", TargetName);

	//Spawn:	
	DispatchSpawn(PhysIndex);

	//Activate:
	ActivateEntity(PhysIndex);

	//Set String:
	SetVariantString("!activator");

	//Accept:
	AcceptEntityInput(PhysIndex, "SetParent", Ent, PhysIndex, 0);

	//Teleport:
	TeleportEntity(PhysIndex, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);

	//Invincible:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnVehicleTakeDamage);

	//Return:
	return Ent;
}

public int CreatePrisonerPod(int Client, float Origin[3], float Angles[3], int Health, int IsCarLocked)
{

	//Declare:
	int Ent = CreateEntityByName("prop_vehicle_prisoner_pod");

	//int Ent = CreateEntityByName("prop_vehicle_driveable");


	//Check:
	if(Ent == -1)
	{

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create vehicle entity");

		//Return:
		return -1;
	}

	//Set Health:
	SetEntProp(Ent, Prop_Data, "m_iHealth", Health);

	//MaxHealth:
	SetEntProp(Ent, Prop_Data, "m_iMaxHealth", Health);

	//Send:
	SetEntProp(Ent, Prop_Data, "m_bLocked", IsCarLocked);

	//Declare:
	char TargetName[10];

	//Format:
	Format(TargetName, sizeof(TargetName), "%i", Ent);

	//Dispatch:
	DispatchKeyValue(Ent, "targetname", TargetName);

	DispatchKeyValue(Ent, "physdamagescale", "1.0");


	DispatchKeyValue(Ent, "model", "models/props_combine/breenpod_inner.mdl");


	DispatchKeyValue(Ent, "vehiclescript", "scripts/vehicles/prisoner_pod.txt");


	//Spawn
	DispatchSpawn(Ent);


	//Teleport:
	TeleportEntity(Ent, Origin, NULL_VECTOR, NULL_VECTOR);

	//Set Physics:
	SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);

	//Invincible:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnVehicleTakeDamage);

	//Return:
	return Ent;
}
public int CreateHelicopter(int Client, float Origin[3], float Angles[3], int Health, int IsCarLocked)
{

	//Declare:
	//int Ent = CreateEntityByName("prop_vehicle_airboat");

	int Ent = CreateEntityByName("prop_vehicle_driveable");


	//Check:
	if(Ent == -1)
	{

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create vehicle entity");

		//Return:
		return -1;
	}

	//Set Health:
	SetEntProp(Ent, Prop_Data, "m_iHealth", Health);

	//MaxHealth:
	SetEntProp(Ent, Prop_Data, "m_iMaxHealth", Health);

	//Send:
	SetEntProp(Ent, Prop_Data, "m_bLocked", IsCarLocked);

	//Declare:
	char TargetName[10];

	//Format:
	Format(TargetName, sizeof(TargetName), "%i", Ent);

	//Dispatch:
	DispatchKeyValue(Ent, "targetname", TargetName);

	DispatchKeyValue(Ent, "physdamagescale", "1.0");


	DispatchKeyValue(Ent, "model", "models/airboat.mdl");


	DispatchKeyValue(Ent, "vehiclescript", "scripts/vehicles/buggy_edit.txt");


	DispatchKeyValue(Ent, "EnableGun", "0");

	//Spawn
	DispatchSpawn(Ent);


	ActivateEntity(Ent);

	//Set do default classname
	SetEntityClassName(Ent, "prop_vehicle_Helicopter");

	SetEntityModel(Ent, "models/combine_helicopter.mdl");

	//Teleport:
	TeleportEntity(Ent, Origin, Angles, NULL_VECTOR);

	//Set Physics:
	SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);

	SetEntProp(Ent, Prop_Data, "m_nVehicleType", 1);

	// stops the vehicle rolling back when it is spawned.
	SetEntProp(Ent, Prop_Data, "m_nNextThinkTick", -1);

	//Accept:
	AcceptEntityInput(Ent, "TurnOn", Client);

	// anti flip, not 100% effective.
	int PhysIndex = CreateEntityByName("phys_ragdollconstraint");

	//Check:
	if (PhysIndex == -1)
	{

		//Request:
		RequestFrame(OnNextFrameKill, Ent);

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create anti flip entity");

		//Return:
		return -1;
	}

	//Dispatch:
	DispatchKeyValue(PhysIndex, "spawnflags", "2");

	DispatchKeyValue(PhysIndex, "ymin", "-50.0");

	DispatchKeyValue(PhysIndex, "ymax", "50.0");

	DispatchKeyValue(PhysIndex, "zmin", "-180.0");

	DispatchKeyValue(PhysIndex, "zmax", "180.0");

	DispatchKeyValue(PhysIndex, "xmin", "-50.0");

	DispatchKeyValue(PhysIndex, "xmax", "50.0");
	
	DispatchKeyValue(PhysIndex, "attach1", TargetName);

	//Spawn:	
	DispatchSpawn(PhysIndex);

	//Activate:
	ActivateEntity(PhysIndex);

	//Set String:
	SetVariantString("!activator");

	//Accept:
	AcceptEntityInput(PhysIndex, "SetParent", Ent, PhysIndex, 0);

	//Teleport:
	TeleportEntity(PhysIndex, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);

	//Invincible:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnVehicleTakeDamage);

	//Return:
	return Ent;
}

//Event Damage:
public Action OnVehicleTakeDamage(int Vehicle, int &Attacker, int &Inflictor, float &Damage, int &DamageType)
{

	//Declare:
	int Driver = GetEntPropEnt(Vehicle, Prop_Send, "m_hPlayer");

	//Check:
	if(Driver == -1)
	{

		//Loop:
		for(int Client = 1; Client <= GetMaxClients(); Client++)
		{

			//Connected:
			if(IsClientConnected(Client) && IsClientInGame(Client) && Driver == Client)
			{

				//Is Not Cuffed + Has Crime:
				if(GetCrime(Client) > 2500)
				{

					if(Attacker > 0 && Attacker <= GetMaxClients())
					{

						//Forward rp_jail.sp
						OnClientCuffCheckInVehicle(Client, Vehicle, Attacker, Damage);
					}
				}
			}
		}
	}

	//Health:
	int Health = GetEntProp(Vehicle, Prop_Data, "m_iHealth");

	//Check:
	if(Health - RoundFloat(Damage) <= 0)
	{

		//Forward:
		OnVehicleExplode(Vehicle);
	}

	//Return:
	return Plugin_Changed;
}

public void OnVehicleExplode(int Vehicle)
{

	//Declare:
	char Model[64];

	//Model:
	GetEntPropString(Vehicle, Prop_Data, "m_ModelName", Model, sizeof(Model));

	//Declare:
	int Driver = GetEntPropEnt(Vehicle, Prop_Send, "m_hPlayer");

	//Check:
	if(Driver == -1)
	{

		//Loop:
		for(int Client = 1; Client <= GetMaxClients(); Client++)
		{

			//Connected:
			if(IsClientConnected(Client) && IsClientInGame(Client) && Driver == Client)
			{

				//Exit:
				ExitVehicle(Driver, Vehicle, true);

				//Request:
				RequestFrame(OnNextFrameKill, Driver);
			}
		}
	}

	//Declare:
	float Angles[3];

	//Initulize:
	GetEntPropVector(Vehicle, Prop_Send, "m_angRotation", Angles);

	//Declare:
	float Origin[3];

	//Initulize:
	GetEntPropVector(Vehicle, Prop_Send, "m_vecOrigin", Origin);

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client) && GetPlayerVehicle(Client) == Vehicle)
		{

			//CreateDamage:
			ExplosionDamage(Vehicle, Vehicle, Origin, DMG_BURN);

			//Declare:
			int Entity = CreateProp(Origin, Angles, Model, true, false);

			//Initulize:
			SetEntityRenderMode(Entity, RENDER_GLOW);

			SetEntityRenderColor(Entity, 40, 40, 40, 255);

			SetPlayerVehicle(Client, Entity);

			//Set do default classname
			SetEntityClassName(Entity, "prop_vehicle_damaged");

			//TE Setup:
			TE_SetupDynamicLight(Origin, 255, 100, 10, 8, 150.0, 0.4, 50.0);

			//Send:
			TE_SendToAll();

			//Emit Sound:
			EmitAmbientSound("ambient/explosions/explode_5.wav", Origin, SNDLEVEL_RAIDSIREN);

			//Temp Ent:
			TE_SetupExplosion(Origin, Smoke(), 10.0, 1, 0, 100, 5000);

			//Send:
			TE_SendToAll();

			//Temp Ent:
			TE_SetupExplosion(Origin, Explode(), 5.0, 1, 0, 600, 5000);

			//Send:
			TE_SendToAll();

			//Declare:
			float Offset[3] = {0.0,...};

			//Create Fire Effect!
			CreateInfoParticleSystemOther(Entity, "null", "Fire_Large_01", 0.2, Offset, Angles);

			//Initulize:
			SetVehicleMetal(Client, 500);

			//Health:
			SetEntProp(Entity, Prop_Data, "m_iHealth", 100000000);

			//Invincible:
			SetEntProp(Entity, Prop_Data, "m_takedamage", 2, 1);

			//Damage Hook:
			SDKHook(Entity, SDKHook_OnTakeDamage, OnVehicleDamagedTakeDamage);

			//Stop:
			break;
		}
	}
}

//Event Damage:
public Action OnVehicleDamagedTakeDamage(int Vehicle, int &Attacker, int &Inflictor, float &Damage, int &DamageType)
{

	//Check:
	if(Attacker > 0 && Attacker <= GetMaxClients())
	{

		//Declare:
		char WeaponName[32];

		//Initulize;
		GetClientWeapon(Attacker, WeaponName, sizeof(WeaponName));

		//Is Stun Stick:
		if(StrEqual(WeaponName, GetArrestWeapon(), false) || StrEqual(WeaponName, GetRepairWeapon(), false))
		{

			//Declare:
			float Origin[3];
			float Position[3];

			//Get Prop Data:
			GetEntPropVector(Vehicle, Prop_Send, "m_vecOrigin", Position);

			GetClientAbsOrigin(Attacker, Origin);

			//Declare:
			float Dist = GetVectorDistance(Position, Origin);

			//In Distance:	
			if(Dist <= 150)
			{

				//Declare:
				int Amount = RoundFloat(Damage);
				int Owner = GetOwnerOfVehicle(Vehicle);

				//Check:
				if(GetVehicleMetal(Owner) - Amount < 0)
				{

					//Initulize:
					SetMetal(Attacker, (GetMetal(Attacker) + GetVehicleMetal(Owner)));

					SetVehicleMetal(Owner, 0);
				}

				//Override:
				else
				{

					//Initulize:
					SetMetal(Attacker, (GetMetal(Attacker) + Amount));

					SetVehicleMetal(Owner, (GetVehicleMetal(Owner) - Amount));
				}
			}
		}
	}

	//Initulize:
	Damage = 0.0;

	//Return:
	return Plugin_Changed;
}
