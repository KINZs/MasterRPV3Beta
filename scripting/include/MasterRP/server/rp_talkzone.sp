//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_talkzone_included_
  #endinput
#endif
#define _rp_talkzone_included_

//Phones:
int Connected[MAXPLAYERS + 1] = {0,...};
bool Answered[MAXPLAYERS + 1] = {false,...};
int TimeOut[MAXPLAYERS + 1] = {0,...};

public void initTalkZone()
{

	//Client Commands
	RegConsoleCmd("sm_answer", Command_Answer);

	RegConsoleCmd("sm_hangup", Command_Hangup);

	RegConsoleCmd("sm_call", Command_Call);

	RegConsoleCmd("sm_sms", Command_Sms);
}

public void initdisconnectphone(int Client)
{

	//Connected:
	if(Connected[Client] != 0)
	{

		//Initialize:
		int Player = Connected[Client];

		if(IsClientConnected(Player) && IsClientInGame(Player))
		{

			//Print:
			CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - You have lost service, phone conversation aborted");
		}

		//Send:
		Connected[Client] = 0;

		Answered[Client] = false;

		Connected[Player] = 0;

		Answered[Player] = false;
	}
}

//Event Death:
public Action OnClientChat(int Client, bool IsTeamOnly, const char[] Text, int maxlength)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Check:
		if(CheckStringSound(Client, Text))
		{

			//Return:
			return Plugin_Handled;
		}

		//Hide Commands
		if(Text[0] == '/')
		{

			//Return:
			return Plugin_Handled;
		}

		//Declare:
		char Color[32] = "null";

		//Fetch Job Color: 
		if(!GetClientChatColor(Client, Color))
		{

			//Format:
			Format(Color, sizeof(Color), "{red}");
		}

		//Declare:
		char FormatMessage[1024];

		//Declare:
		int len = 0;

		//Team Only:
		if(IsTeamOnly)
		{

			//Connected:
			if(Connected[Client] != 0)
			{

				//On Phone:
				if(Answered[Client])
				{

					//Print:
					PrintSilentChat(Client, Connected[Client], "PHONE", Text, Color);

					//Return:
					return Plugin_Handled;
				}
			}

			//Override:
			else
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "(TEAM) ");

				//Is Alive:
				if(!IsPlayerAlive(Client))
				{

					//Format:
					len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "{darkgray}*DEAD* ");
				}

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "%s%N\x01: %s", Color, Client, Text);

				//Loop:
				for(int i = 1; i <= GetMaxClients(); i++)
				{

					//Team:
					if(IsClientConnected(i) && GetClientTeam(i) == GetClientTeam(Client))
					{

						//Print:
						CPrintToChat(i,"%s", FormatMessage);
					}
				}
			}
		}

		//Override
		else
		{

			//Is In Gang:
			if(!StrEqual(GetGang(Client), "null", false))
			{

				//Declare:
				char Tag[6];

				//Format:
				Format(Tag, sizeof(Tag), "%s", GetGangTag(Client));

				//Declare:
				char TagColor[16];

				//Format:
				Format(TagColor, sizeof(TagColor), "%s", GetGangTagColor(Client));

				//Is In Gang and has color:
				if(!StrEqual(Tag, "null", false) && !StrEqual(TagColor, "null", false))
				{

					//Format:
					len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "%s(%s) ", TagColor, Tag);
				}

				//Is In Gang:
				else if(!StrEqual(Tag, "null", false))
				{

					//Format:
					len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "{default}(%s) ", Tag);
				}
			}

			//Is Donator:
			else if(GetDonator(Client) == 1)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "{silver}(VIP) ");
			}

			//Is Donator:
			else if(GetDonator(Client) == 2)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "{gold}(VIP) ");
			}

			//Is Alive:
			if(!IsPlayerAlive(Client))
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "{darkgray}*DEAD* ");
			}

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "%s%N\x01: %s", Color, Client, Text);

			//Print:
			CPrintToChatAll("%s", FormatMessage);
		}
	}

	//Is Console:
	if(Client == 0)
	{

		//Print:
		CPrintToChatAll("{lightseagreen}(SERVER) \x079EC34FConsole\x07FFFFFF: %s", Text);

		//Return:
		return Plugin_Handled;
	}

	//Return:
	return Plugin_Continue;
}

//Event Death:
public Action OnCliedDiedHangUp(int Client)
{

	//Hangup:
	if(Connected[Client] != 0) HangUp(Client);
}

public Action SetTalkZoneDefStats(int Client)
{

	//Initialize:
	Connected[Client] = 0;

	Answered[Client] = false;

	TimeOut[Client] = 0;
}

//Calling:
public void Call(int Client, int Player)
{

	//World:
	if(Client != 0 && Player != 0)
	{

		//Bot Enabled:
		if(GetCallEnable(Player))
		{

			//Not Connected:
			if(Connected[Player] == 0)
			{

				//Has Enough Cash:
				if(GetBank(Client) > 25)
				{

					//Has Enough Cash:
					if(GetBank(Player) > 25)
					{

						//Initialize:
						Connected[Client] = Player;

						Connected[Player] = Client;

						//Send:
						RecieveCall(Player, Client);

						//Initialize:
						TimeOut[Client] = 40;

						//Timer:
						CreateTimer(1.0, TimeOutCall, Client);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF does not have enough money to answer the call!", Player);
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You do not have enough money to call \x0732CD32%N\x07FFFFFF!", Player);
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF is already on the phone", Player);
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has disabled the Phone", Player);
		}
	}
}

//Recieve:
public void RecieveCall(int Client, int Player)
{

	//Is Enabled:
	if(GetRingEnable(Client))
	{

		//Sound:
		EmitSoundToClient(Client, "roleplay/ring.wav", SOUND_FROM_PLAYER, 5);
	}

	//Is Enabled:
	if(GetRingEnable(Player))
	{

		//Sound:
		EmitSoundToClient(Player, "roleplay/ring.wav", SOUND_FROM_PLAYER, 5);
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF is calling you, type !answer to talk to hum.", Player);

	//Send:
	TimeOut[Client] = 40;

	//Timer:
	CreateTimer(1.0, TimeOutRecieve, Client);
}

//Answer:
public void Answer(int Client)
{

	//Connected:
	if(!Answered[Client] && Connected[Client] != 0)
	{

		//Initialize:
		int Player = Connected[Client];

		//Has Enough Cash:
		if(GetBank(Client) > 25)
		{

			//Initulize:
			SetBank(Client, (GetBank(Client) - 25));

			SetBank(Player, (GetBank(Client) - 25));

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have answered your call from \x0732CD32%N\x07FFFFFF!", Player);

			CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has answered their phone!", Client);

			//Send:
			Answered[Client] = true;

			Answered[Player] = true;

			//Is Enabled:
			if(GetRingEnable(Client))
			{

				//Sound:
				StopSound(Client, 5, "roleplay/ring.wav");
			}

			//Is Enabled:
			if(GetRingEnable(Player))
			{

				//Sound:
				StopSound(Player, 5, "roleplay/ring.wav");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You do not have enough money to answer the phone to \x0732CD32%N\x07FFFFFF!", Player);

			CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF does not have enough money to answer the phone!", Client);

			//Send:
			Connected[Client] = 0;

			Answered[Client] = false;

			Connected[Player] = 0;

			Answered[Player] = false;
		}
	}

	//Overrride:
	else if(Answered[Client])
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You already answered the phone");
	}

	//Override:
	else
	{
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - No one is calling you!");
	}
}

//Hang Up:
public void HangUp(int Client)
{

	//Connected:
	if(Connected[Client] != 0)
	{

		//Declare:
		int Player = Connected[Client];

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You hang up on \x0732CD32%N\x07FFFFFF!", Player);
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF hung up on you!", Client);

		//Send:
		Connected[Client] = 0;

		Answered[Client] = false;

		Connected[Player] = 0;

		Answered[Player] = false;

		//Sound:
		StopSound(Client, 5, "roleplay/ring.wav");

		//Sound:
		StopSound(Player, 5, "roleplay/ring.wav");
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are not on the phone");
	}
}

//Time Out (Calling):
public Action TimeOutCall(Handle Timer, any Client)
{

	//Push:
	if(TimeOut[Client] > 0) TimeOut[Client] -= 1;

	//Broken Connection:
	if(Connected[Client] == 0)
	{

		//End:
		TimeOut[Client] = 0;
	}

	//Not Answered:
	if(!Answered[Client] && TimeOut[Client] == 1)
	{

		//Initialize:
		int Player = Connected[Client];

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF failed to answer their phone!", Player);

		//End Connection:
		Answered[Client] = false;

		Connected[Client] = 0;	
	}

	//Loop:
	if(TimeOut[Client] > 0)
	{

		//Send:
		CreateTimer(1.0, TimeOutCall, Client);
	}
}

//Time Out (Recieve):
public Action TimeOutRecieve(Handle Timer, any Client)
{

	//Push:
	if(TimeOut[Client] > 0) TimeOut[Client] -= 1;

	//Broken Connection:
	if(Connected[Client] == 0)
	{

		//End:
		TimeOut[Client] = 0;
	}

	//Not Answered:
	if(!Answered[Client] && TimeOut[Client] == 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your phone has stopped ringing!");

		//Is Enabled:
		if(GetRingEnable(Client))
		{

			//Sound:
			StopSound(Client, 5, "roleplay/ring.wav");
		}

		//End Connection:
		Answered[Client] = false;

		Connected[Client] = 0;
	}

	//Loop:
	if(TimeOut[Client] > 0)
	{

		//Send:
		CreateTimer(1.0, TimeOutRecieve, Client);
	}
}

//Silent:
public void PrintSilentChat(int Client, int Player, char Message[6], const char[] Text, const char[] Color)
{

	//Print:
	CPrintToChat(Player, "{lightseagreen}(%s) %s%N : \x07FFFFFF%s", Message, Color, Client, Text);

	CPrintToChat(Client, "{lightseagreen}(%s) %s%N : \x07FFFFFF%s", Message, Color, Client, Text);
}

public Action Command_Answer(int Client, int Args)
{

	//Anwer Call:
	Answer(Client);

	//Return:
	return Plugin_Handled;
}

public Action Command_Hangup(int Client, int Args)
{

	//Hang up Call:
	HangUp(Client);

	//Return:
	return Plugin_Handled;
}

public Action Command_Call(int Client, int Args)
{

	//Is Valid:
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_call <Name>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Yourself:
	if(Player == Client)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You cannot call yourself");

		//Return:
		return Plugin_Handled;
	}

	//Dead:
	if(!IsPlayerAlive(Player))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF Cannot call a dead player");

		//Return:
		return Plugin_Handled;
	}

	//Call:
	Call(Client, Player);
	
	//Return:
	return Plugin_Handled; 
}

public Action Command_Sms(int Client, int Args)
{

	//Is Valid:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_sms <name> <message>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = FindTarget(Client, Arg1);

	//Valid Player:
	if (Player == -1)
	{

		//Print:
		PrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF Could not find client \x0732CD32%s", Arg1);

		//Return:
		return Plugin_Handled;
	}

	//Yourself:
	if(Player == Client)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You cannot sms yourself!");

		//Return:
		return Plugin_Handled;
	}

	//Dead:
	if(!IsPlayerAlive(Player))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF Cannot sms a dead player!");

		//Return:
		return Plugin_Handled;
	}

	//Enough Money:
	if(GetBank(Client) < 5)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You dont have enough money to SMS, Cost 5!");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	SetBank(Client, (GetBank(Client) - 5));

	//Declare:
	char Text[255];

	//Get Args
	GetCmdArgString(Text, sizeof(Text));

	//Strip All Quoats:
	StripQuotes(Text);

	//Trip String:
	TrimString(Text);

	//Print:
	PrintSilentChat(Client, Player, "SMS", Text, "\x0732CD32");

	//Return:
	return Plugin_Handled; 
}
