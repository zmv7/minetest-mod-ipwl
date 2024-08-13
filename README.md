# minetest-mod-ipwl
Per-player IP whitelist
### Usage
* `/ipwl [playername] add <IP pattern>` - add IP range to the your or *playername*'s whitelist
* `/ipwl [playername] rm <IP pattern>` - remove IP range from your or *playername*'s whitelist
* `/ipwl [playername] ls` - show your or *playername*'s whitelist
* `/ipwl [playername] purge` - purge all your or *playername*'s whitelist
* `/ipwl ls-all` - show all existing whitelistes of all players
### Privs
* `ipwl` priv allows to manage own whitelist
* `server` priv is required to manage whitelist of other players and use `ls-all` command
