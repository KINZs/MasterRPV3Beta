//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_dropped_included_
  #endinput
#endif
#define _rp_dropped_included_


//Define:
#define MAXDROPPEDMONEYPROPS		100
#define MAXDROPPEDDRUGPROPS		25

int DroppedDrugValue[2047] = {0,...};
int DroppedMethValue[2047] = {0,...};
int DroppedPillsValue[2047] = {0,...};
int DroppedCocainValue[2047] = {0,...};
int DroppedMoneyValue[2047] = {0,...};
int DroppedResourcesValue[2047] = {0,...};
int DroppedMetalValue[2047] = {0,...};

public void ResetDropped()
{

	//Clean map entitys:
	for(int X = 0; X < 2047; X++)
	{

		//Initulize:
		DroppedDrugValue[X] = 0;

		DroppedMethValue[X] = 0;

		DroppedPillsValue[X] = 0;

		DroppedCocainValue[X] = 0;

		DroppedMoneyValue[X] = 0;

		DroppedResourcesValue[X] = 0;

		DroppedMetalValue[X] = 0;
	}
}

public void CreateWeedBags(int Client, int Amount)
{

	//Declare:
	int Collision = 0;
	float Position[3];
	float OrgPos[2];
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Declare:
		int Props = GetWeedPropsOnMap();
		int MapProps = CheckMapEntityCount();

		//Loop:
		while(Amount > 0)
		{

			//Check:
			if(MapProps > 1800)
			{

				//Initulize:
				Amount = 0;

				//Return:
				break;
			}

			//Check:
			if(Props >= MAXDROPPEDDRUGPROPS)
			{

				//Can Replace Prop:
				if(ReplaceWeedProp() == false)
				{

					//Initulize:
					Amount = 0;

					//Return:
					break;
				}

				//Remove:
				RemoveLowWeedCountProps();
			}

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				int Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 50000)
				{

					//Initulize:
					DroppedDrugValue[Ent] = 50000;

					//Initulize:
					Amount -= 50000;

					//Declare:
					float ModelScale = GetRandomFloat(3.0, 3.2);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 2000)
				{

					//Initulize:
					DroppedDrugValue[Ent] = 2000;

					//Initulize:
					Amount -= 2000;

					//Declare:
					float ModelScale = GetRandomFloat(2.0, 2.2);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 200)
				{

					//Initulize:
					DroppedDrugValue[Ent] = 200;

					//Initulize:
					Amount -= 250;
				}

				//Override:
				else
				{

					//Initulize:
					DroppedDrugValue[Ent] = Amount;

					//Initulize:
					Amount = 0;
				}

				//Dispatch:
				DispatchKeyValue(Ent, "model", "models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl");

				//Spawn:
				DispatchSpawn(Ent);

				//Initulize:
				Props += 1;
				MapProps += 1;

				//Set Ent Move Type:
				SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Set do default classname
				SetEntityClassName(Ent, "prop_Weed_Bag");

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);
			}
		}
	}
}

public int GetWeedPropsOnMap()
{

	//Declare:
	int Props = -1;
	int Amount = 0;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Weed_Bag")) > 0)
	{

		//Initulize:
		Amount += 1;
	}

	//Return:
	return view_as<int>(Amount);
}

public void RemoveLowWeedCountProps()
{

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Weed_Bag")) > 0)
	{

		//Check:
		if(DroppedDrugValue[Props] > 0 && DroppedDrugValue[Props] <= 500)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedDrugValue[Props] = 0;
		}
	}
}

public bool ReplaceWeedProp()
{

	//Declare:
	bool Result = false;

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Weed_Bag")) > 0)
	{

		//Check:
		if(DroppedDrugValue[Props] > 0)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedDrugValue[Props] = 0;

			Result = true;

			//Stop:
			break;
		}
	}

	//Return:
	return view_as<bool>(Result);
}

public void CreateDroppedPills(int Client, int Amount)
{

	//Declare:
	int Collision = 0;
	float Position[3];
	float OrgPos[2];
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Delclare:
		int Props = GetPillsPropsOnMap();
		int MapProps = CheckMapEntityCount();

		//Loop:
		while(Amount > 0)
		{

			//Check:
			if(MapProps > 1800)
			{

				//Initulize:
				Amount = 0;

				//Return:
				break;
			}

			//Check:
			if(Props >= MAXDROPPEDDRUGPROPS)
			{

				//Can Replace Prop:
				if(ReplacePillsProp() == false)
				{

					//Initulize:
					Amount = 0;

					//Return:
					break;
				}

				//Remove:
				RemoveLowPillsCountProps();
			}

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				int Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 5000)
				{

					//Initulize:
					DroppedPillsValue[Ent] = 10000;

					//Initulize:
					Amount -= 10000;

					//Declare:
					float ModelScale = GetRandomFloat(3.0, 3.2);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 500)
				{

					//Initulize:
					DroppedPillsValue[Ent] = 500;

					//Initulize:
					Amount -= 500;

					//Declare:
					float ModelScale = GetRandomFloat(2.0, 2.2);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 50)
				{

					//Initulize:
					DroppedPillsValue[Ent] = 50;

					//Initulize:
					Amount -= 50;
				}

				//Override:
				else
				{

					//Initulize:
					DroppedPillsValue[Ent] = Amount;

					//Initulize:
					Amount = 0;
				}

				//Dispatch:
				DispatchKeyValue(Ent, "model", "models/props_lab/jar01b.mdl");

				//Spawn:
				DispatchSpawn(Ent);

				//Initulize:
				Props += 1;
				MapProps += 1;

				//Set Ent Move Type:
				SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);

				//Set do default classname
				SetEntityClassName(Ent, "prop_Pill_Jar");
			}
		}
	}
}

public int GetPillsPropsOnMap()
{

	//Declare:
	int Props = -1;
	int Amount = 0;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Pill_Jar")) > 0)
	{

		//Initulize:
		Amount += 1;
	}

	//Return:
	return view_as<int>(Amount);
}

public void RemoveLowPillsCountProps()
{

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Pill_Jar")) > 0)
	{

		//Check:
		if(DroppedPillsValue[Props] > 0 && DroppedPillsValue[Props] <= 500)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedPillsValue[Props] = 0;
		}
	}
}

public bool ReplacePillsProp()
{

	//Declare:
	bool Result = false;

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Pill_Jar")) > 0)
	{

		//Check:
		if(DroppedPillsValue[Props] > 0)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedPillsValue[Props] = 0;

			Result = true;

			//Stop:
			break;
		}
	}

	//Return:
	return view_as<bool>(Result);
}

public void CreateDroppedMeths(int Client, int Amount)
{

	//Declare:
	int Collision = 0;
	float Position[3];
	float OrgPos[2];
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Declare:
		int Props = GetMethPropsOnMap();
		int MapProps = CheckMapEntityCount();

		//Loop:
		while(Amount > 0)
		{

			//Check:
			if(MapProps > 1800)
			{

				//Initulize:
				Amount = 0;

				//Return:
				break;
			}

			//Check:
			if(Props >= MAXDROPPEDDRUGPROPS)
			{

				//Can Replace Prop:
				if(ReplaceMethProp() == false)
				{

					//Initulize:
					Amount = 0;

					//Return:
					break;
				}

				//Remove:
				RemoveLowMethCountProps();
			}

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				int Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 10000)
				{

					//Initulize:
					DroppedMethValue[Ent] = 10000;

					//Initulize:
					Amount -= 10000;

					//Declare:
					float ModelScale = GetRandomFloat(3.0, 3.2);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 2000)
				{

					//Initulize:
					DroppedMethValue[Ent] = 2000;

					//Initulize:
					Amount -= 2000;

					//Declare:
					float ModelScale = GetRandomFloat(2.0, 2.2);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 200)
				{

					//Initulize:
					DroppedMethValue[Ent] = 200;

					//Initulize:
					Amount -= 200;
				}

				//Override:
				else
				{

					//Initulize:
					DroppedMethValue[Ent] = Amount;

					//Initulize:
					Amount = 0;
				}

				//Dispatch:
				DispatchKeyValue(Ent, "model", "models/katharsmodels/contraband/metasync/blue_sky.mdl");

				//Spawn:
				DispatchSpawn(Ent);

				//Initulize:
				Props += 1;
				MapProps += 1;

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);

				//Set do default classname
				SetEntityClassName(Ent, "prop_Meth_Bag");
			}
		}
	}
}

public int GetMethPropsOnMap()
{

	//Declare:
	int Props = -1;
	int Amount = 0;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Meth_Bag")) > 0)
	{

		//Initulize:
		Amount += 1;
	}

	//Return:
	return view_as<int>(Amount);
}

public void RemoveLowMethCountProps()
{

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Meth_Bag")) > 0)
	{

		//Check:
		if(DroppedMethValue[Props] > 0 && DroppedMethValue[Props] <= 50)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedMethValue[Props] = 0;
		}
	}
}

public bool ReplaceMethProp()
{

	//Declare:
	bool Result = false;

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Meth_Bag")) > 0)
	{

		//Check:
		if(DroppedMethValue[Props] > 0)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedMethValue[Props] = 0;

			Result = true;

			//Stop:
			break;
		}
	}

	//Return:
	return view_as<bool>(Result);
}

public void CreateDroppedCocains(int Client, int Amount)
{

	//Declare:
	int Collision = 0;
	float Position[3];
	float OrgPos[2];
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Declare:
		int Props = GetCocainPropsOnMap();
		int MapProps = CheckMapEntityCount();

		//Loop:
		while(Amount > 0)
		{

			//Check:
			if(MapProps > 1800)
			{

				//Initulize:
				Amount = 0;

				//Return:
				break;
			}

			//Check:
			if(Props >= MAXDROPPEDDRUGPROPS)
			{

				//Can Replace Prop:
				if(ReplaceCocainProp() == false)
				{

					//Initulize:
					Amount = 0;

					//Return:
					break;
				}

				//Remove:
				RemoveLowCocainCountProps();
			}

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				int Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 10000)
				{

					//Initulize:
					DroppedCocainValue[Ent] = 10000;

					//Initulize:
					Amount -= 10000;

					//Declare:
					float ModelScale = GetRandomFloat(2.2, 2.4);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 2000)
				{

					//Initulize:
					DroppedCocainValue[Ent] = 2000;

					//Initulize:
					Amount -= 2000;

					//Declare:
					float ModelScale = GetRandomFloat(2.0, 2.2);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 200)
				{

					//Initulize:
					DroppedCocainValue[Ent] = 200;

					//Initulize:
					Amount -= 200;

					//Declare:
					float ModelScale = GetRandomFloat(1.6, 1.8);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				//Override:
				else
				{

					//Initulize:
					DroppedCocainValue[Ent] = Amount;

					//Initulize:
					Amount = 0;
				}

				//Dispatch:
				DispatchKeyValue(Ent, "model", "models/srcocainelab/ziplockedcocaine.mdl");

				//Spawn:
				DispatchSpawn(Ent);

				//Initulize:
				Props += 1;
				MapProps += 1;

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);

				//Set do default classname
				SetEntityClassName(Ent, "prop_Cocain_Bag");
			}
		}
	}
}

public int GetCocainPropsOnMap()
{

	//Declare:
	int Props = -1;
	int Amount = 0;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Cocain_Bag")) > 0)
	{

		//Initulize:
		Amount += 1;
	}

	//Return:
	return view_as<int>(Amount);
}

public void RemoveLowCocainCountProps()
{

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Cocain_Bag")) > 0)
	{

		//Check:
		if(DroppedCocainValue[Props] > 0 && DroppedCocainValue[Props] <= 50)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedCocainValue[Props] = 0;
		}
	}
}

public bool ReplaceCocainProp()
{
	//Declare:
	bool Result = false;

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "prop_Cocain_Bag")) > 0)
	{

		//Check:
		if(DroppedCocainValue[Props] > 0)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedCocainValue[Props] = 0;

			Result = true;

			//Stop:
			break;
		}
	}

	//Return:
	return view_as<bool>(Result);
}

public int GetDroppedDrugValue(int Ent)
{

	//Return:
	return DroppedDrugValue[Ent];
}

public int GetDroppedMethValue(int Ent)
{

	//Return:
	return DroppedMethValue[Ent];
}

public int GetDroppedPillsValue(int Ent)
{

	//Return:
	return DroppedPillsValue[Ent];
}

public int GetDroppedCocainValue(int Ent)
{

	//Return:
	return DroppedCocainValue[Ent];
}

public void SetDroppedDrugValue(int Ent, int Amount)
{

	//Initulize:
	DroppedDrugValue[Ent] = Amount;
}

public void SetDroppedMethValue(int Ent, int Amount)
{

	//Initulize:
	DroppedMethValue[Ent] = Amount;
}

public void SetDroppedPillsValue(int Ent, int Amount)
{

	//Initulize:
	DroppedPillsValue[Ent] = Amount;
}

public void SetDroppedCocainValue(int Ent, int Amount)
{

	//Initulize:
	DroppedCocainValue[Ent] = Amount;
}

public void OnClientPickUpWeedBag(int Client, int Ent)
{

	//Check:
	if(IsCop(Client))
	{

		//Delare:
		int Amount = (DroppedDrugValue[Ent] / 5);

		//Initulize:
		SetCash(Client, (GetCash(Client) + Amount));

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF You have Destroyed Drugs!");
	}

	//Override:
	else
	{

		//Delare:
		int Amount = DroppedDrugValue[Ent];

		//Initulize:
		SetHarvest(Client, (GetHarvest(Client) + Amount));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Drugs|\x07FFFFFF you have just picked up \x0732CD32%ig\x07FFFFFF of weed!", Amount);
	}

	//Request:
	RequestFrame(OnNextFrameKill, Ent);

	//Initulize:
	DroppedDrugValue[Ent] = 0;
}

public void OnClientPickUpMeth(int Client, int Ent)
{

	//Check:
	if(IsCop(Client))
	{

		//Delare:
		int Amount = (DroppedMethValue[Ent] / 2);

		//Initulize:
		SetCash(Client, (GetCash(Client) + Amount));

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF You have Destroyed Drugs!");
	}

	//Override:
	else
	{

		//Delare:
		int Amount = DroppedMethValue[Ent];

		//Initulize:
		SetMeth(Client, (GetMeth(Client) + Amount));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Drugs|\x07FFFFFF you have just picked up \x0732CD32%ig\x07FFFFFF of Meth!", Amount);
	}

	//Request:
	RequestFrame(OnNextFrameKill, Ent);

	//Initulize:
	DroppedMethValue[Ent] = 0;
}

public void OnClientPickUpPills(int Client, int Ent)
{

	//Check:
	if(IsCop(Client))
	{

		//Delare:
		int Amount = (DroppedPillsValue[Ent] / 2);

		//Initulize:
		SetCash(Client, (GetCash(Client) + Amount));

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF You have Destroyed Drugs!");
	}

	//Override:
	else
	{

		//Delare:
		int Amount = DroppedPillsValue[Ent];

		//Initulize:
		SetPills(Client, (GetPills(Client) + Amount));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Drugs|\x07FFFFFF you have just picked up \x0732CD32%i\x07FFFFFF Pills!", Amount);
	}

	//Request:
	RequestFrame(OnNextFrameKill, Ent);

	//Initulize:
	DroppedPillsValue[Ent] = 0;
}

public void OnClientPickUpCocain(int Client, int Ent)
{

	//Check:
	if(IsCop(Client))
	{

		//Delare:
		int Amount = (DroppedCocainValue[Ent] / 2);

		//Initulize:
		SetCash(Client, (GetCash(Client) + Amount));

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF You have Destroyed Drugs!");
	}

	//Override:
	else
	{

		//Delare:
		int Amount = DroppedCocainValue[Ent];

		//Initulize:
		SetCocain(Client, (GetCocain(Client) + Amount));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Drugs|\x07FFFFFF you have just picked up \x0732CD32%ig\x07FFFFFF of Cocain!", Amount);
	}

	//Request:
	RequestFrame(OnNextFrameKill, Ent);

	//Initulize:
	DroppedCocainValue[Ent] = 0;
}

public void OnClientDropAllDrugs(int Client)
{

	//Check:
	if(GetHarvest(Client) > 0)
	{

		//Declare:
		int Amount = GetHarvest(Client);

		//Initulize:
		SetHarvest(Client, (GetHarvest(Client) - Amount));

		//Create:
		CreateWeedBags(Client, Amount);
	}

	//Check:
	if(GetMeth(Client) > 0)
	{

		//Declare:
		int Amount = GetMeth(Client);

		//Initulize:
		SetMeth(Client, (GetMeth(Client) - Amount));

		//Create:
		CreateDroppedMeths(Client, Amount);
	}

	//Check:
	if(GetPills(Client) > 0)
	{

		//Declare:
		int Amount = GetPills(Client);

		//Initulize:
		SetPills(Client, (GetPills(Client) - Amount));

		//Create:
		CreateDroppedPills(Client, Amount);
	}

	//Check:
	if(GetCocain(Client) > 0)
	{

		//Declare:
		int Amount = GetCocain(Client);

		//Initulize:
		SetCocain(Client, (GetCocain(Client) - Amount));

		//Create:
		CreateDroppedCocains(Client, Amount);
	}

	//Check:
	if(GetResources(Client) > 0)
	{

		//Declare:
		int Amount = GetResources(Client);

		//Initulize:
		SetResources(Client, (GetResources(Client) - Amount));

		//Create:
		CreateDroppedResources(Client, Amount);
	}

	//Check:
	if(GetMetal(Client) > 0)
	{

		//Declare:
		int Amount = GetMetal(Client);

		//Initulize:
		SetMetal(Client, (GetMetal(Client) - Amount));

		//Create:
		CreateDroppedMetal(Client, Amount);
	}
}

public int GetDroppedMoneyValue(int Ent)
{

	//Return:
	return DroppedMoneyValue[Ent];
}

public void SetDroppedMoneyValue(int Ent, int Amount)
{

	//Initulize:
	DroppedMoneyValue[Ent] = Amount;
}

public void OnClientPickUpMoney(int Client, int Ent)
{

	//Delare:
	int Amount = DroppedMoneyValue[Ent];

	//Initulize:
	SetCash(Client, (GetCash(Client) + Amount));

	//Request:
	RequestFrame(OnNextFrameKill, Ent);

	//Initulize:
	DroppedMoneyValue[Ent] = 0;
}

public void CreateMoneyBoxes(int Client, int Amount)
{

	//Declare:
	int Collision = 0;
	float Position[3];
	float OrgPos[2];
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Declare:
		int Props = GetMoneyPropsOnMap();
		int MapProps = CheckMapEntityCount();

		//Loop:
		while(Amount > 0)
		{

			//Check:
			if(MapProps > 1800)
			{

				//Initulize:
				Amount = 0;

				//Return:
				break;
			}

			//Check:
			if(Props >= MAXDROPPEDMONEYPROPS)
			{

				//Can Replace Prop:
				if(ReplaceMoneyProp() == false)
				{

					//Initulize:
					Amount = 0;

					//Return:
					break;
				}

				//Remove:
				RemoveLowMoneyCountProps();
			}

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				int Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 10000000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 10000000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/goldbar.mdl");

					//Initulize:
					Amount -= 10000000;

					//Declare:
					float ModelScale = GetRandomFloat(3.0, 3.2);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);


					//Set Glow:
					SetEntityRenderMode(Ent, RENDER_GLOW);

					//Set Color:
					SetEntityRenderColor(Ent, 255, 255, 50, 255);
				}

				else if(Amount > 1000000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 1000000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/goldbar.mdl");

					//Initulize:
					Amount -= 1000000;

					//Declare:
					float ModelScale = GetRandomFloat(2.0, 2.2);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);


					//Set Glow:
					SetEntityRenderMode(Ent, RENDER_GLOW);

					//Set Color:
					SetEntityRenderColor(Ent, 255, 255, 50, 255);
				}

				else if(Amount > 100000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 100000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/goldbar.mdl");

					//Initulize:
					Amount -= 100000;

					//Declare:
					float ModelScale = GetRandomFloat(0.9, 1.1);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);


					//Set Glow:
					SetEntityRenderMode(Ent, RENDER_GLOW);

					//Set Color:
					SetEntityRenderColor(Ent, 255, 255, 50, 255);
				}

				else if(Amount > 10000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 10000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/goldbar.mdl");

					//Initulize:
					Amount -= 10000;

					//Declare:
					float ModelScale = GetRandomFloat(0.5, 0.6);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);


					//Set Glow:
					SetEntityRenderMode(Ent, RENDER_GLOW);

					//Set Color:
					SetEntityRenderColor(Ent, 255, 255, 50, 255);
				}

				else if(Amount > 5000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 5000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 5000;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 6);
				}

				else if(Amount > 3000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 3000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 3000;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 5);
				}

				else if(Amount > 2000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 2000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 2000;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 4);
				}

				else if(Amount > 1000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 1000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 1000;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 3);
				}

				else if(Amount > 500) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 500;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 500;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 2);
				}

				else if(Amount > 200) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 200;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 200;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 0);
				}

				else if(Amount > 100) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 100;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 100;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 1);
				}

				else if(Amount > 25) //golcoin
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 25;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/goldcoin.mdl");

					//Initulize:
					Amount -= 25;
				}

				else if(Amount > 10) //silvcoin
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 10;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/silvcoin.mdl");

					//Initulize:
					Amount -= 10;
				}

				else if(Amount > 5) //silvcoin
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 5;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/silvcoin.mdl");

					//Initulize:
					Amount -= 5;
				}

				else //broncoin
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 1;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/broncoin.mdl");

					//Initulize:
					Amount -= 1;
				}

				//Spawn:
				DispatchSpawn(Ent);

				//Initulize:
				Props += 1;
				MapProps += 1;

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Set do default classname
				SetEntityClassName(Ent, "prop_Money");

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);
			}
		}
	}
}

public void OnClientDropMoney(int Client)
{

	//Override:
	if(GetCash(Client) > 50)
	{

		//Delare:
		int Amount = GetCash(Client);

		//Initulize:
		SetCash(Client, (GetCash(Client) - Amount));

		//Create:
		CreateMoneyBoxes(Client, Amount);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF you have just dropped \x0732CD32%s\x07FFFFFF!", IntToMoney(Amount));
	}
}

public int GetMoneyPropsOnMap()
{

	//Declare:
	int Props = -1;
	int Amount = 0;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "Prop_Money")) > 0)
	{

		//Initulize:
		Amount += 1;
	}

	//Return:
	return view_as<int>(Amount);
}

public void RemoveLowMoneyCountProps()
{

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "Prop_Money")) > 0)
	{

		//Check:
		if(DroppedMoneyValue[Props] > 0 && DroppedMoneyValue[Props] < 10000)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedMoneyValue[Props] = 0;
		}
	}
}

public bool ReplaceMoneyProp()
{

	//Declare:
	bool Result = false;

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "Prop_Money")) > 0)
	{

		//Check:
		if(DroppedMoneyValue[Props] > 0)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedMoneyValue[Props] = 0;

			Result = true;

			//Stop:
			break;
		}
	}

	//Return:
	return view_as<bool>(Result);
}

public int GetDroppedResourcesValue(int Ent)
{

	//Return:
	return DroppedResourcesValue[Ent];
}

public void SetDroppedResourcesValue(int Ent, int Amount)
{

	//Initulize:
	DroppedResourcesValue[Ent] = Amount;
}

public void OnClientPickUpResources(int Client, int Ent)
{

	//Delare:
	int Amount = DroppedResourcesValue[Ent];

	//Initulize:
	SetResources(Client, (GetResources(Client) + Amount));

	//Request:
	RequestFrame(OnNextFrameKill, Ent);

	//Initulize:
	DroppedResourcesValue[Ent] = 0;
}

public void CreateDroppedResources(int Client, int Amount)
{

	//Declare:
	int Collision = 0;
	float Position[3];
	float OrgPos[2];
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Declare:
		int Props = GetResourcesPropsOnMap();
		int MapProps = CheckMapEntityCount();

		//Loop:
		while(Amount > 0)
		{

			//Check:
			if(MapProps > 1800)
			{

				//Initulize:
				Amount = 0;

				//Return:
				break;
			}

			//Check:
			if(Props >= MAXDROPPEDDRUGPROPS)
			{

				//Can Replace Prop:
				if(ReplaceResourcesProp() == false)
				{

					//Initulize:
					Amount = 0;

					//Return:
					break;
				}

				//Remove:
				RemoveLowResourcesCountProps();
			}

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				int Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 100000)
				{

					//Initulize:
					DroppedResourcesValue[Ent] = 100000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/props_debris/concrete_chunk09a.mdl");

					//Initulize:
					Amount -= 100000;

					//Declare:
					float ModelScale = GetRandomFloat(2.2, 2.4);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 10000)
				{

					//Initulize:
					DroppedResourcesValue[Ent] = 10000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/props_debris/concrete_chunk04a.mdl");

					//Initulize:
					Amount -= 10000;

					//Declare:
					float ModelScale = GetRandomFloat(1.4, 1.6);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 1000)
				{

					//Initulize:
					DroppedResourcesValue[Ent] = 1000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/props_debris/concrete_chunk09a.mdl");

					//Initulize:
					Amount -= 1000;

					//Declare:
					float ModelScale = GetRandomFloat(1.2, 1.4);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				//Override:
				else
				{

					//Initulize:
					DroppedResourcesValue[Ent] = Amount;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/props_debris/concrete_chunk05g.mdl");

					//Initulize:
					Amount = 0;
				}

				//Spawn:
				DispatchSpawn(Ent);

				//Initulize:
				Props += 1;
				MapProps += 1;

				//Declare:
				int Random = GetRandomInt(1, 6);

				//Declare:
				int Color[4];

				switch(Random)
				{

					case 1:
					{

						//Initulize:
						Color[0] = 255;
						Color[1] = 100;
						Color[2] = 100;
						Color[3] = 245;
					}

					case 2:
					{

						//Initulize:
						Color[0] = 255;
						Color[1] = 225;
						Color[2] = 100;
						Color[3] = 245;
					}

					case 3:
					{

						//Initulize:
						Color[0] = 100;
						Color[1] = 225;
						Color[2] = 225;
						Color[3] = 245;
					}

					case 4:
					{

						//Initulize:
						Color[0] = 100;
						Color[1] = 100;
						Color[2] = 225;
						Color[3] = 245;
					}

					case 5:
					{

						//Initulize:
						Color[0] = 255;
						Color[1] = 100;
						Color[2] = 225;
						Color[3] = 245;
					}

					case 6:
					{

						//Initulize:
						Color[0] = 100;
						Color[1] = 225;
						Color[2] = 100;
						Color[3] = 245;
					}
				}

				//Set Glow:
				SetEntityRenderMode(Ent, RENDER_GLOW);

				//Set Color:
				SetEntityRenderColor(Ent, Color[0], Color[1], Color[2], Color[3]);

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Set do default classname
				SetEntityClassName(Ent, "prop_Resources");

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);
			}
		}
	}
}

public int GetResourcesPropsOnMap()
{

	//Declare:
	int Props = -1;
	int Amount = 0;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "Prop_Resources")) > 0)
	{

		//Initulize:
		Amount += 1;
	}

	//Return:
	return view_as<int>(Amount);
}

public void RemoveLowResourcesCountProps()
{

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "Prop_Resources")) > 0)
	{

		//Check:
		if(DroppedResourcesValue[Props] > 0 && DroppedResourcesValue[Props] <= 1000)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedResourcesValue[Props] = 0;
		}
	}
}

public bool ReplaceResourcesProp()
{

	//Declare:
	bool Result = false;

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "Prop_Resources")) > 0)
	{

		//Check:
		if(DroppedResourcesValue[Props] > 0)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedResourcesValue[Props] = 0;

			Result = true;

			//Stop:
			break;
		}
	}

	//Return:
	return view_as<bool>(Result);
}

public int GetDroppedMetalValue(int Ent)
{

	//Return:
	return DroppedMetalValue[Ent];
}

public void SetDroppedMetalValue(int Ent, int Amount)
{

	//Initulize:
	DroppedMetalValue[Ent] = Amount;
}

public void OnClientPickUpMetal(int Client, int Ent)
{

	//Delare:
	int Amount = DroppedMetalValue[Ent];

	//Initulize:
	SetMetal(Client, (GetMetal(Client) + Amount));

	//Request:
	RequestFrame(OnNextFrameKill, Ent);

	//Initulize:
	DroppedMetalValue[Ent] = 0;
}

public void CreateDroppedMetal(int Client, int Amount)
{

	//Declare:
	int Collision = 0;
	float Position[3];
	float OrgPos[2];
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Declare:
		int Props = GetMetalPropsOnMap();
		int MapProps = CheckMapEntityCount();

		//Loop:
		while(Amount > 0)
		{

			//Check:
			if(MapProps > 1800)
			{

				//Initulize:
				Amount = 0;

				//Return:
				break;
			}

			//Check:
			if(Props >= MAXDROPPEDDRUGPROPS)
			{

				//Can Replace Prop:
				if(ReplaceMetalProp() == false)
				{

					//Initulize:
					Amount = 0;

					//Return:
					break;
				}

				//Remove:
				RemoveLowMetalCountProps();
			}

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				int Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 100000)
				{

					//Initulize:
					DroppedMetalValue[Ent] = 100000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/gibs/metal_gib2.mdl");

					//Initulize:
					Amount -= 100000;

					//Declare:
					float ModelScale = GetRandomFloat(2.2, 2.4);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 10000)
				{

					//Initulize:
					DroppedMetalValue[Ent] = 10000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/gibs/metal_gib2.mdl");

					//Initulize:
					Amount -= 10000;

					//Declare:
					float ModelScale = GetRandomFloat(1.4, 1.6);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 5000)
				{

					//Initulize:
					DroppedMetalValue[Ent] = 5000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/gibs/metal_gib3.mdl");

					//Initulize:
					Amount -= 1000;

					//Declare:
					float ModelScale = GetRandomFloat(1.2, 1.4);

					//Send:

					SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", ModelScale);

				}

				else if(Amount > 1000)
				{

					//Initulize:
					DroppedMetalValue[Ent] = 1000;


					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/gibs/metal_gib1.mdl");
					//Initulize:
					Amount -= 1000;
				}

				//Override:
				else
				{

					//Initulize:
					DroppedMetalValue[Ent] = Amount;


					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/gibs/metal_gib4.mdl");

					//Initulize:
					Amount = 0;
				}

				//Spawn:
				DispatchSpawn(Ent);

				//Initulize:
				Props += 1;

				MapProps += 1;

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Set do default classname
				SetEntityClassName(Ent, "prop_Metal");

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);
			}
		}
	}
}

public int GetMetalPropsOnMap()
{

	//Declare:
	int Props = -1;
	int Amount = 0;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "Prop_Metal")) > 0)
	{

		//Initulize:
		Amount += 1;
	}

	//Return:
	return view_as<int>(Amount);
}

public void RemoveLowMetalCountProps()
{

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "Prop_Metal")) > 0)
	{

		//Check:
		if(DroppedMetalValue[Props] > 0 && DroppedMetalValue[Props] <= 1000)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedMetalValue[Props] = 0;
		}
	}
}

public bool ReplaceMetalProp()
{

	//Declare:
	bool Result = false;

	//Declare:
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "Prop_Metal")) > 0)
	{

		//Check:
		if(DroppedMetalValue[Props] > 0)
		{

			//Request:
			RequestFrame(OnNextFrameKill, Props);

			//Initulize:
			DroppedMetalValue[Props] = 0;

			Result = true;

			//Stop:
			break;
		}
	}

	//Return:
	return view_as<bool>(Result);
}