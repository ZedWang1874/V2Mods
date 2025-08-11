return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`bordercheck` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("bordercheck", {
			mod_script       = "scripts/mods/bordercheck/bordercheck",
			mod_data         = "scripts/mods/bordercheck/bordercheck_data",
			mod_localization = "scripts/mods/bordercheck/bordercheck_localization",
		})
	end,
	packages = {
		"resource_packages/bordercheck/bordercheck",
	},
}
