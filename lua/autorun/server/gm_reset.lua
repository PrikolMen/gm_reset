local util_KeyValuesToTable = util.KeyValuesToTable
local engine_ActiveGamemode = engine.ActiveGamemode
local engine_GetGamemodes = engine.GetGamemodes
local RunConsoleCommand = RunConsoleCommand
local player_GetHumans = player.GetHumans
local string_format = string.format
local file_Exists = file.Exists
local file_Read = file.Read
local IsValid = IsValid
local ipairs = ipairs

local function getTitle( name )
    for num, tbl in ipairs( engine_GetGamemodes() ) do
        if (tbl.name == name) then
            return tbl.title or name
        end
    end
end

concommand.Add("gm_reset", function( ply, cmd, args )
    local name = engine_ActiveGamemode()
    local title = getTitle( name )

    if IsValid( ply ) then
        if ply:IsListenServerHost() or ply:IsSuperAdmin() then
            ply:ChatPrint( "[" .. title .. "] Settings restored by default!" )
        else
            ply:ChatPrint( "[" .. title .. "] You do not have enough access for this!" )
            return
        end
    end

    local defaults = string_format( "gamemodes/%s/%s.txt", name, name )
    if file_Exists( defaults, "GAME" ) then
        local content = file_Read( defaults, "GAME" )
        if (content) then
            local gm = util_KeyValuesToTable( content )
            if (gm) then
                local settings = gm.settings
                if (settings) then
                    for num, data in ipairs( settings ) do
                        RunConsoleCommand( data.name, args[1] or data.default )
                    end

                    for num, ply in ipairs( player_GetHumans() ) do
                        if ply:IsFullyAuthenticated() then
                            ply:SendLua( 'local a="spawnmenu_reload"if(concommand.GetTable()[a] ~= nil)then RunConsoleCommand(a)end')
                        end
                    end

                    print( "[" .. title .. "] Settings restored to default!" )
                end

                return
            end
        end
    end

    print( "[" .. title .. "] " .. name .. ".txt not exists!" )
end)