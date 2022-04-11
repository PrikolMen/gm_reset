local util_KeyValuesToTable = util.KeyValuesToTable
local engine_ActiveGamemode = engine.ActiveGamemode
local RunConsoleCommand = RunConsoleCommand
local string_format = string.format
local file_Exists = file.Exists
local file_Read = file.Read
local IsValid = IsValid
local ipairs = ipairs

concommand.Add("gm_reset", function( ply, cmd, args )
    local name = engine_ActiveGamemode()
    local arg = args[1]

    if IsValid( ply ) then
        if ply:IsListenServerHost() or ply:IsSuperAdmin() then
            ply:ChatPrint( "[gm_reset] Settings restored " .. ((arg == nil) and "by default" or ("to " .. arg)) .. "!" )
        else
            ply:ChatPrint( "[gm_reset] You do not have enough access for this!" )
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
                        if (arg ~= nil) and (data.type == "Numeric") then
                            RunConsoleCommand( data.name, arg )
                            continue
                        end

                        RunConsoleCommand( data.name, data.default )
                    end

                    print( "[gm_reset] Settings restored " .. ((arg == nil) and "by default" or ("to " .. arg)) .. "!" )
                end

                return
            end
        end
    end

    print( "[gm_reset] gamemodes/" .. name .. "/" .. name .. ".txt not exists!" )
end)