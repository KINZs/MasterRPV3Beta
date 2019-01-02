//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_hud_included_
  #endinput
#endif
#define _rp_hud_included_

//Euro - � dont remove this!
//€ = �

//Show Player Hud
public void ShowClientHud(int Client)
{

	//Declare:
	char FormatMessage[1024];

	//Declare:
	int len = 0;
	int Color[4];

	//Initulize:
	Color[0] = GetClientHudColor(Client, 0);
	Color[1] = GetClientHudColor(Client, 1);
	Color[2] = GetClientHudColor(Client, 2);
	Color[3] = 255;

	//Is Loaded:
	if(!IsLoaded(Client))
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[%N]\nPlease Wait while we load your stats...", Client);

		//Check:
		if(GetGame() == 2 || GetGame() == 3)
		{

			//Show Hud Text:
			CSGOShowHudTextEx(Client, 0, view_as<float>({0.005, 0.005}), Color, Color, 1.0, 0, 6.0, 0.1, 0.3, FormatMessage);
		}

		//Override:
		else
		{

			//Show Hud Text:
			ShowHudTextEx(Client, 0, view_as<float>({0.005, 0.005}), Color, 1.0, 0, 6.0, 0.1, 0.3, FormatMessage);
		}

		//Return:
		return;
	}

	//Declare:
	int Time = GetSalaryCheck();

	//Check:
	if(Time > 60) Time -= 60;

	//Format:
	len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[%N]\nCash: %s %s\nBank: %s %s\nJob: %s\nJob Salary: €%i in %is", Client, IntToMoney(GetCash(Client)), GetCashState(Client), IntToMoney(GetBank(Client)), GetCashState(Client), GetJob(Client), GetJobSalary(Client), Time);

	//Declare
	int More = GetMoreHud(Client);

	//More Hud Enabled
	if(More == 1)
	{

		//Prop Money Printer:
		if(!StrEqual(GetGang(Client), "null"))
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nGang: %s", GetGang(Client));
		}

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nNext raise in %i Min", (RoundToCeil(Pow(float(GetJobSalary(Client)), 3.0)) - GetNextJobRase(Client)));

		//Is Critical:
		if(GetIsCritical(Client))
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nIn Critical Condition");
		}

		//Is Hunger Enabled:
		if(IsHungerDisabled() == 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nHunger: %s", GetHungerString(Client));
		}

		//Has Harvest:
		if(GetHarvest(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nHarvest: %ig", GetHarvest(Client));
		}

		//Has Meth:
		if(GetMeth(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nMeth: %ig", GetMeth(Client));
		}

		//Has Pills:
		if(GetPills(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nPills: %ig", GetPills(Client));
		}

		//Has Cocain:
		if(GetCocain(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCocain: %ig", GetCocain(Client));
		}

		//Has Cocain:
		if(GetRice(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nRice: %ig", GetRice(Client));
		}

		//Has Resources:
		if(GetResources(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nResources: %ig", GetResources(Client));
		}

		//Has Resources:
		if(GetBitCoin(Client) != 0.0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nBTC: %f", GetBitCoin(Client));
		}

		//Has Resources:
		if(GetMetal(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nMetal: %ig", GetMetal(Client));
		}
	}

	//Is In Jail:
	if(IsCuffed(Client))
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nJailtime: %i/%i", GetJailTime(Client), GetMaxJailTime(Client));
	}

	//Has Resources:
	if(GetIsNokill(Client) == true)
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nNo Kill Zone");
	}

	//Check:
	if(GetGame() == 2 || GetGame() == 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 0, view_as<float>({0.005, 0.005}), Color, Color, 0.9, 0, 6.0, 0.1, 0.0, FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 0, view_as<float>({0.005, 0.005}), Color, 0.9, 0, 6.0, 0.1, 0.0, FormatMessage);
	}

	//Return:
	return;
}

//Show Player Hud
public void ShowPlayerNotice(int Client, int Player, float NoticeInterval)
{

	//Is Loaded:
	if(!IsLoaded(Client))
	{

		//Return:
		return;
	}

	//Declare:
	float ClientOrigin[3];
	float EntOrigin[3];
	char FormatMessage[255];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	int len = 0;

	//Connected:
	if(Player > 0 && IsClientConnected(Player) && IsClientInGame(Player) && Player < GetMaxClients())
	{

		//Initialize:
		GetClientAbsOrigin(Player, EntOrigin);

		//Declare:
		float Dist = GetVectorDistance(ClientOrigin, EntOrigin);

		//Declare:
		int PlayerHP = GetClientHealth(Player);

		//In Distance:
		if(Dist <= 350 && !(GetClientButtons(Client) & IN_SCORE))
		{

			//Declare:
			int Salary = GetJobSalary(Player);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[%N] \nHealth: %i% \nJob: %s\nJobSalary: €%i\nEnergy: %i", Player, PlayerHP, GetJob(Player), Salary, GetEnergy(Player));

			//Is Same Team:
			if(IsCop(Client) || IsAdmin(Client))
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCash: %s\nBank: %s", IntToMoney(GetCash(Player)), IntToMoney(GetBank(Player)));

				//Is In Jail:
				if(IsCuffed(Player))
				{

					//Format:
					len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nJailtime: %i/%i", GetJailTime(Player), GetMaxJailTime(Player));
				}
			}

			//Has Player Got Bounty:
			if(!IsCop(Client) && GetBounty(Player) > 0)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nBounty: €%i", GetBounty(Player));
			}

			//IsCuffed:
			if(IsCuffed(Player))
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCUFFED!");
			}

			//Declare:
			int Color[4];

			//Initulize:
			Color[0] = GetPlayerHudColor(Client, 0);
			Color[1] = GetPlayerHudColor(Client, 1);
			Color[2] = GetPlayerHudColor(Client, 2);
			Color[3] = 255;

			//Check:
			if(GetGame() == 2 || GetGame() == 3)
			{

				//Show Hud Text:
				CSGOShowHudTextEx(Client, 1, view_as<float>({-1.0, -0.805}), Color, Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
			}

			//Override:
			else
			{

				//Show Hud Text:
				ShowHudTextEx(Client, 1, view_as<float>({-1.0, -0.805}), Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
			}
		}

		//Override
		else if((Dist > 350 && Dist < 1000))
		{

			//Show Hud Text:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[%N] \nHealth: %i% ",Player, PlayerHP);

			//Has Player Got Bounty:
			if(GetBounty(Player) > 0)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nBounty: %i", GetBounty(Player));
			}

			//IsCuffed:
			if(IsCuffed(Player))
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCUFFED!");
			}

			//Declare:
			int Color[4];

			//Initulize:
			Color[0] = GetPlayerHudColor(Client, 0);
			Color[1] = GetPlayerHudColor(Client, 1);
			Color[2] = GetPlayerHudColor(Client, 2);
			Color[3] = 255;

			//Check:
			if(GetGame() == 2 || GetGame() == 3)
			{

				//Show Hud Text:
				CSGOShowHudTextEx(Client, 1, view_as<float>({-1.0, -0.805}), Color, Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
			}

			//Override:
			else
			{

				//Show Hud Text:
				ShowHudTextEx(Client, 1, view_as<float>({-1.0, -0.805}), Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
			}
		}
	}
}

//Show Player Hud
public void showAdminStats(int Client)
{

	//Is Loaded:
	if(!IsLoaded(Client))
	{

		//Return:
		return;
	}

	//Declare:
	char FormatMessage[1024];
	int len = 0;

	//Has Other Hud Enabled:
	if(GetHudOnline(Client) == 1)
	{

		//Time Calculator:
		int Result = GetOnlineTime(Client);
		int Days = Result / 360;
		Result %= 360;
		int Hours = Result / 60;
		Result %= 60;
		int Minutes = (GetOnlineTime(Client) % 60);

		//Time Calculator:
		Result = GetTime() - GetRunTime();
		int Days2 = Result / 86400;
		Result %= 86400;
		int Hours2 = Result / 3600;
		Result %= 3600;
		int Minutes2 = Result / 60;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[Time Played: %id:%ih:%im]\n[Server Uptime: %id:%ih:%im]", Days, Hours, Minutes, Days2, Hours2, Minutes2);

		//Initulize:
		if(IsPdExplodeJobAvaiable() == true)
		{

			//Time Calculator:
			Result = GetPdExplodeTimeLeft();
			Result %= 3600;
			int Minutes3 = (Result / 60);
			Result %= 60;
			int Seconds3 = Result;

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nPolice Department Event time left %im:%is", Minutes3, Seconds3);
		}
	}

	//Format:
	len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nEnergy: %i\nCop Cuffs: %i\nCop Minutes : %i\nExperience: %i", GetEnergy(Client), GetCopCuffs(Client), GetCopMinutes(Client), GetJobExperience(Client));

	//Declare:
	int Color[4];

	//Initulize:
	Color[0] = GetClientHudColor(Client, 0);
	Color[1] = GetClientHudColor(Client, 1);
	Color[2] = GetClientHudColor(Client, 2);
	Color[3] = 255;

	//Check:
	if(GetGame() == 2 || GetGame() == 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 3, view_as<float>({-1.0, 1.0}), Color, Color, 0.9, 0, 6.0, 0.1, 0.0, FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 3, view_as<float>({-1.0, 1.0}), Color, 0.9, 0, 6.0, 0.1, 0.0, FormatMessage);
	}

	//Return:
	return;
}

//Show Player Hud
public void showCopStats(int Client)
{

	//Is Loaded:
	if(!IsLoaded(Client))
	{

		//Return:
		return;
	}

	//Declare:
	char FormatMessage[1024];
	int len = 0;

	//Has Other Hud Enabled:
	if(GetHudOnline(Client) == 1)
	{

		//Time Calculator:
		int Result = GetOnlineTime(Client);
		int Days = Result / 360;
		Result %= 360;
		int Hours = Result / 60;
		Result %= 60;
		int Minutes = (GetOnlineTime(Client) % 60);

		//Time Calculator:
		Result = GetTime() - GetRunTime();
		int Days2 = Result / 86400;
		Result %= 86400;
		int Hours2 = Result / 3600;
		Result %= 3600;
		int Minutes2 = Result / 60;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[Time Played: %id:%ih:%im]\n[Server Uptime: %id:%ih:%im]", Days, Hours, Minutes, Days2, Hours2, Minutes2);

		//Initulize:
		if(IsPdExplodeJobAvaiable() == true)
		{

			//Time Calculator:
			Result = GetPdExplodeTimeLeft();
			Result %= 3600;
			int Minutes3 = (Result / 60);
			Result %= 60;
			int Seconds3 = Result;

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nPolice Department Event time left %im:%is", Minutes3, Seconds3);
		}
	}

	//Format:
	len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nEnergy: %i\nCuffs: %i\nCop Minutes: %i", GetEnergy(Client), GetCopCuffs(Client), GetCopMinutes(Client));

	//Declare:
	int Color[4];

	//Initulize:
	Color[0] = GetClientHudColor(Client, 0);
	Color[1] = GetClientHudColor(Client, 1);
	Color[2] = GetClientHudColor(Client, 2);
	Color[3] = 255;

	//Check:
	if(GetGame() == 2 || GetGame() == 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 3, view_as<float>({-1.0, 1.0}), Color, Color, 0.9, 0, 6.0, 0.1, 0.0, FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 3, view_as<float>({-1.0, 1.0}), Color, 0.9, 0, 6.0, 0.1, 0.0, FormatMessage);
	}

	//Return:
	return;
}

//Show Player Hud
public void showAddedStats(int Client)
{

	//Is Loaded:
	if(!IsLoaded(Client))
	{

		//Return:
		return;
	}

	//Declare:
	char FormatMessage[1024];
	int len = 0;

	//Has Other Hud Enabled:
	if(GetHudOnline(Client) == 1)
	{

		//Time Calculator:
		int Result = GetOnlineTime(Client);
		int Days = Result / 360;
		Result %= 360;
		int Hours = Result / 60;
		Result %= 60;
		int Minutes = (GetOnlineTime(Client) % 60);

		//Time Calculator:
		Result = GetTime() - GetRunTime();
		int Days2 = Result / 86400;
		Result %= 86400;
		int Hours2 = Result / 3600;
		Result %= 3600;
		int Minutes2 = Result / 60;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[Time Played: %id:%ih:%im]\n[Server Uptime: %id:%ih:%im]", Days, Hours, Minutes, Days2, Hours2, Minutes2);

		//Initulize:
		if(IsPdExplodeJobAvaiable() == true)
		{

			//Time Calculator:
			Result = GetPdExplodeTimeLeft();
			Result %= 3600;
			int Minutes3 = (Result / 60);
			Result %= 60;
			int Seconds3 = Result;

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nPolice Department Event time left %im:%is", Minutes3, Seconds3);
		}
	}

	//Format:
	len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nEnergy: %i\nExperience: %i", GetEnergy(Client), GetJobExperience(Client));

	//Declare:
	int Color[4];

	//Initulize:
	Color[0] = GetClientHudColor(Client, 0);
	Color[1] = GetClientHudColor(Client, 1);
	Color[2] = GetClientHudColor(Client, 2);
	Color[3] = 255;

	//Check:
	if(GetGame() == 2 || GetGame() == 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 3, view_as<float>({-1.0, 1.0}), Color, Color, 0.9, 0, 6.0, 0.1, 0.0, FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 3, view_as<float>({-1.0, 1.0}), Color, 0.9, 0, 6.0, 0.1, 0.0, FormatMessage);
	}

	//Return:
	return;
}

//Show Player Hud
public void showOnlineStats(int Client)
{

	//Is Loaded:
	if(!IsLoaded(Client))
	{

		//Return:
		return;
	}

	//Time Calculator:
	int Result = GetOnlineTime(Client);
	int Days = Result / 360;
	Result %= 360;
	int Hours = Result / 60;
	Result %= 60;
	int Minutes = (GetOnlineTime(Client) % 60);

	//Time Calculator:
	Result = GetTime() - GetRunTime();
	int Days2 = Result / 86400;
	Result %= 86400;
	int Hours2 = Result / 3600;
	Result %= 3600;
	int Minutes2 = Result / 60;

	//Declare:
	char FormatMessage[1024];
	int len = 0;

	//Format:
	len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[Time Played: %id:%ih:%im]\n[Server Uptime: %id:%ih:%im]", Days, Hours, Minutes, Days2, Hours2, Minutes2);

	//Initulize:
	if(IsPdExplodeJobAvaiable() == true)
	{

		//Time Calculator:
		Result = GetPdExplodeTimeLeft();
		Result %= 3600;
		int Minutes3 = (Result / 60);
		Result %= 60;
		int Seconds3 = Result;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nPolice Department Event time left %im:%is\n\n\n", Minutes3, Seconds3);
	}

	//Override:
	else
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\n\n\n\n");
	}

	//Declare:
	int Color[4];

	//Initulize:
	Color[0] = GetClientHudColor(Client, 0);
	Color[1] = GetClientHudColor(Client, 1);
	Color[2] = GetClientHudColor(Client, 2);
	Color[3] = 255;

	//Check:
	if(GetGame() == 2 || GetGame() == 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 3, view_as<float>({-1.0, 1.0}), Color, Color, 0.9, 0, 6.0, 0.1, 0.0, FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 3, view_as<float>({-1.0, 1.0}), Color, 0.9, 0, 6.0, 0.1, 0.0, FormatMessage);
	}

	//Return:
	return;
}

//Crime Hud:
public void ShowCrimeHud(int Client)
{

	//Is Loaded:
	if(!IsLoaded(Client))
	{

		//Return:
		return;
	}

	//Declare:
	bool hasHit = false;
	bool HasCrime = false;

	//Check:
	if(IsCop(Client) || IsAdmin(Client))
	{

		//Declare:
		char Message[1024];

		//Initulize:
		int len = 0;
		int ClientCount = 0;

		//Declare:
		int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

		//Check:
		if(IsValidEdict(InVehicle))
		{

			//Declare:
			char ClassName[32];

			//Get Entity Info:
			GetEdictClassname(InVehicle, ClassName, sizeof(ClassName));

			//Check:
			if(!StrEqual(ClassName, "prop_vehicle_prisoner_pod"))
			{

				//Declare:
				int Speed = GetEntProp(InVehicle, Prop_Data, "m_nSpeed");

				//Format:
				len += Format(Message[len], sizeof(Message)-len, "\nSpeed: %i", Speed);
			}

			//Declare:
			int Owner = GetOwnerOfVehicle(InVehicle);

			if(Owner > 0)
			{

				//Declare:
				float Fuel = GetVehicleFuel(Owner);

				//Format:
				len += Format(Message[len], sizeof(Message)-len, "\nFuel: %0.1f\n", Fuel);
			}

			//Override:
			else
			{

				//Format:
				len += Format(Message[len], sizeof(Message)-len, "\n");
			}
		}

		//Check:
		if(IsClientInCosino(Client))
		{

			//Format:
			len += Format(Message[len], sizeof(Message)-len, "\nCosino Bank: %s\n", IntToMoney(GetCosinoBank()));
		}

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i ++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//To Many Clients:
				if(GetCrime(i) > 2000)
				{

					//Initulize:
					HasCrime = true;
				}
			}
		}

		//Check:
		if(HasCrime == true)
		{

			//Start Hud Message:
			len += Format(Message[len], sizeof(Message)-len,"\nCrime:");
		}

		//Is Self:
		if(GetCrime(Client) > 500)
		{

			//Initialize:
			ClientCount++;

			//Has Bounty:
			if(GetBounty(Client) > 0)
			{

				//Format Message:
				len += Format(Message[len], sizeof(Message) - len,"\n%N (€%i)", Client, GetBounty(Client));
			}

			//Is Alive:
			else if(!IsPlayerAlive(Client))
			{

				//Format Message:
				len += Format(Message[len], sizeof(Message) - len,"\n%N (%i) (Dead)", Client, RoundToNearest(GetCrime(Client) / 1000.0));
			}

			//Override:
			else
			{

				//Format Message:
				len += Format(Message[len], sizeof(Message) - len,"\n%N (%i)", Client, RoundToNearest(GetCrime(Client) / 1000.0));
			}
		}

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i ++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && Client != i)
			{

				//To Many Clients:
				if(GetCrime(i) > 2000 && ClientCount < 8)
				{

					//Initialize:
					ClientCount++;

					//Has Bounty:
					if(GetBounty(i) > 0)
					{

						//Format Message:
						len += Format(Message[len], sizeof(Message) - len,"\n%N (€%i)", i, GetBounty(i));
					}

					//Is Alive:
					else if(!IsPlayerAlive(i))
					{

						//Format Message:
						len += Format(Message[len], sizeof(Message) - len,"\n%N (%i) (Dead)", i, RoundToNearest(GetCrime(i) / 1000.0));
					}

					//Override:
					else
					{

						//Format Message:
						len += Format(Message[len], sizeof(Message) - len,"\n%N (%i)", i, RoundToNearest(GetCrime(i) / 1000.0));
					}
				}
			}
		}

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i ++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//To Many Clients:
				if(GetHit(i) > 0)
				{

					//Initulize:
					hasHit = true;
				}
			}
		}

		//Check:
		if(hasHit == true)
		{

			//Start Hud Message:
			len += Format(Message[len], sizeof(Message)-len,"\n\nHit:");
		}

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i ++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//To Many Clients:
				if(GetHit(i) > 0 && ClientCount < 12)
				{

					//Initialize:
					ClientCount++;

					//Format Message:
					len += Format(Message[len], sizeof(Message) - len,"\n%N (€%i)", i, GetHit(i));
				}
			}
		}

		//Has Player Got Crime/Bounty:
		if(InVehicle > 0 || HasCrime == true || hasHit == true || IsClientInCosino(Client))
		{

			//Declare:
			int Color[4];

			//Initulize:
			Color[0] = 255;
			Color[1] = 50;
			Color[2] = 50;
			Color[3] = 255;

			//Check:
			if(GetGame() == 2 || GetGame() == 3)
			{

				//Show Hud Text:
				CSGOShowHudTextEx(Client, 2, view_as<float>({0.950, 0.015}), Color, Color, 0.9, 0, 6.0, 0.1, 0.2, Message);
			}

			//Override:
			else
			{

				//Show Hud Text:
				ShowHudTextEx(Client, 2, view_as<float>({0.950, 0.015}), Color, 0.9, 0, 6.0, 0.1, 0.2, Message);
			}
		}
	}

	//Override:
	else
	{

		//Declare:
		char Message[512];

		//Initulize:
		int len = 0;
		int ClientCount = 0;

		//Check:
		if(IsClientInCosino(Client))
		{

			//Format:
			len += Format(Message[len], sizeof(Message)-len, "\nCosino Bank: %s\n", IntToMoney(GetCosinoBank()));
		}

		//Declare:
		int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

		//Check:
		if(IsValidEdict(InVehicle))
		{

			//Declare:
			int Speed = GetEntProp(InVehicle, Prop_Data, "m_nSpeed");

			//Format:
			len += Format(Message[len], sizeof(Message)-len, "\nSpeed: %i", Speed);

			//Health:
			int Health = GetEntProp(InVehicle, Prop_Data, "m_iHealth");

			//Format:
			len += Format(Message[len], sizeof(Message)-len, "\nHealth: %i", Health);

			//Declare:
			int Owner = GetOwnerOfVehicle(InVehicle);

			if(Owner > 0)
			{

				//Declare:
				float Fuel = GetVehicleFuel(Owner);

				//Format:
				len += Format(Message[len], sizeof(Message)-len, "\nFuel: %0.1f\n", Fuel);
			}

			//Override:
			else
			{

				//Format:
				len += Format(Message[len], sizeof(Message)-len, "\n", Health);
			}
		}

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i ++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//To Many Clients:
				if(GetCrime(i) > 500)
				{

					//Initulize:
					HasCrime = true;
				}
			}
		}

		//Check:
		if(HasCrime == true && GetCrime(Client) > 500)
		{

			//Start Hud Message:
			len += Format(Message[len], sizeof(Message)-len,"\n\nHit:");
		}

		//Is Self:
		if(GetCrime(Client) > 500)
		{

			//Initialize:
			ClientCount++;

			//Has Bounty:
			if(GetBounty(Client) > 0)
			{

				//Format Message:
				len += Format(Message[len], sizeof(Message) - len,"\n%N (€%i)", Client, GetBounty(Client));
			}

			//Is Alive:
			else if(!IsPlayerAlive(Client))
			{

				//Format Message:
				len += Format(Message[len], sizeof(Message) - len,"\n%N (%i) (Dead)", Client, RoundToNearest(GetCrime(Client) / 1000.0));
			}

			//Override:
			else
			{

				//Format Message:
				len += Format(Message[len], sizeof(Message) - len,"\n%N (%i)", Client, RoundToNearest(GetCrime(Client) / 1000.0));
			}
		}

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i ++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && Client != i)
			{

				//Is Self
				if(Client == i && GetCrime(Client) > 500)
				{

					//Has Bounty:
					if(GetBounty(i) > 0)
					{

						//Format Message:
						len += Format(Message[len], sizeof(Message) - len,"\n%N (€%i)", i, GetBounty(i));
					}

					//Override:
					else
					{

						//Format Message:
						len += Format(Message[len], sizeof(Message) - len,"\n%N (%i)", i, RoundToNearest(GetCrime(i) / 1000.0));
					}

					//Initialize:
					ClientCount++;
				}

				//To Many Clients:
				else if(GetCrime(i) > 2000 && ClientCount < 7 && Client != i)
				{

					//Initialize:
					ClientCount++;

					//Has Bounty:
					if(GetBounty(i) > 0)
					{

						//Format Message:
						len += Format(Message[len], sizeof(Message) - len,"\n%N (€%i)", i, GetBounty(i));
					}

					//Is Self
					else if(Client == i && GetCrime(Client))
					{

						//Format Message:
						len += Format(Message[len], sizeof(Message) - len,"\n%N (%i)", i, RoundToNearest(GetCrime(i) / 1000.0));
					}
				}
			}
		}

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i ++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//To Many Clients:
				if(GetHit(i) > 0)
				{

					//Initulize:
					hasHit = true;
				}
			}
		}

		//Check:
		if(hasHit == true)
		{

			//Start Hud Message:
			len += Format(Message[len], sizeof(Message)-len,"\n\nHit:");
		}

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i ++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//To Many Clients:
				if(GetHit(i) > 0 && ClientCount < 12)
				{

					//Initialize:
					ClientCount++;

					//Format Message:
					len += Format(Message[len], sizeof(Message) - len,"\n%N (€%i)", i, GetHit(i));
				}
			}
		}

		//Has Player Got Crime/Bounty:
		if((ClientCount > 0 && GetCrime(Client) > 500 || HasCrime == true || hasHit == true) || IsClientInCosino(Client) || InVehicle > 0)
		{

			//Declare:
			int Color[4];

			//Initulize:
			Color[0] = 255;
			Color[1] = 50;
			Color[2] = 50;
			Color[3] = 255;

			//Check:
			if(GetGame() == 2 || GetGame() == 3)
			{

				//Show Hud Text:
				CSGOShowHudTextEx(Client, 2, view_as<float>({0.950, 0.015}), Color, Color, 0.9, 0, 6.0, 0.1, 0.2, Message);
			}

			//Override:
			else
			{

				//Show Hud Text:
				ShowHudTextEx(Client, 2, view_as<float>({0.950, 0.015}), Color, 0.9, 0, 6.0, 0.1, 0.2, Message);
			}
		}
	}

	//Return:
	return;
}

public void ShowEntityNotice(int Client, int Ent, float NoticeInterval)
{

	//Is Loaded:
	if(!IsLoaded(Client))
	{

		//Return:
		return;
	}

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Valid Sleeping Couch:
	if(IsValidCouch(Ent, ClassName))
	{

		//Show Hud:
		CouchHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Money Printer:
	if(StrEqual(ClassName, "prop_Money_Printer"))
	{

		//Show Hud:
		PrinterHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Plant Drug:
	if(StrEqual(ClassName, "prop_Plant_Drug"))
	{

		//Show Hud:
		PlantHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Kitchen Meth:
	if(StrEqual(ClassName, "prop_Kitchen_Meth"))
	{
	
		//Show Hud:
		MethHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Kitchen Meth:
	if(StrEqual(ClassName, "prop_Kitchen_Pills"))
	{

		//Show Hud:
		PillsHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Kitchen Meth:
	if(StrEqual(ClassName, "prop_Kitchen_Cocain"))
	{

		//Show Hud:
		CocainHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Plant Rice:
	if(StrEqual(ClassName, "prop_Plant_Rice"))
	{

		//Show Hud:
		RiceHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Bomb:
	if(StrEqual(ClassName, "prop_Bomb"))
	{

		//Show Hud:
		BombHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Gun Lab:
	if(StrEqual(ClassName, "prop_Gun_Lab"))
	{

		//Show Hud:
		GunLabHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Microwave:
	if(StrEqual(ClassName, "prop_Microwave"))
	{

		//Show Hud:
		MicrowaveHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Shield:
	if(StrEqual(ClassName, "prop_Shield"))
	{

		//Show Hud:
		ShieldHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Fire Bomb:
	if(StrEqual(ClassName, "prop_Fire_Bomb"))
	{

		//Show Hud:
		FireBombHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Generator:
	if(StrEqual(ClassName, "prop_Generator"))
	{

		//Show Hud:
		GeneratorHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop BitCoin Mine:
	if(StrEqual(ClassName, "prop_BitCoin_Mine"))
	{

		//Show Hud:
		BitCoinMineHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Propane Tank:
	if(StrEqual(ClassName, "prop_Propane_Tank"))
	{

		//Show Hud:
		PropaneTankHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Phosphoru Tank:
	if(StrEqual(ClassName, "prop_Phosphoru_Tank"))
	{

		//Show Hud:
		PhosphoruTankHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Sodium Tub:
	if(StrEqual(ClassName, "prop_Sodium_Tub"))
	{

		//Show Hud:
		SodiumTubHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop HcAcid Tub:
	if(StrEqual(ClassName, "prop_HcAcid_Tub"))
	{

		//Show Hud:
		HcAcidTubHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Acetone Can:
	if(StrEqual(ClassName, "prop_Acetone_Can"))
	{

		//Show Hud:
		AcetoneCanHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Drug Seeds:
	if(StrEqual(ClassName, "prop_Drug_Seeds"))
	{

		//Show Hud:
		SeedsHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Drug Lamp:
	if(StrEqual(ClassName, "prop_Drug_Lamp"))
	{

		//Show Hud:
		LampHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Erythroxylum:
	if(StrEqual(ClassName, "prop_Erythroxylum"))
	{

		//Show Hud:
		ErythroxylumHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Benzocaine:
	if(StrEqual(ClassName, "prop_Benzocaine"))
	{

		//Show Hud:
		BenzocaineHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Battery:
	if(StrEqual(ClassName, "prop_Battery"))
	{

		//Show Hud:
		BatteryHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Toulene:
	if(StrEqual(ClassName, "prop_Toulene"))
	{

		//Show Hud:
		TouleneHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop SAcid Tub:
	if(StrEqual(ClassName, "prop_SAcid_Tub"))
	{

		//Show Hud:
		SAcidTubHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Ammonia:
	if(StrEqual(ClassName, "prop_Ammonia"))
	{

		//Show Hud:
		AmmoniaHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Drug Bong:
	if(StrEqual(ClassName, "prop_Drug_Bong"))
	{

		//Show Hud:
		BongHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Smoke Bomb:
	if(StrEqual(ClassName, "prop_Smoke_Bomb"))
	{

		//Show Hud:
		SmokeBombHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Water Bomb:
	if(StrEqual(ClassName, "prop_Water_Bomb"))
	{

		//Show Hud:
		WaterBombHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Plasma Bomb:
	if(StrEqual(ClassName, "prop_Plasma_Bomb"))
	{

		//Show Hud:
		PlasmaBombHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Prop Fire Extinguisher:
	if(StrEqual(ClassName, "prop_Fire_Extinguisher"))
	{

		//Show Hud:
		FireExtinguisherHud(Client, Ent, NoticeInterval);

		//Return:
		return;
	}

	//Is NPC:
	if(!IsValidNpc(Ent) && IsValidDymamicNpc(Ent) && !StrEqual(ClassName, "npc_tripmine") && !StrEqual(ClassName, "npc_satchel") && !StrEqual(ClassName, "npc_grenade_frag"))
	{

		//Show Hud:
		NpcHealthHud(Client, Ent, NoticeInterval); //rp_npcdynamic.sp

		//Return:
		return;
	}

	//Is NPC:
	if(IsValidNpc(Ent))
	{

		//Show Hud:
		NpcHud(Client, Ent, NoticeInterval); //rp_npcnotice.sp

		//Return:
		return;
	}


	//VIP Door:
	if(GetVipClaimDoor(Ent) != -1)
	{

		//ShowHud:
		ClaimDoorHud(Client, Ent, NoticeInterval); //rp_vipdoors.sp

		//Return:
		return;
	}

	//Valid Door:
	if(IsValidDoor(Ent))
	{

		//Show Hud:
		DoorHud(Client, Ent, NoticeInterval); //rp_doorLocked.sp

		//Return:
		return;
	}

	//Prop Money Safe:
	if(StrEqual(ClassName, "prop_Money_Safe"))
	{

		//ShowHud:
		MoneySafeHud(Client, Ent, NoticeInterval); //rp_moneysafe.sp

		//Return:
		return;
	}

	//Prop Money Safe:
	if(StrEqual(ClassName, "prop_Server_Money_Safe"))
	{

		//ShowHud:
		ServerMoneySafeHud(Client, Ent, NoticeInterval); //rp_safesafe.sp

		//Return:
		return;
	}

	//Prop Vehicle:
	if(StrContains(ClassName, "prop_vehicle", false) == 0)
	{

		//ShowHud:
		CarHud(Client, Ent, ClassName, NoticeInterval); //rp_carmod.sp

		//Return:
		return;
	}

	//Prop Trash Can:
	if(StrEqual(ClassName, "prop_Garbage_Can"))
	{

		//ShowHud:
		PropTrashCanHud(Client, Ent, NoticeInterval); //rp_garbagezone.sp

		//Return:
		return;
	}

	//Prop Computer:
	if(StrEqual(ClassName, "prop_Computer"))
	{

		//ShowHud:
		ComputerHud(Client, Ent, NoticeInterval); //rp_computer.sp

		//Return:
		return;
	}

	//Prop Computer:
	if(StrEqual(ClassName, "prop_Pd_Computer"))
	{

		//ShowHud:
		PdComputerHud(Client, Ent, NoticeInterval); //rp_pdcomputer.sp

		//Return:
		return;
	}

	//prop Thumper:
	if(StrEqual(ClassName, "prop_Thumper"))
	{

		//ShowHud:
		ThumperHud(Client, Ent, NoticeInterval); //rp_thumper.sp

		//Return:
		return;
	}

	//prop Thumper:
	if(StrEqual(ClassName, "prop_Rock"))
	{

		//ShowHud:
		RockHud(Client, Ent, NoticeInterval); //rp_rockzone.sp

		//Return:
		return;
	}

	//Return:
	return;
}
