-- Please ask me if you want to use parts of this code!
if SERVER then
	-- Add network
	util.AddNetworkString( "KarmaHPText" )
	-- ConVars
	local KarmaHP = CreateConVar( "ttt_Karma_hp", "1", FCVAR_SERVER_CAN_EXECUTE, "Enables and disables KarmaHP addon.")
	local minHealth = CreateConVar( "ttt_karma_hp_min_health", "20", FCVAR_SERVER_CAN_EXECUTE, "Sets the minimum health a player can have (given by this addon). (1-99) Def: 20.")
	local mult = CreateConVar( "ttt_karma_hp_mult", "1", FCVAR_SERVER_CAN_EXECUTE, "Sets the multiplicator how much HP should be stolen. (0.01-5) Def: 1.")
	local tolerance = CreateConVar( "ttt_karma_hp_tolerance", "0", FCVAR_SERVER_CAN_EXECUTE, "Sets the helth tolerance wich does not steal hp. (0-99) Def: 0.")
	local karmaTolerance = CreateConVar( "ttt_karma_hp_tolerance_karma", "0", FCVAR_SERVER_CAN_EXECUTE, "Sets the karma tolerance wich does not steal hp. Def: 0.")
	local cleanBonus = CreateConVar( "ttt_karma_hp_clean_bonus", "0", FCVAR_SERVER_CAN_EXECUTE, "Sets the hp bonus for clean karma. Def: 0.")
	-- Hook to edit HP
	hook.Add("TTTBeginRound","TTTBeginRound4KarmaHP",function()
		-- calculate Health
		local KarmaMax = GetConVarNumber("ttt_karma_max")
		if KarmaHP:GetBool() then
			for k, ply in pairs(player.GetAll()) do
				local Karma = ply:GetBaseKarma()
				local HP = math.min(math.max(math.floor(100-((KarmaMax-math.max(karmaTolerance:GetFloat(), 0))-Karma)/10*math.min(math.max(mult:GetFloat(), 0.01), 5)),math.min(math.max(minHealth:GetFloat(), 1), 99)),100)
				if HP >= 100-math.min(math.max(tolerance:GetFloat(), 0), 99) then
					HP = 100
				end
				if not (cleanBonus == 0) and Karma >= KarmaMax then
					HP = 100+cleanBonus:GetFloat()
				end
				ply:SetHealth(HP)
				-- info text
				net.Start("KarmaHPText")
				net.WriteString("Your have received "..HP.." HP caused of your Karma.")
				net.Send(ply)
			end
		end
	end)
end
if CLIENT then
	-- print text
	net.Receive("KarmaHPText", function(len, ply)
		local Text = net.ReadString()
		chat.AddText("TTT KarmaHP: ", Color( 255, 255, 255 ),Text)
	end)
end