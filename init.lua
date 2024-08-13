local s = minetest.get_mod_storage()

local to_x = function(pat)
	return (pat and pat:gsub("%%d%+","X") or "error")
end

minetest.register_on_prejoinplayer(function(name, ip)
	local wl = s:get(name)
	if wl then
		local ips = wl:split(", ")
		for _,wl_ip in ipairs(ips) do
			if ip:match(wl_ip) then
				return
			end
		end
		return "Your IP is not in the whitelist for "..name
	end
end)

local cmds = {
	add = true,
	rm = true,
	ls = true,
	purge = true,
	["ls-all"] = true,
}

minetest.register_privilege("ipwl",{
	description = "Allows to manage own IP whitelist",
	give_to_singleplayer = false,
	give_to_admin = false,	
})

minetest.register_chatcommand("ipwl",{
	description = "Manage your IP whitelist",
	privs = {ipwl=true},
	params = "[playername] [<add> | <rm> <ip pattern>] | <ls> | <ls-all> | <purge>",
	func = function(name, param)
		local params = param:split(" ")
		local target, cmd, ip
		if cmds[params[2]] then
			if not minetest.check_player_privs(name, "server") then
				return false, "Your privileges are insufficient to manage IPWL for other players"
			end
			target = params[1]
			cmd = params[2]
			ip = params[3]
		elseif cmds[params[1]] then
			target = name
			cmd = params[1]
			ip = params[2]
		end
		if cmd == "ls" then
			local wl = s:get(target)
			return true, wl and to_x(wl) or "There is no IP whitelist for "..target
		elseif cmd == "purge" then
			s:set_string(target,"")
			return true, "IP whitelist of "..target.." purged"
		elseif cmd == "ls-all" then
			if not minetest.check_player_privs(name, "server") then
				return false, "Your privileges are insufficient to run this"
			end
			local out = {}
			for pname, wl in pairs(s:to_table().fields) do
				table.insert(out, pname..": "..to_x(wl))
			end
			return true, table.concat(out, "\n")
		end
		if not ip then
			return false, "Invalid params"
		end
		local segs = ip:split(".")
		local pattern = {"%d+","%d+","%d+","%d+"}
		for i,seg in ipairs(segs) do
			if seg:match("%D+") then
				seg = "%d+"
			end
			pattern[i] = seg
		end
		local pat = table.concat(pattern,".")
		local wl = s:get_string(target)
		local ips = wl:split(", ")
		if cmd == "add" and ip then
			for i,wl_ip in ipairs(ips) do
				if wl_ip == pat then
					return false, to_x(pat).." is already in the whitelist"
				end
			end
			table.insert(ips, pat)
			s:set_string(target, table.concat(ips, ", "))
			return true, "Added "..to_x(pat).." to "..target.."'s IP whitelist"
		elseif cmd == "rm" and ip then
			for i,wl_ip in ipairs(ips) do
				if wl_ip == pat then
					table.remove(ips, i)
					s:set_string(target, table.concat(ips, ", "))
					return true, "Removed "..to_x(pat).." from "..target.."'s IP whitelist"
				end
			end
			return false, "Nothing to remove"
		end
end})
