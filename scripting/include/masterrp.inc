
/** Double-include prevention */
#if defined _masterrp_included_
  #endinput
#endif
#define _masterrp_included_


forward Action OnClientChat(int Client, bool IsTeamOnly, const char[] Text, int maxlength);

forward Action OnCvarChange(const char[] CvarName, const char[] CvarValue);


native int RP_SetBank(int Client, int Amount);
native int RP_GetBank(int Client);

native int RP_SetCash(int Client, int Amount);
native int RP_GetCash(int Client);

native int RP_SetBounty(int Client, int Amount);
native int RP_GetBounty(int Client);
native int RP_AddBounty(int Client, int Amount);

native int RP_SetCrime(int Client, int Amount);
native int RP_GetCrime(int Client);

native int RP_SetPostCrime(int Client, int Amount);
native int RP_GetPostCrime(int Client);

native int RP_SetDonator(int Client, int Amount);
native int RP_GetDonator(int Client);

native int RP_SetHatEnt(int Client, int Amount);
native int RP_GetHatEnt(int Client);

native void RP_SetHatModel(int Client, char ModelName[255]);
native void RP_GetHatModel(int Client, char ModelName[255]);
native void RP_SetHatModelFx(int Client, char ModelName[255]);

native bool RP_SetIsCritical(int Client, bool Result);
native bool RP_GetIsCritical(int Client);

native bool RP_SetIsNokill(int Client, bool Result);
native bool RP_GetIsNokill(int Client);

native bool RP_SetIsLoaded(int Client, bool Result);
native bool RP_GetIsLoaded(int Client);

native bool RP_IsCop(int Client);