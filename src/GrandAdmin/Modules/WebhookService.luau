--//CREATED BY SNAWRK (LuaScape on YouTube)
--//Proxies by master3395 and lewistehminerz

local wsv4 = { 
	
	colors = {
	
	['red'] = tonumber(16711680),
	['green'] = tonumber(65280),
	['blue'] = tonumber(255),
	['black'] = tonumber(0),
	['yellow'] = tonumber(16514837)	
		
	},
}

local https = game:GetService("HttpService")

wsv4.__index = wsv4

function wsv4.new(...)
	local self = {}
	setmetatable(self, wsv4)

	local args = table.unpack({...})
	self.Title = args.Title or 'No Title Provided'
	self.Description = args.Description or ''
	self.Content = args.Content or ''
	self.Fields = args.Fields or nil
	self.Thumbnail = args.Thumbnail or ''
	self.Image = args.Image or ''
	self.Footer = args.Footer or ''
	self.FooterIcon = args.FooterIcon or ''
	self.TimeStamp = args.TimeStamp or ''
	self.Color = self.Color or wsv4.colors.black
	
	self.Author = args.Author or ''
	self.AuthorUrl = args.AuthorUrl or ''
	self.AuthorLink = args.AuthorLink or ''
	return self
end


local function postWebhook(url, data)
	
	local finalUrl = string.gsub(url, "discord.com", "webhook.newstargeted.com")
	local finalBackupUrl = string.gsub(url, "discord.com", "webhook.lewisakura.moe")
	
	local good, bad = pcall(function()
		coroutine.wrap(function()
			https:PostAsync(finalUrl, data)
		end)()
	end)
	
	if good then
		--print("Webhook request success!")
	else
		warn("Webhook Request Failed " .. bad .. " Trying backup URL")
		
		local goodbackup, badbackup = pcall(function()
			coroutine.wrap(function()
				https:PostAsync(finalBackupUrl, data)
			end)()
		end)
		
		if goodbackup then
			print("Backup request success")
		else
			warn("Backup request failed " .. badbackup .. " bad request or both proxy down")
		end
		
	end
end

function wsv4:sendMessage(url)
	
	local data = {
		['content'] = self.Content
	}
	
	local finalData = https:JSONEncode(data)
	
	postWebhook(url, finalData)
end

function wsv4:sendAuthorEmbed(url)
	
	local data = {
		['content'] = self.Content,
		["embeds"] = {{
			["author"] = {
				["name"] = self.Author,
				["icon_url"] = self.AuthorUrl,
				['url'] = self.AuthorLink
			},
			
			["description"] = self.Description,
			["color"] = self.Color,
			["fields"] = self.Fields,
			["image"] = {["url"] = self.Image},
			['thumbnail'] = {["url"] = self.Thumbnail},
			['timestamp'] = self.TimeStamp,
			['footer'] = {
				['text'] = self.Footer,
				['icon_url'] = self.FooterIcon
			},

		}},
	}
	
	local finalData = https:JSONEncode(data)
	
	postWebhook(url, finalData)
end

function wsv4:sendEmbed(url)
	
	local data = {
		['content'] = self.Content,
		['embeds'] = {{
			["image"] = {["url"] = self.Image},
			['thumbnail'] = {["url"] = self.Thumbnail},
			['title'] = "**"..self.Title.."**",
			['description'] = self.Description,
			['type'] = "rich",
			["color"] = self.Color,
			['fields'] = self.Fields,
			['timestamp'] = self.TimeStamp,
			['footer'] = {
				['text'] = self.Footer,
				['icon_url'] = self.FooterIcon
			},
		  },
		},
	}
	local finalData = https:JSONEncode(data)
	
	postWebhook(url, finalData)
	
end

return wsv4