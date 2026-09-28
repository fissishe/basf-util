<div align="center">
	<img 
		src="https://raw.githubusercontent.com/fissishe/basf-util/refs/heads/main/imgs/bauti-logo.webp"
		width="128"
		height="128"
		alt="Official repository logo made by Jody"
	>
	<h1>BASF-Util</h1>
</div>

BASF-Util is a utility library written in [Luau](https://luau.org/) and [Lua](https://lua.org/) for easier to access internal system and develop your own script faster.

### Example
This code will print all plots into the console. You can press <kbd>F9</kbd> or type `/console` into the chat to open the [Developer Console](https://create.roblox.com/docs/studio/developer-console) or look into Console log in your executor to see a result.
```luau
local Util = loadstring(game:HttpGet("https://raw.githubusercontent.com/fissishe/basf-util/refs/heads/main/src/util/util-loader.luau"))()

if Util then
	for _, Item in ipairs(Util.Plot.GetOwnerList()) do
		if Item.Owner then
			print(("%f Plot owned by %s"):format(Item.Plot, Item.Owner.Name))
		else
			print(("%f Plot is empty"):format(Item.Plot))
		end
	end
end
```

## Luau
[Luau](https://en.wikipedia.org/wiki/Luau_(programming_language)) is an open-source programming language influenced by [Lua](https://en.wikipedia.org/wiki/Lua) since 2019 for [Roblox](https://en.wikipedia.org/wiki/Roblox) platform with [Gradual Typing](https://en.wikipedia.org/wiki/Gradual_typing) feature and more to improve the development with dynamic type check and type correction.

<br>
<br>

<p align="center">This repository is not affiliated with Prestonina, and contributors involved are not game admin.</p>
