local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1249352791529623635/QIrJ0O0jxdJSCf21NJ-HyXfPF3S6lOhPryfx4i5FZ4oVUkeTFiQ8lg-GacU0CciF_w3a"

RegisterNetEvent('wlv:unauthorizedUse')
AddEventHandler('wlv:unauthorizedUse', function(playerId, jobName, coords, imageUrl)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        local playerName = xPlayer.getName()
        local x, y, z = coords.x or 0.0, coords.y or 0.0, coords.z or 0.0
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

        local embed = {
            {
                title = "🚨 Unauthorized Emergency Vehicle Use Detected",
                description = "**A player has attempted to use a restricted emergency vehicle without proper authorization.**",
                color = 16711680,
                timestamp = timestamp,
                fields = {
                    {
                        name = "👤 Player",
                        value = string.format("`%s`", playerName),
                        inline = true
                    },
                    {
                        name = "🆔 Server ID",
                        value = string.format("`%d`", src),
                        inline = true
                    },
                    {
                        name = "💼 Job",
                        value = string.format("`%s`", jobName),
                        inline = true
                    },
                    {
                        name = "📍 Location",
                        value = string.format("`x: %.2f, y: %.2f, z: %.2f`", x, y, z),
                        inline = false
                    },
                    {
                        name = "⏰ Time (UTC)",
                        value = string.format("`%s`", os.date("%Y-%m-%d %H:%M:%S")),
                        inline = true
                    }
                },
                footer = {
                    text = "WLV System • Avalon Legacy",
                    icon_url = "https://i.imgur.com/tZsOD2L.png"
                },
                image = imageUrl and { url = imageUrl } or nil
            }
        }

        PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers)
            -- Optional: print("Discord Webhook Response:", err)
        end, "POST", json.encode({
            username = "WLV Logger",
            avatar_url = "https://i.imgur.com/tZsOD2L.png",
            embeds = embed
        }), { ["Content-Type"] = "application/json" })
    end
end)
