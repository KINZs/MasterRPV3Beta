//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_trail_included_
  #endinput
#endif
#define _rp_trail_included_

#define MAXTRAILS	3

int PlayerTrail[MAXPLAYERS + 1][MAXTRAILS];
int PlayerFaceTrail[MAXPLAYERS + 1] = {-1,...};

public void initPlayerTrails()
{

	//Commands:
	RegConsoleCmd("sm_trails", Command_PlayerTrails);

	RegAdminCmd("sm_settrail", Command_SetTrail, ADMFLAG_ROOT, "<Slot> <Trail>- set the a player a status!");
}

public void initPlayerTrailEffects(int Client, int Timer)
{

	//Limit Timer to hud!
	if(Timer == 1 || Timer == 3 || Timer == 5 || Timer == 7 || Timer == 9)
	{

		//Is Player Alive:
		if(IsPlayerAlive(Client))
		{

			//Loop:
			for(int i = 0; i < MAXTRAILS; i++)
			{

				//Declare:
				int EntSlot = GetEntAttatchedEffect(Client, i);

				//Check:
				if(IsValidEntity(EntSlot))
				{

					//Check:
					if(PlayerTrail[Client][i] >= 15 && PlayerTrail[Client][i] <= 21)
					{

						//Accept:
						AcceptEntityInput(EntSlot, "DoSpark");
					}
				}

				//Switch:
				switch(PlayerTrail[Client][i])
				{

					//Misc Trails:
					case 1:
					{

						//Declare:
						float Angles[3];
						float Position[3];

						//Initialize:
						GetClientEyePosition(Client, Position);

						GetClientEyeAngles(Client, Angles);

						//Declare:
						char Particle[32];

						//Format:
						Format(Particle, sizeof(Particle), "env_fire_tiny_smoke");

						//Create Fire Effect!
						int Ent = CreateInfoParticleSystemOther(Client, "Eyes", Particle, 0.2, Position, Angles);

						//Initulize:
						SetEntAttatchedEffect(Client, i, Ent);

						//Initulize:
						PlayerFaceTrail[Client] = Ent;

						//SDKHOOK:
						SDKHook(Ent, SDKHook_SetTransmit, OnPlayerTrailTransmit);
					}

					//Misc Trails:
					case 22:
					{

						//Declare:
						float Angles[3];
						float Position[3];

						//Initialize:
						GetClientEyePosition(Client, Position);

						GetClientEyeAngles(Client, Angles);

						//Create Fire Effect!
						int Ent = CreateInfoParticleSystemOther(Client, "Eyes", "blood_impact_red_01", 0.2, Position, Angles);

						//Initulize:
						PlayerFaceTrail[Client] = Ent;

						//Initulize:
						SetEntAttatchedEffect(Client, i, Ent);

						//SDKHOOK:
						SDKHook(Ent, SDKHook_SetTransmit, OnPlayerTrailTransmit);
					}

					//Misc Trails:
					case 23:
					{

						//Declare:
						float Angles[3];
						float Position[3];

						//Initialize:
						GetClientEyePosition(Client, Position);

						GetClientEyeAngles(Client, Angles);

						//Declare:
						int Ent = CreateDynamicProp(Position, Angles, "models/gibs/hgibs.mdl", true);

						//Is Player:
						SetEntityRenderColor(Ent, 0, 0, 0, 255);

						//Set String:
						SetVariantString("!activator");

						//Accept:
						AcceptEntityInput(Ent, "SetParent", Client, Ent, 0);

						//Attach:
						SetVariantString("Eyes");

						//Accept:
						AcceptEntityInput(Ent, "SetParentAttachment", Ent , Ent, 0);

						//Initulize:
						PlayerFaceTrail[Client] = Ent;

						//Initulize:
						SetEntAttatchedEffect(Client, i, Ent);

						//SDKHOOK:
						SDKHook(Ent, SDKHook_SetTransmit, OnPlayerTrailTransmit);

						//Dessolve:
						EntityDissolve(Ent, 1);


						//TE Setup:

						TE_SetupDynamicLight(Position, 20, 70, 180, 8, 75.0, 0.4, 80.0);



						//Send:

						TE_SendToAll();
					}

					//Misc Trails:
					case 24:
					{

						//Declare:
						float Angles[3];
						float Position[3];

						//Initulize:
						GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);

						GetEntPropVector(Client, Prop_Data, "m_angRotation", Angles);

						//Declare:
						int Ent = CreateDynamicProp(Position, Angles, "models/gibs/hgibs.mdl", true);

						//Dessolve:
						EntityDissolve(Ent, 2);


						//TE Setup:

						TE_SetupDynamicLight(Position, 20, 70, 180, 8, 140.0, 0.4, 80.0);



						//Send:

						TE_SendToAll();
					}

					//Misc Trails:
					case 25:
					{

						//Declare:
						float Angles[3];
						float Position[3];

						//Initialize:
						GetClientEyePosition(Client, Position);

						GetClientEyeAngles(Client, Angles);

						//Create Fire Effect!
						int Ent = CreateInfoParticleSystemOther(Client, "Eyes", "blood_impact_green_01", 0.2, Position, Angles);

						//Initulize:
						SetEntAttatchedEffect(Client, i, Ent);

						//Initulize:
						PlayerFaceTrail[Client] = Ent;

						//SDKHOOK:
						SDKHook(Ent, SDKHook_SetTransmit, OnPlayerTrailTransmit);
					}

					//Misc Trails:
					case 26:
					{

						//Declare:
						float Angles[3];
						float Position[3];

						//Initialize:
						GetClientEyePosition(Client, Position);

						GetClientEyeAngles(Client, Angles);

						//Create Fire Effect!
						int Ent = CreateInfoParticleSystemOther(Client, "Eyes", "blood_impact_yellow_01", 0.2, Position, Angles);

						//Initulize:
						SetEntAttatchedEffect(Client, i, Ent);

						//Initulize:
						PlayerFaceTrail[Client] = Ent;

						//SDKHOOK:
						SDKHook(Ent, SDKHook_SetTransmit, OnPlayerTrailTransmit);
					}

					//Misc Trails:
					case 28:
					{

						//Declare:
						int OtherEnt = GetPlayerHatEnt(Client);

						//Check
						if(IsValidEdict(OtherEnt))
						{

							//Declare:
							char ModelName[128];

							//Initialize:
							GetEntPropString(OtherEnt, Prop_Data, "m_ModelName", ModelName, 128);

							//Check:
							if(StrEqual(ModelName, "models/props_lab/dogobject_wood_crate001a_damagedmax.mdl"))
							{

								//Declare:
								int Random = GetRandomInt(1, 7);

								//Declare:
								int Color[4] = {255,...};

								switch(Random)
								{

									case 1:
									{

										//Initulize:
										Color[0] = 255;
										Color[1] = 100;
										Color[2] = 100;
									}

									case 2:
									{

										//Initulize:
										Color[0] = 255;
										Color[1] = 225;
										Color[2] = 100;
									}

									case 3:
									{

										//Initulize:
									}

									case 4:
									{

										//Initulize:
										Color[0] = 100;
										Color[1] = 225;
										Color[2] = 225;
									}

									case 5:
									{

										//Initulize:
										Color[0] = 100;
										Color[1] = 100;
										Color[2] = 225;
									}

									case 6:
									{

										//Initulize:
										Color[0] = 255;
										Color[1] = 100;
										Color[2] = 225;
									}

									case 7:
									{

										//Initulize:
										Color[0] = 100;
										Color[1] = 225;
										Color[2] = 100;
									}
								}

								//Declare:
								float Position[3];

								//Initulize:
								GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);
								Position[2] += 20;

								//Is Player:
								SetEntityRenderColor(OtherEnt, Color[0], Color[1], Color[2], 128);


								//TE Setup:

								TE_SetupDynamicLight(Position, Color[0], Color[1], Color[2], 8, 140.0, 0.4, 80.0);



								//Send:

								TE_SendToAll();
							}
						}
					}

					//Misc Trails:
					case 29:
					{

						//Declare:
						int OtherEnt = GetEntAttatchedEffect(Client, i);

						//Check:
						if(IsValidEdict(OtherEnt))
						{

							//Declare:
							float Angles[3];
							float Position[3];

							//Initulize:
							GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);

							//Declare:
							float Random = GetRandomFloat(0.0, 360.0);
							Angles[0] = Random;
							Angles[1] = Random;
							Angles[2] = Random;

							//Send:
							TeleportEntity(OtherEnt, NULL_VECTOR, Angles, NULL_VECTOR);

							//TE Setup:

							TE_SetupDynamicLight(Position, 20, 70, 180, 8, 140.0, 0.4, 80.0);



							//Send:

							TE_SendToAll();
						}
					}

					//Misc Trails:
					case 30:
					{

						//Declare:
						float Angles[3];
						float Position[3];

						//Initialize:
						GetClientEyePosition(Client, Position);

						GetClientEyeAngles(Client, Angles);

						//Declare:
						char Particle[32];

						//Format:
						Format(Particle, sizeof(Particle), "vortigaunt_hand_glow");

						//Create Fire Effect!
						int Effect = CreateInfoParticleSystemOther(Client, "Eyes", Particle, 0.2, Position, Angles);

						//Initulize:
						SetEntAttatchedEffect(Client, i, Effect);

						//Initulize:
						PlayerFaceTrail[Client] = Effect;

						//SDKHOOK:
						SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
					}

					//Misc Trails:
					case 31:
					{
					}
				}
			}
		}
	}
}

public void CreatePlayerTrails(int Client)
{

	//Declare:
	int Effect = -1;

	//Loop:
	for(int i = 0; i < MAXTRAILS; i++)
	{

		int Entity = GetEntAttatchedEffect(Client, i);

		if(IsValidEdict(Client) && Entity > GetMaxClients())
		{

			//Request:
			RequestFrame(OnNextFrameKill, Entity);

			SetEntAttatchedEffect(Client, i, -1);
		}

		if(IsValidEdict(PlayerFaceTrail[Client]) && PlayerFaceTrail[Client] > GetMaxClients())
		{

			//Request:
			RequestFrame(OnNextFrameKill, PlayerFaceTrail[Client]);
		}

		//Initulize:
		PlayerFaceTrail[Client] = -1;

		//Switch:
		switch(PlayerTrail[Client][i])
		{

			//Fire On Face:
			case 1:
			{

			}

			//Red Smoke Effect:
			case 2:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "255 50 50", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Blue Smoke Effect:
			case 3:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "50 50 255", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Green Smoke Effect:
			case 4:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "50 255 50", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Yellow Smoke Effect:
			case 5:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "255 255 50", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Gray Smoke Effect:
			case 6:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "255 255 255", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Black Smoke Effect:
			case 7:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "50 50 50", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Red Light:
			case 8:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 255, 120, 120, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Blue Light:
			case 9:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 120, 120, 255, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Green Light:
			case 10:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 120, 255, 120, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Yellow Light:
			case 11:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 240, 230, 50, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Purple Light:
			case 12:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 240, 20, 230, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//White Light:
			case 13:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 240, 230, 240, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Black Light:
			case 14:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 120, 130, 120, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Red Tesla:
			case 15:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "250 50 50");

				SetEntAttatchedEffect(Client, i, Effect);

				//Initulize:
				PlayerFaceTrail[Client] = Effect;

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Blue Tesla:
			case 16:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "50 50 250");

				SetEntAttatchedEffect(Client, i, Effect);

				//Initulize:
				PlayerFaceTrail[Client] = Effect;

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Green Tesla:
			case 17:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "120 250 50");

				SetEntAttatchedEffect(Client, i, Effect);

				//Initulize:
				PlayerFaceTrail[Client] = Effect;

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Yellow Tesla:
			case 18:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "240 230 50");

				SetEntAttatchedEffect(Client, i, Effect);

				//Initulize:
				PlayerFaceTrail[Client] = Effect;

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Purple Tesla:
			case 19:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "250 50 250");

				SetEntAttatchedEffect(Client, i, Effect);

				//Initulize:
				PlayerFaceTrail[Client] = Effect;

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Orange Tesla:
			case 20:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "240 200 50");

				SetEntAttatchedEffect(Client, i, Effect);

				//Initulize:
				PlayerFaceTrail[Client] = Effect;

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//White Tesla:
			case 21:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "250 255 250");

				SetEntAttatchedEffect(Client, i, Effect);

				//Initulize:
				PlayerFaceTrail[Client] = Effect;

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			case 22:
			{

			}

			case 23:
			{

			}

			case 24:
			{

			}

			case 25:
			{

			}

			case 26:
			{

			}

			//Drift Portal Effect:
			case 27:
			{

				//Declare:
				float Origin[3];
				float Angles[3] = {180.0, 0.0, 0.0};

				//Initulize:
				GetEntPropVector(Client, Prop_Data, "m_vecOrigin", Origin);
				Origin[2] += 2.0;

				//Create Portal:
				int PortalEffect = CreateDynamicProp(Origin, Angles, "models/effects/portalrift.mdl", true);

				SetEntAttatchedEffect(Client, i, PortalEffect);

				//Send:

				SetEntPropFloat(PortalEffect, Prop_Send, "m_flModelScale", 0.047);


				//Set String:
				SetVariantString("!activator");

				//Accept:
				AcceptEntityInput(PortalEffect, "SetParent", Client, PortalEffect, 0);
			}

			case 28:
			{

				//Declare:
				int OtherEnt = GetPlayerHatEnt(Client);

				//Check
				if(IsValidEdict(OtherEnt))
				{


					//Declare:
					char ModelName[128];

					//Initialize:
					GetEntPropString(OtherEnt, Prop_Data, "m_ModelName", ModelName, 128);

					//Check:
					if(StrEqual(ModelName, "models/props_lab/dogobject_wood_crate001a_damagedmax.mdl"))
					{

						//Set ClassName:
						SetEntPropString(OtherEnt, Prop_Data, "m_iClassname", "prop_Rotate");
					}
				}
			}

			case 29:
			{

				//Declare:
				float Random = GetRandomFloat(0.0, 360.0);
				float Angles[3] = {0.0,...};
				Angles[1] = 90.0;
				Angles[2] = Random;
				float Position[3];

				//Initulize:
				GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);
				Position[2] += 37.5;

				//GetEntPropVector(Client, Prop_Data, "m_angRotation", Angles);

				//Declare:
				int Ent = CreateDynamicProp(Position, Angles, "models/effects/splodearc.mdl", true);

				SetEntAttatchedEffect(Client, i, Ent);

				//Send:

				SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", 0.3);


				//Set String:
				SetVariantString("!activator");

				//Accept:
				AcceptEntityInput(Ent, "SetParent", Client, Ent, 0);
			}

			case 30:
			{

			}
			case 31:
			{

				//Declare:
				float Angles2[3] = {0.0,...};
				float Offset[3] = {0.0,...};

				//Create Effect!
				int Effect = CreateInfoParticleSystemOther(Client, "null", "striderbuster_shotdown_trail", 0.0, Offset, Angles2);

				SetEntAttatchedEffect(Client, i, Effect);
			}
		}
	}
}

public bool CheckHasPlayerAlreadyTrailToFace(int Client, int Trail)
{

	//Declare:
	bool Result = false;

	//Loop:
	for(int i = 0; i < MAXTRAILS; i++)
	{

		//Switch:
		switch(PlayerTrail[Client][i])
		{

			case 1:
			{

				//Initulize:
				Result = true;
			}

			case 15:
			{

				//Initulize:
				Result = true;
			}

			case 16:
			{

				//Initulize:
				Result = true;
			}

			case 17:
			{

				//Initulize:
				Result = true;
			}

			case 18:
			{

				//Initulize:
				Result = true;
			}

			case 19:
			{

				//Initulize:
				Result = true;
			}

			case 20:
			{

				//Initulize:
				Result = true;
			}

			case 21:
			{

				//Initulize:
				Result = true;
			}

			case 22:
			{

				//Initulize:
				Result = true;
			}

			case 23:
			{

				//Initulize:
				Result = true;
			}

			case 25:
			{

				//Initulize:
				Result = true;
			}

			case 26:
			{

				//Initulize:
				Result = true;
			}

			case 27:
			{

				//Initulize:
				Result = true;
			}

			case 28:
			{

				//Initulize:
				Result = true;
			}

			case 30:
			{

				//Initulize:
				Result = true;
			}
		}
	}

	if(Result == true && IsValidEdict(PlayerFaceTrail[Client]))
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}


public Action Command_PlayerTrails(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");
	}

	//Override:
	else
	{

		//Show Menu:
		PlayerTrailMenu(Client);
	}

	//Return:
	return Plugin_Handled;
}

public void PlayerTrailMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandlePlayerTrailMenu);

	//Menu Title:
	menu.SetTitle("Player Trail Menu");

	//Declare:
	char State[128];
	char Index[32];

	//Loop:
	for(int i = 0; i < MAXTRAILS; i++)
	{

		//Format:
		Format(State, sizeof(State), "Slot (%i) has %i", i, PlayerTrail[Client][i]);

		//Initulize:
		IntToString(i, Index, sizeof(Index));

		//Menu Button:
		menu.AddItem(Index, State);
	}

	//Menu Button:
	menu.AddItem("5", "Remove All Trails!");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Trail|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//Handle:
public int HandlePlayerTrailMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Declare:
			int IndexSlot = StringToInt(info);

			//Check:
			if(IndexSlot == 5)
			{

				//Loop:
				for(int i = 0; i < MAXTRAILS; i++)
				{

					//Declare:
					int OtherEnt = GetEntAttatchedEffect(Client, i);

					//Check
					if(IsValidEdict(OtherEnt))
					{

						//Request:
						RequestFrame(OnNextFrameKill, OtherEnt);
					}

					//Initulize:
					PlayerTrail[Client][i] = 0;
				}

				//Save:
				SavePlayerTrail(Client);

				//Print:
				CPrintToChat(Client, "%s You have reset your trails!", PREFIX);
			}

			//Override
			else
			{

				//Initulize:
				SetMenuTarget(Client, IndexSlot);

				//Show Menu:
				SelectTrailTypeMenu(Client);
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

public void SelectTrailTypeMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleSelectTrailTypeMenu);

	//Menu Title:
	menu.SetTitle("What Effect type would you like to put on?");

	//Menu Button:
	menu.AddItem("1", "Misc Trails!");

	//Menu Button:
	menu.AddItem("2", "Smoke Trails!");

	//Menu Button:
	menu.AddItem("3", "Light Trails!");

	//Menu Button:
	menu.AddItem("4", "Tesla Trails!");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//Handle:
public int HandleSelectTrailTypeMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Declare:
			int SelectedType = StringToInt(info);

			//Show Menu:
			SelectTrailMenu(Client, SelectedType);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

public void SelectTrailMenu(int Client, int SelectedType)
{

	//Handle:
	Menu menu = CreateMenu(HandleSelectTrailMenu);

	//Menu Title:
	menu.SetTitle("What Effect would you like to put on? Current Trail Index: %i, Trail: %i", SelectedType, PlayerTrail[Client][SelectedType]);

	//Declare:
	bool ShowMenu = false;

	//Check:
	if(IsAdmin(Client) || GetDonator(Client))
	{

		//Switch:
		switch(SelectedType)
		{

			//Misc Trails:
			case 1:
			{

				//Menu Button:
				menu.AddItem("0", "Reset Index");

				//Menu Button:
				menu.AddItem("1", "Face of Fire!");

				//Menu Button:
				menu.AddItem("22", "Face Of Blood!");

				//Menu Button:
				menu.AddItem("23", "Face of Plasma!");

				//Menu Button:
				menu.AddItem("25", "Face of Green Blood!");

				//Menu Button:
				menu.AddItem("26", "Face of Ywllow Blood!");

				//Menu Button:
				menu.AddItem("27", "Portal Effect!");

				//Menu Button:
				menu.AddItem("28", "Rotating Box Head!");

				//Menu Button:
				menu.AddItem("24", "Tesla Trail!");

				//Menu Button:
				menu.AddItem("29", "Lightning Trail!");

			}

			//Smoke Trails:
			case 2:
			{

				//Menu Button:
				menu.AddItem("0", "Reset Index");

				//Menu Button:
				menu.AddItem("2", "Red Smoke Trail!");

				//Menu Button:
				menu.AddItem("3", "Blue Smoke Trail!");

				//Menu Button:
				menu.AddItem("4", "Green Smoke Trail!");

				//Menu Button:
				menu.AddItem("5", "Gray Smoke Trail!");

				//Menu Button:
				menu.AddItem("6", "Yellow Smoke Trail!");

				//Menu Button:
				menu.AddItem("7", "Black Smoke Trail!");
			}

			//Light Trails:
			case 3:
			{

				//Menu Button:
				menu.AddItem("0", "Reset Index");

				//Menu Button:
				menu.AddItem("8", "Red Light Trail!");

				//Menu Button:
				menu.AddItem("9", "Blue Light Trail!");

				//Menu Button:
				menu.AddItem("10", "Green Light Trail!");

				//Menu Button:
				menu.AddItem("11", "Yellow Light Trail!");

				//Menu Button:
				menu.AddItem("12", "Purple Light Trail!");

				//Menu Button:
				menu.AddItem("13", "White Light Trail!");

				//Menu Button:
				menu.AddItem("14", "Black Light Trail!");
			}

			//Tesla Trails:
			case 4:
			{

				//Menu Button:
				menu.AddItem("0", "Reset Index");

				//Menu Button:
				menu.AddItem("15", "Red Tesla Trail!");

				//Menu Button:
				menu.AddItem("16", "Blue Tesla Trail!");

				//Menu Button:
				menu.AddItem("17", "Green Tesla Trail!");

				//Menu Button:
				menu.AddItem("18", "Yellow Tesla Trail!");

				//Menu Button:
				menu.AddItem("19", "Purple Tesla Trail!");

				//Menu Button:
				menu.AddItem("20", "Orange Tesla Trail!");

				//Menu Button:
				menu.AddItem("21", "White Tesla Trail!");
			}
		}

		//Initulize:
		ShowMenu = true;
	}

	//Has JetPack In Inventory:
	else if(!HasItemTypeInInventory(Client, 61))
	{

		//Switch:
		switch(SelectedType)
		{

			//Misc Trails:
			case 1:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				if(GetItemAmount(Client, 388) > 0) menu.AddItem("1", "Face of Fire!");

				//Menu Button:
				if(GetItemAmount(Client, 389) > 0) menu.AddItem("22", "Blood Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 453) > 0) menu.AddItem("23", "Face Of Plasma!");

				//Menu Button:
				if(GetItemAmount(Client, 455) > 0) menu.AddItem("24", "Tesla Trail!");
			}

			//Smoke Trails:
			case 2:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				if(GetItemAmount(Client, 390) > 0) menu.AddItem("2", "Red Smoke Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 391) > 0) menu.AddItem("3", "Blue Smoke Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 392) > 0) menu.AddItem("4", "Green Smoke Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 393) > 0) menu.AddItem("5", "Gray Smoke Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 394) > 0) menu.AddItem("6", "Yellow Smoke Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 395) > 0) menu.AddItem("7", "Black Smoke Trail!");
			}

			//Light Trails:
			case 3:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				if(GetItemAmount(Client, 396) > 0) menu.AddItem("8", "Red Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 397) > 0) menu.AddItem("9", "Blue Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 398) > 0) menu.AddItem("10", "Green Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 399) > 0) menu.AddItem("11", "Yellow Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 400) > 0) menu.AddItem("12", "Purple Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 401) > 0) menu.AddItem("13", "White Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 402) > 0) menu.AddItem("14", "Black Light Trail!");
			}

			//Tesla Trails:
			case 4:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				if(GetItemAmount(Client, 403) > 0) menu.AddItem("15", "Red Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 404) > 0) menu.AddItem("16", "Blue Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 405) > 0) menu.AddItem("17", "Green Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 406) > 0) menu.AddItem("18", "Yellow Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 407) > 0) menu.AddItem("19", "Purple Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 408) > 0) menu.AddItem("20", "Orange Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 409) > 0) menu.AddItem("21", "White Tesla Trail!");
			}
		}

		//Initulize:
		ShowMenu = true;
	}

	//Check:
	if(ShowMenu)
	{

		//Set Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);
	}

	//Has JetPack In Inventory:
	else if(!HasItemTypeInInventory(Client, 61))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you dont have any Trail items!");
	}

	//Override:
	else
	{

		//Close:
		delete menu;
	}
}

//Handle:
public int HandleSelectTrailMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[64];
			char display[255];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info), _, display, sizeof(display));

			//Declare:
			int SelectedTrail = StringToInt(info);

			//Declare:
			int IndexSlot = GetMenuTarget(Client);

			if(SelectedTrail == 0)
			{

				//Initulize:
				PlayerTrail[Client][IndexSlot] = 0;

				//Check:
				if(IsValidAttachedEffect(Client))
				{

					//Remove:
					RemoveAttachedEffect(Client);
				}

				//Create Trail:
				CreatePlayerTrails(Client);

				//Save:
				SavePlayerTrail(Client);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Removed Trail \x0732CD32%s\x07FFFFFF Index (#%i) Slot(#%i)!", display, IndexSlot, SelectedTrail);
			}

			else if(CheckHasPlayerAlreadyTrailToFace(Client, SelectedTrail))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your already have a face trail attached!");
			}

			//Check:
			else if(HasPlayerAlreadyAttachedTrail(Client, SelectedTrail, IndexSlot))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF -You already have this Trail attached!");
			}

			//Override:
			else
			{

				//Initulize:
				PlayerTrail[Client][IndexSlot] = SelectedTrail;

				//Check:
				if(IsValidAttachedEffect(Client))
				{

					//Remove:
					RemoveAttachedEffect(Client);
				}

				//Create Trail:
				CreatePlayerTrails(Client);

				//Save:
				SavePlayerTrail(Client);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your new Trail is a \x0732CD32%s\x07FFFFFF Index (#%i) Slot(#%i)!", display, IndexSlot, SelectedTrail);
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

public Action Command_SetTrail(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");
	}

	//No Valid Charictors:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_settrail <Slot> <Trail>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Declare:
	int Slot = StringToInt(Arg1);

	//Check:
	if(Slot < 0 || Slot > MAXTRAILS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_settrail <0-%i> <Trail>", MAXTRAILS);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Declare:
	int SelectedTrail = StringToInt(Arg2);

	//Initulize:
	PlayerTrail[Client][Slot] = SelectedTrail;

	//Check:
	if(IsValidAttachedEffect(Client))
	{

		//Remove:
		RemoveAttachedEffect(Client);
	}

	//Create Trail:
	CreatePlayerTrails(Client);

	//Save:
	SavePlayerTrail(Client);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - New Trail selected Index (#%i) Slot(#%i)!", SelectedTrail, Slot);

	//Return:
	return Plugin_Handled;
}

public Action OnPlayerTrailTransmit(int Ent, int Client)
{

	//Connected:
	if(Ent > 0 && IsValidEdict(Ent) && IsClientConnected(Client) && IsClientInGame(Client))
	{

		if(GetObserverMode(Client) == 5 || GetViewWearables(Client))
			return Plugin_Continue;

		if(GetObserverMode(Client) == 4 && GetObserverTarget(Client) >= 0)
			if(Ent == PlayerFaceTrail[GetObserverTarget(Client)])
				return Plugin_Handled;

		if(Ent == PlayerFaceTrail[Client])
			return Plugin_Handled;
	}

	//Return:
	return Plugin_Continue;
}

public bool HasPlayerAlreadyAttachedTrail(int Client, int Trail, int IndexSelected)
{

	//Declare:
	bool Result = false;

	//Check:
	if(PlayerTrail[Client][IndexSelected] == Trail || Trail == 0)
	{

		//Initulize:
		Result = true;
	}

	//Return:
	return view_as<bool>(Result);
}

public int GetPlayerTrail(int Client, int Type)
{

	//Initulize:
	return view_as<int>(PlayerTrail[Client][Type]);
}

public void SetPlayerTrail(int Client, int Type, int Trail)
{

	//Initulize:
	PlayerTrail[Client][Type] = Trail;
}

public void SavePlayerTrail(int Client)
{

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE Settings SET Trails = '%i^%i^%i' WHERE STEAMID = %i;", PlayerTrail[Client][0], PlayerTrail[Client][1], PlayerTrail[Client][2], SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 69);
}