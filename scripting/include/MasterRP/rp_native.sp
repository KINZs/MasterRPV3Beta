//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_native_included_
  #endinput
#endif
#define _rp_native_included_

/*This will seperate game functions*/
//#if defined HL2DM
//#endif

//Initation:
public void OnPluginStartRP_Native()
{

}

/*
//Initation:
public void OnAskPluginLoad2()
{

	//Create Native for Bank[]
	CreateNative("RP_SetBank", Native_SetBank);
	CreateNative("RP_GetBank", Native_GetBank);

	//Create Native for Cash[]
	CreateNative("RP_SetCash", Native_SetCash);
	CreateNative("RP_GetCash", Native_GetCash);

	//Create Native for Bounty[]
	CreateNative("RP_SetBounty", Native_SetBounty);
	CreateNative("RP_GetBounty", Native_GetBounty);
	CreateNative("RP_AddBounty", Native_AddBounty);

	//Create Native for Crime[]
	CreateNative("RP_SetCrime", Native_SetCrime);
	CreateNative("RP_GetCrime", Native_GetCrime);

	//Create Native for PostCrime[]
	CreateNative("RP_SetPostCrime", Native_SetPostCrime);
	CreateNative("RP_GetPostCrime", Native_GetPostCrime);

	//Create Native for Donator[]
	CreateNative("RP_SetDonator", Native_SetDonator);
	CreateNative("RP_GetDonator", Native_GetDonator);

	//Create Native for HatEnt[]
	CreateNative("RP_SetHatEnt", Native_SetHatEnt);
	CreateNative("RP_GetHatEnt", Native_GetHatEnt);

	//Create Native for HatModel[]
	CreateNative("RP_SetHatModel", Native_SetHatModel);
	CreateNative("RP_GetHatModel", Native_GetHatModel);
	CreateNative("RP_SetHatModelFx", Native_SetHatModelFx);

	//Create Native for IsCritical[]
	CreateNative("RP_SetCritical", Native_SetIsCritical);
	CreateNative("RP_GetCritical", Native_GetIsCritical);

	//Create Native for IsNokill[]
	CreateNative("RP_SetIsNokill", Native_SetIsNokill);
	CreateNative("RP_GetIsNokill", Native_GetIsNokill);

	//Create Native for Loaded[]
	CreateNative("RP_SetIsLoaded", Native_SetIsLoaded);
	CreateNative("RP_GetIsLoaded", Native_GetIsLoaded);

	CreateNative("RP_IsCop", Native_IsCop);

	RegPluginLibrary("masterrp");
}
*/


public int Native_SetBank(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	int Amount = GetNativeCell(2);


	return (SetBank(Client, Amount));

}



public int Native_GetBank(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	return (GetBank(Client));

}





public int Native_SetCash(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	int Amount = GetNativeCell(2);


	return (SetCash(Client, Amount));

}



public int Native_GetCash(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	return (GetCash(Client));

}




public int Native_SetBounty(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	int Amount = GetNativeCell(2);


	return (SetBounty(Client, Amount));

}



public int Native_GetBounty(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	return (GetBounty(Client));

}



public int Native_AddBounty(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	int Amount = GetNativeCell(2);


	return (AddBounty(Client, Amount));

}





public int Native_SetCrime(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	int Amount = GetNativeCell(2);


	return (SetCrime(Client, Amount));

}



public int Native_GetCrime(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	return (GetCrime(Client));

}



public int Native_SetPostCrime(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	int Amount = GetNativeCell(2);


	return (SetPostCrime(Client, Amount));

}



public int Native_GetPostCrime(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	return (GetPostCrime(Client));

}


public int Native_SetDonator(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	int Amount = GetNativeCell(2);


	return (SetDonator(Client, Amount));

}



public int Native_GetDonator(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	return (GetDonator(Client));

}


public int Native_SetHatEnt(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	int Amount = GetNativeCell(2);


	return (SetPlayerHatEnt(Client, Amount));

}



public int Native_GetHatEnt(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	return (GetPlayerHatEnt(Client));

}


public int Native_SetHatModel(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	char ModelName[255];
	GetNativeString(2, ModelName, sizeof(ModelName));

	SetHatModel(Client, ModelName);
}



public int Native_GetHatModel(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	char ModelName[255];

	Format(ModelName, sizeof(ModelName), "%s", GetHatModel(Client));

	SetNativeString(2, ModelName, sizeof(ModelName));
}

public int Native_SetHatModelFx(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	char ModelName[255];

	GetNativeString(2, ModelName, sizeof(ModelName));

	SetHatModelFx(Client, ModelName);
}




public int Native_SetIsCritical(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	bool Result = GetNativeCell(2);


	return boolToint(SetIsCritical(Client, Result));

}



public int Native_GetIsCritical(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	return boolToint(GetIsCritical(Client));

}


public int Native_SetIsNokill(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	bool Result = GetNativeCell(2);


	return boolToint(SetIsCritical(Client, Result));

}



public int Native_GetIsNokill(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	return boolToint(GetIsCritical(Client));

}


public int Native_SetIsLoaded(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	bool Result = GetNativeCell(2);


	return boolToint(SetIsLoaded(Client, Result));

}



public int Native_GetIsLoaded(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	return boolToint(IsLoaded(Client));

}

public int Native_IsCop(Handle plugin, int numParams)

{

	int Client = GetNativeCell(1);


	return view_as<bool>(boolToint(IsCop(Client)));
}