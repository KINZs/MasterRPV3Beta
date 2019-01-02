//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_jobHelper_included_
  #endinput
#endif
#define _rp_jobHelper_included_

//Roleplay Core:
char JobHelper[256];

public void initJobHelper()
{

	//Job Setup DB:
	BuildPath(Path_SM, JobHelper, 256, "data/roleplay/jobs_helper.txt");
	if(FileExists(JobHelper) == false) SetFailState("[SM] ERROR: Missing file '%s'", JobHelper);

	//Commands:
	RegConsoleCmd("sm_jobhelp", Command_JobHelperMenu);
}

//allows player to view Job Menu
public Action Command_JobHelperMenu(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Show Menu:
	JobHelperMenu(Client);

	//Return:
	return Plugin_Handled;
}

public void JobHelperMenu(int Client)
{

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, JobHelper);

	//Declare:
	char JobId[32];
	char Buffer[255];
	char Key[32];
	char MenuString[2048];
	int len = 0;
	bool FoundJob = false;

	//Format:
	Format(JobId, sizeof(JobId), "%s", GetJob(Client));

	//Format:
	len += Format(MenuString[len], sizeof(MenuString)-len, "%s:\n", GetJob(Client));

	//Loop:
	for(int i = 1; i <= 15; i++)
	{

		//Convert:
		IntToString(i, Key, sizeof(Key));

		//Skip:
		KvJumpToKey(Vault, GetJob(Client), false);

		//Get KV:
		KvGetString(Vault, Key, Buffer, sizeof(Buffer), "null");

		//Restart KV:
		KvRewind(Vault);

		//Prop Money Printer:
		if(!StrEqual(Buffer, "null"))
		{

			//Format:
			len += Format(MenuString[len], sizeof(MenuString)-len, "%i: %s\n", i, Buffer);

			//Initulize:
			FoundJob = true;
		}

		//Prop Money Printer:
		if(StrEqual(Buffer, "null"))
		{

			//Stop:
			break;
		}

		//Initulize:
		Buffer = "null";
	}

	//Check:
	if(FoundJob == false)
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP-Helper|\x07FFFFFF - There is no job found within the job helper database!");
	}

	//Override:
	else
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP-Helper|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");

		//Create Menu:
		CreateMenuTextBox(Client, 1, 60, 20, 255, 20, 250, MenuString);
	}

}